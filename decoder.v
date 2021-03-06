// decoder - reading microcode
//

module decoder (
  instr,
  MAR_LOAD,
  IR_LOAD,
  MDR_LOAD,
  REG_LOAD,
  RAM_LOAD,
  INCR_PC,
	DECR_SP,
	INCR_SP,
  BE,
	RE,
  REGR0S,
  REGR1S,
  REGWS,
  OP0S,
  OP1S,
  IRimm,
  MDRS,
  ALUfunc,
  COND_CHK,
  cond,
  state,
  reset,
	HLT,
	fault_r,
	irq_r,
	SYSCALL,
	RETI,
	cont_r,
	WPTB,
	WPTE,
	IVEC_LOAD,
	UREG,
	SEXT,
  clk
);

input clk, reset, fault_r, irq_r, cont_r;
input [15:0] instr;

output MDR_LOAD, REG_LOAD, MAR_LOAD, IR_LOAD, RAM_LOAD, INCR_PC, BE, COND_CHK, HLT, RE, SYSCALL, RETI, DECR_SP, INCR_SP;
output WPTB, WPTE, IVEC_LOAD, UREG, SEXT;
output [1:0] MDRS, OP0S, OP1S;
output [15:0] IRimm;
output [2:0] ALUfunc, cond;
output [3:0] REGWS, REGR0S, REGR1S;
output [3:0] state;

reg [15:0] IRimm;


// internal registers
reg [3:0] state;
wire [3:0] next_state;


parameter FETCH = 4'b0001, FETCHM = 4'b0010, DECODE = 4'b0011, DECODEM = 4'b0100, READ = 4'b0101, READM = 4'b0110, EXEC = 4'b0111, EXECM = 4'b1000, BREAK = 4'b1001;
parameter ARG0 = 8, ARG1 = 9, TGT = 10, TGT2 = 11, ARG2 = 12, FLAGS = 15;
parameter IMM7 = 0, IMM10 = 1, IMM13 = 2, IMMIR = 3, IMM7U = 4, IMM4 = 5;

assign next_state = fsm_function(state, skipstate);

function [3:0] fsm_function;
	input [3:0] state;
  input [2:0] skipstate;
	case(state)
		FETCH: fsm_function = FETCHM;
		FETCHM: fsm_function = DECODE;
		DECODE: fsm_function = DECODEM;
		DECODEM:
      begin
        if(skipstate == 0) begin
          fsm_function = READ;
        end else if(skipstate == 1) begin
          fsm_function = EXEC;
        end else if(skipstate == 2) begin
          fsm_function = FETCH;
        end
      end
		READ: fsm_function = READM;
		READM: fsm_function = EXEC;
		EXEC: fsm_function = EXECM;
		EXECM:
			begin
					if (brk == 1) begin
						fsm_function = BREAK;
					end else if (irq_r == 1) begin
						fsm_function = 0;
					end else begin
						fsm_function = FETCH;
					end
			end
		BREAK: fsm_function = BREAK;
		default: fsm_function = FETCH;
	endcase
endfunction


//outputs
reg [7:0] ROMaddr;
wire [47:0] ROMread;

rom micro (
  .address (ROMaddr),
  .data    (ROMread)
);


reg HLT;

always @(negedge clk)
begin
  if(reset == 1) begin
    state <= 0;
		HLT <= 0;
  end
	else if (instr == 16'hfe00) begin
		state <= 0;
		HLT <= 1;
	end
	else if (state == BREAK && cont_r == 1) begin
		state <= 0;
	end
	else if (fault_r == 1) begin
		state <= 0;
	end else begin
	  state <= #1 next_state;
		HLT <= 0;
  end
end

wire codetype;
wire [5:0] opcodelong;
wire [1:0] opcodeshort;

reg [5:0] opcode;


// Opcode & Immediate splits
assign codetype = instr[15];
assign opcodelong = instr[14:9];
assign opcodeshort = instr[14:13];

// Immediates
wire [12:0] imm13;
wire [9:0] imm10;
wire [6:0] imm7;
wire [3:0] imm4;
reg [15:0] immir;

assign imm7 = instr[8:2];
assign imm10 = instr[12:3];
assign imm13 = instr[12:0];
assign imm4 = instr[8:5];
// Arguments

wire [2:0] tgt, arg0, arg1, arg2;
wire [1:0] tgt2;

assign arg0 = instr[8:6];
assign arg1 = instr[5:3];
assign tgt = instr[2:0];
assign tgt2 = instr[1:0];
assign arg2 = instr[5:2];


// Muxes
wire [3:0] xregr0s, xregr1s, xregws, imms;
reg [3:0] REGR0S, REGR1S, REGWS;
wire [1:0] MDRS, condtype, skipstate;
//reg incr_pc;
wire [2:0] ALUfunc;
reg [2:0] cond;

assign xregr0s = ROMread[39:36];
assign xregr1s = ROMread[35:32];
assign xregws = ROMread[31:28];
assign MDRS = ROMread[27:26];
assign imms = ROMread[25:23];
assign OP0S = ROMread[22:21];
assign OP1S = ROMread[20:19];
assign condtype = ROMread[18:17];
assign COND_CHK = ROMread[16];
assign ALUfunc = ROMread[15:13];
assign skipstate = ROMread[12:11];

assign RETI = ROMread[8];
assign UREG = ROMread[7];
assign brk = ROMread[6];

// csigs - only on xxM cycles
// mcycle have their lsb 0
wire loadpos, loadneg;

assign loadpos = state[0];
not(loadneg, state[0]);

and( MAR_LOAD, loadpos, ROMread[47]);
and( IR_LOAD, loadneg, ROMread[46]);
and( MDR_LOAD, loadpos, ROMread[45]);
and( REG_LOAD, loadneg, ROMread[44]);
and( RAM_LOAD, loadneg, ROMread[43]);
and( INCR_PC, loadneg, ROMread[42]);
and( DECR_SP, loadneg, ROMread[41]);
and( INCR_SP, loadneg, ROMread[10]);

reg RE_fetch;

//assign SKIP = ROMread[25];
//and( BE, loadneg, ROMread[40]);
assign BE = ROMread[40];
assign WPTB = ROMread[5];
assign WPTE = ROMread[4];
or(RE, RE_fetch, ROMread[3]);
assign SEXT = ROMread[2];
assign IVEC_LOAD = (opcode == 6'd44 && state == DECODEM) ? 1'b1 : 1'b0;
assign SYSCALL = (opcode == 6'd34 && state == DECODEM) ? 1'b1 : 1'b0;



always @* begin
	RE_fetch = 0;
  ROMaddr = 3; // HACK: 3 holds a zero micro instruction for now!!!
  //incr_pc = 0;

  if(codetype != 1) begin
    opcode = {4'b0, opcodeshort};
  end else begin
    opcode = opcodelong;
  end

  case(state)
    FETCH:
			begin
				ROMaddr = 2;
				RE_fetch = 1'b1;
			end
    FETCHM:
			begin
				ROMaddr = 2;
				RE_fetch = 1'b1;
			end
    DECODE: ROMaddr = opcode;
    DECODEM: ROMaddr = opcode;
    READ: ROMaddr = opcode + 64;
    READM: ROMaddr = opcode + 64;
    EXEC: ROMaddr = opcode + 128;
    EXECM: ROMaddr = opcode + 128;
    default: ROMaddr = 3;
  endcase

  case(xregr0s)
    ARG0: REGR0S = arg0;
    ARG1: REGR0S = arg1;
    TGT: REGR0S = tgt;
    TGT2: REGR0S = tgt2 + 1; // alternative encoding (can't assign to r0)
    ARG2: REGR0S = arg2;
    default: REGR0S = xregr0s[3:0];
  endcase

  case(xregr1s)
    ARG0: REGR1S = arg0;
    ARG1: REGR1S = arg1;
    TGT: REGR1S = tgt;
    TGT2: REGR1S = tgt2 + 1; // alternative encoding (can't assign to r0)
	 	ARG2: REGR1S = arg2;
    default: REGR1S = xregr1s[3:0];
  endcase

  case(xregws)
    ARG0: REGWS = arg0;
    ARG1: REGWS = arg1;
    TGT: REGWS = tgt;
    TGT2: REGWS = tgt2 + 1; // alternative encoding (can't assign to r0)
    default: REGWS = xregws[3:0];
  endcase

  case(arg0)
    // { 1,2,4,8,-8,-4,-2,-1 }
    0: immir = 1;
    1: immir = 2;
    2: immir = 4;
    3: immir = 8;
    4: immir = -8;
    5: immir = -4;
    6: immir = -2;
    7: immir = -1;
  endcase

	// sign extension: { 16{a[15]}, a }
  case(imms)
    IMM7: IRimm = { {9{imm7[6]}}, {imm7}} ;
    IMM10: IRimm = { {6{imm10[9]}}, {imm10}} ;
    IMM13: IRimm = { {3{imm13[12]}}, {imm13}} ;
    IMMIR: IRimm = immir; // immir is already 16b
		IMM7U: IRimm = { {9'b000000000}, {imm7} };
		IMM4: IRimm = { {12'b000000000000}, {imm4} };
    default: IRimm = 0;
  endcase

  // cond / skip logic
  case(condtype)
    0: cond = 0;
    1: cond = 1;
    2: cond = tgt;
    default: cond = 0;
  endcase

end

endmodule


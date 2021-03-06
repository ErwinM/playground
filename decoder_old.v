// decoder - proof of concept
//

module decoder (
  instr,
  MAR_LOAD,
  IR_LOAD,
  MDR_LOAD,
  REG_LOAD,
  RAM_LOAD,
  INCR_PC,
  BYTE_ENABLE,
  REGR0S,
  REGR1S,
  REGWS,
  OP0S,
  OP1S,
  IRimm,
  MDRS,
 //  slus,
 //  cond,
 state,
 reset,
 clk
);

input clk, reset;
input [15:0] instr;
output MDR_LOAD, REG_LOAD, MAR_LOAD, IR_LOAD, RAM_LOAD, INCR_PC;
output [1:0] MDRS, OP0S, OP1S, BYTE_ENABLE;
output [12:0] IRimm;
output [2:0] REGWS, REGR0S, REGR1S, state;

//outputs
reg [12:0] IRimm;
// csig
reg MDR_LOAD, REG_LOAD, MAR_LOAD, INCR_PC, IR_LOAD, RAM_LOAD;

//regsel
reg [2:0] REGR0S, REGR1S, REGWS;

//bussel
// MDRS: 0: Imm, 1: RAM, 2:ALU
// OP0S/OP1S: 0:R0, 1:R1, 2:MDR
reg [1:0] MDRS, OP0S, OP1S, BYTE_ENABLE;

// internal registers
reg [2:0] state;
wire [2:0] next_state;

// following regs are triggers to extend mem-i/o loads during the M cycles
reg lmdr, lir, lram;

wire [2:0] opc0, tgt, arg0, arg1;
wire [10:0] imm10;
wire [7:0] imm7;

parameter REG0 = 3'b000, REG1 = 3'b001, REG2 = 3'b010, REG3 = 3'b011, REG4 = 3'b100, REG5 = 3'b101, REG6 = 3'b110, PC = 4'b111;
parameter MDRS_IMM = 2'b00, MDRS_RAM = 2'b01, MDRS_ALU = 2'b10;
parameter OPS_R0 = 2'b00, OPS_R1 = 2'b01, OPS_MDR = 2'b10;
parameter FETCH = 3'b001, FETCHM = 3'b010, DECODE = 3'b011, READ = 3'b100, READM = 3'b101, EXEC = 3'b110, EXECM = 3'b111;

assign next_state = fsm_function(state);

initial begin
  state = 0;
  //reset = 0;
end

function [2:0] fsm_function;
	input [2:0] state;
	case(state)
		FETCH: fsm_function = FETCHM;
		FETCHM: fsm_function = DECODE;
		DECODE: fsm_function = READ;
		//DECODEM: fsm_function = READ;
		READ: fsm_function = READM;
		READM: fsm_function = EXEC;
		EXEC: fsm_function = EXECM;
		EXECM: fsm_function = FETCH;
		default: fsm_function = FETCH;
	endcase
endfunction

always @(negedge clk)
begin
  if(reset == 1) begin
    state = 0;
  end else begin
	  state <= #1 next_state;
  end
end

// Opcode & Immediate splits
assign opc0 = instr[15:13];
assign imm7 = instr[12:6];
assign imm10 = instr[12:3];
assign arg0 = instr[8:6];
assign arg1 = instr[5:3];
assign tgt = instr[2:0];


always @*
// To synthesize combinational logic using an always block, all inputs to the design must appear in the sensitivity list.
begin
  // Immediate mux
  case(opc0)
    3'b000: IRimm = imm7;
    3'b010: IRimm = imm7;
    3'b011: IRimm = imm7;
    3'b101: IRimm = imm10;
    default: IRimm = 0;
  endcase

  // reset csig and bussel?
  // let signals lag during Mem cycles
  if(state == FETCH || state == DECODE || state == READ || state == EXEC) begin
    MDR_LOAD = 0;
    //RAM_LOAD = 0;
    IR_LOAD = 0;
    BYTE_ENABLE = 2'b11;
  end
  RAM_LOAD = 0;
  REG_LOAD = 0;
  MAR_LOAD = 0;
  INCR_PC = 0;

  // generate csig and bussel
  case(state)
    FETCH:
      begin
        MDRS = 0;
        OP0S = 0;
        //OP1S = 0;
        REGR0S = 0;
        //REGR1S = 0;

        REGR1S = 3'b111;
        OP1S = 2'b01;
        MAR_LOAD = 1'b1;
        INCR_PC = 1'b1;
        IR_LOAD = 1'b1;
      end
    DECODE:
      begin
        case(opc0)
          3'b000:
            begin
              MDRS = MDRS_IMM;
              MDR_LOAD = 1;
            end
          3'b010:
            begin
              MDRS = MDRS_IMM;
              MDR_LOAD = 1;
            end
          3'b011:
            begin
              MDRS = MDRS_IMM;
              MDR_LOAD = 1;
            end
          3'b101:
            begin
              MDRS = 2'b00;
              OP0S = 2'b10;
              MDR_LOAD = 1'b1;
            end
        endcase
      end
    READ:
      begin
        case(opc0)
          3'b000:
            begin
              REGR0S = arg1;
              OP0S = OPS_MDR;
              OP1S = OPS_R0;
              MAR_LOAD = 1;
            end
          3'b010:
            begin
              REGR0S = arg1;
              OP0S = OPS_MDR;
              OP1S = OPS_R0;
              MAR_LOAD = 1;
            end
          3'b011:
            begin
              // NOT WORKING I THINK
              REGR0S = arg1;
              OP0S = OPS_MDR;
              OP1S = OPS_R0;
              MAR_LOAD = 1;
            end
        endcase
      end
    EXEC:
      begin
        case(opc0)
          3'b000:
            begin
              REGR1S = REG0;
              OP0S = OPS_MDR;
              OP1S = OPS_R1;
              REGWS = tgt;
              MDRS = MDRS_RAM;
              MDR_LOAD = 1;
              REG_LOAD = 1;
            end
          3'b010:
            begin
              MDRS = MDRS_ALU;
              REGR0S = tgt;
              REGR1S = REG0;
              OP0S = OPS_R0;
              OP1S = OPS_R1;
              MDR_LOAD = 1;
              RAM_LOAD = 1;
            end
          3'b011:
            begin
              MDRS = MDRS_ALU;
              REGR0S = tgt;
              REGR1S = REG0;
              OP0S = OPS_R0;
              OP1S = OPS_R1;
              MDR_LOAD = 1;
              RAM_LOAD = 1;
				      BYTE_ENABLE = 2'b01;
            end
          3'b101:
            begin
              REGR1S = REG0;
              OP0S = OPS_MDR;
              OP1S = OPS_R1;
              REGWS = tgt;
              REG_LOAD = 1'b1;
            end
        endcase
      end
  endcase
end


endmodule


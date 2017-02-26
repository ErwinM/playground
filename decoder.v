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
  REGR0S,
  REGR1S,
  REGWS,
  OP0S,
  OP1S,
  IRimm,
  MDRS,
 //  slus,
 //  cond,
 clk
);

input clk;
input [15:0] instr;
output MDR_LOAD, REG_LOAD, MAR_LOAD, IR_LOAD, RAM_LOAD, INCR_PC;
output [1:0] MDRS, OP0S, OP1S;
output [12:0] IRimm;
output [2:0] REGWS, REGR0S, REGR1S;

//outputs
reg [12:0] IRimm;
// csig
reg MDR_LOAD, REG_LOAD, MAR_LOAD, INCR_PC, IR_LOAD, RAM_LOAD;

//regsel
reg REGR0S, REGR1S, REGWS;

//bussel
// MDRS: 0: Imm, 1: RAM, 2:ALU
// OP0S/OP1S: 0:R0, 1:R1, 2:MDR
reg [1:0] MDRS, OP0S, OP1S;

// internal registers
reg [3:0] state;
wire [3:0] next_state;

wire [2:0] opc0, tgt;
wire [10:0] imm10;



parameter FETCH = 4'b0001, DECODE = 4'b0010, READ = 4'b0100, EXEC = 4'b1000;

assign next_state = fsm_function(state);

initial begin
  state = 0;
  //reset = 0;
end

function [3:0] fsm_function;
	input [3:0] state;
	case(state)
		FETCH: fsm_function = DECODE;
		DECODE: fsm_function = READ;
		READ: fsm_function = EXEC;
		EXEC: fsm_function = FETCH;
		default: fsm_function = FETCH;
	endcase
endfunction

always @(posedge clk)
begin
	state <= #1 next_state;
end

// Opcode & Immediate splits
assign opc0 = instr[15:13];
assign imm10 = instr[12:3];
assign tgt = instr[2:0];


always @*
// To synthesize combinational logic using an always block, all inputs to the design must appear in the sensitivity list.
begin
  // Immediate mux
  case(opc0)
    3'b101: IRimm = imm10;
    default: IRimm = 0;
  endcase

  // reset csig and bussel?
  MDR_LOAD = 0;
  MAR_LOAD = 0;
  REG_LOAD = 0;
  IR_LOAD = 0;
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
          3'b101:
            begin
              MDRS = 2'b00;
              OP0S = 2'b10;
              MDR_LOAD = 1'b1;
            end
        endcase
      end
    EXEC:
      begin
        case(opc0)
          3'b101:
            begin
              OP0S = 2'b10;
              OP1S = 0;
              REGWS = tgt;
              REG_LOAD = 1'b1;
            end
        endcase
      end
  endcase
end


endmodule


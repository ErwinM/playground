
module cpu (
  reset,
  RAMin,
  RAMout,
  we,
  RAMaddr,
  be,
	hlt,
  clk
);

// i/o
input clk, reset;
input [15:0] RAMout;
output we, be, hlt;
output [15:0] RAMin, RAMaddr;

wire [1:0] op0s, op1s, mdrs;
wire [15:0] IRimm;
wire [2:0]  regr0s, regr1s, regws, cond, ALUfunc;
wire [15:0] IRout;
wire [3:0] state;

wire mdr_load, mar_load, reg_load, ram_load, ir_load, incr_pc, cond_chk;

decoder decoder (
  .instr      (IRout),
  .MDR_LOAD   (mdr_load),
  .MAR_LOAD   (mar_load),
  .REG_LOAD   (reg_load),
  .RAM_LOAD   (ram_load),
  .IR_LOAD    (ir_load),
  .INCR_PC    (incr_pc),
  .BE			    (be),
  .OP0S       (op0s),
  .OP1S       (op1s),
  .IRimm      (IRimm),
  .MDRS       (mdrs),
  .REGR0S     (regr0s),
  .REGR1S     (regr1s),
  .REGWS      (regws),
  .ALUfunc    (ALUfunc),
  .COND_CHK   (cond_chk),
  .cond       (cond),
  .state      (state),
  .reset      (reset),
	.HLT				(hlt),
  .clk        (clk)
);


// SYSREGS
// register(in, reset, load, clk, out)
wire [15:0] MDRout, MARin, MARout, IRin;
reg [15:0] MDRin;

register_posedge MDR (
  .in     (MDRin),
  .reset  (reset),
  .load   (mdr_load),
  .clk    (clk),
  .out    (MDRout)
);

register_posedge MAR (
  .in     (MARin),
  .reset  (reset),
  .load   (mar_load),
  .clk    (clk),
  .out    (MARout)
);

register IR (
  .in     (RAMout),
  .reset  (reset),
  .load   (ir_load),
  .clk    (clk),
  .out    (IRout)
);

// REGFILE

wire [15:0] regr0, regr1, regw;
reg skip;
wire loadneg, incr_pc_temp, incr_pc_out;

not(loadneg, state[0]);

or(incr_pc_temp, skip, incr_pc);
and(incr_pc_out, loadneg, incr_pc_temp);

regfile2 regfile (
  .regr0  (regr0),
  .regr1  (regr1),
  .regw   (regw),
  .regr0s (regr0s),
  .regr1s (regr1s),
  .regws  (regws),
  .we     (reg_load),
  .incr_pc  (incr_pc_out),
  .reset		(reset),
  .clk    (clk)
);

// ALU
wire [15:0] ALUout;
reg [15:0] op0, op1;

alu alu (
  .x          (op0),
  .y          (op1),
  .f          (ALUfunc),
  .out        (ALUout)
);

assign regw = ALUout;
assign MARin = ALUout;
assign RAMin = MDRout;
assign we = ram_load;
assign RAMaddr = MARout;

// bussel muxes
// MDRS: 0: Imm, 1: RAM, 2:ALU
// OP0S/OP1S: 0:R0, 1:R1, 2:MDR
always @* begin

  case(mdrs)
  2'b00: MDRin = IRimm;
  2'b01: MDRin = RAMout;
  2'b10: MDRin = ALUout;
  default: MDRin = IRimm;
  endcase

  case(op0s)
  2'b00: op0 = regr0;
  2'b01: op0 = regr1;
  2'b10: op0 = MDRout;
  default: op0 = regr0;
  endcase

  case(op1s)
  2'b00: op1 = regr0;
  2'b01: op1 = regr1;
  2'b10: op1 = MDRout;
  default: op1 = regr1;
  endcase

  // check if we need to skip
  skip = 0;
  if (cond_chk == 1) begin
    if(ALUout == 0) begin
      // ALU out is 0
      if(cond == 3 | cond == 0 | cond == 5 ) begin
        skip = 1;
      end
    end else if (ALUout[0] == 1) begin
      // ALUout is neg
      if(cond == 3 | cond == 1 | cond == 2) begin
        skip = 1;
      end
    end else if(ALUout[0] == 0 ) begin
      // ALUout is pos
      if(cond == 5 | cond == 1 | cond == 4) begin
        skip = 1;
      end
    end
    // TO DO: unsigned conditions
  end

end

endmodule
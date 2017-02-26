
module cpu (
  // reset,
//   RAMin,
//   RAMout,
//we,
  clk
);

// i/o
input clk;

wire [1:0] op0s, op1s, mdrs;
wire [12:0] IRimm;
wire [2:0]  regr0s, regr1s, regws;

decoder decoder (
  .MDR_LOAD   (mdr_load),
  .REG_LOAD   (reg_load),
  .OP0S       (op0s),
  .OP1S       (op1s),
  .IRimm      (IRimm),
  .MDRS       (mdrs),
  .REGWS      (regws),
  .clk        (clk)
);


// SYSREGS
// register(in, reset, load, clk, out)
wire [15:0] MDRout, MARin, MARout, IRin, IRout, RAMin;
reg [15:0] MDRin;

register MDR (
  .in     (MDRin),
  .reset  (reset),
  .load   (mdr_load),
  .clk    (clk),
  .out    (MDRout)
);

register MAR (
  .in     (MARin),
  .reset  (reset),
  .load   (mar_load),
  .clk    (clk),
  .out    (MARout)
);

register IR (
  .in     (RAMin),
  .reset  (reset),
  .load   (ir_load),
  .clk    (clk),
  .out    (IRout)
);

// REGFILE

wire [15:0] regr0, regr1, regw;

regfile regfile (
  .regr0  (regr0),
  .regr1  (regr1),
  .regw   (regw),
  .regr0s (regr0s),
  .regr1s (regr1s),
  .regws  (regws),
  .we     (reg_load),
  .incr_pc  (incr_pc),
  .clk    (clk)
);

// ALU
wire [15:0] ALUout;
wire [2:0] f;
reg [15:0] op0, op1;

alu alu (
  .x          (op0),
  .y          (op1),
  .f          (f),
  .out        (ALUout)
);

assign regw = ALUout;

// bussel muxes
// MDRS: 0: Imm, 1: RAM, 2:ALU
// OP0S/OP1S: 0:R0, 1:R1, 2:MDR
always @* begin

  case(mdrs)
  2'b00: MDRin = IRimm;
  //2'b01: MDRin = RAMout;
  2'b10: MDRin = ALUout;
  endcase

  case(op0s)
  2'b00: op0 = regr0;
  2'b01: op0 = regr1;
  2'b10: op0 = MDRout;
  endcase

  case(op1s)
  2'b00: op1 = regr0;
  2'b01: op1 = regr1;
  2'b10: op1 = MDRout;
  endcase
end

endmodule

module cpu (
  reset,
  RAMin,
  RAMout,
  we,
	re,
  RAMaddr,
  be,
	hlt,
	UART_intr,
	page_fault,
  clk
);

// i/o
input clk, reset, UART_intr, page_fault;
input [15:0] RAMout;
output we, be, hlt, re;
output [15:0] RAMin, RAMaddr;

wire [1:0] op0s, op1s, mdrs;
wire [15:0] IRimm;
wire [2:0]  regr0s, regr1s, regws, cond, ALUfunc;
wire [15:0] IRout;
wire [3:0] state;

wire mdr_load, mar_load_dec, reg_load, ram_load, ir_load, incr_pc, cond_chk, fault, irq, incr_sp, decr_sp;

parameter FETCH = 4'b0001, FETCHM = 4'b0010, DECODE = 4'b0011, DECODEM = 4'b0100, READ = 4'b0101, READM = 4'b0110, EXEC = 4'b0111, EXECM = 4'b1000;

decoder decoder (
  .instr      (IRout),
  .MDR_LOAD   (mdr_load),
  .MAR_LOAD   (mar_load_decoder),
  .REG_LOAD   (reg_load),
  .RAM_LOAD   (ram_load),
  .IR_LOAD    (ir_load),
  .INCR_PC    (incr_pc),
	.DECR_SP		(decr_sp),
	.INCR_SP		(incr_sp),
  .BE			    (be),
	.RE					(re),
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
	.fault_r		(fault),
	.irq_r			(irq),
	.SYSCALL		(syscall),
	.RETI				(reti),
  .clk        (clk)
);

wire [3:0] trapnr;
reg deassert_trap;
// irq_encoder
irq_encoder irq_encoder (
	.reset			(reset),
	.uart_irq		(UART_intr),
	.page_fault	(page_fault),
	.trapnr			(trapnr),
	.irq				(irq),
	.fault			(fault),
	.deassert		(deassert_trap),
	.clk				(clk)
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

reg mar_force;
or(mar_load, mar_load_decoder, mar_force);

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


// ALU
wire [15:0] ALUout, regw;
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

reg [15:0] regr0, regr1, CR;

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

	// Interrupt and fault logic
	// push trap_nr into sR1 on interrupt
	if (irq == 1 || fault == 1) begin
		sR1 = { {13'b0000000000000}, {trapnr} };
	end

end

	// Control Reg
	//  0	Carry
	// 	1	Mode - This one is actually static in the respective reg
	// 	2	Paging
	// 	3	irq enable ( I DO need this because software might want to disable!)
	// 	4
	// 	5
	// 	6
	// 	7 reserved for forcing write

always @* begin

	if (reset == 1) begin
		bank = 0;
	end

	deassert_trap = 0;
	if (state == 0 && irq == 1 && CR[3] == 1) begin
		bank <= 1'b1;
		deassert_trap <= 1;
		CR[3] <= 0;
	end

	if (state == 0 && fault == 1) begin
		bank <= 1'b1;
		mar_force <= 1; // force MAR_LOAD
		deassert_trap <= 1;
		R7 = R7 - 2;
	end

	if (reti == 1) begin
		bank <= 0;
		CR[3] <= 1;
	end

end

parameter IVEC = 16'h4, CR_INIT = 16'h8, sCR_INIT = 16'h2;

// REGFILE

reg skip, bank;
wire loadneg, incr_pc_temp, incr_pc_out;

not(loadneg, state[0]);

or(incr_pc_temp, skip, incr_pc);
and(incr_pc_out, loadneg, incr_pc_temp);


reg [15:0] R1 = 0;
reg [15:0] R2 = 0;
reg [15:0] R3 = 0;
reg [15:0] R4 = 0;
reg [15:0] R5 = 0;
reg [15:0] R6 = 0;
reg [15:0] R7 = 0;
reg [15:0] uCR = 0;

reg [15:0] sR1 = 0;
reg [15:0] sR2 = 0;
reg [15:0] sR3 = 0;
reg [15:0] sR4 = 0;
reg [15:0] sR5 = 0;
reg [15:0] sR6 = 0;
reg [15:0] sR7 = IVEC;
reg [15:0] sCR = 0;

always @*
begin
	if (bank==0) begin
		CR = uCR;

		case(regr0s)
		3'b000: regr0 = 0;
		3'b001: regr0 = R1;
		3'b010: regr0 = R2;
		3'b011: regr0 = R3;
		3'b100: regr0 = R4;
		3'b101: regr0 = R5;
		3'b110: regr0 = R6;
		3'b111: regr0 = R7;
	  default: regr0 = 0;
		endcase

		case(regr1s)
		3'b000: regr1 = 0;
		3'b001: regr1 = R1;
		3'b010: regr1 = R2;
		3'b011: regr1 = R3;
		3'b100: regr1 = R4;
		3'b101: regr1 = R5;
		3'b110: regr1 = R6;
		3'b111: regr1 = R7;
	  default: regr1 = 0;
		endcase
	end else begin
		CR = sCR;

		case(regr0s)
		3'b000: regr0 = 0;
		3'b001: regr0 = sR1;
		3'b010: regr0 = sR2;
		3'b011: regr0 = sR3;
		3'b100: regr0 = sR4;
		3'b101: regr0 = sR5;
		3'b110: regr0 = sR6;
		3'b111: regr0 = sR7;
	  default: regr0 = 0;
		endcase

		case(regr1s)
		3'b000: regr1 = 0;
		3'b001: regr1 = sR1;
		3'b010: regr1 = sR2;
		3'b011: regr1 = sR3;
		3'b100: regr1 = sR4;
		3'b101: regr1 = sR5;
		3'b110: regr1 = sR6;
		3'b111: regr1 = sR7;
	  default: regr1 = 0;
		endcase
	end
end


always @(negedge clk)
begin
	if (reset && reg_load) begin
		R7 <= 0;
	end else if (reset) begin
		R1 <= 0;
		R2 <= 0;
		R3 <= 0;
		R4 <= 0;
		R5 <= 0;
		R6 <= 0;
		R7 <= 0;
		uCR <= CR_INIT;
		sR1 <= 0;
		sR2 <= 0;
		sR3 <= 0;
		sR4 <= 0;
		sR5 <= 0;
		sR6 <= 0;
		sR7 <= IVEC;
		sCR <= sCR_INIT;
	end else if (reg_load) begin
		if (bank==0) begin
	    case(regws)
			3'b001: R1 <= regw;
			3'b010: R2 <= regw;
			3'b011: R3 <= regw;
			3'b100: R4 <= regw;
			3'b101: R5 <= regw;
			3'b110: R6 <= regw;
			3'b111: R7 <= regw;
	    endcase
  	end else begin
			case(regws)
			3'b001: sR1 <= regw;
			3'b010: sR2 <= regw;
			3'b011: sR3 <= regw;
			3'b100: sR4 <= regw;
			3'b101: sR5 <= regw;
			3'b110: sR6 <= regw;
			3'b111: sR7 <= regw;
			endcase
		end
	end

	if (bank == 0) begin
		if (incr_pc_out)
	    R7 <= R7 + 2;
	end else begin
		if (incr_pc_out)
			sR7 <= sR7 +2;
	end

	if (bank == 0) begin
		if (decr_sp)
	    R5 <= R5 - 2;
	end else begin
		if (decr_sp)
			sR5 <= sR5 - 2;
	end

	if (bank == 0) begin
		if (incr_sp)
	    R5 <= R5 + 2;
	end else begin
		if (incr_sp)
			sR5 <= sR5 + 2;
	end

end


endmodule
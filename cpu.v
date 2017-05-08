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
	cont,
	brk,
  clk
);

// i/o
input clk, reset, UART_intr, cont;
input [15:0] RAMout;
output we, be, hlt, re, brk;
output [15:0] RAMin;
output [18:0] RAMaddr;

wire [1:0] op0s, op1s, mdrs;
wire [15:0] IRimm;
wire [2:0] cond, ALUfunc;
wire [3:0] regr0s, regr1s, regws;
wire [15:0] IRout;
wire [3:0] state;
wire mdr_load, mar_load, mar_load_decoder, reg_load, ram_load, ir_load, incr_pc, cond_chk, fault, irq, reti, incr_sp, decr_sp;
wire wptb, wpte, ivec_load, syscall_irq, ureg;

parameter FETCH = 4'b0001, FETCHM = 4'b0010, DECODE = 4'b0011, DECODEM = 4'b0100, READ = 4'b0101, READM = 4'b0110, EXEC = 4'b0111, EXECM = 4'b1000;

assign brk = (state == 4'b1001) ? 1 : 0;

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
	.RETI				(reti),
	.cont_r			(cont),
	.WPTB				(wptb),
	.WPTE				(wpte),
	.IVEC_LOAD	(ivec_load),
	.SYSCALL		(syscall_irq),
	.UREG				(ureg),
  .clk        (clk)
);

wire [7:0] trapnr;
reg deassert_trap;
wire page_fault, prot_fault;

// irq_encoder
irq_encoder irq_encoder (
	.reset			(reset),
	.uart_irq		(UART_intr),
	.syscall_irq (syscall_irq),
	.page_fault	(page_fault),
	.prot_fault	(prot_fault),
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

// reg to copy MAR so we can inspect it at page fault
reg bank;
wire load_cr2;
wire [15:0] CR2out;

and(load_cr2, ~bank, mar_load);

register_posedge CR2 (
  .in     (MARin),
  .reset  (reset),
  .load   (load_cr2),
  .clk    (clk),
  .out    (CR2out)
);

register IR (
  .in     (RAMout),
  .reset  (reset),
  .load   (ir_load),
  .clk    (clk),
  .out    (IRout)
);

// Control reg
wire [7:0] CRin, CRout;
wire CRY, setCRY, uMode, sMode;

controlreg Creg (
	.reset		(reset),
	.clk			(clk),
	.in				(CRin),
	.out			(CRout),
	.we				(CRwe),
	.bank			(bank),
	.CRY			(CRY),
	.setCRY		(setCRY)
);

wire [15:0] ALUout, ivec_out;

register Ivec (
  .in     (ALUout),
  .reset  (reset),
  .load   (ivec_load),
  .clk    (clk),
  .out    (ivec_out)
);

// carry flag logic
// carry flag is the only CR flag that gets set independently (i think)
assign setCRY = (state == EXEC) ? 1 : 0;
assign CRin = regw[7:0];
assign CRwe = (regws == 4'b1111 && reg_load) ? 1 : 0;
assign sMode = CRout[0];
not(uMode, CRout[0]);


// ALU
wire [15:0] regw;
reg [15:0] op0, op1;

alu alu (
  .x          (op0),
  .y          (op1),
  .f          (ALUfunc),
  .out        (ALUout),
	.carry_out	(CRY)
);

assign regw = ALUout;
assign MARin = ALUout;
assign RAMin = MDRout;
assign we = ram_load;


// bussel muxes
// MDRS: 0: Imm, 1: RAM, 2:ALU
// OP0S/OP1S: 0:R0, 1:R1, 2:MDR

reg [15:0] regr0, regr1;

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
  2'b11: op0 = ptb;
  default: op0 = regr0;
  endcase

  case(op1s)
  2'b00: op1 = regr0;
  2'b01: op1 = regr1;
  2'b10: op1 = MDRout;
  2'b11: op1 = pagetable[MDRout];
  default: op1 = regr1;
  endcase

  // check if we need to skip
  skip = 0;
  if (cond_chk == 1) begin
    if(ALUout == 0) begin
      // ALU out is 0
      if(cond == 3 | cond == 0 | cond == 5 | cond == 7) begin
        skip = 1;
      end
    end
		if (ALUout[15] == 1) begin
      // ALUout is neg
      if(cond == 3 | cond == 1 | cond == 2) begin
        skip = 1;
      end
    end
		if(ALUout[15] == 0 && ALUout != 0) begin
      // ALUout is pos
      if(cond == 5 | cond == 1 | cond == 4) begin
        skip = 1;
      end
    end
		if(CRout[1] == 1) begin
			// carry flag is set (unsigned conditional LT LTE)
			if(cond == 6 | cond == 7) begin
				skip = 1;
			end
		end
    // TO DO: unsigned conditions
  end

end

always @(posedge clk) begin

	// fault and trap logic

	if (reset == 1) begin
		bank <= 0;
		deassert_trap <= 0;
		mar_force <= 0;
	end else if (state == 0 && fault == 1) begin
		bank <= 1'b1;
		mar_force <= 1'b1; // force MAR_LOAD
		deassert_trap <= 1'b1;
	end else if (state == 0 && irq == 1 && CRout[3] == 1) begin
		bank <= 1'b1;
		deassert_trap <= 1;
	end else if (reti == 1) begin
		bank <= 0;
	end else begin
		deassert_trap <= 0;
		mar_force <= 0;
	end
end

// PAGING LOGIC

reg [15:0] pagetable [0:512];
reg [15:0] ptb, ptidx, pte, pageaddr_t;
reg [18:0] pageaddr;
wire pg_not_present, prot_f;

// page & prot fault logic
not(page_not_present, pte[0]);
and(prot_f, uMode, pte[1]);
and(page_fault, CRout[2], page_not_present);
and(prot_fault, CRout[2], prot_f);

assign RAMaddr = (CRout[2] == 1) ? pageaddr : MARout;

always @* begin
	ptidx <= ptb + {{11{1'b0}},{MARout[15:11]}};
	pte <= pagetable[ptidx];
	pageaddr <= {{pte[15:8]}, {MARout[10:0]}};

	//pageaddr_t <= pageaddr[15:0];
end

always @(negedge clk) begin
	// how to load a pte into the pt...
	// lets try and bypass the alu so we can use op0/1 directly
	// wpte (r1), r2
	if (wpte) begin
		pagetable[op0] <= op1;
	end

	if (reset) begin
		ptb <= 0;
	end else if (wptb) begin
		ptb <= op0;
	end
end


// REGFILE

reg skip;
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
reg [15:0] PC = 0;

reg [15:0] sR1 = 0;
reg [15:0] sR2 = 0;
reg [15:0] sR3 = 0;
reg [15:0] sR4 = 0;
reg [15:0] sR5 = 0;
reg [15:0] sR6 = 0;
reg [15:0] sPC = 0;

always @*
begin
	if (bank==0 || ureg == 1) begin

		case(regr0s)
		4'b0000: regr0 = 0;
		4'b0001: regr0 = R1;
		4'b0010: regr0 = R2;
		4'b0011: regr0 = R3;
		4'b0100: regr0 = R4;
		4'b0101: regr0 = R5;
		4'b0110: regr0 = R6;
		4'b0111: regr0 = PC;
		4'b1110: regr0 = 16'hdead;
		4'b1111: regr0 = CRout;
	  default: regr0 = 0;
		endcase

		case(regr1s)
		4'b0000: regr1 = 0;
		4'b0001: regr1 = R1;
		4'b0010: regr1 = R2;
		4'b0011: regr1 = R3;
		4'b0100: regr1 = R4;
		4'b0101: regr1 = R5;
		4'b0110: regr1 = R6;
		4'b0111: regr1 = PC;
	  default: regr1 = 0;
		endcase
	end else begin

		case(regr0s)
		4'b0000: regr0 = 0;
		4'b0001: regr0 = sR1;
		4'b0010: regr0 = sR2;
		4'b0011: regr0 = sR3;
		4'b0100: regr0 = sR4;
		4'b0101: regr0 = sR5;
		4'b0110: regr0 = sR6;
		4'b0111: regr0 = sPC;
		4'b1110: regr0 = CR2out;
		4'b1111: regr0 = CRout;
	  default: regr0 = 0;
		endcase

		case(regr1s)
		4'b0000: regr1 = 0;
		4'b0001: regr1 = sR1;
		4'b0010: regr1 = sR2;
		4'b0011: regr1 = sR3;
		4'b0100: regr1 = sR4;
		4'b0101: regr1 = sR5;
		4'b0110: regr1 = sR6;
		4'b0111: regr1 = sPC;
	  default: regr1 = 0;
		endcase
	end
end

always @(negedge clk)
begin
	// logic for R1-R5 (without cntr)
	if (reset) begin
		R1 <= 0;
		R2 <= 0;
		R3 <= 0;
		R4 <= 0;
		R5 <= 0;
		sR1 <= 0;
		sR2 <= 0;
		sR3 <= 0;
		sR4 <= 0;
		sR5 <= 0;
	end else if ((irq == 1 || fault == 1) && !deassert_trap) begin
		// Interrupt and fault logic
		// push trapnr into sR1 on interrupt
		sR1 <= { {8'b00000000}, {trapnr} };
		if (syscall_irq) begin
			// push syscall nr into sR2
			sR2 <= ALUout;
		end
	end else if (reg_load) begin
		if (bank==0) begin
	    case(regws)
			4'b0001: R1 <= regw;
			4'b0010: R2 <= regw;
			4'b0011: R3 <= regw;
			4'b0100: R4 <= regw;
			4'b0101: R5 <= regw;
			// R6 is assigned below
			// R7 is assigned below
	    endcase
  	end else begin
			case(regws)
			4'b0001: sR1 <= regw;
			4'b0010: sR2 <= regw;
			4'b0011: sR3 <= regw;
			4'b0100: sR4 <= regw;
			4'b0101: sR5 <= regw;
			// sR6 is assigned below
			// sR7 is assigned below
			endcase
		end
	end


	// SP counter reg
	if (reset) begin
		R6 <= 0;
		sR6 <= 0;
	end else if (incr_sp) begin
		if (bank == 0)
			R6 <= R6 + 16'h2;
		else
			sR6 <= sR6 + 16'h2;
	end else if (decr_sp) begin
		if (bank == 0)
			R6 <= R6 - 16'h2;
		else
			sR6 <= sR6 - 16'h2;
	end else if (reg_load && regws == 4'b0110) begin
		if (bank == 0)
			R6 <= regw;
		else
			sR6 <= regw;
	end

	// PC counter reg
	if (reset) begin
		PC <= 0;
		sPC <= ivec_out;
	end else if (syscall_irq) begin
		sPC <= ivec_out;
	end else if (mar_force) begin
		PC <= PC - 16'h2;
	end else if (incr_pc_out) begin
		if (bank == 0)
			PC <= PC + 16'h2;
		else
			sPC <= sPC + 16'h2;
	end else if (reti) begin
		sPC <= ivec_out;
	end else if (reg_load && regws == 4'b0111) begin
		if (bank == 0)
			PC <= regw;
		else
			sPC <= regw;
	end
end


endmodule
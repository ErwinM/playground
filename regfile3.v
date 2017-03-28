// Regfile proof of concept
//

module regfile3 (
regr0,
regr1,
regw,
regr0s,
regr1s,
regws,
we,
bank,
incr_pc,
reset,
cr_wr,
cr_rd,
sr1_wr,
clk
);

input [15:0] regw, cr_wr, sr1_wr;
input [2:0] regr0s, regr1s, regws;
input we, clk, incr_pc, reset, bank;
output [15:0] regr0, regr1, cr_rd;
reg [15:0] regr0, regr1;

parameter IVEC = 16'h2, CR_INIT = 16'h0;

reg [15:0] R1 = 0;
reg [15:0] R2 = 0;
reg [15:0] R3 = 0;
reg [15:0] R4 = 0;
reg [15:0] R5 = 0;
reg [15:0] R6 = 0;
reg [15:0] R7 = 0;
reg [15:0] CR = 0;

reg [15:0] sR1 = 0;
reg [15:0] sR2 = 0;
reg [15:0] sR3 = 0;
reg [15:0] sR4 = 0;
reg [15:0] sR5 = 0;
reg [15:0] sR6 = 0;
reg [15:0] sR7 = IVEC;
reg [15:0] sCR = CR_INIT;

assign cr_rd = (bank == 1 ) ? CR : sCR;

always @*
begin
	if (bank==0) begin
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
	if (reset && we) begin
		R7 <= 0;
	end else if (reset) begin
		R1 <= 0;
		R2 <= 0;
		R3 <= 0;
		R4 <= 0;
		R5 <= 0;
		R6 <= 0;
		R7 <= 0;
		CR <= CR_INIT;
		sR1 <= 0;
		sR2 <= 0;
		sR3 <= 0;
		sR4 <= 0;
		sR5 <= 0;
		sR6 <= 0;
		sR7 <= IVEC;
		CR <= CR_INIT;
	end else if (we) begin
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

	if (bank == 0)
		CR <= cr_wr;
	else
		sCR <= cr_wr;

	if (incr_pc) begin
    R7 <= R7 + 2;
  end

	if (sr1_wr > 0)
		sR1 <= sr1_wr;
end

endmodule

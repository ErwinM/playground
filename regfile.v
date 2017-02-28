// Regfile proof of concept
//

module regfile (
regr0,
regr1,
regw,
regr0s,
regr1s,
regws,
we,
incr_pc,
reset,
clk
);

input [15:0] regw;
input [2:0] regr0s, regr1s, regws;
input we, clk, incr_pc, reset;
output [15:0] regr0, regr1;

reg [15:0] regr0, regr1;

reg [15:0] R1;
reg [15:0] R2;
reg [15:0] R3;
reg [15:0] R4;
reg [15:0] R5;
reg [15:0] R6;
reg [15:0] R7 = 0;

always @*
begin
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
  default: regr0 = 0;
	endcase
end

always @(negedge clk)
begin
	if (reset && we) begin
		R7 <= 0;
	end else if (reset) begin
		R7 <= 0;
	end else if (we) begin
		case(regws)
		3'b001: R1 <= regw;
		3'b010: R2 <= regw;
		3'b011: R3 <= regw;
		3'b100: R4 <= regw;
		3'b101: R5 <= regw;
		3'b110: R6 <= regw;
		3'b111: R7 <= regw;
		endcase
	end

	// PC should auto increment always (?)
	if (incr_pc) begin
    R7 <= R7 + 2;
  end

end
endmodule

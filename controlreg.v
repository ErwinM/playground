module controlreg(
	reset,
	clk,
	in,
	out,
	we,
	bank,
	CRY,
	setCRY
);


	// Control Reg
	//  0	MODE (static)
	// 	1	Carry
	// 	2	Paging
	// 	3	irq enable ( I DO need this because software might want to disable!)
	// 	4
	// 	5
	// 	6
	// 	7


input reset, clk, we, bank, CRY, setCRY;
input [7:0] in;
output [7:0] out;

reg [7:0] uCR, sCR;

assign out = (bank == 0) ? uCR : sCR;

always @(negedge clk) begin

	if (reset) begin
		uCR <= 8'h8;
		sCR <= 8'h1;
	end else if (we) begin
		if (bank == 0)
			uCR <= in;
		else
			sCR <= in;
	end else if (setCRY) begin
		if (bank == 0)
			uCR[1] <= CRY;
		else
			sCR[1] <= CRY;
	end
end


endmodule

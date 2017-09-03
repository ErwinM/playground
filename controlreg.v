module controlreg(
	reset,
	clk,
	in,
	curr_out,
	read_out,
	we,
	bank,
	ureg,
	CRY,
	setCRY
);


	// Control Reg
	//  0	MODE (static) - 0 = user, 1 = super
	// 	1	Carry
	// 	2	Paging
	// 	3	irq enable ( I DO need this because software might want to disable!)
	// 	4
	// 	5
	// 	6
	// 	7


input reset, clk, we, bank, CRY, setCRY, ureg;
input [7:0] in;
output [7:0] curr_out, read_out;

reg [7:0] uCR, sCR;

assign curr_out = (bank == 0) ? uCR : sCR;

assign read_out = (ureg) ? uCR :
									(bank == 0) ? uCR : sCR;

always @(posedge clk) begin

	if (reset) begin
		uCR <= 8'h8;
		sCR <= 8'h1;
	end else if (we) begin
		if (bank == 0 || ureg)
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

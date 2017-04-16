module controlreg(
	reset,
	clk,
	init,
	we_mask,
	in,
	out,
	ce
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


input reset, clk, ce;
input [7:0] we_mask, in, init;
output [7:0] out;

reg [7:0] out;

always @(negedge clk) begin

	if (reset) begin
		out <= init;
	end else if (ce) begin
		if (we_mask[7])
			out[7] <= in[7];
		if (we_mask[6])
			out[6] <= in[6];
		if (we_mask[5])
			out[5] <= in[5];
		if (we_mask[4])
			out[4] <= in[4];
		if (we_mask[3])
			out[3] <= in[3];
		if (we_mask[2])
			out[2] <= in[2];
		if (we_mask[1])
			out[1] <= in[1];
		// bit 0 (MODE) is not writeable, only during init (linked to bank)
	end
end


endmodule

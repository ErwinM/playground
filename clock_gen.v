module clock_gen(
  clk_in,
  manual_in,
  manual_sel,
  speed_sel,
  clk_out
);

input clk_in, manual_in, manual_sel, speed_sel;
output clk_out;

// we have a 50mhz clock in.
// Slow clock divides that clock by 32 to get a ~1,5mhz clock (1.562.500)
reg [5:0] counter;
reg clk_out;

always @* begin
	if (manual_sel) begin
		clk_out = manual_in;
	end else begin
		if (speed_sel) begin
			clk_out = counter[5];
		end else begin
			clk_out = clk_in;
		end
	end
end

always @(posedge clk_in) begin
	counter = counter + 1;
end

endmodule
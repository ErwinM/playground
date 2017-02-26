module register(
in, reset, load, clk, out
);

input [15:0] in;
input load, reset, clk;
output [15:0] out;

reg [15:0] out = 0;

always @(negedge clk)
begin

if (reset && load)
	out = 0;
else if (reset)
	out = 0;
else if (load)
	out = in;
end

endmodule


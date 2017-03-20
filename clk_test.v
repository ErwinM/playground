module clk_test (
  input wire clk,
  output wire slow_clk
);

reg [2:0] cntr;

assign slow_clk = cntr[2];

initial begin
	cntr = 0;
end

always @(posedge clk)
begin
  cntr <= cntr + 1'b1;
end


endmodule


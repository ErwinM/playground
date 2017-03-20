module clock_gen(
manual, slow_clock, select, clk_out, slow_out);

input manual, slow_clock, select;
output clk_out, slow_out;

wire manual, slow_clock;
wire select, not_select;
wire source1, source2;

not n1( not_select, select );

and a1 (source1, manual, not_select);
and a2 (source2, slow_clock, select);

or o1(clk_out, source1, source2);

assign slow_out = slow_clock;

endmodule
module clock_gen_tb;
  reg clk, reset;

reg manual, sel, slow;

clock_gen U0 (
  .manual		(manual),
	.slow_clock	(slow),
	.select			(sel),
	.clk_out		(out)
);

  initial begin
    clk = 0;
		slow = 0;
		sel = 0;
		#50
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;
		#15
		manual = 1;
		#15
		manual = 0;

  end

  always
    #5 clk = !clk;

	always
		#25 slow = !slow;
  initial  begin
    $dumpfile ("clok_gen.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #250 $finish;

  //Rest of testbench code after this line

endmodule
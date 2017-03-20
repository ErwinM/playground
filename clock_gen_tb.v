module clock_gen_tb;
  reg clk, reset;

reg manual, sel, slow;

clock_generator U0 (
  .clk	(clk),
	.manual_clk		(manual),
	.clk_select			(sel)
);

  initial begin
    clk = 0;
		sel = 0;
		manual = 0;
  end

  always
    #5 clk = !clk;


  initial  begin
    $dumpfile ("clk_gen.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #5000 $finish;

  //Rest of testbench code after this line

endmodule
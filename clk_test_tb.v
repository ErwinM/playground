module clk_test_tb;
 reg clk;


clk_test U0 (
.clk (clk)
);

initial begin
  clk = 0;
end

always
  #5 clk = !clk;

  initial  begin
    $dumpfile ("clk_test.vcd");
    $dumpvars;

  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  	#5000 $finish;


endmodule
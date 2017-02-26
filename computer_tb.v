module computer_tb;
  reg clk, reset;

computer U0 (
  .clk    (clk)
  );

  initial begin
    clk = 0;
    reset = 0;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("computer.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #100 $finish;

  //Rest of testbench code after this line

endmodule
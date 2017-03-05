module decoder_tb;
  reg clk, reset;

reg [15:0] instr;

decoder U0 (
  .clk    (clk),
  .instr  (instr)
  );

  initial begin
    clk = 0;
    reset = 0;

    instr = 16'had01;

  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("decoder.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #100 $finish;

  //Rest of testbench code after this line

endmodule
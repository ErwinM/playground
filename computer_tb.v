module computer_tb;
  reg clk, reset;

computer U0 (
  .clock_50_b7a   (clk)
  );

  initial begin
    clk = 0;
    reset = 0;
  end

  integer idx;

  always
    #5 clk = !clk;


  initial  begin
    $dumpfile ("computer.vcd");
    $dumpvars;
    $dumpvars(0,computer_tb.U0.ram.memory[0]);
    $dumpvars(0,computer_tb.U0.ram.memory[1]);
    $dumpvars(0,computer_tb.U0.ram.memory[2]);
    $dumpvars(0,computer_tb.U0.ram.memory[3]);
    $dumpvars(0,computer_tb.U0.ram.memory[4]);
    $dumpvars(0,computer_tb.U0.ram.memory[5]);
    $dumpvars(0,computer_tb.U0.ram.memory[6]);
    $dumpvars(0,computer_tb.U0.ram.memory[7]);
    $dumpvars(0,computer_tb.U0.ram.memory[8]);

  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #200 $finish;

  //Rest of testbench code after this line

endmodule
module ram_tb;
  reg clk, reset;

reg [15:0] addr;

ram U0 (
  .address (addr),
  .clk    (clk)
  );

  initial begin
    clk = 0;
    addr = 0;
    //reset = 0;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("ram.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #100 $finish;

  //Rest of testbench code after this line
  always @(posedge clk) begin
    addr <= addr + 2;
  end

endmodule
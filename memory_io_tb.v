module memory_io_tb;
  reg clk, reset;


reg [15:0] cpuaddr, cpuwrite, ramread;
reg [1:0] cpube;
reg cpuwe;

memory_io U0 (
  //.clk    (clk)
  .CPUaddr  (cpuaddr),
  .CPUbe    (cpube),
  .CPUwe    (cpuwe),
  .CPUwrite (cpuwrite),
  .RAMread  (ramread)
  );

  initial begin
    clk = 0;

    cpuaddr = 16'd4;
    cpuwrite = 16'hbb;
    ramread = 16'haabb;
    cpube = 1;
    cpuwe = 1;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("memory_io.vcd");
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
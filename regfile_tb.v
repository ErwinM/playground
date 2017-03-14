module decoder_tb;
  reg clk, reset;

reg [15:0] regw;
reg [2:0] regws;
reg we, he;

regfile2 U0 (
  .clk    (clk),
  .regws  (regws),
  .regw   (regw),
  .we     (we),
  .he     (he)
  );


//   regr0,
//   regr1,
//   regw,
//   regr0s,
//   regr1s,
//   regws,
//   we,
//   be,
//   incr_pc,
//   reset,
//   clk

  initial begin
    clk = 0;

    regws = 3'b001;
    regw = 16'h1ff;
    we = 1;
    #20
    regws = 3'b001;
    regw = 7'h7f;
    we = 1;
    be = 1;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("regfile2.vcd");
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
module uart_tb;
  reg clk, rst;

reg [7:0] tx_byte;
wire [7:0] rx_byte;
wire [1:0] state;
reg trans;

uart_ctrl U0 (
  .clk	(clk),
  .rst	(rst),
  .to_send	(tx_byte),
  .we			(trans)
  );

  initial begin
		clk = 0;
		rst = 0;
		#5
		tx_byte = 69;
		trans = 1;
		#10
		tx_byte = 69;
		trans = 0;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile("uart.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,rst);
  end

  initial
  #2000 $finish;

  //Rest of testbench code after this line

endmodule
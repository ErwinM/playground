module t16450_tb;
  reg clk, reset;

	reg [7:0] wr_data;
	reg [2:0] addr;
	reg rd_n, wr_n, cs_n, rclk;

	wire [7:0] rd_data;
	wire loop;

t16450 U0 (
  .clk   (clk),
	.reset_n	(reset),
	.rclk  (rclk),
	.addr	(addr),
	.wr_data (wr_data),
	.rd_data (rd_data),
	.rd_n (rd_n),
	.wr_n (wr_n),
	.cs_n (cs_n),
	.baudout (loop)
);

   // input reset_n,
   // input clk,
   // input rclk,
   // input cs_xn,
   // input rd_n,
   // input wr_n,
   // input [2:0] addr,
   // input [7:0] wr_data,
   // output reg [7:0] rd_data,
   // input sin,
   // input cts_n,
   // input dsr_n,
   // input ri_n,
   // input dcd_n,


  initial begin
    clk = 0;
    cs_n = 0; // select uart
		rclk = 1;
		reset = 0;
		#10
		reset = 1;
		#10
		wr_n = 0;
		addr = 3'h1;
		wr_data = 0;
		#10
		addr = 3'h3;
		wr_data = 8'h80;
		#10
		addr = 3'h0;
		wr_data = 8'h01;
		#10
		addr = 3'h1;
		wr_data = 8'h0;
		#10
		addr = 3'h3;
		wr_data = 8'h3;
		#10
		addr = 3'h5;
		wr_data = 8'h20;
		#10
		addr = 3'h0;
		wr_data = 8'h69;
  end

  integer idx;

  always
    #5 clk = !clk;


  initial  begin
    $dumpfile ("t16450.vcd");
    $dumpvars;

  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #50000 $finish;

  //Rest of testbench code after this line

endmodule
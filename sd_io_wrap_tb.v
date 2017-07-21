module sd_io_wrap_tb;
  reg clk, reset, mem_we;

	reg [7:0] BUSaddr;
	reg [15:0] BUSwrite;
	wire [15:0] BUSread;
	reg BUSwe;

sd_io_wrap U0 (
	.clk				(clk),
	.reset			(reset),
	.i_IO_data	(BUSwrite),
	.i_IO_addr  (BUSaddr),
	.i_IO_we		(BUSwe),
	.i_IO_re		(BUSre),
	.o_IO_data	(BUSread)
);

  initial begin
		clk = 0;
		reset = 1;
		#20
		reset = 0;
		BUSaddr = 16'ha6;
		BUSwrite = 9;
		BUSwe = 1;
		#20
		BUSaddr = 16'ha2;
		BUSwrite = 16'hff;
		BUSwe = 1;
		#20
		BUSaddr = 16'ha6;
		BUSwrite = 0;
		BUSwe = 1;
		#20
		BUSaddr = 16'ha2;
		BUSwrite = 16'h40;
		BUSwe = 1;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("sd_io_wrap.vcd");
    $dumpvars;
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #2000 $finish;

  //Rest of testbench code after this line

endmodule
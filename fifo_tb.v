module fifo_tb;
  reg clk, reset;


reg [7:0] data_in;
reg rd_in, wr_in, rst;

wire [3:0] fifo_cnt;
wire [7:0] data_out;

fifo U0 (
  .data_in  (data_in),
  .clk			(clk),
	.rst			(rst),
	.rd_in		(rd_in),
	.wr_in		(wr_in),
  .empty		(empty),
	.full			(full),
  .fifo_cnt	(fifo_cnt),
  .data_out	(data_out)
 );



  initial begin
    rst = 1;
		clk = 0;
		#20
		rst = 0;
    data_in = 8'hA;
    wr_in = 1;
    #10
    data_in = 8'hB;
    wr_in = 1;
    #10
    data_in = 8'hC;
    wr_in = 1;
    #10
   	rd_in =1;
    #10
   	rd_in =1;
    #10
   	rd_in =1;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("fifo.vcd");
    $dumpvars;
		$dumpvars(0,fifo_tb.U0.fifo_ram[0]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[1]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[2]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[3]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[4]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[5]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[6]);
		$dumpvars(0,fifo_tb.U0.fifo_ram[7]);
  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    $monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #200 $finish;

  //Rest of testbench code after this line

endmodule
module sdmapper_tb;
  reg clk, reset, mem_we;

	reg [31:0] sd_in;
	reg [3:0] mem_addr;
	reg [15:0] mem_in;

SDmapper U0 (
	.mem_addr	(mem_addr),
	.sd_addr		(sd_addr),
	.mem_we		(mem_we),
	.sd_we			(sd_we),
	.mem_in		(mem_in),
	.mem_out		(mem_out),
	.sd_in			(sd_in),
	.sd_out		(sd_out),
	.clk				(clk),
	.reset			(reset)
);

  initial begin
    sd_in = 32'hcafebabe;
		clk = 0;
		reset = 1;
		#10
		reset = 0;
		mem_addr = 0;
		#10
		mem_addr = 1;
		#10
		mem_addr = 2;
		mem_we = 1;
		mem_in = 16'hfafa;
		#10
		mem_addr = 3;
		mem_we = 1;
		mem_in = 16'hfafa;
		#10
		mem_addr = 4;
		mem_we = 1;
		mem_in = 16'hfafa;
  end

  always
    #5 clk = !clk;

  initial  begin
    $dumpfile ("sdmapper.vcd");
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
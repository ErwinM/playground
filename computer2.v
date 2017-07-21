// Computer

module computer2 (
  clock_50_b7a,
	reset,
	uart_rx,
	intr,
	trap,
	cont,
	bios_e
);

input clock_50_b7a, reset, uart_rx, intr, trap, cont, bios_e;

wire [15:0] CPUwrite, CPUread, RAMread, RAMwrite, BIOSread;
wire [18:0] CPUaddr;
wire [17:0] RAMaddr;
wire [15:0] i_IO_read, o_IO_write;
wire [7:0] o_IO_addr;
wire we, be, re, RAMwe, i_IO_re, i_IO_be, i_IO_we;
wire [1:0] RAMbe;

mem_io mem_io (
	.o_CPU_read		(CPUread),
  .i_CPU_write	(CPUwrite),
  .i_CPU_addr		(CPUaddr),
  .i_CPU_be			(be),
  .i_CPU_re			(re),
  .i_CPU_we			(we),
  .i_RAM_read		(RAMread),
  .o_RAM_write	(RAMwrite),
  .o_RAM_addr		(RAMaddr),
  .o_RAM_be			(RAMbe),
  .o_RAM_we			(RAMwe),
  .i_BIOS_ena		(bios_e),
  .i_BIOS_read	(BIOSread),
  .i_IO_read		(i_IO_read),
  .o_IO_write		(o_IO_write),
  .o_IO_addr		(o_IO_addr),
  .o_IO_be			(o_IO_be),
  .o_IO_we			(o_IO_we),
  .o_IO_re			(o_IO_re)
);

cpu cpu (
	.reset	(reset),
  .RAMin (CPUwrite),
  .RAMout (CPUread),
  .RAMaddr  (CPUaddr),
	.UART_intr	(intr),
  .we (we),
	.re	(re),
  .be (be),
	.cont (cont),
	.brk (brk),
  .clk (clock_50_b7a)
);

ram ram (
  .data_out (RAMread),
  .data_in  (RAMwrite),
  .address  (RAMaddr),
  .we       (RAMwe),
  .be       (RAMbe),
  .clk      (clock_50_b7a)
);

bios bios (
	.address	(RAMaddr),  // Address input
	.data			(BIOSread),      // Data output
	.clk			(clock_50_b7a)
);


uart_io_wrap uart(
	.reset			(reset),
	.clk				(clock_50_b7a),
	.i_IO_re		(o_IO_re),
	.i_IO_we		(o_IO_we),
	.i_IO_addr	(o_IO_addr),
	.i_IO_data	(o_IO_write),
 	.o_IO_data	(i_IO_read),
	.i_sin			(uart_rx),
	.o_sout			(uart_tx)
);

sd_io_wrap sd (
	.clk				(clock_50_b7a),
	.reset			(reset),
	.i_IO_data	(o_IO_write),
	.i_IO_addr  (o_IO_addr),
	.i_IO_we		(o_IO_we),
	.i_IO_re		(o_IO_re),
	.o_IO_data	(i_IO_read)
);


endmodule
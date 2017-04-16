// Computer

module computer (
  clock_50_b7a,
	reset,
	uart_rx,
	intr,
	trap,
	cont
);

input clock_50_b7a, reset, uart_rx, intr, trap, cont;

wire [15:0] CPUwrite, CPUread, CPUaddr, RAMaddr, RAMread, RAMwrite, BIOSread;
wire [7:0] UARTread, UARTwrite;
wire we, be, re, RAMwe, UARTwe, UARTre;
wire [1:0] RAMbe;
wire [2:0] UARTaddr;

memory_io mem_io (
  .CPUwrite    (CPUwrite),
  .CPUread     (CPUread),
  .CPUaddr     (CPUaddr),
  .be       	 (be),
  .we       	 (we),
	.re					 (re),
  .RAMread  	 (RAMread),
  .RAMwrite  	 (RAMwrite),
  .RAMaddr     (RAMaddr),
  .RAMbe       (RAMbe),
  .RAMwe			 (RAMwe),
  .UARTread  	 (UARTread),
  .UARTwrite   (UARTwrite),
  .UARTaddr    (UARTaddr),
  .UARTwe			 (UARTwe),
	.UARTre			 (UARTre),
	.BIOSread		 (BIOSread),
	.clk				 (clock_50_b7a)
);


cpu cpu (
	.reset	(reset),
  .RAMin (CPUwrite),
  .RAMout (CPUread),
  .RAMaddr  (CPUaddr),
	.UART_intr	(intr),
	.page_fault (trap),
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
	.address	(CPUaddr),  // Address input
	.data			(BIOSread),      // Data output
	.clk			(clock_50_b7a)
);

wire not_reset;
not(not_reset,reset);

wire not_UARTwe, not_UARTre;
reg UARTce = 0;
not(not_UARTwe, UARTwe);
not(not_UARTre, UARTre);

t16450 uart (
   .clk			(clock_50_b7a),  // clock
	 .rclk		(1'b1),
	 .reset_n	(not_reset),
   .cs_n		(UARTce),  // chip select
   .rd_n  	(not_UARTre),// read enable
   .wr_n		(not_UARTwe),  // write enable
   .addr		(UARTaddr),
   .wr_data	(UARTwrite),
   .rd_data	(UARTread),
   .sout		(uart_tx),
	 .sin			(uart_rx)
);



endmodule
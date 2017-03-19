// Computer

module computer (
  clock_50_b7a
);

input clock_50_b7a;

wire [15:0] CPUwrite, CPUread, CPUaddr, RAMaddr, RAMread, RAMwrite;
wire [7:0] UARTread, UARTwrite;
wire we, be, RAMwe, UARTwe;
wire [1:0] RAMbe;
wire [2:0] UARTaddr;

memory_io mem_io (
  .CPUwrite    (CPUwrite),
  .CPUread     (CPUread),
  .CPUaddr     (CPUaddr),
  .be       	 (be),
  .we       	 (we),
  .RAMread  	 (RAMread),
  .RAMwrite  	 (RAMwrite),
  .RAMaddr     (RAMaddr),
  .RAMbe       (RAMbe),
  .RAMwe			 (RAMwe),
  .UARTread  	 (UARTread),
  .UARTwrite   (UARTwrite),
  .UARTaddr    (UARTaddr),
  .UARTwe			 (UARTwe)
);


cpu cpu (
  .RAMin (CPUwrite),
  .RAMout (CPUread),
  .RAMaddr  (CPUaddr),
  .we  (we),
  .be (be),
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


endmodule
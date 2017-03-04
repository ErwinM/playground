// Computer

module computer (
  clock_50_b7a
);

input clock_50_b7a;

wire [15:0] CPUwrite, CPUread, CPUaddr, RAMwrite, RAMread, RAMaddr;
wire CPUwe, RAMwe;
wire [1:0] CPUbe, RAMbe;


memory_io mem_io (
  .CPUwrite    (CPUwrite),
  .CPUread     (CPUread),
  .CPUaddr     (CPUaddr),
  .CPUbe       (CPUbe),
  .CPUwe       (CPUwe),
  .RAMwrite    (RAMwrite),
  .RAMread     (RAMread),
  .RAMaddr     (RAMaddr),
  //.RAMue,
  //.RAMle,
  .RAMbe       (RAMbe),
  .RAMwe       (RAMwe)
);

cpu cpu (
  .RAMin (CPUwrite),
  .RAMout (CPUread),
  .RAMaddr  (CPUaddr),
  .we  (CPUwe),
  .byte_enable (CPUbe),
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

// Memory mapping the UART (why not start there right?)

// always @* begin
//   if CPUaddr[15] == 1'b1;
//
// end

endmodule
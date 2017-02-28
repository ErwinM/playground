// Computer

module computer (
  clock_50_b7a
);

input clock_50_b7a;

wire [15:0] RAMin, RAMout, RAMaddr, CPUaddr, DEVaddr;
wire we;
wire [1:0] be;

cpu cpu (
  .RAMin (RAMin),
  .RAMout (RAMout),
  .RAMaddr  (RAMaddr),
  .we  (we),
  .byte_enable (be),
  .clk (clock_50_b7a)
);

ram ram (
  .data_out (RAMout),
  .data_in  (RAMin),
  .address  (RAMaddr),
  .we       (we),
  .be       (be),
  .clk      (clock_50_b7a)
);

// Memory mapping the UART (why not start there right?)

// always @* begin
//   if CPUaddr[15] == 1'b1;
//
// end

endmodule
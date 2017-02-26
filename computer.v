// Computer

module computer (
  clk
);

input clk;

wire [15:0] RAMin, RAMout, RAMaddr;
wire we;

cpu cpu (
  .RAMin (RAMin),
  .RAMout (RAMout),
  .RAMaddr  (RAMaddr),
  .we  (we),
  .clk (clk)
);

ram ram (
  .data_out (RAMout),
  .data_in  (RAMin),
  .address  (RAMaddr),
  .we       (we),
  .clk      (clk)
);

endmodule
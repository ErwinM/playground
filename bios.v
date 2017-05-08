//-----------------------------------------------------
// Design Name : rom_using_file
// File Name   : rom_using_file.v
// Function    : ROM using readmemh
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------
module bios (
address,  // Address input
data,      // Data output
be,
ce,
clk
);

input [17:0] address;
input [1:0] be;
input clk, ce;
output [15:0] data;

reg [15:0] memory [0:4096];
reg [15:0] temp;

assign data = temp;

initial begin
  $readmemh("bios.hex", memory); // memory_list is memory file
end

always @* begin
  if (be == 2'b01) begin
      temp[15:8] <= 8'b0;
      temp[7:0] <= memory[address];
  end else begin
      temp <= memory[address];
  end
end

endmodule
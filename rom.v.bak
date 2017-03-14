//-----------------------------------------------------
// Design Name : rom_using_file
// File Name   : rom_using_file.v
// Function    : ROM using readmemh
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------
module rom (
address,  // Address input
data      // Data output
);
input [7:0] address;
output [39:0] data;

reg [39:0] mem [0:151] ;

assign data = mem[address];

initial begin
  $readmemb("./micro.list", mem); // memory_list is memory file
end

endmodule
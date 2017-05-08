module ram_switch(
	MEMread,
  MEMwrite,
  MEMbe,
  MEMwe,
	CHIPread,
  CHIPwrite,
  CHIPbe,
  CHIPwe,
	SRAMdata,
	SRAMlb,
	SRAMub,
	SRAMwe,
	sel
);

input [15:0] MEMwrite, CHIPread;
input [1:0] MEMbe;
input sel, MEMwe;


output [15:0] MEMread, CHIPwrite;
output [1:0] CHIPbe;
output CHIPwe, SRAMwe, SRAMlb, SRAMub;

inout [15:0] SRAMdata;

// read
assign MEMread = sel ? SRAMdata : CHIPread;

// we
assign CHIPwe = sel ? 1'b0 : MEMwe;
assign SRAMwe = sel ? !MEMwe : 1'b0;

// write
assign SRAMdata = MEMwe ? MEMwrite : 16'bZ;
assign CHIPwrite = MEMwrite;

// be
assign CHIPbe = MEMbe;
assign SRAMlb = ~MEMbe[0];
assign SRAMub = ~MEMbe[1];

endmodule

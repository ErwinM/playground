module ram_interface (
  Dbus,
  address,
  be,
  we,
	ce,
	RAMaddr,
	RAMread,
	RAMwrite,
	RAMbe,
	RAMwe
);

// dbus side
inout [15:0] Dbus;
input [15:0] address;
input [1:0] be;
input we;
input ce;

// Quartus RAM side
input [15:0] RAMread;
output [15:0] RAMwrite;
output [10:0] RAMaddr;
output [1:0] RAMbe;
output RAMwe;

// hook it up
assign dbus = (we || !ce) ? 'bz : RAMread;
assign RAMwrite = Dbus;
assign RAMbe = be;
assign RAMwe = we;
assign RAMaddr = address[10:0];


endmodule

module hex_io_wrap(
	clk,
	reset,
	i_IO_we,
	i_IO_addr,
	i_IO_data,
	i_RAM_data,
	o_d0,
	o_d1,
	o_d2,
	o_d3
);

input clk, reset, i_IO_we;
input [15:0] i_IO_data, i_RAM_data;
input [7:0] i_IO_addr;
output [6:0] o_d0,o_d1,o_d2,o_d3;

wire ena, w_ena;

hex_control hex0 (
	.reset		(reset),
	.RAMin		(i_RAM_data),
	.PORTin		(i_IO_data),
	.clk			(clk),
	.we				(ena),
	.d0				(o_d0),
	.d1				(o_d1),
	.d2				(o_d2),
	.d3				(o_d3)
);

// memory map code
// hex display is mapped to 0xff80
assign ena = (i_IO_addr >= 8'h80 && i_IO_addr < 8'h90) ? 1'b1 : 1'b0;
and(w_ena, ena, i_IO_we);

endmodule

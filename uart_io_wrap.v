module uart_io_wrap(
	input reset,
	input clk,
	input i_IO_re,
	input i_IO_we,
	input [7:0] i_IO_addr,
	input [15:0] i_IO_data,
 	output [15:0] o_IO_data,
	input i_sin,
	output o_sout,
	output o_intr
);

wire reset_n;
wire baud_loopback;
wire cs_n, rd_n, wr_n, ena;
wire [2:0] addr;
wire [7:0] wr_data, rd_data;

t16450 t0 (
  .reset_n	(reset_n),
  .clk			(clk),  				 // clock
  .rclk			(baud_loopback),
  .cs_n			(cs_n),		  		 // chip select
  .rd_n			(rd_n), 				 // read enable
  .wr_n			(wr_n),  				 // write enable
  .addr			(addr),
  .wr_data	(wr_data),
  .rd_data	(rd_data),
  .sin			(i_sin),  				// rx serial line
  .sout			(o_sout),   			// tx serial line
  .baudout	(baud_loopback),
  .intr 		(o_intr)					// interrupt
);

// memory map logic
assign reset_n = ~reset;
assign ena = (i_IO_addr >= 8'h90 && i_IO_addr < 8'ha0) ? 1'b1 : 1'b0;
assign cs_n = 1'b0; // low active
assign addr = i_IO_addr[2:0];
assign wr_data = i_IO_data[7:0];
assign o_IO_data = (ena) ? { {8'b00000000}, {rd_data} } : 16'bZ;
assign rd_n = (ena) ? ~i_IO_re : 1'b1; // THIS IS NOT CORRECT YET AS MOST INSTR DON'T TRIGGER RE
assign wr_n = (ena) ? ~i_IO_we : 1'b1;

endmodule
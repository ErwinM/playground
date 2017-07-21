//
// this module maps our 16-bit architecture to the 32-bit wishbone interface
// to make this work we need to set some standards:
//
// 1. the 32b words will always be written in 2 instructions (high word, low word). writing the low will
// trigger the we signal towards the SD controller
//
// 2. the controller expects the 32b word to be little endian; this should be handled by
// the software driving the controller
//
// 3. all 4 registers will be memory mapped sequentially towards the CPU
//


module SDmapper(
	mem_addr,
	sd_addr,
	mem_we,
	sd_we,
	mem_in,
	mem_out,
	sd_in,
	sd_out,
	clk,
	reset
);

input [3:0] mem_addr;
output [1:0] sd_addr;

input mem_we, clk, reset;
output sd_we;

input [15:0] mem_in;
output [15:0] mem_out;

input [31:0] sd_in;
output [31:0] sd_out;

reg [15:0] SDi_high, SDi_low, SDo_high, SDo_low;
wire [2:0] adj_addr;

assign adj_addr = mem_addr[3:1];
assign sd_addr = mem_addr[3:2];
assign sd_out = { {SDo_high}, {SDo_low} };
assign mem_out = (adj_addr[0]) ? SDi_low : SDi_high;

// if we are writing an odd adj address we should strobe the buffer to controller
and(sd_we, mem_we, adj_addr[0]);

always @(negedge clk)
begin

	if (reset) begin
		SDi_low  <= 0;
		SDi_high <= 0;
		SDo_low  <= 0;
		SDo_high <= 0;
	end else if (mem_we) begin
		if (adj_addr[0])
			SDo_low <= mem_in;
		else
			SDo_high <= mem_in;
	end else begin
		SDi_low <= sd_in[15:0];
		SDi_high <= sd_in[31:16];
	end
end
endmodule

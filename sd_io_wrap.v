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

module sd_io_wrap (
	input clk,
	input reset,
	input [15:0] i_IO_data,
	input [7:0] i_IO_addr,
	input i_IO_we,
	input i_IO_re,
	output [15:0] o_IO_data,
	// towards sd card
	output o_cs_n,
	output o_sck,
	output o_mosi,
	input	i_miso
);

wire [31:0] SDresponse;
wire [31:0] SDwrite;
wire [15:0] o_IO_data_prep;
wire [2:0] adj_addr;
reg [1:0] SDaddr;
wire ena, bus_grant, o_int, long_ena, SDstb;
reg SDwe, SDwe_trig, SDstb_re, SDstb_trig;

reg [15:0] write_hi, write_lo;

reg [1:0] fsm;
reg extend_ena;

assign ena = (i_IO_addr >= 8'ha0 && i_IO_addr < 8'hb0) ? 1'b1 : 1'b0;
assign long_ena = extend_ena || ena;
assign adj_addr = i_IO_addr[3:1];
assign bus_grant = 1'b1;

assign o_IO_data_prep = (adj_addr[0]) ? SDresponse[15:0] : SDresponse[31:16];
assign o_IO_data = (long_ena) ? o_IO_data_prep : 1'bZ;
// i need to do something with acknowledging the read after the low word...


sdspi sd (
	.i_clk				(clk),
	.i_wb_cyc			(long_ena),
	.i_wb_stb			(SDstb),
	.i_wb_we			(SDwe),
	.i_wb_addr		(SDaddr),
	.i_wb_data		(SDwrite),
	//.o_wb_ack			(),
	.o_wb_data		(SDresponse),
	.o_cs_n				(o_cs_n),
	.o_sck				(o_sck),
	.o_mosi				(o_mosi),
	.i_miso				(i_miso),
	.o_int				(o_int),
	.i_bus_grant	(bus_grant)
);

// we need a little state machine that handles the write to sdspi if required
// because the signals don't line up. We also need to save the address for a
// clock and make sure the value is only strobed once to the controller

parameter IDLE = 2'b0, WRITE = 2'b01, CLEAR = 2'b10;

assign 	SDwrite = {{write_hi}, {write_lo}};
assign SDstb = SDwe | SDstb_re;

always @(negedge clk)
begin
	if (reset) begin
		write_hi <=0;
		write_lo <=0;
		fsm = IDLE;
	end else begin
		case(fsm)
			IDLE:
				begin
					SDwe = 1'b0;
					extend_ena = 1'b0;
					SDaddr = i_IO_addr[3:2];
					if (SDwe_trig == 1'b0 && i_IO_we == 1'b1) begin
						SDwe_trig = 1'b1;
					end
					if (i_IO_we == 1'b0)
						SDwe_trig = 1'b0;
					if (SDwe_trig) begin
						if (adj_addr[0]) begin
							write_lo <= i_IO_data;
							fsm = WRITE;
						end else begin
							write_hi <= i_IO_data;
						end
					end
					if (SDstb_trig == 1'b0 && i_IO_re == 1'b1 && adj_addr[0]) begin
						SDstb_re = 1'b1;
						SDstb_trig = 1'b1;
					end else begin
						SDstb_re = 1'b0;
					end
					if (i_IO_re == 1'b0)
						SDstb_trig = 1'b0;
				end
			WRITE:
				begin
					SDwe = 1'b1;
					extend_ena = 1'b1;
					fsm = CLEAR;
				end
			CLEAR:
				begin
					// we have just written the value so we can clear all regs
					write_lo  <= 0;
					write_hi  <= 0;
					SDwe = 1'b0;
					fsm = IDLE;
				end
			default: fsm = IDLE;
		endcase
	end
end

endmodule
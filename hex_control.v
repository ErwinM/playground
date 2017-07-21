module hex_control(
reset, RAMin, PORTin, clk, we, d0,d1,d2,d3);

input clk, we, reset;
input [15:0] RAMin, PORTin;
output [6:0] d0,d1,d2,d3;

reg [15:0] port;
reg [6:0] d0_t,d1_t,d2_t,d3_t;

assign d0 = d0_t;
assign d1 = d1_t;
assign d2 = d2_t;
assign d3 = d3_t;

function [6:0] get_digit_mask;
	input [3:0] in;
	case(in)
   4'h0 : get_digit_mask = 7'b1000000; //to display 0
   4'h1 : get_digit_mask = 7'b1111001; //to display 1
   4'h2 : get_digit_mask = 7'b0100100; //to display 2
   4'h3 : get_digit_mask = 7'b0110000; //to display 3
   4'h4 : get_digit_mask = 7'b0011001; //to display 4
   4'h5 : get_digit_mask = 7'b0010010; //to display 5
   4'h6 : get_digit_mask = 7'b0000010; //to display 6
   4'h7 : get_digit_mask = 7'b1111000; //to display 7
   4'h8 : get_digit_mask = 7'b0000000; //to display 8
   4'h9 : get_digit_mask = 7'b0010000; //to display 9
	 4'ha : get_digit_mask = 7'b0001000; //to display a
	 4'hb : get_digit_mask = 7'b0000011; //to display b
	 4'hc : get_digit_mask = 7'b1000110; //to display c
	 4'hd : get_digit_mask = 7'b0100001; //to display d
	 4'he : get_digit_mask = 7'b0000110; //to display e
	 4'hf : get_digit_mask = 7'b0001110; //to display f
   default : get_digit_mask = 7'b0111111; //dash
  endcase
endfunction

always @* begin

	if (port > 0) begin
		d0_t = get_digit_mask(port[3:0]);
		d1_t = get_digit_mask(port[7:4]);
		d2_t = get_digit_mask(port[11:8]);
		d3_t = get_digit_mask(port[15:12]);
	end else begin
		d0_t = get_digit_mask(RAMin[3:0]);
		d1_t = get_digit_mask(RAMin[7:4]);
		d2_t = get_digit_mask(RAMin[11:8]);
		d3_t = get_digit_mask(RAMin[15:12]);
	end
end

always @(posedge clk) begin
	if (reset) begin
		port <= 0;
	end else if (we) begin
		port <= PORTin;
	end
end


endmodule
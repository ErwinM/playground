module clock_generator (

input clk,
input reset,
input manual_clk,
input clk_select,
output sel_out,
output slow_out
);

reg [7:0] counter;
reg slow_clk;

assign sel_out = (clk_select) ? manual_clk : slow_clk;
assign slow_out = slow_clk;

// counter size calculation according to input and output frequencies
parameter incoming_clk = 50000000;  // 50 MHz system clock
parameter slow = 5000000;  // 1 MHz clock output
parameter half_div = incoming_clk / (2*slow); // max-counter size

initial begin
	counter = 0;
	slow_clk = 0;
end

always@(negedge clk) begin
	if (reset) begin
		counter <= 0;
		slow_clk <= 0;
	end else begin
	  if (counter == half_div - 1)
	    begin
	    counter <= 0;
	    slow_clk <= ~slow_clk;
	    end
	  else
	    begin
	    counter <= counter + 1'd1;
	    end
	  end
	end
endmodule

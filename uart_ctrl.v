// uart controller
// memory mapped by mem_io to 0xffff
//
// initially we will have a single byte 'buffer' on each end

module uart_ctrl(
  clk,
  rst,
  to_send,
  we,
	rx,
	tx
);

input [7:0] to_send;
input we, clk, rst, rx;
output tx;

// internal registers
//reg [7:0] tx_byte, buffer;
reg transmit, tx_toggle;

reg [7:0] tx_byte;
wire [7:0] rx_byte;

uart uart0 (
    .clk (clk),
    .rst (rst),             // Synchronous reset.
    .rx  (rx),              // Incoming serial line
    .tx  (tx),              // Outgoing serial line
    .transmit (transmit),   // Signal to transmit
    .tx_byte  (to_send),    // Byte to transmit
    .received (received),   // Indicated that a byte has been received.
    .rx_byte  (rx_byte),    // Byte received
    .is_receiving (is_receiving), // Low when receive line is idle.
    .is_transmitting  (is_transmitting), // Low when transmit line is idle.
    .recv_error (recv_error)
);

initial begin
  tx_toggle = 0;
end

always @(posedge clk) begin

	if (we && tx_toggle == 0)
	begin
		tx_toggle = 1;
		tx_byte = to_send;
	end
	if (transmit == 1)
		tx_toggle = 0;
end

always @(negedge clk) begin
	if (tx_toggle == 1)
	begin
		transmit = 1;
	end else begin
		transmit = 0;
	end
end

endmodule





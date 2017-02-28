// uart controller
// memory mapped
//
// 0x00 tx_byte [7:0]
// 0x01 transmit
// 0x10 rx_byte [7:0]
// 0x11 received
// 0x20 is_transmitting
// 0x21 is_receiving
// 0x22 recv_error

module uart_ctrl(
  clk,
  rst,
  addr,
  data,
  we,
);

input [7:0] addr;
input we, clk, rst;
inout [7:0] data;

// internal registers
reg [7:0] tx_byte, buffer;
reg transmit;

wire [7:0] rx_byte;

uart uart0 (
    .clk (clk),
    .rst (rst),             // Synchronous reset.
    .rx  (rx),              // Incoming serial line
    .tx  (tx),              // Outgoing serial line
    .transmit (transmit),   // Signal to transmit
    .tx_byte  (tx_byte),    // Byte to transmit
    .received (received),   // Indicated that a byte has been received.
    .rx_byte  (rx_byte),    // Byte received
    .is_receiving (is_receiving), // Low when receive line is idle.
    .is_transmitting  (is_transmitting), // Low when transmit line is idle.
    .recv_error (recv_error)
);

assign data =  we ? buffer : 'bz;

always @(negedge clk) begin

  if(we == 1) begin
    case(addr)
      7'h00: tx_byte <= data;
      7'h01: transmit <= data;
    endcase
  end else begin
    case(addr)
      7'h00: buffer <= tx_byte;
      7'h01: buffer <= transmit;
      7'h10: buffer <= rx_byte;
      7'h11: buffer <= received;
      7'h20: buffer <= is_transmitting;
      7'h21: buffer <= is_receiving;
      7'h22: buffer <= recv_error;
    endcase
  end
end

endmodule





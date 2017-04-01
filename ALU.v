module alu(
  x,y,
  f,
  out
);

  input       [15:0]  x,y;
  input       [2:0]   f;
  output      [15:0]  out;

  reg [15:0] out;


  always @* begin

    case(f)
      3'b000: out = x + y;
      3'b001: out = x - y;
			3'b010: out = x & y;
			3'b011: out = x | y;
			3'b100: out = x << (y + 16'h1);
			3'b101: out = x >> (y + 16'h1);
			3'b110: out = (x << 9) | (y & 16'h1ff);
      default: out = x + y;
    endcase
  end

endmodule
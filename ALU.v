module alu(
  x,y,
  f,
  out,
	carry_out
);

  input       [15:0]  x,y;
  input       [2:0]   f;
  output      [15:0]  out;
	output			carry_out;

  reg [15:0] out;
	reg [16:0] cout;

	assign carry_out = cout[16];

  always @* begin
		cout = 0;

    case(f)
      3'b000:
				begin
					out = x + y;
					cout = x + y;
				end
      3'b001:
				begin
					out = x - y;
					cout = x - y;
				end
			3'b010: out = x & y;
			3'b011: out = x | y;
			3'b100: out = x << (y + 16'h1);
			3'b101: out = x >> (y + 16'h1);
			3'b110: out = (x << 9) | (y & 16'h1ff);
      default:
				begin
					out = x + y;
					cout = x + y;
				end
    endcase

  end

endmodule
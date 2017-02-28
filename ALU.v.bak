module alu(
  x,y,
  f,
  out
);

  input       [15:0]  x,y;
  input       [2:0]   f;
  output      [15:0]  out;

  reg out;


  always @* begin

    case(f)
      3'b000: out = x + y;
      default: out = x + y;
    endcase
  end

endmodule
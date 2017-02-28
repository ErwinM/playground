module ram(
    output [15:0] data_out,
    input [15:0] address,
    input [15:0] data_in,
    input [1:0] be,
    input we,
    input clk
);
    reg [7:0] memory [0:255]; // byte addressable
    reg [15:0] temp;


    initial begin
      $readmemh("bios.hex", memory,0,3);
    end

    assign data_out = temp;

    always @(posedge clk) begin
        if (we) begin
            if (be == 2'b01) begin
              memory[address] <= data_in[7:0];
            end else begin
              memory[address] <= data_in[15:8];
              memory[address+1] <= data_in[7:0];
            end
        end
    end

    always @* begin
      if (be == 2'b01) begin
          temp[15:8] = 8'b0;
          temp[7:0] = memory[address];
      end else begin
          temp[15:8] = memory[address];
          temp[7:0] = memory[address+1];
      end
    end
endmodule
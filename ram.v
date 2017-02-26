module ram(
    output [15:0] data_out,
    input [15:0] address,
    input [15:0] data_in,
    input we,
    input clk
);
    reg [7:0] memory [0:255]; // byte addressable


    initial begin
      $readmemh("bios.hex", memory,0,3);
    end

    always @(negedge clk) begin
        if (we) begin
            memory[address] <= data_in[15:8];
            memory[address+1] <= data_in[7:0];
        end
    end

    assign data_out[15:8] = memory[address];
    assign data_out[7:0] = memory[address+1];

endmodule
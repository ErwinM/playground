module ram(
    output [15:0] data_out,
    input [15:0] address,
    input [15:0] data_in,
    input [1:0] be,
    input we,
    input clk
);
    reg [15:0] memory [0:2048]; // byte addressable
    reg [15:0] temp;


    initial begin
      $readmemh("trampoline.hex", memory,0,2);
      $readmemh("bios.hex", memory,128,256);
    end

    assign data_out = temp;

    always @(posedge clk) begin
        if (we) begin
            if (be == 2'b01) begin
              temp[15:8] = 8'b0;
              temp[7:0] = data_in[7:0];
              memory[address] = memory[address] || temp; // preserve high byte in mem
            end else begin
              memory[address] <= data_in;
            end
        end
    end

    always @(posedge clk) begin
      if (be == 2'b01) begin
          temp[15:8] = 8'b0;
          temp[7:0] = memory[address];
      end else begin
          temp = memory[address];
      end
    end
endmodule
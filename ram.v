module ram(
    output [15:0] data_out,
    input [17:0] address,
    input [15:0] data_in,
    input [1:0] be,
    input we,
    input clk
);
    reg [15:0] memory [0:4096]; // byte addressable
    reg [15:0] temp;


    initial begin
			// validation suite trampoline
			//$readmemh("trampoline.hex", memory,0,2);
      //$readmemh("A_simple.hex", memory,16'h80,1024);
      $readmemh("A_simple.hex", memory,0,256);
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
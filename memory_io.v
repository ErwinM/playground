// Memory I/O & bus controller

module memory_io(
 CPUread,
 CPUwrite,
 CPUaddr,
 be,
 we,
 re,
 RAMread,
 RAMwrite,
 RAMaddr,
 RAMbe,
 RAMwe,
 UARTread,
 UARTwrite,
 UARTaddr,
 UARTwe,
 UARTre,
 UARTce
);

input [15:0] CPUwrite, RAMread;
output [15:0] CPUread, RAMwrite;

input [7:0] UARTread;
output [7:0] UARTwrite;

input [15:0] CPUaddr;
output [15:0] RAMaddr;
output [2:0] UARTaddr;

input we, be, re;
output RAMwe, UARTwe, UARTre, UARTce;
output [1:0] RAMbe;

// internal thingies
wire [15:0] RAMaddr;
reg [15:0] data, wdata;
reg RAMwe, UARTwe, UARTce, UARTre;

reg [1:0] RAMbe;

parameter UARTbase = 16'h0ff0;


assign CPUread = (CPUaddr < UARTbase) ? data : UARTread;
assign RAMwrite = wdata;

assign UARTwrite = CPUwrite[7:0];

// shift addr right one bit to translate from byte address to word address (RAM is in words)
assign RAMaddr[0] = CPUaddr[1];
assign RAMaddr[1] = CPUaddr[2];
assign RAMaddr[2] = CPUaddr[3];
assign RAMaddr[3] = CPUaddr[4];
assign RAMaddr[4] = CPUaddr[5];
assign RAMaddr[5] = CPUaddr[6];
assign RAMaddr[6] = CPUaddr[7];
assign RAMaddr[7] = CPUaddr[8];
assign RAMaddr[8] = CPUaddr[9];
assign RAMaddr[9] = CPUaddr[10];
assign RAMaddr[10] = CPUaddr[11];
assign RAMaddr[11] = CPUaddr[12];
assign RAMaddr[12] = CPUaddr[13];
assign RAMaddr[13] = CPUaddr[14];
assign RAMaddr[14] = CPUaddr[15];
assign RAMaddr[15] = 0;


// For now we only have 8 dev addr which get translated straight to the 16450
assign UARTaddr[0] = CPUaddr[0];
assign UARTaddr[1] = CPUaddr[1];
assign UARTaddr[2] = CPUaddr[2];




always @* begin
	RAMwe = 0;
	UARTwe = 0;
	UARTce = 0;
	UARTre = 0;
	if (we && CPUaddr < UARTbase) begin
		RAMwe = 1;
	end
	else if (we && CPUaddr >= UARTbase) begin
		UARTwe = 1;
	end
	if (re && CPUaddr >= UARTbase) begin
		UARTre = 1;
	end

	wdata = CPUwrite;
  RAMbe = 2'b11;
  data = RAMread;
  if(we == 1) begin
    if(be == 1) begin
      if(CPUaddr[0] == 1) begin
        // address is odd - we need to write to the low byte
        wdata[0] = CPUwrite[0];
        wdata[1] = CPUwrite[1];
        wdata[2] = CPUwrite[2];
        wdata[3] = CPUwrite[3];
        wdata[4] = CPUwrite[4];
        wdata[5] = CPUwrite[5];
        wdata[6] = CPUwrite[6];
        wdata[7] = CPUwrite[7];
        wdata[8] = 0;
        wdata[9] = 0;
        wdata[10] = 0;
        wdata[11] = 0;
        wdata[12] = 0;
        wdata[13] = 0;
        wdata[14] = 0;
        wdata[15] = 0;
        //ue = 0;
        //le = 1;
        RAMbe = 2'b01;
      end else begin
        wdata[0] = 0;
        wdata[1] = 0;
        wdata[2] = 0;
        wdata[3] = 0;
        wdata[4] = 0;
        wdata[5] = 0;
        wdata[6] = 0;
        wdata[7] = 0;
        wdata[8] = CPUwrite[0];
        wdata[9] = CPUwrite[1];
        wdata[10] = CPUwrite[2];
        wdata[11] = CPUwrite[3];
        wdata[12] = CPUwrite[4];
        wdata[13] = CPUwrite[5];
        wdata[14] = CPUwrite[6];
        wdata[15] = CPUwrite[7];
        //ue = 1;
        //le = 0;
        RAMbe = 2'b10;
      end
    end
  end

  if(be == 1) begin
    if(CPUaddr[0] == 1) begin
      // address is odd - we need to read the low byte
      data[0] = RAMread[0];
      data[1] = RAMread[1];
      data[2] = RAMread[2];
      data[3] = RAMread[3];
      data[4] = RAMread[4];
      data[5] = RAMread[5];
      data[6] = RAMread[6];
      data[7] = RAMread[7];
    end else begin
      data[0] = RAMread[8];
      data[1] = RAMread[9];
      data[2] = RAMread[10];
      data[3] = RAMread[11];
      data[4] = RAMread[12];
      data[5] = RAMread[13];
      data[6] = RAMread[14];
      data[7] = RAMread[15];
    end
    data[8] = 0;
    data[9] = 0;
    data[10] = 0;
    data[11] = 0;
    data[12] = 0;
    data[13] = 0;
    data[14] = 0;
    data[15] = 0;
  end

end

endmodule
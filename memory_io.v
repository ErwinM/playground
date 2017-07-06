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
 UARTce,
 HEXwe,
 BIOSread,
 bios
);

input [15:0] CPUwrite, RAMread, BIOSread;
output [15:0] CPUread, RAMwrite;

input [7:0] UARTread;
output [7:0] UARTwrite;

input [18:0] CPUaddr;
output [17:0] RAMaddr;
output [2:0] UARTaddr;

input we, be, re, bios;
output RAMwe, UARTwe, UARTre, UARTce, HEXwe;
output [1:0] RAMbe;

// internal thingies
wire [17:0] RAMaddr;
wire [15:0] CPUread;
reg [15:0] data, wdata, BIOSdata; //CPUread;
reg RAMwe, UARTwe, UARTce, UARTre, HEXwe;

reg [1:0] RAMbe;

// Memory map
// 0x0000 - 0xff6f -> RAM
// 0xff70 - 0xff7f -> Interrupt vector (16 instructions max, push fault_nr and branch_) - is just RAM
// 0xff80 - 0xff8f -> 7SEG display (and other onboard i/o later (e.g. switches and buttons))
// 0xff90 - 0xff9f -> UART 16450

parameter HEXbase = 16'hff80, Sbase = 16'hff90;

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
assign RAMaddr[15] = CPUaddr[16];
assign RAMaddr[16] = CPUaddr[17];
assign RAMaddr[17] = CPUaddr[18];

assign UARTaddr[0] = CPUaddr[0];
assign UARTaddr[1] = CPUaddr[1];
assign UARTaddr[2] = CPUaddr[2];

// this is the memory map implementation
assign CPUread = (CPUaddr < 16'h0800 && bios == 1) ? BIOSdata :
								 (CPUaddr > 16'hffff) ? data :
								 (CPUaddr >= Sbase) ? UARTread :
								 (CPUaddr >= HEXbase) ? 16'hcafe :
								 data;

always @* begin
	RAMwe = 0;
	UARTwe = 0;
	UARTce = 0;
	UARTre = 0;
	HEXwe = 0;

	if (we) begin
		if (CPUaddr < HEXbase) begin
			RAMwe = 1;
		end else if (CPUaddr < Sbase) begin
			HEXwe = 1;
		end else if (CPUaddr >= Sbase) begin
			UARTwe = 1;
		end
	end

	if (re) begin
		if(CPUaddr >= Sbase)
			UARTre = 1;
	end

	if (re) begin
		RAMbe = 2'b11;
	end

	wdata = CPUwrite;
  RAMbe = 2'b11;
  //if(we == 1) begin
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
      wdata[8] = 1'b0;
      wdata[9] = 1'b0;
      wdata[10] = 1'b0;
      wdata[11] = 1'b0;
      wdata[12] = 1'b0;
      wdata[13] = 1'b0;
      wdata[14] = 1'b0;
      wdata[15] = 1'b0;
      //ue = 1'b0;
      //le = 1;
      RAMbe = 2'b01;
    end else begin
      wdata[0] = 1'b0;
      wdata[1] = 1'b0;
      wdata[2] = 1'b0;
      wdata[3] = 1'b0;
      wdata[4] = 1'b0;
      wdata[5] = 1'b0;
      wdata[6] = 1'b0;
      wdata[7] = 1'b0;
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

	data = RAMread;
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

	BIOSdata = BIOSread;
	if(be == 1)begin
    if(CPUaddr[0] == 1) begin
      // address is odd - we need to read the low byte
			BIOSdata = BIOSread & 16'hff;
		end else begin
			BIOSdata = BIOSread >> 8;
		end
	end

end

endmodule
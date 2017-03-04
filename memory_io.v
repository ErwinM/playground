// Memory I/O

module memory_io(

 CPUwrite,
 CPUread,
 CPUaddr,
 CPUbe,
 CPUwe,
 RAMwrite,
 RAMread,
 RAMaddr,
 //RAMue,
 //RAMle,
 RAMbe,
 RAMwe
);

input [15:0] CPUwrite, RAMread, CPUaddr;
input CPUwe;
input CPUbe;

output [15:0] CPUread, RAMwrite, RAMaddr;
output RAMwe;
output [1:0] RAMbe;

// internal thingies
wire [15:0] addr;
reg [15:0] data, wdata;
//reg ue,le;
reg [1:0] be;

// shift addr right one bit
assign addr[0] = CPUaddr[1];
assign addr[1] = CPUaddr[2];
assign addr[2] = CPUaddr[3];
assign addr[3] = CPUaddr[4];
assign addr[4] = CPUaddr[5];
assign addr[5] = CPUaddr[6];
assign addr[6] = CPUaddr[7];
assign addr[7] = CPUaddr[8];
assign addr[8] = CPUaddr[9];
assign addr[9] = CPUaddr[10];
assign addr[10] = CPUaddr[11];
assign addr[11] = CPUaddr[12];
assign addr[12] = CPUaddr[13];
assign addr[13] = CPUaddr[14];
assign addr[14] = CPUaddr[15];
assign addr[15] = 0;

assign RAMaddr = addr;
assign RAMwrite = wdata;
assign CPUread = data;
assign RAMwe = CPUwe;
assign RAMbe = be;
//assign RAMue = ue;
//assign RAMle = le;



always @* begin
  wdata = CPUwrite;
  be = 2'b11;
  data = RAMread;
  if(CPUwe == 1) begin
    if(CPUbe == 1) begin
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
        be = 2'b01;
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
        be = 2'b10;
      end
    end
  end


  if(CPUbe == 1) begin
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
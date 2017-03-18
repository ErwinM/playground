module FIFO (clk, reset, data_in, put, get, data_out, fillcount, empty, full);
parameter DEPTHP2 = 8 ;
parameter WIDTH = 8 ;
input [WIDTH-1:0] data_in;
input put, get, reset, clk;
output fillcount;
output reg [WIDTH-1:0] data_out;
output reg empty, full;




reg [3:0]fillcount ;
reg [WIDTH-1:0] fifo_1[0:DEPTHP2-1];
reg [2:0] rp,wp;


always@(posedge clk or posedge reset)
begin
   if( reset )
   begin
      wp <= 0;
      rp <= 0;
   end
   else
   begin
      if( !full && put )    wp <= wp + 1;
          else  wp <= wp;

      if( !empty && get )   rp <= rp + 1;
      else rp <= rp;
   end

end

always @(fillcount)
begin
if(fillcount==0)
  empty =1 ;
  else
  empty=0;

  if(fillcount==8)
   full=1;
   else
   full=0;
end

always @(posedge clk or posedge reset)
begin
   if( reset )
       fillcount <= 0;

   else if( (!full && put) && ( !empty && get ) )
       fillcount <= fillcount;

   else if( !full && put )
       fillcount <= fillcount + 1;

   else if( !empty && get )
       fillcount <= fillcount - 1;
   else
      fillcount <= fillcount;
end

always @( posedge clk or posedge reset)
begin:Reading
   if( reset )
      data_out <= 0;
   else
   begin
      if( get && !empty )
         data_out <= fifo_1[rp];

      else
         data_out <= data_out;

   end
end

always @(posedge clk)
begin:Writing

   if( put && !full )
      fifo_1[ wp ] <= data_in;

   else
      fifo_1[ wp ] <= fifo_1[ wp ];
end

endmodule
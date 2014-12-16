module memory(input rdwt,input clk,input [0:15]addr,inout [0:15]data);
reg[0:7] mem[0:65535]
always@(posedge clk)
begin
    if(rdwt === read)
        data = mem[addr];
    else 
        mem[addr] = data;
end
endmodule

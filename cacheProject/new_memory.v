`include global_def.v
module(clk,reset,blockAddr,dataIn,dataOut,rdwt,releaseBus,errFlag);
input wire clk,reset,rdwt;
input wire[BLOCKADDRBIT-1:0] blockAddr;
input wire[BLOCKBYTE*WORDSIZE-1:0] dataIn;
output reg[BLOCKBYTE*WORDSIZE-1:0] dataIn;
output reg releaseBus;
output reg[ERRWIDTH-1:0] errFlag;
//main memory
reg[WORDSIZE-1:0] mem[MEMSIZE-1:0];

reg[7:0] delayCounter;
+
integer i;
always@(posedge clk)
begin 
    if(reset)
    begin 
        delayCounter = 0;
        releaseBus   = 0;
        for(i=0; i<MEMSIZE; i=i+1)
            mem[i] = 0;
    end
end

always @(rdwt,blockAddr,dataIn)
begin 
    delayCounter <= MEM_ACCESS_DELAY;
    releaseBus   <= ACCESSING;
end 

always @(posedge clk) begin 
    if(delayCounter > 0)
    begin 
        delayCounter = delayCounter -1;
        releaseBus   = ACCESSING;
    end 
    else begin 
        case(rdwt)
            RD:dataOut = mem[(blockAddr)+:BLOCKBYTE*WORDSIZE];
            WT:mem[(blockAddr)+:BLOCKBYTE*WORDSIZE] = dataIn;
            default: errFlag = MEM_ERR;
        endcase
        releaseBus = ACCESS_SUCCESS;
    end 
end 
endmodule


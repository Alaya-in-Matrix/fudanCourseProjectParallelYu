`include "./def.v"
`define MEMWORDS 65536 //65536 word * 2B/word
module memBus(
    input clk,
    input reset,

    //interact with cache A
    input wire[IOSTATEWIDTH-1:0] rwFromCacheA;
    input wire[ADDRWIDTH-1:0]    addrFromCacheA;
    input wire[WORDWIDTH-1:0]    dataFromCacheA;
    output reg[ADDRWIDTH-1:0]    dataToCacheA;
    output reg rdEnToCacheA;
    output reg wbDoneToCacheA;

    //interact with cache B
    input wire[IOSTATEWIDTH-1:0] rwFromCacheB;
    input wire[ADDRWIDTH-1:0]    addrFromCacheB;
    input wire[WORDWIDTH-1:0]    dataFromCacheB;
    output reg[ADDRWIDTH-1:0]    dataToCacheB;
    output reg rdEnToCacheB;
    output reg wbDoneToCacheB;

    output reg[ERRWIDTH-1:0] errReg;
);

reg[IOSTATEWIDTH-1:0]  rwToMem;//if rwtomem is not idel, then it means mem is being accessed
reg[ADDRWIDTH-1:0]     addrToMem;
reg[WORDWIDTH-1:0]     dataToMem;
reg[WORDWIDTH-1:0]     dataFromMem;
reg rdEn,wbDone;
reg[7:0] delay;//128 delay
reg[WORDWIDTH-1:0] mem[0:MEMWORDS-1];

/* always @(reset,rwFromCacheA,rwFromCacheB) begin */ 
always begin 
    if(rdEn ==1 && wbDone = 1) begin 
        rwToMem = IDEL;
    end 
end
always begin
    if(reset) begin 
        rdEn    = 1;
        wbDone  = 1;
        rwToMem = IDEL;
        rdEnToCacheB   = 1;
        wbDoneToCacheB = 1;
        rdEnToCacheA   = 1;
        wbDoneToCacheA = 1;
    end
    else if(rwToMem == IDEL) begin 
        if(rwFromCacheA != IDEL) begin 
            dataToCacheA   = dataFromMem;
            rdEnToCacheA   = rdEn;
            wbDoneToCacheA = wbDone;
            rwToMem        = rwFromCacheA;
            addrToMem      = addrFromCacheA;
            dataToMem      = dataFromCacheA;

            rdEnToCacheB   = 0;
            wbDoneToCacheB = 0;
        end 
        else if(rwFromCacheB != IDEL) begin 
            dataToCacheB   = dataFromMem;
            rdEnToCacheB   = rdEn;
            wbDoneToCacheB = wbDone;
            rwToMem        = rwFromCacheB;
            addrToMem      = addrFromCacheB;
            dataToMem      = dataFromCacheB;

            rdEnToCacheA   = 0;
            wbDoneToCacheA = 0;
        end
        else begin 
            rdEnToCacheA   = 1;
            wbDoneToCacheA = 1;
            rdEnToCacheB   = 1;
            wbDoneToCacheB = 1;
        end 
    end
end
//同一个reg是不是不能够被多个always块赋值
always @(posedge clk) begin 
    if(reset)
        rwToMem = IDEL;
    else if(rwToMem == RD) begin 
        if(delayCounter > 0) begin 
            rdEn    = 0;
            delay   = delay -1;
        end 
        else begin 
            dataFromMem = mem[addrToMem];
            rdEn        = 1;
        end
    end 
    else if(rwToMem == WT) begin 
        if(delayCounter > 0) begin 
            wbDone = 0;
            delay  = delay -1;
        end 
        else begin 
            mem[addrToMem] = dataToMem;
            wbDone         = 1;
        end
    end 
    else if(rwToMem == IDEL) begin 
        wbDone = 1;
        rdEn   = 1;
        delay  = 100;
    end
end
endmodule

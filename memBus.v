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

always @(reset,rwFromCacheA,rwFromCacheB) begin 
    if(!reset && rwToMem == IDEL) begin 
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
            rdEnToCacheA   = 0;
            wbDoneToCacheA = 0;
            rdEnToCacheB   = 0;
            wbDoneToCacheB = 0;
        end 
    end
end
always @(posedge clk) begin 
    if(reset)
        rwToMem = IDEL;
    else if(rwToMem == RD) begin 
        if(delayCounter > 0) begin 
            wbDone  = 0;
            rdEn    = 0;
            delay   = delay -1;
        end 
        else begin 
            dataFromMem = mem[addrToMem];
            rdEn        = 1;
            rwToMem     = IDEL;
        end
    end 
    else if(rwToMem == WT) begin 
        if(delayCounter > 0) begin 
            wbDone = 0;
            rdEn   = 0;
            delay  = delay -1;
        end 
        else begin 
            mem[addrToMem] = dataToMem;
            wbDone         = 1;
            rwToMem        = IDEL;
        end
    end 
    else if(rwToMem == IDEL) begin 
        wbDone = 0;
        rdEn   = 0;
        delay  = 100;
    end
end
endmodule

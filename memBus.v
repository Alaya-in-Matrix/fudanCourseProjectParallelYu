`include "./def.v"
module memBus(
    input clk,
    input reset,

    //interact with cache A
    input wire[`IOSTATEWIDTH-1:0] rwFromCacheA,
    input wire[`ADDRWIDTH-1:0]    addrFromCacheA,
    input wire[`WORDWIDTH-1:0]    dataFromCacheA,
    output reg[`ADDRWIDTH-1:0]    dataToCacheA,
    output reg memEnA,

    //interact with cache B
    input wire[`IOSTATEWIDTH-1:0] rwFromCacheB,
    input wire[`ADDRWIDTH-1:0]    addrFromCacheB,
    input wire[`WORDWIDTH-1:0]    dataFromCacheB,
    output reg[`ADDRWIDTH-1:0]    dataToCacheB,
    output reg memEnB,
    output reg[`ERRWIDTH-1:0] errReg,

    //debug output 
    output[`IOSTATEWIDTH-1:0] debugRwToMem,
    output[7:0] debugDelay
);

reg[`IOSTATEWIDTH-1:0]  rwToMem;//if rwtomem is not idel, then it means mem is being accessed
reg[`ADDRWIDTH-1:0]     addrToMem;
reg[`WORDWIDTH-1:0]     dataToMem;
reg[7:0] delay;//128 delay
reg[`WORDWIDTH-1:0] mem[0:`MEMWORDS-1];

parameter MEMDELAY = 5;
parameter CA       = 1'b0;
parameter CB       = 1'b1;
reg chipSelect;
reg prefer;

assign debugRwToMem = rwToMem;
assign debugDelay   = delay;

//似乎目前是个摩尔模型, 不如改成米利模型, 同cache统一起来.
reg stall;
always @(posedge clk) begin 
    if(reset)begin 
        memEnA     = 0;
        memEnB     = 0;
        rwToMem    = `IDEL;
        delay      = MEMDELAY;
        mem[0]     = 0;
        mem[1]     = 0;
        mem[2]     = 0;
        mem[3]     = 0;
        prefer     = CA; //默认cache的优先级较高
        stall = 0;
    end
    else begin 
        if(rwToMem == `IDEL) begin 
            if(stall > 0) begin 
                rwToMem = `IDEL;
                stall   = 0;
            end
            else begin 
                memEnA = 0;
                memEnB = 0;
                if(prefer == CA) begin
                    if(rwFromCacheA != `IDEL) begin 
                        chipSelect     = CA;
                        rwToMem        = rwFromCacheA;
                        addrToMem      = addrFromCacheA;
                        dataToMem      = dataFromCacheA;
                    end
                    else if(rwFromCacheB != `IDEL) begin 
                        chipSelect     = CB;
                        rwToMem        = rwFromCacheB;
                        addrToMem      = addrFromCacheB;
                        dataToMem      = dataFromCacheB;
                    end
                    else begin 
                        rwToMem = `IDEL;
                    end
                end
                else begin //prefer is CB
                    if(rwFromCacheB != `IDEL) begin 
                        chipSelect     = CB;
                        rwToMem        = rwFromCacheB;
                        addrToMem      = addrFromCacheB;
                        dataToMem      = dataFromCacheB;
                    end
                    else if(rwFromCacheA != `IDEL) begin 
                        chipSelect     = CA;
                        rwToMem        = rwFromCacheA;
                        addrToMem      = addrFromCacheA;
                        dataToMem      = dataFromCacheA;
                    end
                    else begin 
                        rwToMem = `IDEL;
                    end
                end
            end
        end
        else if(rwToMem ==`RD) begin 
            if(delay == 0) begin 
                rwToMem = `IDEL;
                stall   = 1;
                delay   = MEMDELAY;
                if(chipSelect == CA) begin 
                    dataToCacheA = mem[addrToMem];
                    memEnA       = 1;
                    memEnB       = 0;
                    prefer       = CB;
                end
                else begin 
                    dataToCacheB = mem[addrToMem];
                    memEnB       = 1;
                    memEnA       = 0;
                    prefer       = CA;
                end
            end
            else begin 
                delay = delay -1;
            end
        end 
        else if(rwToMem == `WT) begin 
            if(delay == 0) begin 
                rwToMem = `IDEL;
                stall   = 1;
                delay   = MEMDELAY;
                mem[addrToMem] = dataToMem;
                if(chipSelect == CA) begin
                    memEnA = 1;
                    memEnB = 0;
                    prefer = CB;
                end
                else begin
                    memEnB = 1;
                    memEnA = 0;
                    prefer = CA;
                end
            end 
            else begin 
                delay = delay -1;
            end
        end
        else begin 
        end
    end
end
endmodule

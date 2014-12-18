`define global_def.v

//cache, interact with bus and cpu
module cache(
    clk,reset,errFromBus,errToCpu,busAvailable,releaseBus,
    cpuRW,cpuAddr,cpuDataIn,cpuDataOut,cpuSuccess,
    snoopInActionC,snoopInAddrC,snoopInValueC,
    snoopOutActionC,snoopOutAddrC,snoopOutValueC,
    snoopInActionM,snoopInAddrM,snoopInValueM,
    snoopOutActionM,snoopOutAddrM,snoopOutValueM);

input clk,reset,busAvailable;
output releaseBus;
//error handling
input wire[ERRWIDTH-1:0] errFromBus;
output reg[ERRWIDTH-1:0] errToCpu;
//interact with cpu
input cpuRW;
input wire[ADDRESSBIT-1:0] cpuAddr;
input wire[WORDSIZE-1:0]   cpuDataIn;
output reg[WORDSIZE-1:0]   cpuDataOut;
output reg                 cpuSuccess;   //tell cpu whether it need to stall


//interact with bus
input wire[3:0] snoopInActionC;
input wire[3:0] snoopInActionM;
output reg[3:0] snoopOutActionC;
output reg[3:0] snoopOutActionM;
input wire[BLOCKADDRBIT-1:0] snoopInAddrC;
output reg[BLOCKADDRBIT-1:0] snoopOutAddrC;
input wire[BLOCKADDRBIT-1:0] snoopInAddrM;
output reg[BLOCKADDRBIT-1:0] snoopOutAddrM;
input wire[BLOCKBYTE*WORDSIZE-1:0] snoopInValueC;
input wire[BLOCKBYTE*WORDSIZE-1:0] snoopInValueM;
output reg[BLOCKBYTE*WORDSIZE-1:0] snoopOutValueC;
output reg[BLOCKBYTE*WORDSIZE-1:0] snoopOutValueM;

//simple direct map cache  
reg[STATUSWIDTH:0] status[CACHELINENUM-1:0];
reg[STATUSWIDTH:0] statusAfterIO[CACHELINENUM-1:0];
reg[BLOCKADDRBIT-1:0]       blockAddr[CACHELINENUM-1:0];
reg[BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];

wire cpuBlockAddr = cpuAddr[(ADDRESSBIT-1)-:BLOCKADDRBIT];
wire offset       = cpuAddr[0+:OFFSETADDRBIT];

wire cBusIdx = snoopInAddrC % CACHELINENUM;
wire cpuIdx  = cpuBlockAddr % CACHELINENUM;
wire mBusIdx = snoopInActionM % CACHELINENUM;

wire [1:0] hitmiss;
assign hitmiss[1] = (cpuRW == RD ? 1'b0 : 1'b1);
assign hitmiss[0] = (cpuBlockAddr == blockAddr[cpuIdx] ? 1'b0 : 1'b1);

integer i;

always @(posedge) begin 
    if(reset) begin 
        //TODO  reset 
    end 
    else begin 
        for(i = 0; i < CACHELINENUM; i++) begin 
            case(status[i])
                RD_STALLING: 
                    if(busAvailable) begin //IO has finished
                        status[i] = statusAfterIO[i];
                        cacheLine[i] = snoopInValue;
                    end 
                    else 
                        status[i] = status[i];
                    end
        end 
    end 
end 
endmodule

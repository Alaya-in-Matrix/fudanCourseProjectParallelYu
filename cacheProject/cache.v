`include global_def.v
module cache(clk,
             cpuRW, cpuAddr, cpuDataIn, cpuDataOut,cpuSuccess,
             memRW,memAddr,memDataOut,memDataIn,memSuccess,
             snoopInAction,snoopInProc,snoopInAddr,snoopInValue,
             snoopOutAction,snoopOutProc,snoopOutAddr,snoopOutValue);
//clock
input clk;

//interact with cpu
input cpuRW;
input [ADDRESSBIT-1:0]   cpuAddr;
input [WORDSIZE-1:0]     cpuDataIn;
output reg[WORDSIZE-1:0] cpuDataOut;
output reg cpuSuccess;

//memory access
output reg memRW;
output reg [ADDRESSBIT-1:0] memAddr;
output reg [WORDSIZE*BLOCKBYTE-1:0] memDataOut;
input [WORDSIZE*BLOCKBYTE-1:0] memDataIn;
input memSuccess;

input [3:0] snoopInAction;
input snoopInProc;
input [ADDRESSBIT-1:0] snoopInAddr;
input [WORDSIZE-1:0] snoopInValue;

output reg[3:0] snoopOutAction;
output reg snoopOutProc;
output reg[ADDRESSBIT-1:0] snoopOutAction;
output reg[WORDSIZE-1:0] SnoopOutValue;

//simple direct map cache
reg[ADDRESSBIT-1:0] blockAddr[CACHELINENUM-1:0];
reg[1:0] status[CACHELINENUM-1:0];
reg[BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];

always @(posedge clk)
begin
    //是不是可以试一下生成块呢
    //大键似乎还是有一点肉, 不过比ikbc要好一点.
    for(i=0; i<CACHELINENUM; i=i+1)
    begin
        case (status[i])
            MODIFIED:
                $display(1);
            SHARED:
                $display(1);
            INVALID:
                $display(1);
            default:
                $display("error cache line status");
        endcase
    end
end
endmodule

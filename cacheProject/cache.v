`include global_def.v
module cache(clk,
             cpuRW, cpuAddr, cpuDataIn, cpuDataOut,cpuSuccess,
             memRW,memAddr,memDataOut,memDataIn,memNotBusy,
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
input memNotBusy;

input [3:0] snoopInAction;
input [ADDRESSBIT-1:0] snoopInAddr;
input [WORDSIZE-1:0] snoopInValue;

output reg[3:0] snoopOutAction;
output reg[ADDRESSBIT-1:0] snoopOutAction;
output reg[WORDSIZE-1:0] SnoopOutValue;

//simple direct map cache
reg[ADDRESSBIT-1:0] cacheLineBlockAddr[CACHELINENUM-1:0];
reg[1:0] status[CACHELINENUM-1:0];
reg[BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];

wire[BLOCKADDRBIT-1:0] blockAddr       = cpuAddr[(ADDRESSBIT-1)-:BLOCKADDRBIT];
wire[OFFSETADDRBIT-1:0] offsetAddr     = cpuAddr[0+:OFFSETADDRBIT];
wire[CACHELINEIDXBIT-1:0] cacheLineIdx = blockAddr % CACHELINENUM;

wire [1:0] hitmiss;
assign hitmiss[1] = (cpuRW == RD) ? 0 : 1;
assign hitmiss[0] = (blockAddr == cacheLineBlockAddr[cacheLineIdx]) ? 0 : 1;

always @(posedge clk)
begin
    case(status[cacheLineIdx])
        MODIFIED:
            case (hitmiss)
                READHIT:
                    cpuDataOut = cacheLine[cacheLineIdx][offset];
                WRITEHIT:
                    //TODO: 这个只会有one bit!
                    cacheLineIdx[cacheLineIdx][offset] = cpuDataIn;
                READMISS:
                begin
                    status[cacheLineIdx] = SHARED;
                    snoopOutAction = MSG_READMISS;
                    snoopOutAddr = blockAddr;
                end
                WRITEMISS:
                begin
                    if(memNotBusy)
                    begin
                        //write back memory
                    end
                    snoopOutAction = MSG_WRITEMISS;
                end
        SHARED:
        INVALID:
        default:
    endcase
end
endmodule

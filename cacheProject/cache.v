`include global_def.v
module cache(clk,
             cpuRW, cpuAddr, cpuDataIn, cpuDataOut,cpuSuccess,
             memRW,memAddr,memDataOut,memDataIn,memSuccess,
             snoopIn,snoopOut);
//clock
input clk;

//interact with cpu
input cpuRW;
input [ADDRESSBIT-1:0]   cpuAddr;
input [WORDSIZE-1:0]     cpuDataIn;
output reg[WORDSIZE-1:0] cpuDataOut;
output reg cpuSuccess;

//memory access
output memRW;
output [ADDRESSBIT-1:0] memAddr;
output reg [WORDSIZE*BLOCKBYTE-1:0] memDataOut;
input reg [WORDSIZE*BLOCKBYTE-1:0] memDataIn;
input memSuccess;

input [SNOOPMSGWIDTH-1:0] snoopIn;
output reg [SNOOPMSGWIDTH-1:0] snoopOut;

//simple direct map cache

reg[ADDRESSBIT-1:0] blockAddr[CACHELINENUM-1:0];
reg[1:0] status[CACHELINENUM-1:0];
reg[BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];

always @(posedge clk)
begin
end
endmodule

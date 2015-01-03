`define ADDRWIDTH 16
`define WORDWIDTH 16
//`define BLOCKSIZE 8

//需不需要为已经broad cast而其他cache还没有完成写回单独设置一个状态?
//各种状态的WM_RD与RM_RD(inv,shared)似乎可以合并.
`define STATEWIDTH 4
`define ERROR      4'h0     //(done)
`define MODIFIED   4'h1     //(done)
`define M_SRM_WB   4'h2     //modified, snooped read miss,writing back
`define M_SWM_WB   4'h3     //modified, snooped write miss, writing back
`define M_WM_WB    4'h4     //modified, cpu write miss, writing back
`define M_RM_WB    4'h5     //modified, cpu read miss, writing back
`define M_WM_RD    4'h6     //modified, cpu write miss, finished writing back, other cache has write back its copy, reading
`define M_RM_RD    4'h7     //modified, cpu read miss, finished writing back, other cache has write back its copy, reading
`define SHARED     4'h8     //shared.
`define S_RM_RD    4'h9     //shared, cpu read miss, other cache has write back its copy,reading
`define S_WM_RD    4'ha   //shared, cpu write miss, other cache has wrtie back its copy,reading
`define INVALID    4'hb   //INVALID
`define I_RM_RD    4'hc    //invalid, cpu read miss, other cache has write back its copy,reading
`define I_WM_RD    4'hd    //invalid, cpu write miss, other cache has write back its copy, reaading

`define IOSTATEWIDTH 2
`define RD   2'd0
`define WT   2'd1
`define IDEL 2'd2


`define ERRWIDTH          4
`define ERR_UNKNOWN       4'd0
`define ERR_ADDR_MISMATCH 4'd1
`define ERR_MEMRW         4'd2
`define NOERR             4'd3
`define ERR_CPUOP         4'd4


`define INSWIDTH 24 //(4+4+16)
`define OPWIDTH 4 //we have 5 operations(ld,st,nop,end,set)
`define REGWIDTH 4 //one bit to specify register
`define RESTINSWIDTH 16
`define R0 4'd0
`define R1 4'd1
`define REGNUM 4 //two register
`define PCWIDTH 8
`define NOP  4'd0
`define LD   4'd1
`define ST   4'd2
`define SET  4'd3
`define GET  4'd4


`define CPUSTATENUM 3
`define CPUSTATENUMWIDTH 2
`define FETCH 2'd0
`define EXE   2'd1
`define MEM   2'd2
`define ERR   2'd3


`define MEMWORDS 32 //32 word * 2B/word
module top(
    input clk,
    input reset,
    input ins_code2_proc2,
    input ins_code1_proc1,
    output pc_proc1_code1,
    output pc_proc2_code2
);
wire[`PCWIDTH-1:0]      pc_proc1_code1,pc_proc2_code2;
wire[`INSWIDTH-1:0]     ins_code1_proc1,ins_code2_proc2;
wire[`WORDWIDTH-1:0]    dataOut1,dataOut2;
wire[`IOSTATEWIDTH-1:0] rw_P1_C1,rw_P2_C2;

wire                  en_C1_P1,en_C2_P2;
wire [`ADDRWIDTH-1:0] addr_P1_C1,addr_P2_C2;
wire [`WORDWIDTH-1:0] data_P1_C1,data_P2_C2;
wire [`WORDWIDTH-1:0] data_C1_P1,data_C2_P2;

wire[`WORDWIDTH-1:0]data_M_C1,data_M_C2;
wire en_M_C1,en_M_C2;
wire[`IOSTATEWIDTH-1:0]rw_C1_M,rw_C2_M;
wire[`ADDRWIDTH-1:0] addr_C1_M,addr_C2_M;
wire[`WORDWIDTH-1:0] data_C1_M,data_C2_M;
wire msg_C2_C1,msg_C1_C2;
wire allowRead_C2_C1,allowRead_C1_C2;
wire [`ADDRWIDTH-1:0] allowReadAddr_C1_C2,allowReadAddr_C2_C1;
wire[`ADDRWIDTH-1:0] addr_C2_C1,addr_C1_C2;
wire rm_C2_C1,rm_C1_C2,wm_C2_C1,wm_C1_C2,inv_C1_C2,inv_C2_C1;

//debug vars
wire[`CPUSTATENUMWIDTH-1:0] stateP1,stateP2;
wire[`WORDWIDTH-1:0]r0P1,r0P2,r1P1,r1P2;
wire[`REGWIDTH-1:0] regIdxP1,regIdxP2;
/* codeRam code1( */
/*     .pc(pc_proc1_code1), */
/*     .ins(ins_code1_proc1) */
/* ); */
/* codeRam code2( */
/*     .pc(pc_proc2_code2), */
/*     .ins(ins_code2_proc2) */
/* ); */

processor P1(
    .clk(clk),
    .reset(reset),

    .instruction(ins_code1_proc1),
    .data(dataOut1),
    .pcCounter(pc_proc1_code1),

    .rwToMem(rw_P1_C1),
    .addrToMem(addr_P1_C1),
    .dataToMem(data_P1_C1),
    .cacheEn(en_C1_P1),
    .dataFromMem(data_C1_P1),
    .cpuState(stateP1),
    .r0(r0P1),
    .r1(r1P1),
    .regId(regIdxP1)
);
processor P2(
    .clk(clk),
    .reset(reset),

    .instruction(ins_code2_proc2),
    .data(dataOut2),
    .pcCounter(pc_proc2_code2),

    .rwToMem(rw_P2_C2),
    .addrToMem(addr_P2_C2),
    .dataToMem(data_P2_C2),
    .cacheEn(en_C2_P2),
    .dataFromMem(data_C2_P2),
    .cpuState(stateP2),
    .r0(r0P2),
    .r1(r1P2),
    .regId(regIdxP2)
);
wire [`STATEWIDTH-1:0] debugStateC1,debugStateC2;
wire [`WORDWIDTH-1:0] debugCacheLineC1,debugCacheLineC2;
cache C1(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P1_C1),
    .addrFromCPU(addr_P1_C1),
    .dataFromCPU(data_P1_C1),
    .cacheEnToCPU(en_C1_P1),
    .dataToCPU(data_C1_P1),

    .dataFromMem(data_M_C1),
    .memEn(en_M_C1),
    .rwToMem(rw_C1_M),
    .addrToMem(addr_C1_M),
    .dataToMem(data_C1_M),

    .havMsgFromCache(msg_C2_C1),
    .allowReadFromCache(allowRead_C2_C1),
    .allowReadFromCacheAddr(allowReadAddr_C2_C1),
    .addrFromCache(addr_C2_C1),
    .rmFromCache(rm_C2_C1),
    .wmFromCache(wm_C2_C1),
    .invFromCache(inv_C2_C1),
    .havMsgToCache(msg_C1_C2),
    .allowReadToCache(allowRead_C1_C2),
    .allowReadToCacheAddr(allowReadAddr_C1_C2),
    .addrToCache(addr_C1_C2),
    .rmToCache(rm_C1_C2),
    .wmToCache(wm_C1_C2),
    .invToCache(inv_C1_C2),

    //debug ms
    .debugState(debugStateC1),
    .debugCacheLine(debugCacheLineC1)
);
cache C2(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P2_C2),
    .addrFromCPU(addr_P2_C2),
    .dataFromCPU(data_P2_C2),
    .cacheEnToCPU(en_C2_P2),
    .dataToCPU(data_C2_P2),

    .dataFromMem(data_M_C2),
    .memEn(en_M_C2),
    .rwToMem(rw_C2_M),
    .addrToMem(addr_C2_M),
    .dataToMem(data_C2_M),

    .havMsgFromCache(msg_C1_C2),
    .allowReadFromCache(allowRead_C1_C2),
    .allowReadFromCacheAddr(allowReadAddr_C1_C2),
    .addrFromCache(addr_C1_C2),
    .rmFromCache(rm_C1_C2),
    .wmFromCache(wm_C1_C2),
    .invFromCache(inv_C1_C2),
    .havMsgToCache(msg_C2_C1),
    .allowReadToCache(allowRead_C2_C1),
    .allowReadToCacheAddr(allowReadAddr_C2_C1),
    .addrToCache(addr_C2_C1),
    .rmToCache(rm_C2_C1),
    .wmToCache(wm_C2_C1),
    .invToCache(inv_C2_C1),

    //debug ms
    .debugState(debugStateC2),
    .debugCacheLine(debugCacheLineC2)
);
wire[`IOSTATEWIDTH-1:0] debugRwToMem;
wire[7:0] debugDelay;
memBus mb(
    .clk(clk),
    .reset(reset),

    .rwFromCacheA(rw_C1_M),
    .addrFromCacheA(addr_C1_M),
    .dataFromCacheA(data_C1_M),
    .dataToCacheA(data_M_C1),
    .memEnA(en_M_C1),

    .rwFromCacheB(rw_C2_M),
    .addrFromCacheB(addr_C2_M),
    .dataFromCacheB(data_C2_M),
    .dataToCacheB(data_M_C2),
    .memEnB(en_M_C2),

    //debug output 
    .debugRwToMem(debugRwToMem),
    .debugDelay(debugDelay)
);
endmodule

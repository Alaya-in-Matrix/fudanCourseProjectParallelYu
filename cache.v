`define ADDRWIDTH 16
`define WORDWIDTH 16

`define STATEWIDTH 4
`define ERROR      4'd0 //(done)
`define MODIFIED   4'd1 //(done)
`define M_SRM_WB   4'd2 //modified, snooped read miss,writing back
`define M_SWM_WB   4'd3 //modified, snooped write miss, writing back
`define M_WM_WB    4'd4 //modified, cpu write miss, writing back
`define M_RM_WB    4'd5 
`define M_WM_RD    4'd6 //modified, cpu write miss, finished writing back, need to read
`define M_RM_RD    4'd7
`define SHARED     4'd8
`define S_SWM_INV  4'd9 //shared, snooped write miss, invalidate
`define S_SINV_INV 4'd10 //shared, snooped invalidate, invalidate
`define S_RM_RD    4'd11 //shared, cpu read miss, reading mem
`define S_WM_RD    4'd12 //shared, cpu write miss, need to read
`define INVALID    4'd13
`define I_RM_RD    4'd14 //invalid, cpu read miss, read mem
`define I_WM_RD    4'd15 //invalid, cpu write miss, read mem

`define IOSTATEWIDTH 2
`define RD   2'd0
`define WT   2'd1
`define IDEL 2'd2


`define ERRWIDTH     4
`define ERR_UNKNOWN 4'd0;

//只有allowRead才能进入需要read的状态.
//也许write enable没什么用?
//非error/m/s/i的状态, 只能有一个出口.
module cache(
    input clk,
    input reset,

    //input from cpu
    input[IOSTATEWIDTH-1:0] rwFromCPU,
    input[ADDRWIDTH-1:0]    addrFromCPU,
    input[WORDWIDTH-1:0]    dataFromCPU,
    //input from mem bus
    input[ADDRWIDTH-1:0]    addrFromMem,
    input[WORDWIDTH-1:0]    dataFromMem,
    input readEnFromMem, //readEnable, finished reading
    input writeDoneFromMem,//writeEnable,
    //input from the other cache
    input havMsgFromCache,
    input allowReadFromCache
    input[ADDRWIDTH-1:0]    addrFromCache,
    input rmFromCache,
    input wmFromCache,
    input invFromCache,

    //output to cpu
    output reg readEnToCPU,
    output reg writeDoneToCPU,
    output [WORDWIDTH-1:0] dataToCPU,
    //output to mem  
    output reg[IOSTATEWIDTH-1:0] rwToMem,
    output reg[ADDRWIDTH-1:0] addrToMem,
    output reg[WORDWIDTH-1:0] dataToMem,
    //output to the other cache 
    output reg havMsgToCache,
    output reg allowReadToCache,
    output reg[ADDRWIDTH-1:0] addrToCache,
    output reg rmToCache,
    output reg wmToCache,
    output reg invToCache
);

reg [STATEWIDTH-1:0] state,nextState;
reg [ADDRWIDTH-1:0] addr;
reg [WORDWIDTH-1:0] cacheLine;

reg [ERRWIDTH-1:0] errReg; //register to store err id


wire rh       = (state != INVALID) && (rwFromCPU == RD) && (addrFromCPU == addr);
wire rm       = (state == INVALID) || ((rwFromCPU == RD) && (addrFromCPU != addr));
wire wh       = (state != INVALID) && (rwFromCPU == WT) && (addrFromCPU == addr);
wire wm       = (state == INVALID) || ((rwFromCPU == WT) && (addrFromCPU != addr));
wire idel     = (rwFromCPU == IDEL);

wire snoopRm  = (addrFromCache == addr) && rmFromCache;
wire snoopWM  = (addrFromCache == addr) && wmFromCache;
wire snoopInv = (addrFromCache == addr) && invFromCache;

reg allowRead;

always @(allowReadFromCache) begin
    //应该保证 allowreadfromcache
    //和 allowreadtocache 不会同时跳变
    if(allowReadFromCache)
        allowRead = allowReadFromCache;
end

always @(reset,rwFromCPU,addrFromCache,dataFromCPU,addrFromMem,dataFromMem,readEnFromMem,writeEnFromMem,allowReadFromCache,addrFromCache,rmFromCache,wmFromCache, invFromCache) begin 
    //这样的初始化方式是不是有问题?
    //有些需要保持的量因为无关的输入变化而无法保持?
    readEnToCPU        = 0;
    writeDoneToCPU     = 0;
    rwToMem            = IDEL;
    allowReadFromCache = 0;
    rmToCache          = 0;
    wmToCache          = 0;
    invToCache         = 0;
    havMsgToCache      = 0;
    if(reset) begin 
    end
    else begin 
        case(state) 
            MODIFIED: begin 
                if(snoopRm) begin 
                    rwToMem   = WT;
                    addrToMem = addr;
                    dataToMem = cacheLine;
                    nextState = M_SRM_WB;
                end 
                else if(snoopWM) begin
                    rwToMem   = WT;
                    addrToMem = addr;
                    dataToMem = cacheLine;
                    nextState = M_SWM_WB;
                end
                else if(rh) begin 
                    readEnToCPU = 1;
                    dataToCPU   = cacheLine;
                    nextState   = MODIFIED;
                end 
                else if(wh) begin 
                    cacheLine      = dataFromCPU;
                    writeDoneToCPU = 1;
                    nextState      = MODIFIED;
                end 
                else if(rm) begin 
                    //mem,bus,state
                    memRW         = WT;
                    addrToMem     = addr;
                    dataToMem     = cacheLine
                    havMsgToCache = 1;
                    rmToCache     = 1;
                    addrToCache   = addr;
                    nextState     = M_RM_WB;
                end 
                else if(wm) begin 
                    memRW         = WT;
                    addrToMem     = addr;
                    dataToMem     = cacheLine;
                    havMsgToCache = 1;
                    wmToCache     = 1;
                    addrToMem     = addr;
                    nextState     = M_WM_WB;
                end 
                else if(idel) begin 
                    nextState = MODIFIED;
                end 
                else begin 
                    errReg    = ERR_UNKNOWN;
                    nextState = ERROR;
                end
            end
            M_SRM_WB: begin 
                if(writeDoneFromMem) begin 
                    nextState        = SHARED;
                    allowReadToCache = 1;
                end
                else begin 
                    nextState = M_SRM_WB;
                end
            end
            M_SWM_WB: begin 
                if(writeDoneFromMem) begin 
                    nextState        = INVALID;
                    allowReadToCache = 1;
                end
                else begin 
                    nextState = M_SWM_WB;
                end
            end
            M_WM_WB: begin 
                if(writeDoneFromMem) begin 
                    //mem,data,cpu,bus
                    if(allowReadFromCache)
                        rwToMem   = RD;
                        addrToMem = addrFromCPU;
                        nextState = M_WM_RD;
                    else 
                        nextState = M_WM_WB;
                end
                else begin 
                    nextState = M_WM_WB;
                end
            end
            M_RM_WB:begin 
                if(writeDoneFromMem) begin 
                    if(allowReadFromCache) 
                        rwToMem   = RD;
                        addrToMem = addrFromCPU;
                        nextState = M_RM_RD;
                    else
                        nextState = M_RM_WB;
                end 
                else  nextState = M_RM_WB; 
            end
            M_WM_RD: begin 
                if(readEnFromMem) begin //read enable
                    rwToMem   = IDEL;
                    cacheLine = dataFromMem;
                    addr      = addrFromMem;
                    cacheLine = dataFromCPU;
                    nextState = MODIFIED;
                end
                else nextState = M_WM_RD;
            end
            M_RM_RD: begin 
                if(readEnFromMem) begin //read enable
                    rwToMem   = IDEL;
                    cacheLine = dataFromMem;
                    addr      = addrFromMem;
                    nextState = SHARED;
                end
                else nextState = M_RM_RD;
            end 
            SHARED:begin 
                if(snoopRm) begin 
                    nextState = SHARED;
                end 
                else if(snoopWM) begin
                    nextState = INVALID;
                end
                else if(rh) begin 
                    readEnToCPU = 1;
                    dataToCPU   = cacheLine;
                    nextState   = MODIFIED;
                end 
                else if(wh) begin 
                    cacheLine      = dataFromCPU;
                    writeDoneToCPU = 1;
                    nextState      = MODIFIED;
                end 
                else if(rm) begin 
                    //mem,bus,state
                    memRW         = WT;
                    addrToMem     = addr;
                    dataToMem     = cacheLine
                    havMsgToCache = 1;
                    rmToCache     = 1;
                    addrToCache   = addr;
                    nextState     = S_RM_RD;
                end 
                else if(wm) begin 
                    memRW         = WT;
                    addrToMem     = addr;
                    dataToMem     = cacheLine;
                    havMsgToCache = 1;
                    wmToCache     = 1;
                    addrToMem     = addr;
                    nextState     = S_WM_RD;
                end 
                else if(idel) begin 
                    nextState = SHARED;
                end 
                else begin 
                    errReg    = ERR_UNKNOWN;
                    nextState = ERROR;
                end
            end
            default: 
                nextState = ERROR;
                /* `define ERROR      4'd0 //(done) */
                /* `define MODIFIED   4'd1 //(done) */
                /* `define M_SRM_WB   4'd2 (done)
                /* `define M_SWM_WB   4'd3 (done)
                /* `define M_WM_WB    4'd4 (done)
                /* `define M_RM_WB    4'd5 (done)
                /* `define M_WM_RD    4'd6 (done)
                /* `define M_RM_RD    4'd7 (done)
                /* `define SHARED     4'd8 
                /* `define S_SWM_INV  4'd9 
                /* `define S_SINV_INV 4'd10 //shared, snooped invalidate, invalidate */
                /* `define S_RM_RD    4'd11 //shared, cpu read miss, reading mem */
                /* `define S_WM_RD    4'd12 //shared, cpu write miss, need to read */
                /* `define INVALID    4'd13 */
                /* `define I_RM_RD    4'd14 //invalid, cpu read miss, read mem */
                /* `define I_WM_RD    4'd15 //invalid, cpu write miss, read mem */
        endcase
    end
end


//时序逻辑
always @(posedge clk) begin 
    state <= nextState;
end


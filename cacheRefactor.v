//只有allowRead才能进入需要read的状态.
//也许write enable没什么用?
//非error/m/s/i的状态, 只能有一个出口.
`include "./def.v"
module cache(
    input clk,
    input reset,

    input[`IOSTATEWIDTH-1:0] rwFromCPU,
    input[`ADDRWIDTH-1:0]    addrFromCPU,
    input[`WORDWIDTH-1:0]    dataFromCPU,
    input[`WORDWIDTH-1:0]    dataFromMem,
    input                 memEn,
    input                 havMsgFromCache,
    input                 allowReadFromCache,
    input                 rmFromCache,
    input                 wmFromCache,
    input                 invFromCache,
    input[`ADDRWIDTH-1:0] allowReadFromCacheAddr,
    input[`ADDRWIDTH-1:0] addrFromCache,
    output reg                    cacheEnToCPU,
    output reg[`WORDWIDTH-1:0]    dataToCPU,
    output reg[`IOSTATEWIDTH-1:0] rwToMem,
    output reg[`ADDRWIDTH-1:0]    addrToMem,
    output reg[`WORDWIDTH-1:0]    dataToMem,
    output reg havMsgToCache,
    output reg allowReadToCache,
    output reg[`ADDRWIDTH-1:0] allowReadToCacheAddr,
    output reg[`ADDRWIDTH-1:0] addrToCache,
    output reg rmToCache,
    output reg wmToCache,
    output reg invToCache,

    //debug msg
    output [`STATEWIDTH-1:0] debugState,
    output [`WORDWIDTH-1:0] debugCacheLine
);

reg [`STATEWIDTH-1:0] state;
reg [`ADDRWIDTH-1:0]  addr;
reg [`WORDWIDTH-1:0]  cacheLine;
reg [`ERRWIDTH-1:0]   errReg; //register to store err id


wire isInvalid = (state == `INVALID) || (state == `I_RM_RD) || (state == `I_WM_RD);
wire idel      = (rwFromCPU == `IDEL);
wire rm        = (rwFromCPU == `RD  ) && (isInvalid  || addrFromCPU != addr);
wire rh        = (rwFromCPU == `RD  ) && (!isInvalid && addrFromCPU == addr);
wire wm        = (rwFromCPU == `WT  ) && (isInvalid  || addrFromCPU != addr);
wire wh        = (rwFromCPU == `WT  ) && (!isInvalid && addrFromCPU == addr);
wire snoopRm   = (addrFromCache == addr) && rmFromCache;
wire snoopWm   = (addrFromCache == addr) && wmFromCache;
wire snoopInv  = (addrFromCache == addr) && invFromCache;

//debug msg
//TODO: remove debug state
assign debugState     = state;
assign debugCacheLine = cacheLine;

reg stall;
always @(posedge clk) begin
    if(reset) begin 
        cacheEnToCPU     = 0;
        rwToMem          = `IDEL;
        havMsgToCache    = 0;
        allowReadToCache = 1; //也许这句不能有?
        rmToCache        = 0;
        wmToCache        = 0;
        invToCache       = 0;
        state            = `INVALID;
        cacheLine        = 0;
        stall            = 0;
        addr             = 0;
    end
    else begin 
        case(state) 
            `MODIFIED: begin 
                if(snoopRm) begin 
                    //write back this block 
                    //final state change to shared
                    cacheEnToCPU         = 0;
                    dataToCPU            = 0;
                    rwToMem              = `WT;
                    addrToMem            = addr;
                    dataToMem            = cacheLine;
                    havMsgToCache        = 0;
                    allowReadToCache     = 0;
                    allowReadToCacheAddr = addr;
                    rmToCache            = 0;
                    wmToCache            = 0;
                    invToCache           = 0;
                    stall                = 0;
                    state                = `M_SRM_WB;
                end 
                else if(snoopWm) begin
                    //write back, final state change to INVALID
                    cacheEnToCPU         = 0;
                    dataToCPU            = 0;
                    rwToMem              = `WT;
                    addrToMem            = addr;
                    dataToMem            = cacheLine;
                    havMsgToCache        = 0;
                    allowReadToCache     = 0;
                    allowReadToCacheAddr = addr;
                    stall                = 0;
                    state                = `M_SWM_WB;
                end
                else if(rh) begin 
                    cacheEnToCPU         = 1;
                    dataToCPU            = cacheLine;
                    rwToMem              = `IDEL;
                    addrToMem            = 0;
                    dataToMem            = 0;
                    havMsgToCache        = 0;
                    allowReadToCache     = 1;
                    allowReadToCacheAddr = 0;
                    addrToMem            = 0;
                    rmToCache            = 0;
                    wmToCache            = 0;
                    invToCache           = 0;
                    stall                = 0;
                    addr                 = addr;
                    cacheLine            = cacheLine;
                    state                = state;
                end 
                else if(wh) begin 
                    cacheEnToCPU         = 1;
                    dataToCPU            = 0;
                    rwToMem              = `IDEL;
                    addrToMem            = 0;
                    dataToMem            = 0;
                    havMsgToCache        = 0;
                    allowReadToCache     = 0;
                    allowReadToCacheAddr = 0;
                    addrToCache          = 0;
                    rmToCache            = 0;
                    wmToCache            = 0;
                    invToCache           = 0;
                    stall                = 0;
                    state                = state;
                    addr                 = addr;
                    cacheLine            = dataFromCPU;
                end 
                else if(rm) begin 
                    //write back
                    //broadcast read miss
                    //final state change to shared
                    cacheEnToCPU         = 0;
                    dataToCPU            = 0;
                    rwToMem              = `WT;
                    addrToMem            = addr;
                    dataToMem            = cacheLine;
                    havMsgToCache        = 1;
                    allowReadToCache     = 0;
                    allowReadToCacheAddr = addr;
                    addrToCache          = addrFromCPU;
                    rmToCache            = 1;
                    wmToCache            = 0;
                    invToCache           = 0;
                    stall                = 0;
                    state                = `M_RM_WB;
                    addr                 = addr;
                    cacheLine            = dataFromCPU;
                end 
                else if(wm) begin 
                    //write back
                    //broadcast write miss
                    //final state remains modified
                    cacheEnToCPU         = 0;
                    dataToCPU            = 0;
                    rwToMem              = `WT;
                    addrToMem            = addr;
                    dataToMem            = cacheLine;
                    havMsgToCache        = 1;
                    allowReadToCache     = 0;
                    allowReadToCacheAddr = addr;
                    addrToCache          = addrFromCPU;
                    rmToCache            = 0;
                    wmToCache            = 1;
                    invToCache           = 0;
                    stall                = 0;
                    addr                 = addr;
                    cacheLine            = dataFromCPU;
                    state                = `M_WM_WB;
                end 
                else if(idel) begin 
                    //no bus msg and no cpu access
                    cacheEnToCPU         = cacheEnToCPU;
                    dataToCPU            = dataToCPU;
                    rwToMem              = rwToMem;
                    addrToMem            = addrToMem;
                    dataToMem            = dataToMem;
                    havMsgToCache        = havMsgToCache;
                    allowReadToCache     = allowReadToCache;
                    allowReadToCacheAddr = allowReadToCacheAddr;
                    addrToCache          = addrFromCPU;
                    rmToCache            = rmToCache;
                    wmToCache            = wmToCache;
                    invToCache           = invToCache;
                    stall                = stall;
                    addr                 = addr;
                    cacheLine            = cacheLine;
                    state                = state;
                end 
                else begin 
                    //error occurs
                    errReg    = `ERR_UNKNOWN;
                    state = `ERROR;
                end
            end
            `M_SRM_WB: begin 
                if(memEn) begin 
                    rwToMem = `IDEL;
                    if(rwFromCPU == `IDEL) begin 
                        cacheEnToCPU = 1;
                    end
                    else begin 
                        cacheEnToCPU = 0;
                    end
                    allowReadToCache = 1;
                    state            = `SHARED;
                end
                else begin 
                    cacheEnToCPU     = 0;
                    allowReadToCache = 0;
                    state            = `M_SRM_WB;
                end
            end
            `M_SWM_WB: begin 
                if(memEn) begin 
                    rwToMem = `IDEL;
                    if(rwFromCPU == `IDEL) begin
                        cacheEnToCPU = 1;
                    end 
                    else begin 
                        cacheEnToCPU = 0;
                    end
                    state            = `INVALID;
                    allowReadToCache = 1;
                    if(rwFromCPU != `IDEL) begin 
                        stall = 1;
                    end 
                    else begin 
                        stall = 0;
                    end
                end
                else begin 
                    state = `M_SWM_WB;
                end
            end
            `M_WM_WB: begin 
                if(memEn) begin 
                    //mem,data,cpu,bus
                    if(allowReadFromCache || allowReadFromCacheAddr != addrFromCPU) begin
                        rwToMem              = `RD;
                        addrToMem            = addrFromCPU;
                        allowReadToCache     = 0;
                        allowReadToCacheAddr = addrFromCPU;
                        state                = `M_WM_RD;
                    end
                    else 
                        state = `M_WM_WB;
                end
                else begin 
                    state = `M_WM_WB;
                end
            end
            `M_RM_WB:begin 
                if(memEn) begin 
                    if(allowReadFromCache || allowReadToCacheAddr != addrFromCPU) begin
                        rwToMem   = `RD;
                        addrToMem = addrFromCPU;
                        state     = `M_RM_RD;
                    end
                    else
                        state = `M_RM_WB;
                end 
                else  state = `M_RM_WB; 
            end
            `M_WM_RD: begin 
                if(memEn) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        cacheLine     = dataFromMem;
                        addr          = addrToMem;
                        cacheLine     = dataFromCPU;
                        rwToMem       = `IDEL;
                        cacheEnToCPU  = 1;
                        havMsgToCache = 0;
                        wmToCache     = 0;
                        state         = `MODIFIED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else state = `M_WM_RD;
            end
            `M_RM_RD: begin 
                if(memEn) begin //read enable
                    if(addrFromCPU == addrToMem) begin
                        cacheLine        = dataFromMem;
                        addr             = addrToMem;
                        dataToCPU        = cacheLine;
                        rwToMem          = `IDEL;
                        cacheEnToCPU     = 1;
                        allowReadToCache = 1;
                        havMsgToCache    = 0;
                        rmToCache        = 0;
                        state            = `SHARED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else state = `M_RM_RD;
            end 
            `SHARED:begin 
                if(snoopRm) begin 
                    state = `SHARED;
                end 
                else if(snoopWm) begin
                    state = `INVALID;
                end
                else if(snoopInv) begin 
                    state = `INVALID;
                end 
                else if(rh) begin 
                    dataToCPU   = cacheLine;
                    state   = `SHARED;
                end 
                else if(wh) begin 
                    cacheLine    = dataFromCPU;
                    cacheEnToCPU = 1;
                    state        = `MODIFIED;
                end 
                else if(rm) begin 
                    //mem,bus,state
                    havMsgToCache = 1;
                    rmToCache     = 1; //broad cast read miss
                    addrToCache   = addrFromCPU;
                    cacheEnToCPU  = 0;
                    if(allowReadFromCache || allowReadFromCacheAddr != addrFromCPU) begin 
                        rwToMem   = `RD;
                        addrToMem = addrFromCPU;
                        state     = `S_RM_RD;
                    end
                    else begin 
                        state = `SHARED; 
                    end
                end 
                else if(wm) begin 
                    havMsgToCache = 1;
                    wmToCache     = 1;
                    addrToCache   = addrFromCPU;
                    cacheEnToCPU  = 0;
                    
                    if(allowReadFromCache || allowReadToCacheAddr != addrFromCPU) begin 
                        rwToMem              = `RD;
                        addrToMem            = addrFromCPU;
                        state                = `S_WM_RD;
                        allowReadToCache     = 0;
                        allowReadToCacheAddr = addrFromCPU;
                    end 
                    else begin 
                        state = `SHARED; 
                    end
                end 
                else if(idel) begin 
                    havMsgToCache = 0;
                    wmToCache     = 0;
                    rmToCache     = 0;
                    invToCache    = 0;
                    state     = `SHARED;
                end 
                else begin 
                    havMsgToCache = 0;
                    errReg        = `ERR_UNKNOWN;
                    state     = `ERROR;
                end
            end
            `S_RM_RD: begin 
                havMsgToCache = 1;
                rmToCache     = 1;
                if(memEn) begin //read enable
                    if(addrToMem == addrFromCPU) begin 
                        cacheLine     = dataFromMem;
                        addr          = addrToMem;
                        cacheLine     = dataFromCPU;
                        dataToCPU     = cacheLine;
                        rwToMem       = `IDEL;
                        cacheEnToCPU  = 1;
                        havMsgToCache = 0;
                        rmToCache     = 0;
                        state         = `SHARED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else state = `S_RM_RD;
            end
            `S_WM_RD: begin 
                havMsgToCache = 1;
                wmToCache     = 1;
                if(memEn) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        cacheLine     = dataFromMem;
                        addr          = addrToMem;
                        cacheLine     = dataFromCPU;
                        rwToMem       = `IDEL;
                        cacheEnToCPU  = 1;
                        havMsgToCache = 0;
                        rmToCache     = 0;
                        state         = `MODIFIED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else state = `S_WM_RD;
            end
            `INVALID: begin 
                if(rm) begin 
                    //broadcast readmiss
                    havMsgToCache = 1;
                    rmToCache     = 1;
                    addrToCache   = addrFromCPU;
                    cacheEnToCPU  = 0;
                    if(allowReadFromCache || allowReadToCacheAddr != addrFromCPU) begin 
                        if(stall == 0) begin 
                            rwToMem   = `RD;
                            addrToMem = addrFromCPU;
                            state = `I_RM_RD;
                        end
                        else begin 
                            stall = 0;
                            state = `INVALID;
                        end
                    end 
                    else begin 
                        state = `INVALID;
                    end
                end 
                else if(wm) begin 
                    havMsgToCache = 1;
                    addrToCache   = addrFromCPU;
                    wmToCache     = 1;
                    cacheEnToCPU  = 0;
                    if(allowReadFromCache || allowReadFromCacheAddr != addrFromCPU) begin 
                        if(stall == 0) begin
                            rwToMem              = `RD;
                            addrToMem            = addrFromCPU;
                            state            = `I_WM_RD;
                            allowReadToCache     = 0;
                            allowReadToCacheAddr = addrFromCPU;
                        end 
                        else begin 
                            stall     = 0;
                            state = `INVALID;
                        end
                    end 
                    else begin 
                        state = `INVALID;
                    end 
                end 
                else if(idel) begin 
                    havMsgToCache = 0;
                    state     = `INVALID;
                end 
                else begin 
                    state = `ERROR;
                    errReg    = `ERR_UNKNOWN;
                end 
            end
            `I_RM_RD: begin  //equal to I_RM_RD
                havMsgToCache = 1;
                if(memEn) begin //read enable
                    if(addrToMem == addrFromCPU) begin 
                        cacheLine    = dataFromMem;
                        addr         = addrToMem;
                        dataToCPU    = cacheLine;
                        rwToMem      = `IDEL;
                        cacheEnToCPU = 1;
                        rmToCache    = 0;
                        state        = `SHARED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else state = `I_RM_RD;
            end 
            `I_WM_RD: begin 
                if(memEn) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        cacheLine     = dataFromMem;
                        addr          = addrToMem;
                        cacheLine     = dataFromCPU;
                        rwToMem       = `IDEL;
                        cacheEnToCPU  = 1;
                        havMsgToCache = 0;
                        wmToCache     = 0;
                        state         = `MODIFIED;
                    end 
                    else begin 
                        state = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else state = `I_WM_RD;
            end
            default: 
                state = `ERROR;
        endcase
    end
end
endmodule

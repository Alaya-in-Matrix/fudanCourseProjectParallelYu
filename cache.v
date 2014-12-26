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
    input readEnFromMem,                    //readEnable, finished reading
    input writeDoneFromMem,                 //writeEnable,
    input havMsgFromCache,
    input allowReadFromCache,
    input[`ADDRWIDTH-1:0]    addrFromCache,
    input rmFromCache,
    input wmFromCache,
    input invFromCache,
    output reg readEnToCPU,
    output reg writeDoneToCPU,
    output reg[`WORDWIDTH-1:0] dataToCPU,
    output reg[`IOSTATEWIDTH-1:0] rwToMem,
    output reg[`ADDRWIDTH-1:0] addrToMem,
    output reg[`WORDWIDTH-1:0] dataToMem,
    output reg havMsgToCache,
    output reg allowReadToCache,
    output reg[`ADDRWIDTH-1:0] addrToCache,
    output reg rmToCache,
    output reg wmToCache,
    output reg invToCache
);

reg [`STATEWIDTH-1:0] state,nextState;
reg [`ADDRWIDTH-1:0]  addr;
reg [`WORDWIDTH-1:0]  cacheLine;
reg [`ERRWIDTH-1:0]   errReg; //register to store err id


wire rh   = (state != `INVALID) && (rwFromCPU  == `RD) && (addrFromCPU == addr);
wire rm   = (state == `INVALID) || ((rwFromCPU == `RD) && (addrFromCPU != addr));
wire wh   = (state != `INVALID) && (rwFromCPU  == `WT) && (addrFromCPU == addr);
wire wm   = (state == `INVALID) || ((rwFromCPU == `WT) && (addrFromCPU != addr));
wire idel = (rwFromCPU == `IDEL);

wire snoopRm  = (addrFromCache == addr) && rmFromCache;
wire snoopWM  = (addrFromCache == addr) && wmFromCache;
wire snoopInv = (addrFromCache == addr) && invFromCache;

//组合逻辑
always @(reset,
         rwFromCPU,addrFromCache,dataFromCPU,
         dataFromMem,readEnFromMem,writeDoneFromMem,
         havMsgFromCache,addrFromCache,rmFromCache,wmFromCache, invFromCache
     ) begin 
    //这样的初始化方式是不是有问题?
    //有些需要保持的量因为无关的输入变化而无法保持?
    // readEnToCPU      = 0;
    // writeDoneToCPU   = 0;
    rwToMem          = `IDEL;
    havMsgToCache    = 0;
    rmToCache        = 0;
    wmToCache        = 0;
    invToCache       = 0;
    nextState        = state;
    if(reset) begin 
        readEnToCPU      = 1;
        writeDoneToCPU   = 1;
        rwToMem          = `IDEL;
        havMsgToCache    = 0;
        allowReadToCache = 1; //也许这句不能有?
        rmToCache        = 0;
        wmToCache        = 0;
        invToCache       = 0;
        nextState        = INVALID;
    end
    else begin 
        case(state) 
            `MODIFIED: begin 
                if(snoopRm) begin 
                    //write back, final state change to SHARED
                    //应该不需要writeEnable信号吧, 反正本来就是要stall的.
                    rwToMem          = `WT;
                    addrToMem        = addr;
                    readEnToCPU      = 0;
                    writeDoneToCPU   = 0;
                    dataToMem        = cacheLine;
                    allowReadToCache = 0;
                    nextState        = `M_SRM_WB;
                end 
                else if(snoopWM) begin
                    //write back, final state change to INVALID
                    rwToMem          = `WT;
                    allowReadToCache = 0;
                    addrToMem        = addr;
                    readEnToCPU      = 0;
                    writeDoneToCPU   = 0;
                    dataToMem        = cacheLine;
                    nextState        = `M_SWM_WB;
                end
                else if(rh) begin 
                    readEnToCPU    = 1;
                    writeDoneToCPU = 1;
                    dataToCPU      = cacheLine;
                    nextState      = `MODIFIED;
                end 
                else if(wh) begin 
                    cacheLine      = dataFromCPU;
                    readEnToCPU    = 1;
                    writeDoneToCPU = 1;
                    nextState      = `MODIFIED;
                end 
                else if(rm) begin 
                    //write back
                    //broadcast read miss
                    //final state change to shared
                    rwToMem        = `WT;
                    readEnToCPU    = 0;
                    writeDoneToCPU = 0;
                    addrToMem      = addr;

                    dataToMem      = cacheLine;
                    havMsgToCache  = 1;
                    rmToCache      = 1;
                    addrToCache    = addrFromCPU;
                    nextState      = `M_RM_WB;
                end 
                else if(wm) begin 
                    //write back
                    //broadcast write miss
                    //final state remains modified
                    rwToMem        = `WT;
                    readEnToCPU    = 0;
                    writeDoneToCPU = 0;
                    addrToMem      = addr;
                    dataToMem      = cacheLine;
                    havMsgToCache  = 1;
                    wmToCache      = 1;
                    addrToCache    = addrFromCPU;
                    nextState      = `M_WM_WB;
                end 
                else if(idel) begin 
                    //no bus msg and no cpu access
                    nextState = `MODIFIED;
                end 
                else begin 
                    //error occurs
                    errReg    = `ERR_UNKNOWN;
                    nextState = `ERROR;
                end
            end
            `M_SRM_WB: begin 
                if(writeDoneFromMem) begin 
                    writeDoneToCPU   = 1;
                    readEnToCPU      = 1;
                    nextState        = `SHARED;
                    allowReadToCache = 1;
                end
                else begin 
                    nextState = `M_SRM_WB;
                end
            end
            `M_SWM_WB: begin 
                if(writeDoneFromMem) begin 
                    writeDoneToCPU   = 1;
                    readEnToCPU      = 1;
                    nextState        = `INVALID;
                    allowReadToCache = 1;
                end
                else begin 
                    nextState = `M_SWM_WB;
                end
            end
            `M_WM_WB: begin 
                if(writeDoneFromMem) begin 
                    //mem,data,cpu,bus
                    if(allowReadFromCache) begin
                        rwToMem   = `RD;
                        addrToMem = addrFromCPU;
                        nextState = `M_WM_RD;
                    end
                    else 
                        nextState = `M_WM_WB;
                end
                else begin 
                    nextState = `M_WM_WB;
                end
            end
            `M_RM_WB:begin 
                if(writeDoneFromMem) begin 
                    if(allowReadFromCache) begin
                        rwToMem   = `RD;
                        addrToMem = addrFromCPU;
                        nextState = `M_RM_RD;
                    end
                    else
                        nextState = `M_RM_WB;
                end 
                else  nextState = `M_RM_WB; 
            end
            `M_WM_RD: begin 
                if(readEnFromMem) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        cacheLine      = dataFromCPU;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        nextState      = `MODIFIED;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else nextState = `M_WM_RD;
            end
            `M_RM_RD: begin 
                if(readEnFromMem) begin //read enable
                    if(addrFromCPU == addrToMem) begin
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        nextState      = `SHARED;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        dataToCPU      = cacheLine;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else nextState = `M_RM_RD;
            end 
            `SHARED:begin 
                if(snoopRm) begin 
                    nextState = `SHARED;
                end 
                else if(snoopWM) begin
                    nextState = `INVALID;
                end
                else if(snoopInv) begin 
                    nextState = `INVALID;
                end 
                else if(rh) begin 
                    readEnToCPU = 1;
                    dataToCPU   = cacheLine;
                    nextState   = `SHARED;
                end 
                else if(wh) begin 
                    cacheLine      = dataFromCPU;
                    writeDoneToCPU = 1;
                    nextState      = `MODIFIED;
                end 
                else if(rm) begin 
                    //mem,bus,state
                    havMsgToCache = 1;
                    rmToCache     = 1; //broad cast read miss
                    addrToCache   = addrFromCPU;
                    if(allowReadFromCache) begin 
                        rwToMem        = `RD;
                        addrToMem      = addrFromCPU;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        nextState      = `S_RM_RD;
                    end
                    else begin 
                        nextState = `SHARED; 
                    end
                end 
                else if(wm) begin 
                    havMsgToCache = 1;
                    wmToCache     = 1;
                    addrToCache   = addrFromCPU;
                    if(allowReadFromCache) begin 
                        rwToMem        = `RD;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        addrToMem      = addrFromCPU;
                        nextState      = `S_WM_RD;
                    end 
                    else begin 
                        nextState = `SHARED; 
                    end
                end 
                else if(idel) begin 
                    nextState = `SHARED;
                end 
                else begin 
                    errReg    = `ERR_UNKNOWN;
                    nextState = `ERROR;
                end
            end
            `S_RM_RD: begin 
                if(readEnFromMem) begin //read enable
                    if(addrToMem == addrFromCPU) begin 
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        cacheLine      = dataFromCPU;
                        nextState      = `SHARED;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        dataToCPU      = cacheLine;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else nextState = `S_RM_RD;
            end
            `S_WM_RD: begin 
                if(readEnFromMem) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        cacheLine      = dataFromCPU;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        nextState      = `MODIFIED;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else nextState = `S_WM_RD;
            end
            `INVALID: begin 
                if(rm) begin 
                    //broadcast readmiss
                    havMsgToCache = 1;
                    addrToCache   = addrFromCPU;
                    rmToCache     = 1;
                    if(allowReadFromCache) begin 
                        rwToMem   = `RD;
                        addrToMem = addrFromCPU;
                        nextState = `I_RM_RD;
                    end 
                    else begin 
                        nextState = `INVALID;
                    end
                end 
                else if(wm) begin 
                    havMsgToCache = 1;
                    addrToCache   = addrFromCPU;
                    wmToCache     = 1;
                    if(allowReadFromCache) begin 
                        rwToMem = `RD;
                        addrToMem = addrFromCPU;
                        nextState = `I_WM_RD;
                    end 
                    else begin 
                        nextState = `INVALID;
                    end 
                end 
                else if(idel) begin 
                    nextState = `INVALID;
                end 
                else begin 
                    nextState = `ERROR;
                    errReg    = `ERR_UNKNOWN;
                end 
            end
            `I_RM_RD: begin  //equal to I_RM_RD
                if(readEnFromMem) begin //read enable
                    if(addrToMem == addrFromCPU) begin 
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        cacheLine      = dataFromCPU;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                        dataToCPU      = cacheLine;
                        nextState      = `SHARED;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end 
                end
                else nextState = `I_RM_RD;
            end 
            `I_WM_RD: begin 
                if(readEnFromMem) begin //read enable
                    if(addrFromCPU == addrToMem) begin 
                        rwToMem        = `IDEL;
                        cacheLine      = dataFromMem;
                        addr           = addrToMem;
                        cacheLine      = dataFromCPU;
                        nextState      = `MODIFIED;
                        readEnToCPU    = 1;
                        writeDoneToCPU = 1;
                    end 
                    else begin 
                        nextState = `ERROR;
                        errReg    = `ERR_ADDR_MISMATCH;
                    end
                end
                else nextState = `I_WM_RD;
            end
            default: 
                nextState = `ERROR;
        endcase
    end
end
//时序逻辑
always @(posedge clk) begin 
    state <= nextState;
end
endmodule

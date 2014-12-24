`define ADDRWIDTH 16
`define WORDWIDTH 16

`define STATEWIDTH      3
`define MODIFIED        3'd0 //done
`define SHARED          3'd1 //done
`define INVALID         3'd2
/* `define WAITINV         3'd3 //state is to be set as modified, but have to wait until the other have invalidate its copy */
`define WRITING         3'd4
`define READING         3'd5
`define WAITINGWBTOREAD 3'd6
`define ERROR           3'd7

`define IOSTATEWIDTH 2
`define RD   2'd0 //read
`define WT   2'd1 //write
`define IDEL 2'd2 //no io

`define ERRWIDTH     4
`define ERR_SNOOPMSG 4'd0
`define ERR_HITMIT   4'd1
module cache(
    input clk,
    input reset,
    //interact with cpu
    input [IOSTATEWIDTH-1:0] cpuRW,
    input [ADDRWIDTH-1:0]    addrFromCPU,
    input [WORDWIDTH-1:0]    dataFromCPU,
    //interact with mem(bus)
    input [ADDRWIDTH-1:0] addrFromMem,
    input [WORDWIDTH-1:0] dataFromMem,
    input memReadEn,
    input memWriteDone,
    //snoop input and output
    input [ADDRWIDTH-1:0] addrFromCache,
    input inReadM,
    input inWriteM,
    input inInv,
    input inWbDone,
    input inInvDone,
    input inHavMsg,

    
    output reg havErr;
    //interact with cpu
    output reg [WORDWIDTH-1:0] dataToCPU,
    output reg readEn,
    output reg cpuWriteDone,
    //interact with mem(bus)
    output reg [IOSTATEWIDTH-1:0] memRW,
    output reg [ADDRWIDTH-1:0] addrToMem,//重构的时候宽度可以直接改成blockwidth
    output reg [WORDWIDTH-1:0] dataToMem,
    //snoopy input and output
    output reg [ADDRWIDTH-1:0] addrToCache,
    output reg outReadM,
    output reg outWriteM,
    output reg outInv,
    output reg outWbDone, //告诉另一个cache不必等待这个cache的写回
    output reg outInvDone,//如果一个cache本身没有snoop到的data,当snoop到writeMiss/invalidate的时候, 仍然要设置wbDone,invDone
    output reg outHavMsg,
);

//version 1
//only one cacheLine, and one word per block
//direct map
wire rh   = (cpuRW == RD) && (cpuAddr == addr);
wire rm   = (cpuRW == RD) && (cpuAddr != addr);
wire wh   = (cpuRW == WT) && (cpuAddr == addr);
wire wm   = (cpuRW == WT) && (cpuAddr != addr);
wire idel = (cpuRW == IDEL);

reg[WORDWIDTH-1:0]  cacheLine;//data in cache
reg[ADDRWIDTH-1:0]  addr;
reg[STATEWIDTH-1:0] state,nextState;


reg[STATEWIDTH-1:0] stateAfterWB;//state after finished writing back
reg[STATEWIDTH-1:0] stateAfterRD;//state after finished writing back

reg[ERRWIDTH-1:0] errReg;
//combinaional 
//但凡有nextState = INVALID的时候,
//就该allInvDone = 1
//如果READING状态的nextState是MODIFIED, 那么需要查看cpuRW是否为WT,如果是, 需要
//执行写操作
//状态将改为modified的时候, 需要check是否allInvDone
always @(reset,cpuRW,addrFromCPU,dataFromCPU,addrFromMem,dataFromMem,memReadEn,memWriteDone,addrFromCache,inReadM,inWriteM,inInv) begin 
    //default value of output
    readEn       = 0;
    cpuWriteDone = 0;
    outReadM     = 0;
    outWriteM    = 0;
    outInv       = 0;
    wbDone       = 0;
    invDone      = 0;
    havErr       = 0;
    memRW        = IDEL;
    stateAfterWB = INVALID;
    outHavMsg    = 0;
    outwbDone    = 0;
    outInvDone   = 0;
    if(reset) begin end else begin
    case(state) 
        MODIFIED: begin 
            if(inHavMsg && (addrFromCache == addr)) begin
                if(inReadM) begin  //snoop read miss
                    nextState    = WRITING;
                    stateAfterWB = SHARED;

                    memRW        = RD;
                    addrToMem    = addr;
                    dataToMem    = cacheLine;
                end 
                else if(inWriteM) begin  //snoop write miss
                    memRW        = RD;
                    addrToMem    = addr;
                    dataToMem    = cacheLine;
                    nextState    = WRITING;
                    stateAfterWB = INVALID;
                end 
                else begin 
                    nextState = ERROR;
                    errReg    = ERR_SNOOPMSG;
                end
            end
            else if(rh) begin 
                nextState = MODIFIED;
                dataToCPU = cacheLine;
                readEn    = 1;
            end 
            else if(wh) begin 
                nextState    = MODIFIED;
                cacheLine    = dataFromCPU;
                cpuWriteDone = 1;
            end
            else if(rm) begin
                nextState    = WRITING; //first write back
                stateAfterWB = WAITINGWBTOREAD; //then fetch data from mem, it should only occur after other cache with data-copy have finished WB
                stateAfterRD = SHARED;//final state is shared

                memRW        = WT;
                addrToMem    = addr;
                dataToMem    = cacheLine;

                outHavMsg    = 1;
                addrToCache  = addrFromCPU;
                outReadM     = 1; //broadcasting read miss
            end 
            else if(wm) begin 
                nextState    = WRITING;
                stateAfterWB = WAITINGWBTOREAD;//want to fetch cpuAddr to cache
                stateAfterRD = MODIFIED;

                memRW        = WT;
                addrToMem    = addr;
                dataToMem    = cacheLine;

                outHavMsg    = 1;
                addrToCache  = addrFromCPU;
                outWriteM    = 1;
            end 
            else if(idel) begin //neither hav cpu access nor bus msg
                nextState = MODIFIED;
            end 
            else begin 
                nextState = ERROR;
                errReg    = ERR_HITMIT;
            end
        end
        SHARED: begin 
            if(inHavMsg && (addrFromCache == addr)) begin
                if(inReadM) begin         //snoop read miss
                    outWbDone = 1;        //tell the other cache no need to wait for writing back
                    nextState = SHARED;
                end 
                else if(inWriteM) begin   //snoop write miss
                    outInvDone = 1;
                    outWbDone  = 1;
                    nextState  = INVALID;
                end 
                else if(invalidate) begin //snoop invalidate msg
                    outWbDone  = 1;
                    outInvDone = 1;
                    nextState  = INVALID;
                end
                else begin 
                    nextState = ERROR;
                    errReg    = ERR_SNOOPMSG;
                end 
            end
            else if(rh) begin 
                dataToCPU = cacheLine;
                readEn    = 1;
                nextState = SHARED;
            end 
            else if(wh) begin 
                cacheLine = dataFromCPU;
                nextState = MODIFIED;
                outHavMsg = 1;
                outInv    = 1;
            end
            else if(rm) begin
                //state:    change to reading
                //with cpu: nothing 
                //with mem: read main mem
                //with bus: read miss message
                nextState    = READING;
                stateAfterRD = SHARED;
                memRW        = RD;
                addrToMem    = addrFromCPU;
                outHavMsg    = 1;
                outReadM     = 1;
            end 
            else if(wm) begin 
                //state:    change to reading
                //with cpu: nothing 
                //with mem: read main mem
                //with bus: read miss message
                nextState    = READING;
                stateAfterRD = MODIFIED;
                memRW        = RD;
                addrToMem    = addrFromCPU;
                outHavMsg    = 1;
                outWriteM    = 1;
            end 
            else if(idel) begin //neither hav cpu access nor bus msg
                nextState = SHARED;
            end 
            else begin 
                nextState = ERROR;
                errReg    = ERR_HITMIT;
            end
        end
        INVALID: begin 
        end 
        default: begin //error state
            nextState = ERROR;//for DFT consideration
            havErr    = 1;
            $display(errReg); //comment this line when synthesising
        end
    endcase
end
end
always @(posedge clk) begin 
    if(state !== MODIFIED && nextState == MODIFIED && ! inInvDone) begin 
        state <= ERROR;
    end 
    else begin
        state <= nextState;
    end
end
endmodule

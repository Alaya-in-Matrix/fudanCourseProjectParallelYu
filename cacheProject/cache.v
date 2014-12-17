`include global_def.v

`define CACHE_MEM_ACTION_WIDTH 2

`define NOIO           2'o0
`define WRITING        2'o1
`define READING        2'o2
`define READY_TO_READ  2'o3

module cache(
    clk,reset,errFlag;
    cpuRW,cpuAddr,cpuDataIn,cpuDataOut,cpuSuccess,
    memRW,memAddr,memDataOut,memDataIn,memSuccess,
    snoopInAction,snoopInAddr,snoopInValue,
    snoopOutAction,snoopOutAddr,snoopOutValue);

input clk,reset;

//interact with cpu
input cpuRW;
output reg[ERRWIDTH-1:0] errFlag;
input wire[ADDRESSBIT-1:0] cpuAddr;
input wire[WORDSIZE-1:0]   cpuDataIn;
output reg[WORDSIZE-1:0]   cpuDataOut;
output reg                 cpuSuccess;   //tell cpu whether it need to stall

//interact with memory
output reg memRW;
output reg [BLOCKADDRBIT-1:0]       memBlockAddr;
output reg [WORDSIZE*BLOCKBYTE-1:0] memDataOut;
input wire [WORDSIZE*BLOCKBYTE-1:0] memDataIn;
input wire memAvailable; 

//interact with the other cache 
input wire[3:0] snoopInAction;
output reg[3:0] snoopOutAction;
input wire[BLOCKADDRBIT-1:0] snoopInAddr;
output reg[BLOCKADDRBIT-1:0] snoopOutAddr;

//simple direct map cache  
reg[1:0] status[CACHELINENUM-1:0];
reg[CACHE_MEM_ACTION_WIDTH-1:0] currMemAction[CACHELINENUM-1:0];// record what IO action was performed
reg[CACHE_MEM_ACTION_WIDTH-1:0] nextMemAction[CACHELINENUM-1:0];
reg[BLOCKADDRBIT-1:0]       blockAddr[CACHELINENUM-1:0];
reg[BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];

wire busIdx = snoopInAddr % CACHELINENUM;
wire cpuIdx = cpuAddr     % CACHELINENUM;
wire memIdx = memAddr     % CACHELINENUM;

integer i;
reg stall;//to break the execution
always @(posedge clk) begin
    if(reset) begin
        //initialize
        for(i=0; i<CACHELINENUM; i=i+1) begin
            blockAddr[i]     <= 0;
            cacheLine[i]     <= 0;
            status[i]        <= INVALID;
            prevMemAction[i] <= NOIO; 
        end 
        snoopOutAction <= MSG_NOTHING;
        snoopOutAddr   <= 0;
        snoopOutValue  <= 0;
        errFlag        <= NOERR;
    end
    else if(errFlag == NOERR) begin 
        for(i=0;i<CACHELINENUM; i=i+1) begin 
            case(status[i]) 
                MODIFIED: begin
                    if(snoopInAddr == blockAddr[i] && snoopInAction != MSG_NOTHING) begin 
                        case(snoopInAction) 
                            MSG_READMISS,MSG_WRITEMISS: begin 
                                case (currMemAction[i])
                                    NOIO,READY_TO_READ: begin 
                                        memRW = WT;
                                        memAddr = blockAddr[i];
                                        stall = 1;
                                        status[i] = (snoopInAction == MSG_WRITEMISS ? INVALID : SHARED);
                                    default:
                                        stall = 1;
                                endcase
                            end 
                            default: 
                                errFlag = BUS_ACTION_ERR;
                        endcase
                    end 
                    if(stall==0 && cpuIdx == i) begin // have cpu request for this cache block
                    end 
                end 
                SHARED: begin 
                end 
                INVALID: begin 
                end 
                default: $display("error status:%d",status[i]);
            endcase
        end 
    end 
    else 
        errFlag = errFlag;
end 

//do memory IO
always @(posedge memAvailable) begin 
    if(memAvailable && currMemAction[memIdx]==READING) begin
        cacheLine[memIdx] = memDataIn;
        blockAddr[memIdx] = memAddr;
        status[memIdx]    = SHARED;
        currMemAction[memIdx] = nextMemAction[memIdx];
        nextMemAction[memIdx] = NOIO;
    end
    else if(memAvailable && currMemAction[memIdx] == WRITING) begin 
        currMemAction[memIdx] = nextMemAction[memIdx];
        nextMemAction[memIdx] = NOIO;
    end
end
endmodule


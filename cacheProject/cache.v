`define global_def.v 
module cache(
    clk,reset,busAvailable,releaseBus,readEnable,
    cpuRW,cpuAddr,cpuDataIn,cpuDataOut,cpuSuccess,
    snoopInAction,snoopInAddr,snoopInValue,
    snoopOutAction,snoopOutAddr,snoopOutValue)

input clk,reset,busAvailable;
input cpuRW;
input [ADDRESSBIT-1:0]         cpuAddr;
input [WORDSIZE-1:0]           cpuDataIn;
input [3:0]                    snoopInAction;
input [BLOCKADDRBIT-1:0]       snoopInAddr;
input [BLOCKBYTE*WORDSIZE-1:0] snoopInValue;

output releaseBus,readEnable;
output reg[WORDSIZE-1:0]           cpuDataOut;
output reg[3:0]                    snoopOutAction;
output reg[BLOCKADDRBIT-1]         snoopOutAddr;
output reg[BLOCKBYTE*WORDSIZE-1:0] snoopOutValue

reg [STATUSWIDTH-1:0]        status[CACHELINENUM-1:0];
reg [STATUSWIDTH:0]          statusAfterIO[CACHELINENUM-1:0];
reg [BLOCKADDRBIT-1:0]       blockAddr[CACHELINENUM-1:0];
reg [BLOCKBYTE*WORDSIZE-1:0] cacheLine[CACHELINENUM-1:0];


wire cpuBlockAddr = cpuAddr[(ADDRESSBIT-1)-:BLOCKADDRBIT];
wire offset       = cpuAddr[0+:OFFSETADDRBIT];

wire BusIdx = snoopInAddrC % CACHELINENUM;
wire cpuIdx = cpuBlockAddr % CACHELINENUM;

wire [1:0] hitmiss;
assign hitmiss[1] = (cpuRW == RD ? 1'b0 : 1'b1);
assign hitmiss[0] = ((cpuBlockAddr == blockAddr[cpuIdx]) && status[cpuIdx]!=INVALID ? 1'b0 : 1'b1);


integer i;
always @(posedge) begin 
    if(reset) begin 
        //TODO  reset 
    end 
    else begin 
        for(i = 0; i < CACHELINENUM; i++) begin 
            case(status[i])
                RD_STALLING: begin 
                    if(busAvailable) begin //IO has finished
                        status[i]    = statusAfterIO[i];
                        cacheLine[i] = snoopInValue;
                        blockAddr[i] = snoopInAddr;//需不需要为bus和snoop分别设置一个总线?
                        if(snoopInAddr % CACHELINENUM != i)
                            $display("error snoopInAddr");
                    end 
                    else begin status[i] = status[i]; end //wait for IO to finish
                end 
                WB_STALLING: begin 
                    if(busAvailable)  //IO has finished
                        status[i] = statusAfterIO[i];
                end 
                REP_STALLING: begin 
                end 
                MODIFIED: begin 
                    if(snoopInAddr == blockAddr[i] && snoopInAction != MSG_NOTHING) begin //have msg
                        if(snoopInAction == MSG_WRITEMISS) begin 
                            if(busAvailable) begin 
                                status[i]        = WB_STALLING;
                                statusAfterIO[i] = INVALID;
                                snoopOutAction   = WRITEBACK;
                                snoopOutAddr     = blockAddr[i];
                                snoopOutValue    = cacheLine[i]; 
                            end 
                        end 
                        else if(snoopInAction == MSG_READMISS) begin 
                            if(busAvailable) begin 
                                status[i]        = WB_STALLING;
                                statusAfterIO[i] = SHARED;
                                snoopOutAction   = WRITEBACK;
                                snoopOutAddr     = blockAddr[i];
                                snoopOutValue    = cacheLine[i];
                            end 
                        end 
                        else 
                            $display("errorSnoopInAction");
                    end 
                    else if(cpuBlockAddr == blockAddr) begin 
                        if(hitmiss == READHIT) 
                            cpuDataOut = cacheLine[i][offset+:WORDSIZE];
                        else if(hitmiss == WRITEHIT)
                            cacheLine[i][offset+:WORDSIZE] = cpuDataIn;
                        else if(hitmiss == READMISS) begin 
                            status[i] = REP_STALLING;
                            statusAfterIO[i] = SHARED;
                        end 
                    end 
                end 
                SHARED: begin 
                    if(snoopInAddr == blockAddr[i] && snoopInAction != MSG_NOTHING) begin //have msg
                    end 
                    else if(cpuBlockAddr == blockAddr) begin 
                    end 
                end 
                INVALID: begin 
                    if(snoopInAddr == blockAddr[i] && snoopInAction != MSG_NOTHING) begin //have msg
                    end 
                    else if(cpuBlockAddr == blockAddr) begin 
                    end 
                end 
            endcase
        end 
    end 
end 
endmodule
endmodule

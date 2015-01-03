/*
* instruction supported::
    * ld regIdx,memAddr
    * st regIdx,memAddr
    * nop :stall one cycle
    * set reg,instanceNum
*/

`include "./def.v"
module processor(
    input clk,
    input reset,

    //interact with real world 
    input [`INSWIDTH-1:0]  instruction,
    output reg[`WORDWIDTH-1:0] data,
    output[`PCWIDTH-1:0]          pcCounter,
    //interact with memory, cache is transparent to CPU
    output reg[`IOSTATEWIDTH-1:0] rwToMem,
    output reg[`ADDRWIDTH-1:0] addrToMem,
    output reg[`WORDWIDTH-1:0] dataToMem,
    input wire cacheEn,
    input wire[`WORDWIDTH-1:0] dataFromMem,

    //for debug purpose
    output [`CPUSTATENUMWIDTH-1:0] cpuState,
    output [`REGWIDTH-1:0] regId,
    output [`WORDWIDTH-1:0] r0,
    output [`WORDWIDTH-1:0] r1
);
reg[`PCWIDTH-1:0]          counter;
reg[`CPUSTATENUMWIDTH-1:0] state;
reg[`WORDWIDTH-1:0]        regFile[`REGNUM-1:0];//register files



wire[`OPWIDTH-1:0] op        = instruction[(`INSWIDTH-1)-:`OPWIDTH];
wire[`REGWIDTH-1:0] regIdx   = instruction[(`INSWIDTH-`OPWIDTH-1)-:`REGWIDTH];
wire[`WORDWIDTH-1:0] insData = instruction[`INSWIDTH-`OPWIDTH-`REGWIDTH-1:0];

assign pcCounter = counter;
assign cpuState  = state;
assign r0        = regFile[0];
assign r1        = regFile[1];
assign regId     = regIdx;
always @(posedge clk) begin 
    if(reset) begin 
        data       = 0;
        rwToMem    = `IDEL;
        counter    = 0;
        state      = `FETCH;
        regFile[0] = 0;
        regFile[1] = 0;
    end 
    else if(state == `ERR) begin 
        state = `ERR;
    end 
    else if(state == `FETCH) begin 
        //counter,state,data,rwtomem,addrtomem,datatomem
        state   = `EXE;
        rwToMem = `IDEL;
    end 
    else if(state == `EXE) begin 
        case(op) 
            `NOP : begin 
                rwToMem = `IDEL;
                counter = counter + 1'b1;
                regFile[0] = regFile[0];
                regFile[1] = regFile[1];
                state   = `FETCH;
            end
            `SET : begin 
                rwToMem         = `IDEL;
                regFile[regIdx] = insData;
                counter         = counter + 1'b1;
                state           = `FETCH;
            end 
            `GET : begin
                rwToMem = `IDEL;
                data    = regFile[regIdx];
                counter = counter + 1'b1;
                state   = `FETCH;
            end
            `LD  : begin 
                rwToMem   = `RD;
                addrToMem = insData;
                state     = `MEM;
            end 
            `ST  : begin 
                rwToMem   = `WT;
                addrToMem = insData;
                dataToMem = regFile[regIdx];
                state     = `MEM;
            end
            default:
                state = `ERR;
        endcase
    end 
    else if(state == `MEM) begin 
        case(op) 
            `NOP,`SET : begin 
                state   = `ERR;
            end
            `LD  : begin 
                if(! cacheEn) 
                    state = `MEM;
                else begin 
                    regFile[regIdx] = dataFromMem;
                    rwToMem         = `IDEL;
                    counter         = counter + 1'b1;
                    state           = `FETCH;
                end 
            end 
            `ST  : begin 
                if(! cacheEn) 
                    state = `MEM;
                else begin 
                    rwToMem = `IDEL;
                    counter = counter + 1'b1;
                    state   = `FETCH;
                end 
            end
            default:
                state = `ERR;
        endcase
    end 
end 
endmodule

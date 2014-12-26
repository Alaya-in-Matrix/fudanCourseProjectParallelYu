/*
* instruction supported::
    * ld regIdx,memAddr
    * st regIdx,memAddr
    * nop :stall one cycle
    * set reg,instanceNum
*/

`include "./def.v"


`define CPUSTATENUM 3
`define CPUSTATENUMWIDTH 2
`define FETCH 2'd0
`define EXE   2'd1
`define MEM   2'd2
`define ERR   2'd3
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
    input wire rdEn,wtEn,
    input wire[`WORDWIDTH-1:0] dataFromMem
);

reg[`PCWIDTH-1:0]          counter;
reg[`CPUSTATENUMWIDTH-1:0] state;
reg[`WORDWIDTH-1:0]        regFile[`REGNUM-1:0];//register files
assign pcCounter = counter;


wire[`OPWIDTH-1:0] op        = instruction[(`INSWIDTH-1)-:`OPWIDTH];
wire[`REGWIDTH-1:0] regIdx   = instruction[(`INSWIDTH-`OPWIDTH-1)-:`REGWIDTH];
wire[`WORDWIDTH-1:0] insData = instruction[`INSWIDTH-`OPWIDTH-`REGWIDTH-1:0];

always @(posedge clk) begin 
    if(reset) begin 
        data    = 0;
        rwToMem = `IDEL;
        counter = 0;
        state   = `FETCH;
    end 
    else if(state == `ERR) begin 
        state = `ERR;
    end 
    else if(state == `FETCH) begin 
        //counter,state,data,rwtomem,addrtomem,datatomem
        counter = counter + 1'b1;
        state   = `EXE;
        rwToMem = `IDEL;
    end 
    else if(state == `EXE) begin 
        case(op) 
            `NOP : begin 
                rwToMem = `IDEL;
                state   = `FETCH;
            end
            `SET : begin 
                rwToMem         = `IDEL;
                regFile[regIdx] = insData;
                state           = `FETCH;
            end 
            `GET : begin
                rwToMem = `IDEL;
                data    = regFile[regIdx];
                state   = `FETCH;
            `LD  : begin 
                rwToMem   = `RD;
                addrToMem = insData;
                state     = `MEM;
            end 
            `ST  : begin 
                rwToMem   = `WT;
                addrToMem = insData;
                dataToMem = regFile[regIdx];
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
                if(! rdEn) 
                    state = `MEM;
                else begin 
                    regFile[regIdx] = dataFromMem;
                    rwToMem         = `IDEL;
                    state           = `FETCH;
                end 
            end 
            `ST  : begin 
                if(! wtEn) 
                    state = `MEM;
                else begin 
                    rwToMem = `IDEL;
                    state   = `FETCH;
                end 
            end
            default:
                state = `ERR;
        endcase
    end 
end 
endmodule

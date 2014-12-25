//instruction supported: 
//ld registerNum,memAddr
//st memAddr,registerNum
//ldi register,#number
//sti memAddr,#number

`include "./def.v"
`define INSTRUCTIONWIDTH 32 //32-bit instruction 
module processor(
    input clk,
    input reset,
        
    //interact with outside world
    input[INSTRUCTIONWIDTH-1:0] instrction;
    output[WORDWIDTH-1:0] dataOut;


    //interact with memory(cache),cache is transparent to CPU
    input rdEn,
    input wtEn,
    input [WORDWIDTH-1:0] dataFromMem,
    output reg[IOSTATEWIDTH-1:0] rwToMem,
    output reg[ADDRWIDTH-1:0] addrToMem,
    output reg[WORDWIDTH-1:0] dataToMem,

    //err
    output reg[ERRWIDTH-1:0] errReg;
);

wire[OPWIDTH-1:0] op    = instrction[(INSTRUCTIONWIDTH-1)-                  :OPWIDTH];
wire[DESTWIDTH-1:0] dst = instrction[(INSTRUCTIONWIDTH-OPWIDTH-1)-          :DSTWIDTH];
wire[SRCWIDTH-1:0] src  = instrction[(INSTRUCTIONWIDTH-OPWIDTH-DSTWIDTH-1)- :SRCWIDTH];

reg havErr;
//暂时先不用PC, 之后重构时可以采用PC自动加载指令.
always @(posedge clk) begin 
    if(reset) begin 
        havErr  = 0;
        errReg  = NOERR;
        dataOut = 0;
        rwToMem = IDEL;
    end
    else if(! havErr)  begin 
        if(op == LD) begin 
            if(rdEn) begin 
            end
        end
        else if(OP = ST) begin 
            if(wtEn) begin 
            end
        end 
        else if(OP = LI) begin 
            if(rdEn) begin 
            end
        end 
        else if(OP = SI) begin 
            if(wtEn) begin 
            end
        end 
        else begin 
            havErr = 1;
            errReg = ERR_CPUOP;
        end 
    end
    else 
        havErr = 1;
end
end
endmodule

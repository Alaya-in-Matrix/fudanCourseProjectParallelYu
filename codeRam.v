
    `include "./def.v"
    module codeRam(
        input[`PCWIDTH-1:0] pc,
        output reg[`INSWIDTH-1:0] ins
    );
    parameter CODESIZE = 8; //a program could have at most 8 instructions
    reg[`INSWIDTH-1:0] codes[0:CODESIZE-1];
    reg[3:0] codeSize;
    always @(pc,codeSize) begin 
        if(pc >= codeSize) begin 
            ins = 0; //return nop
        end
        else begin 
            ins = codes[pc];
        end 
    end 
    endmodule

    

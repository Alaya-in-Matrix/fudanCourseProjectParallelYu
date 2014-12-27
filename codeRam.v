`include "./def.v"
module codeRam(
    input[`PCWIDTH-1:0] pc,
    output reg[`INSWIDTH-1:0] ins
);
parameter CODESIZE = 8; //a progra could have at most 8 instructions
reg[`INSWIDTH-1:0] codes[0:CODESIZE-1];

always @(pc) begin 
    if(pc >= CODESIZE) begin 
        ins = {`NOP,18'd0}; //return nop
    end
    else begin 
        ins = codes[pc];
    end 
end 
endmodule

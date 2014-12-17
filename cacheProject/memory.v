// this module plays the role of main memory and memeoy bus
`include global_def.v
module memory(clk,addrA,addrB,dataInA,dataInB,dataOutA,dataOutB,rdwtA,rdwtB);
input  clk,rdwtA,rdwtB;
input  [ADDRESSBIT-1:0]  addrA,addrB;
input  [WORDSIZE-1:0]    dataInA,dataInB;
output reg[WORDSIZE-1:0] dataOutA,dataOutB;

// memeoy access hav a delay_cycle
/* parameter delay_cycle = 100; */ 

reg[WORDSIZE-1:0] mem[MEMSIZE-1:0];//main memory
//race will occur if two cache want to access memory EXACTLY at same time
//but this will be easy to handle...may be set priority for two cache,
//and add logic to handle situation that one cache want to read while the
//other want to write...
//but now, we just assume that two cache won't do mem-access at same time

//behavior for cache1
always @(posedge clk) begin
    case(rdwtA)
        RD: dataOutA   = mem[addrA];
        WT: mem[addrA] = dataInA;
        default: $display("error rdwtA");
    endcase
end

//behavior for cache2
always @(posedge clk) begin
    case(rdwtB)
        RD: dataOutB   = mem[addrB];
        WT: mem[addrB] = dataInB;
        default: $display("error rdwtB");
    endcase
end
endmodule

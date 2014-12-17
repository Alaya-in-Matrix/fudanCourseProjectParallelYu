// this module plays the role of main memory and memeoy bus
// memory只支持block级别的读写, 不支持byte(word)级别的读写
`include global_def.v
module memory(clk,addrA,addrB,dataInA,dataInB,dataOutA,dataOutB,rdwtA,rdwtB,access_successA,access_successB);
//A和B的in/out其实可以统一成一个位宽加倍的in/out
input  clk,rdwtA,rdwtB;
input  [ADDRESSBIT-1:0]  addrA,addrB;
input  [BLOCKBYTE*WORDSIZE-1:0]    dataInA,dataInB;
output reg[BLOCKBYTE*WORDSIZE-1:0] dataOutA,dataOutB;
output reg access_successA,access_successB;

// memeoy access hav a delay_cycle

reg[WORDSIZE-1:0] mem[MEMSIZE-1:0];//main memory
//race will occur if two cache want to access memory EXACTLY at same time
//but this will be easy to handle...may be set priority for two cache,
//and add logic to handle situation that one cache want to read while the
//other want to write...
//but now, we just assume that two cache won't do mem-access at same time

//behavior for cache1
reg[7:0] delayCounterA = 0;
reg[7:0] delayCounterB = 0;


wire [ADDRESSBIT-1:0] effAddrA,effAddrB;

//应该是取前x位为block address
assign effAddrA = addrA / BLOCKBYTE; 
assign effAddrB = addrB / BLOCKBYTE;


//当前面的访问还没有完成就有新的数据访问请求被发送时, 
//前面的访问会被无效化
//内存访问的正确性交给cache来处理, cache应当根据ACCESS_SUCCSS的值
//来确定是否继续发送数据请求
always @(rdwtA,effAddrA,dataInA)
begin
    delayCounterA   <= MEM_ACCESS_DELAY;
    access_successA <= ACCESSING
end
always @(rdwtB,errAddrB,dataInA)
begin
    delayCounterB   <= MEM_ACCESS_DELAY;
    access_successB <= ACCESSING
end

always @(posedge clk) begin
    if(delayCounterA > 0)
        delayCounterA = delayCounterA - 1;
    else 
    begin
        case(rdwtA)
            RD: dataOutA   = mem[effAddrA+:BLOCKBYTE*WORDSIZE];
            WT: mem[effAddrA+:BLOCKBYTE*WORDSIZE] = dataInA;
            default: $display("error rdwtA");
        endcase
        access_successA = ACCESS_SUCCESS;
    end 
end

//behavior for cache2
always @(posedge clk) begin
    if(delayCounterB > 0)
        delayCounterB = delayCounterB - 1;
    else 
    begin
        case(rdwtB)
            RD: dataOutB   = mem[effAddrB+:BLOCKBYTE*WORDSIZE];
            WT: mem[effAddrB+:BLOCKBYTE*WORDSIZE] = dataInB;
            default: $display("error rdwtB");
        endcase
        access_successA = ACCESS_SUCCESS;
    end
end
endmodule

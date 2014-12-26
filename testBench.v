`include "./def.v"
module testBench;
/*
* 应该为两个processor各实例化一个codeRam
* 初始化两个codeRam
* 实例化两个processor
* 实例化两个cache
* 实例化memBus
* initial语句打印
*/
// instances
reg reset;
reg clk;
//真正仿真前, 代码, 尤其是cache的代码需要review一遍. 
wire[`PCWIDTH-1:0] pc_proc1_code1,pc_proc2_code2;
wire[`INSWIDTH-1:0] ins_code1_proc1,ins_code2_proc2;
reg[`WORDWIDTH-1:0] dataOut1,dataOut2;
wire[`IOSTATEWIDTH-1:0] rw_P1_C1,rw_P2_C2;

wire [`ADDRWIDTH-1:0]addr_P1_C1,addr_P2_C2;
wire [`WORDWIDTH-1:0]data_P1_C1,data_P2_C2;
wire rdEn_C1_P1,rdEn_C2_P2;
wire wtEn_C1_P1,wtEn_C2_P2;
wire [`WORDWIDTH-1:0]data_C1_P1,data_C2_P2;

wire[`WORDWIDTH-1:0]data_M_C1,data_M_C2;
wire rdEn_M_C1,rdEn_M_C2;
wire wtEn_M_C1,wtEn_M_C2;
wire[`IOSTATEWIDTH-1:0]rw_C1_M,rw_C2_M;
wire[`ADDRWIDTH-1:0] addr_C1_M,addr_C2_M;
wire[`WORDWIDTH-1:0] data_C1_M,data_C2_M;
wire msg_C2_C1,msg_C1_C2;
wire allowRead_C2_C1,allowRead_C1_C2;
wire[`ADDRWIDTH-1:0] addr_C2_C1,addr_C1_C2;
wire rm_C2_C1,rm_C1_C2,wm_C2_C1,wm_C1_C2,inv_C1_C2,inv_C2_C1;
codeRam code1(
    .pc(pc_proc1_code1),
    .ins(ins_code1_proc1),
);
codeRam code2(
    .pc(pc_proc2_code2),
    .ins(ins_code2_proc2),
);
processor P1(
    .clk(clk),
    .reset(reset),

    .instruction(ins_code1_proc1),
    .data(dataOut1),
    .pcCounter(pc_proc1_code1),

    .rwToMem(rw_P1_C1),
    .addrToMem(addr_P1_C1),
    .dataToMem(data_P1_C1),
    .rdEn(rdEn_C1_P1),
    .wtEn(wtEn_C1_P1),
    .dataFromMem(data_C1_P1)
);
processor P2(
    .clk(clk),
    .reset(reset),

    .instruction(ins_code2_proc2),
    .data(dataOut2),
    .pcCounter(pc_proc2_code2),

    .rwToMem(rw_P2_C2),
    .addrToMem(addr_P2_C2),
    .dataToMem(data_P2_C2),
    .rdEn(rdEn_C2_P2),
    .wtEn(wtEn_C2_P2),
    .dataFromMem(data_C2_P2)
);
cache C1(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P1_C1),
    .addrFromCPU(addr_P1_C1),
    .dataFromCPU(data_P1_C1),
    .readEnToCPU(rdEn_C1_P1),
    .writeDoneToCPU(wtEn_C1_P1),
    .dataToCPU(data_P1_C1),

    .dataFromMem(data_M_C1),
    .readEnFromMem(rdEn_M_C1),
    .writeDoneFromMem(wtEn_M_C1),
    .rwToMem(rw_C1_M),
    .addrToMem(addr_C1_M),
    .datatomem(data_C1_M),

    .havMsgFromCache(msg_C2_C1),
    .allowReadToCache(allowRead_C2_C1),
    .addrFromCache(addr_C2_C1),
    .rmFromCache(rm_C2_C1),
    .wmFromCache(wm_C2_C1),
    .invFromCache(inv_C2_C1),
    .havMsgToCache(msg_C1_C2),
    .allowReadToCache(allowRead_C1_C2),
    .addrToCache(addr_C1_C2),
    .rmToCache(rm_C1_C2),
    .wmToCache(wm_C1_C2),
    .invToCache(inv_C1_C2)
);
cache C2(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P2_C2),
    .addrFromCPU(addr_P2_C2),
    .dataFromCPU(data_P2_C2),
    .readEnToCPU(rdEn_C2_P2),
    .writeDoneToCPU(wtEn_C2_P2),
    .dataToCPU(data_P2_C2),

    .dataFromMem(data_M_C2),
    .readEnFromMem(rdEn_M_C2),
    .writeDoneFromMem(wtEn_M_C2),
    .rwToMem(rw_C2_M),
    .addrToMem(addr_C2_M),
    .datatomem(data_C2_M),

    .havMsgFromCache(msg_C1_C2),
    .allowReadToCache(allowRead_C1_C2),
    .addrFromCache(addr_C1_C2),
    .rmFromCache(rm_C1_C2),
    .wmFromCache(wm_C1_C2),
    .invFromCache(inv_C1_C2),
    .havMsgToCache(msg_C2_C1),
    .allowReadToCache(allowRead_C2_C1),
    .addrToCache(addr_C2_C1),
    .rmToCache(rm_C2_C1),
    .wmToCache(wm_C2_C1),
    .invToCache(inv_C2_C1)
);
memBus mb(
    .clk(clk),
    `.reset(reset),

    .rwFromCacheA(rw_C1_M),
    .addrFromCacheA(addr_C1_M),
    .dataFromCacheA(data_C1_M),
    .dataToCacheA(data_M_C1),
    .rdEnToCacheA(rdEn_M_C1),
    .wbDoneToCacheA(wtEn_M_C1),

    .rwFromCacheA(rw_C2_M),
    .addrFromCacheA(addr_C2_M),
    .dataFromCacheA(data_C2_M),
    .dataToCacheA(data_M_C2),
    .rdEnToCacheA(rdEn_M_C2),
    .wbDoneToCacheA(wtEn_M_C2)
);
//似乎对于reset和default值,还有些问题
//initial and simulations
always #5 clk = ~clk;
initial begin 
    clk   = 0;
    reset = 0;
    code1.code[0] = {`SET,`R0,`WORDWIDTH'd3}; //p1.r0 = 3
    code1.code[1] = {`ST,`R0,`ADDRWIDTH'd0};  //mem[0] = p1.r0

    code2.code[0] = {`NOP,`R0,`WORDWIDTH'd0};
    code2.code[1] = {`NOP,1'd0,16'd0};
    code2.code[2] = {`LD,`R0,`ADDRWIDTH'd0};  //p2.r0 = mem[0];
    codd2.code[3] = {`GET,`R0,16'd0};         //print p2.r0; should be 3
    #5;
    reset = 1;
    #5;
    reset = 0;
end
endmodule

//store instructions
module codeRam(
    input[`PCWIDTH-1:0] pc,
    output[`INSWIDTH-1:0] ins
);
parameter CODESIZE 16; //a progra could have at most 16 instructions
reg[`INSWIDTH-1:0] codes[0:CODESIZE-1];
always @(pc) begin 
    if(pc >= CODESIZE) begin 
        ins = {NOP,(`INSWIDTH-`OPWIDTH)'d0}; //return nop
    end
    else begin 
        ins = codes[pc];
    end 
end 
endmodule

//TODO: remove debug signal
`include "./def.v"
module testCodeRam;
reg reset,clk;
wire[`PCWIDTH-1:0]      pc_proc1_code1,pc_proc2_code2;
wire[`INSWIDTH-1:0]     ins_code1_proc1,ins_code2_proc2;
wire[`WORDWIDTH-1:0]    dataOut1,dataOut2;
wire[`IOSTATEWIDTH-1:0] rw_P1_C1,rw_P2_C2;

wire                  en_C1_P1,en_C2_P2;
wire [`ADDRWIDTH-1:0] addr_P1_C1,addr_P2_C2;
wire [`WORDWIDTH-1:0] data_P1_C1,data_P2_C2;
wire [`WORDWIDTH-1:0] data_C1_P1,data_C2_P2;

wire[`WORDWIDTH-1:0]data_M_C1,data_M_C2;
wire en_M_C1,en_M_C2;
wire[`IOSTATEWIDTH-1:0]rw_C1_M,rw_C2_M;
wire[`ADDRWIDTH-1:0] addr_C1_M,addr_C2_M;
wire[`WORDWIDTH-1:0] data_C1_M,data_C2_M;
wire msg_C2_C1,msg_C1_C2;
wire allowRead_C2_C1,allowRead_C1_C2;
wire [`ADDRWIDTH-1:0] allowReadAddr_C1_C2,allowReadAddr_C2_C1;
wire[`ADDRWIDTH-1:0] addr_C2_C1,addr_C1_C2;
wire rm_C2_C1,rm_C1_C2,wm_C2_C1,wm_C1_C2,inv_C1_C2,inv_C2_C1;

//debug vars
wire[`CPUSTATENUMWIDTH-1:0] stateP1,stateP2;
wire[`WORDWIDTH-1:0]r0P1,r0P2,r1P1,r1P2;
wire[`REGWIDTH-1:0] regIdxP1,regIdxP2;
codeRam code1(
    .pc(pc_proc1_code1),
    .ins(ins_code1_proc1)
);
codeRam code2(
    .pc(pc_proc2_code2),
    .ins(ins_code2_proc2)
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
    .cacheEn(en_C1_P1),
    .dataFromMem(data_C1_P1),
    .cpuState(stateP1),
    .r0(r0P1),
    .r1(r1P1),
    .regId(regIdxP1)
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
    .cacheEn(en_C2_P2),
    .dataFromMem(data_C2_P2),
    .cpuState(stateP2),
    .r0(r0P2),
    .r1(r1P2),
    .regId(regIdxP2)
);
wire [`STATEWIDTH-1:0] debugStateC1,debugStateC2;
wire [`WORDWIDTH-1:0] debugCacheLineC1,debugCacheLineC2;
cache C1(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P1_C1),
    .addrFromCPU(addr_P1_C1),
    .dataFromCPU(data_P1_C1),
    .cacheEnToCPU(en_C1_P1),
    .dataToCPU(data_C1_P1),

    .dataFromMem(data_M_C1),
    .memEn(en_M_C1),
    .rwToMem(rw_C1_M),
    .addrToMem(addr_C1_M),
    .dataToMem(data_C1_M),

    .havMsgFromCache(msg_C2_C1),
    .allowReadFromCache(allowRead_C2_C1),
    .allowReadFromCacheAddr(allowReadAddr_C2_C1),
    .addrFromCache(addr_C2_C1),
    .rmFromCache(rm_C2_C1),
    .wmFromCache(wm_C2_C1),
    .invFromCache(inv_C2_C1),
    .havMsgToCache(msg_C1_C2),
    .allowReadToCache(allowRead_C1_C2),
    .allowReadToCacheAddr(allowReadAddr_C1_C2),
    .addrToCache(addr_C1_C2),
    .rmToCache(rm_C1_C2),
    .wmToCache(wm_C1_C2),
    .invToCache(inv_C1_C2),

    //debug ms
    .debugState(debugStateC1),
    .debugCacheLine(debugCacheLineC1)
);
cache C2(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P2_C2),
    .addrFromCPU(addr_P2_C2),
    .dataFromCPU(data_P2_C2),
    .cacheEnToCPU(en_C2_P2),
    .dataToCPU(data_C2_P2),

    .dataFromMem(data_M_C2),
    .memEn(en_M_C2),
    .rwToMem(rw_C2_M),
    .addrToMem(addr_C2_M),
    .dataToMem(data_C2_M),

    .havMsgFromCache(msg_C1_C2),
    .allowReadFromCache(allowRead_C1_C2),
    .allowReadFromCacheAddr(allowReadAddr_C1_C2),
    .addrFromCache(addr_C1_C2),
    .rmFromCache(rm_C1_C2),
    .wmFromCache(wm_C1_C2),
    .invFromCache(inv_C1_C2),
    .havMsgToCache(msg_C2_C1),
    .allowReadToCache(allowRead_C2_C1),
    .allowReadToCacheAddr(allowReadAddr_C2_C1),
    .addrToCache(addr_C2_C1),
    .rmToCache(rm_C2_C1),
    .wmToCache(wm_C2_C1),
    .invToCache(inv_C2_C1),

    //debug ms
    .debugState(debugStateC2),
    .debugCacheLine(debugCacheLineC2)
);
wire[`IOSTATEWIDTH-1:0] debugRwToMem;
wire[7:0] debugDelay;
memBus mb(
    .clk(clk),
    .reset(reset),

    .rwFromCacheA(rw_C1_M),
    .addrFromCacheA(addr_C1_M),
    .dataFromCacheA(data_C1_M),
    .dataToCacheA(data_M_C1),
    .memEnA(en_M_C1),

    .rwFromCacheB(rw_C2_M),
    .addrFromCacheB(addr_C2_M),
    .dataFromCacheB(data_C2_M),
    .dataToCacheB(data_M_C2),
    .memEnB(en_M_C2),

    //debug output 
    .debugRwToMem(debugRwToMem),
    .debugDelay(debugDelay)
);
initial begin 
    clk            = 1'b0;
    reset          = 1'b0;
    code1.codeSize = 3;
    code2.codeSize = 3;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[2] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    #5 reset  = 1'b1;
    #17 reset = 1'b0;
    #1000;
    $display("Write After Write");
    $display("time:%d,P1.r0:%d,C1.cachLine:%d,C1.state:%h", $time,P1.regFile[0],C1.cacheLine, C1.state);
    $display("time:%d,P2.r0:%d,C2.cachLine:%d,C2.state:%h", $time,P2.regFile[0],C2.cacheLine, C2.state);
    $display("mem[0]:%d", mb.mem[0]);
    $display("___________________________________________________");
    code1.codeSize = 3;
    code2.codeSize = 3;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[2] = {`LD,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    reset          = 1'b1;
    #20 reset      = 1'b0;
    #1000;
    $display("Read After Write");
    $display("time:%d,P1.r0:%d,C1.cachLine:%d,C1.state:%h",$time,P1.regFile[0],C1.cacheLine, C1.state);
    $display("time:%d,P2.r0:%d,C2.cachLine:%d,C2.state:%h",$time,P2.regFile[0],C2.cacheLine, C2.state);
    $display("mem[0]:%d", mb.mem[0]);
    $display("___________________________________________________");
    #1500;
    code1.codeSize = 4;
    code2.codeSize = 3;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code1.codes[3] = {`LD,  `R0,    `WORDWIDTH'd0};
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[2] = {`LD,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    reset          = 1'b1;
    #20 reset      = 1'b0;
    #1500;
    $display("Read After Read");
    $display("time:%d,P1.r0:%d,C1.cachLine:%d,C1.state:%h",$time,P1.regFile[0],C1.cacheLine, C1.state);
    $display("time:%d,P2.r0:%d,C2.cachLine:%d,C2.state:%h",$time,P2.regFile[0],C2.cacheLine, C2.state);
    $display("mem[0]:%d", mb.mem[0]);
    $display("___________________________________________________");
    #1500;
    code1.codeSize = 4;
    code2.codeSize = 5;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code1.codes[3] = {`LD,  `R0,    `WORDWIDTH'd0};
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[3] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[4] = {`ST,  `R0,    `ADDRWIDTH'd0};
    reset          = 1'b1;
    #20 reset      = 1'b0;
    #1500;
    $display("Special Read After Write");
    $display("time:%d,P1.r0:%d,C1.cachLine:%d,C1.state:%h",$time,P1.regFile[0],C1.cacheLine, C1.state);
    $display("time:%d,P2.r0:%d,C2.cachLine:%d,C2.state:%h",$time,P2.regFile[0],C2.cacheLine, C2.state);
    $display("mem[0]:%d", mb.mem[0]);
    $display("___________________________________________________");
    #1500;
    reset          = 1'b1;
    #20 reset      = 1'b0;
    code1.codeSize = 4;
    code2.codeSize = 0;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0};
    code1.codes[3] = {`LD,  `R0,    `WORDWIDTH'd0};
    #500;
    P2.counter     = 0;
    code2.codeSize = 3;
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0};
    code2.codes[2] = {`ST,  `R0,    `ADDRWIDTH'd0};
    #2500;
    $display("Write After Read");
    $display("time:%d,P1.r0:%d,C1.cachLine:%d,C1.state:%h",$time,P1.regFile[0],C1.cacheLine, C1.state);
    $display("time:%d,P2.r0:%d,C2.cachLine:%d,C2.state:%h",$time,P2.regFile[0],C2.cacheLine, C2.state);
    $display("mem[0]:%d", mb.mem[0]);
    $display("___________________________________________________");
    $stop;
end
always #5 clk = ~clk;
endmodule

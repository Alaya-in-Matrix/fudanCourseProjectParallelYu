`include "./def.v"
module testCodeRam;
reg reset,clk;
wire[`PCWIDTH-1:0] pc_proc1_code1,pc_proc2_code2;
wire[`INSWIDTH-1:0] ins_code1_proc1,ins_code2_proc2;
wire[`WORDWIDTH-1:0] dataOut1,dataOut2;
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

//debug vars
wire[`CPUSTATENUMWIDTH-1:0] cpuState;
wire[`WORDWIDTH-1:0]r0;
wire[`WORDWIDTH-1:0]r1;
wire[`REGWIDTH-1:0] regIdx;
codeRam code1(
    .pc(pc_proc1_code1),
    .ins(ins_code1_proc1)
);

reg[`INSWIDTH-1:0]testIns;
reg testWtEn,testRdEn;


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
    .dataFromMem(data_C1_P1),
    .cpuState(cpuState),
    .r0(r0),
    .r1(r1),
    .regId(regIdx)
);
wire testHavMsg_C2_C1    = 0;
wire testAllowRead_C2_C1 = 1;
wire [`STATEWIDTH-1:0] debugState;
wire [`WORDWIDTH-1:0] debugCacheLine;
cache C1(
    .clk(clk),
    .reset(reset),

    .rwFromCPU(rw_P1_C1),
    .addrFromCPU(addr_P1_C1),
    .dataFromCPU(data_P1_C1),
    .readEnToCPU(rdEn_C1_P1),
    .writeDoneToCPU(wtEn_C1_P1),
    .dataToCPU(data_C1_P1),

    .dataFromMem(data_M_C1),
    .readEnFromMem(rdEn_M_C1),
    .writeDoneFromMem(wtEn_M_C1),
    .rwToMem(rw_C1_M),
    .addrToMem(addr_C1_M),
    .dataToMem(data_C1_M),

    .havMsgFromCache(testHavMsg_C2_C1),
    .allowReadFromCache(testAllowRead_C2_C1),
    .addrFromCache(addr_C2_C1),
    .rmFromCache(rm_C2_C1),
    .wmFromCache(wm_C2_C1),
    .invFromCache(inv_C2_C1),
    .havMsgToCache(msg_C1_C2),
    .allowReadToCache(allowRead_C1_C2),
    .addrToCache(addr_C1_C2),
    .rmToCache(rm_C1_C2),
    .wmToCache(wm_C1_C2),
    .invToCache(inv_C1_C2),

    //debug ms
    .debugState(debugState),
    .debugCacheLine(debugCacheLine)
);
wire[`IOSTATEWIDTH-1:0] testRw_C2_M = `IDEL;
wire[`IOSTATEWIDTH-1:0] debugRwToMem;
wire[7:0] debugDelay;
memBus mb(
    .clk(clk),
    .reset(reset),

    .rwFromCacheA(rw_C1_M),
    .addrFromCacheA(addr_C1_M),
    .dataFromCacheA(data_C1_M),
    .dataToCacheA(data_M_C1),
    .rdEnToCacheA(rdEn_M_C1),
    .wbDoneToCacheA(wtEn_M_C1),

    .rwFromCacheB(testRw_C2_M),
    .addrFromCacheB(addr_C2_M),
    .dataFromCacheB(data_C2_M),
    .dataToCacheB(data_M_C2),
    .rdEnToCacheB(rdEn_M_C2),
    .wbDoneToCacheB(wtEn_M_C2),

    //debug output 
    .debugRwToMem(debugRwToMem),
    .debugDelay(debugDelay)
);
initial begin
    $monitor($time," adrTomMe = %b",addr_P1_C1);
end

initial begin 
    clk = 1'b0;
    reset = 1'b0;
    testWtEn = 1'b1;	
    testRdEn = 1'b1;
    code1.codes[0] = {`SET,`R0,`WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`SET,`R1,`WORDWIDTH'd4}; //p1.r0 = 3
    code1.codes[2] = {`ST,`R0,`ADDRWIDTH'd0};  //mem[0] = p1.r0, write miss
    code1.codes[3] = {`ST,`R0,`ADDRWIDTH'd1};  //mem[1] = p1.r0, write miss
    /* code1.codes[4] = {`LD,`R1,`ADDRWIDTH'd1};  //p1.r1 = mem[1], read hit */
    /* code1.codes[5] = {`LD,`R0,`ADDRWIDTH'd0};  //p1.r0 = mem[0], read miss */
    /* code1.codes[6] = {`ST,`R0,`ADDRWIDTH'd0}; */
    /* code1.codes[7] = {`NOP,`R0,`WORDWIDTH'd0}; */
    #5 reset = 1'b1;
    #17 reset = 1'b0;
    #2000 $stop;
end
always #10 clk = ~clk;
endmodule

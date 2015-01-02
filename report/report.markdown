# Cache一致性协议报告 #

* 吕文龙
* 14210720082

## project要求 ##
* 设计一个双核的cache coherency系统
    * 系统由两个处理器及一个share memory构成
    * 每个处理器含一个cache
    * Processor不需要完整的功能，但需要简单的读写memory的功能
    * 从MSI/MESI/Directory-based挑选一种protocol；
* 要求：
    * 完成RTL code，testbench验证系统，完成综合。
    * 递交code及文档。文档中要体现设计方案，验证方案及典型结果，综合结果。
    * 最后会有个课堂presentation。
* deadline: 12.26.2014

## 摘要 ##
实现了一个基于MSI总线监听协议的双核cache coherency模型. 包括:
*   两个具有指令计数器(PC), 包含五条指令, 实现取指译码(fetch and decode), 执行(exe),访存(mem)功能, 带两个register的processor
*   每个Processor各连接一个cache, 因为project重点是实现一致性协议, 每个cache只包含一条cacheline, 同时每个block只有一个word.
*   memory bus及data memory. data memory使用verilog中的reg变量模拟, 具有5个clock cycle的访存延迟.
*   code memory. 每个processor的PC连接一个code memory, 其中存储该processor的指令. 测试时只要把指令存入, 就可以通过PC自动加载.

完整的电路结构如下图所示:
[all](./image/all.png)
## MSI模型 ##

## 电路模块设计细节 ##
### code memory ###
```verilog
`include "./def.v"
module codeRam(
    input[`PCWIDTH-1:0] pc,
    output reg[`INSWIDTH-1:0] ins
);
parameter CODESIZE = 8; //a progra could have at most 8 instructions
reg[`INSWIDTH-1:0] codes[0:CODESIZE-1];
reg[3:0] codeSize;
always @(pc) begin 
    if(pc >= codeSize) begin 
        ins = 0; //return nop
    end
    else begin 
        ins = codes[pc];
    end 
end 
endmodule
```
code memory全部代码如上. 在code ram中, 输出为以指针计数器的值为地址的memory的值, 认为没有访存延迟. 当指令计数器的值超过程序指令数时, 输出nop指令, 其实可以认为code ram是一块不会发生read miss的code cache, 因为指令集中没有`jmp`指令, 所以PC只会顺序增加. 

这块memory只是用来存储指令, 用作测试. 因此并没有设计可综合的加载指令的功能, 需要在testbench代码中通过initial语句将指令载入code memory中, 并设置好code size, 相当于人肉编译器. 加载指令的形式如下面的代码:
```verilog
initial begin 
    clk            = 1'b0;
    reset          = 1'b0;
    code1.codeSize = 3;
    code2.codeSize = 3;
    code1.codes[0] = {`SET, `R0,    `WORDWIDTH'd3}; //p1.r0 = 3
    code1.codes[1] = {`ST,  `R0,    `ADDRWIDTH'd0}; //mem[0] = p1.r0, write miss
    code1.codes[2] = {`NOP, `R0,    `WORDWIDTH'd0}; //nop;
    code2.codes[0] = {`SET, `R0,    `WORDWIDTH'd4}; //p1.r0 = 3
    code2.codes[1] = {`NOP, `R0,    `WORDWIDTH'd0}; //nop
    code2.codes[2] = {`ST,  `R0,    `ADDRWIDTH'd0}; //mem[0] = p1.r0, write miss
    // rest of test bench code
end
```

### Processor   ### 
Processor具有五条指令, 能够完成内存读写, 寄存器读写功能, 对Processor来说, cache是透明的,指令分为fetch and decode, exe, mem三个阶段, 没有流水线, 当访存时, CPU要stall. Processor的Schematic框图如下:
[Processor](./image/processor.png)
#### 输入输出端口   ####
Processor的输入输出端口分别为:
*   clk,reset:  时钟与复位输入.
*   instruction:24位指令.
*   data:       运行GET指令读取某个寄存器中的值时的输出端口.
*   pcCounter:  程序计数器,与指令内存相连.
*   rwToMem:    与cache相连, 告诉cache是要读取还是写入, 有三个状态, read/write/idel.
*   addrToMem:  与cache相连, 告诉cache要读取/写入的地址.
*   dataToMem:  与cache相连, 向cache传入要写入的数据.
*   cacheEn:    由cache输入的信号, 当CPU要访存时, 由1变成0, 当访存完毕, 则输入正脉冲.
*   其他用作debug的输出端口

#### 内部硬件       ####
*   Processor中包含两个寄存器, 寄存器位宽为16bit.

#### 指令集         ####
为CPU设计了5条简单的指令, 指令为24位, 其中4位表示指令类型, 4位为寄存器ID, 16位为内存地址或者立即数, 指令格式均为`OP REGID ADR_DATA`. 其实五条指令用3bit就可以表示, 之所以用四个bit, 只是为了在使指令代码在16进制的波形图中更可读. 五条指令类型分别如下:
```verilog
`define NOP  4'd0 //nop, do nothing
`define LD   4'd1 //ld registerIdx addr: load data from memory to register
`define ST   4'd2 //st registeridx addr: store value of one register to memory(cache)
`define SET  4'd3 //set registeridx data: set value of one register as data in the instruction
`define GET  4'd4 //read the value of one register
```
#### 状态模型       ####
一条指令的执行流程分为fetch and decode, exe, mem三个过程, 另外增加了一个error state, 用来进行出错检测, 当cpu进入error state后, 就再也无法转到其他状态, 除非摁下reset键. 

每个时钟上升沿, 如果reset无效并且状态不是error, 则检查当前的state.
如果当前状态为fetch, 则说明取指与译码已经完成, 转入exe阶段. 代码如下:
```verilog
else if(state == `FETCH) begin 
    //counter,state,data,rwtomem,addrtomem,datatomem
    state   = `EXE;
    rwToMem = `IDEL;
end 
```

如果当前状态为exe, 则对于nop指令, 设置下一个状态为fetch, 对于`set`和`get`指令, 分别完成对寄存器的修改或者读取, 然后转入fetch状态, 即`nop`,`set`,`get`三条指令, 执行只需要两个cycle.对于`ld`和`st`指令, 则设置相应的地址/数据输出, 转入mem阶段.

如果当前状态为mem, 则指令只可能是`ld`或者`st`, 如果不是, 说明有硬件错误, 转入error state
当转入mem状态时, 或者cache目前正在执行其他访存动作(如响应其他cache总线广播的写回动作) 由cache输入的cacheEn会被置零, 当cache完成访存(hit或者miss并且完成访存)后, cacheEn会有一个正脉冲, 如果cacheEn为0, 则等待, 如果检测到cacheEn为1, 则fetch下一条指令. 如下图所示:
[cacheEn](./image/cacheEn.png)
### Cache   ### 
cache的schematic框图如下:
[CACHE](./image/cache.png)
#### 设计思路 ####
cache是本设计的重点与难点, 基本状态转换关系为课程课件上的MSI状态转换图. 因为电路设计的经验不多, 在设计时, 遇到的困难主要有以下三点:
1. 某个cycle同时监听到总线信息和CPU访存请求时的处理
2. 课程课件上的状态转换图只有MODFIED, SHARED, INVALID三种状态, 但这个状态图并非是一个cycle to cycle的状态转换图. 即, 状态的转换尚需要许多中间动作, 这些中间动作本质上是新的状态.例如, 当状态为MODIFIED的cacheline遇到write miss时, 需要执行的动作为:
    * 写回cacheline中的数据
    * 等待其他cache写回miss的内存数据
    * 读取目标地址的内存数据
    * 修改cacheLine中的内存数据
也就是说, 在这个modified to modified的状态转换关系中, 其实cache需要执行一次写回操作和一次读取操作.
3. 两个cache之间的通信以及互动

本设计对以上三个问题的解决方案为: 
    1. cacheLine在每个clock cycle首先检查总线信息, 如果总线上有信息, 则优先处理总线信息.
    2. 设置一些中间状态, 即除了MSI三个状态之外, 另设计一些中间状态表示状态转换的进程. 例如, 上面的MODIFIEDcacheline遭遇write miss为例, 新增了M_WM_WB和M_WM_RD两个状态, 于是原本modified to modified的状态转换关系现在变为modified->m_wm_wb->M_WM_RD->modified. 这些中间状态的前一个状态和目标状态都是唯一的. 此外, 像processor一样, 设置了一个error状态. 只可能从其他状态转入error状态, 不可能从error状态转入其他状态. 除非摁下reset键.
    3. 因为是双核系统, 因此cache之间可以直接互联, 一个cache向另一个cache发送的信号有:
        *    havMsgToCache:      表示遇到write miss或者read miss, 有需要广播的信息. 
        *    addrToCache:        表示write miss或者write miss的数据地址.
        *    rmToCache:          表示遇到read miss
        *    wmToCache:          表示遇到write miss
        *    invToCache:         invalidate信号
        *    allowReadToCache:   响应其他cache的miss信号, 譬如遇到read miss而在本cache中为modified时, 在这个cache写回完毕之前, 不允许另一个cache发送访存信号, allowReadToCache置零.

#### 输入输出端口 ####       
输入输出端口列表如下:
```verilog
input clk,  //时钟信号
input reset,//复位信号

input[`IOSTATEWIDTH-1:0] rwFromCPU,         //表示CPU访存动作, 允许状态有read/write/idel
input[`ADDRWIDTH-1:0]    addrFromCPU,       //由CPU传入的访存地址
input[`WORDWIDTH-1:0]    dataFromCPU,       //由CPU传入的数据
input[`WORDWIDTH-1:0]    dataFromMem,       //从memory取回的数据
input                 memEn,                //memory bus向cache发送的表示访存完成的信号
input                 havMsgFromCache,      //表示收到其他cache的广播
input                 rmFromCache,          //收到广播的read miss信号
input                 wmFromCache,          //收到广播的write miss信号
input                 invFromCache,         //收到广播的invalidate信号
input                 allowReadFromCache,   //表示这个cache不必等待其他cache的访存完成
input[`ADDRWIDTH-1:0] allowReadFromCacheAddr,   //需要等待其他cache访存完成的地址
input[`ADDRWIDTH-1:0] addrFromCache,        //其他cache广播信号的内存地址
output reg                    cacheEnToCPU, //告诉CPU写入完成或者可以放心读取数据
output reg[`WORDWIDTH-1:0]    dataToCPU,    //响应CPU read发送的数据
output reg[`IOSTATEWIDTH-1:0] rwToMem,      //cache访存的动作, 可以为write/read/idel
output reg[`ADDRWIDTH-1:0]    addrToMem,    //传入memory的地址
output reg[`WORDWIDTH-1:0]    dataToMem,    //要写入memory的数据
output reg havMsgToCache,                   //表示有需要广播的信号
output reg allowReadToCache,                //表示其他cache是否需要等待本cache完成访存才能读取特定地址数据
output reg[`ADDRWIDTH-1:0] allowReadToCacheAddr, //本cache正在访存因而其他cache不能读取的内存地址
output reg[`ADDRWIDTH-1:0] addrToCache,     //bus广播中的内存地址
output reg rmToCache,                       //广播read miss信号
output reg wmToCache,                       //广播write miss信号
output reg invToCache,                      //广播invalidate信号
```
#### 状态关系转换 ####
为一条cacheline定义了以下几种状态
```verilog
`define ERROR      4'h0     //表示cacheline遇到了硬件错误.
`define MODIFIED   4'h1     //表示cacheline为MODIFIED.
`define M_SRM_WB   4'h2     //表示cacheline为MODIFIED, 并且监听到了总线上的readmiss 信号, 正在执行写回操作.
`define M_SWM_WB   4'h3     //表示cacheline为MODIFIED, 并且监听到了总线上的writemiss信号, 正在执行写回操作.
`define M_WM_WB    4'h4     //表示cacheline为MODIFIED, 并且遇到了CPU writemiss, 正在执行写回操作.
`define M_RM_WB    4'h5     //表示cacheline为MODIFIED, 并且遇到了CPU readmiss,  正在执行写回操作.
`define M_WM_RD    4'h6     //表示cacheline为MODIFIED, 并且遇到了CPU writemiss, 已经执行完写回操作, 正在执行读取操作.
`define M_RM_RD    4'h7     //表示cacheline为MODIFIED, 并且遇到了CPU readmiss,  已经执行完写回操作, 正在执行读取操作.
`define SHARED     4'h8     //表示cacheline为SHARED.
`define S_RM_RD    4'h9     //表示cacheline为SHARED, 并且遇到了CPU readmiss, 正在执行读内存操作.
`define S_WM_RD    4'ha     //表示cacheline为SHARED, 并且遇到了CPU writemiss, 正在执行读内存操作.
`define INVALID    4'hb     //表示cacheline为INVALID.
`define I_RM_RD    4'hc     //表示cacheline为INVALID, 并且遇到了read miss,正在执行读内存操作.
`define I_WM_RD    4'hd     //表示cacheline为INVALID, 并且遇到了writemiss, 正在执行读内存操作.
```
在时钟上升沿, 检测cacheLine的状态,或者复位信号, 并执行相应的动作.
对于MODIFIED状态: 如果检测到总线上的readmiss或者writemiss信号, 则执行写回操作, 并将状态置为M_SRM_WB/M_SWM_WB. 否则, 检查CPU动作, 如果readhit/writehit, 则状态仍为MODIFIED. 如果发现readmiss/writemiss, 则执行写回操作, 发送总线广播信号, 并将状态置为M_RM_WB或M_WM_WB. 表示正在执行写回操作, 写回完成之后需要进行读取.

对于M_SRM_WB状态, 本状态说明cache正在进行响应readmiss的写回操作, 此时检测memEn信号判断写回是否已经完成, 如果没有完成, 则等待. 如果写回已经完成, 则状态转为SHARED. 这里需要注意, 因为本cache完成系会操作是因为监听到了其他cache的miss信息, 即本cache完成写回后, 另一cache要立刻读取写回的内存的, 因此, 此时如果本cache上也有CPU上的miss信息,即在本cache访存期间, CPU又执行了需要访存的指令, cache的处理需要stall一个cycle.

对于M_SWM_WB状态, 处理方式与M_SRM_WB大致相同, 只不过最后的状态不是转向SHARED, 而是转向INVALID.

对于M_RM_WB
### Bus and Memory  ###
## 测试报告 ##
## 综合结果 ##

## todo ##
* 冗余状态合并
* 两个processor指令同步
* 对memory的exchange原子操作
## 参考文献 ##
* cache一致性协议维基百科
* 量化研究方法
* verilog教程

<input type='hidden' id='markdowncodestyle' value='vs'>

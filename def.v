`define ADDRWIDTH 16
`define WORDWIDTH 16
//`define BLOCKSIZE 8

//需不需要为已经broad cast而其他cache还没有完成写回单独设置一个状态?
//各种状态的WM_RD与RM_RD(inv,shared)似乎可以合并.
`define STATEWIDTH 4
`define ERROR      4'h0     //(done)
`define MODIFIED   4'h1     //(done)
`define M_SRM_WB   4'h2     //modified, snooped read miss,writing back
`define M_SWM_WB   4'h3     //modified, snooped write miss, writing back
`define M_WM_WB    4'h4     //modified, cpu write miss, writing back
`define M_RM_WB    4'h5     //modified, cpu read miss, writing back
`define M_WM_RD    4'h6     //modified, cpu write miss, finished writing back, other cache has write back its copy, reading
`define M_RM_RD    4'h7     //modified, cpu read miss, finished writing back, other cache has write back its copy, reading
`define SHARED     4'h8     //shared.
`define S_RM_RD    4'h9     //shared, cpu read miss, other cache has write back its copy,reading
`define S_WM_RD    4'ha   //shared, cpu write miss, other cache has wrtie back its copy,reading
`define INVALID    4'hb   //INVALID
`define I_RM_RD    4'hc    //invalid, cpu read miss, other cache has write back its copy,reading
`define I_WM_RD    4'hd    //invalid, cpu write miss, other cache has write back its copy, reaading

`define IOSTATEWIDTH 2
`define RD   2'd0
`define WT   2'd1
`define IDEL 2'd2


`define ERRWIDTH          4
`define ERR_UNKNOWN       4'd0
`define ERR_ADDR_MISMATCH 4'd1
`define ERR_MEMRW         4'd2
`define NOERR             4'd3
`define ERR_CPUOP         4'd4


`define INSWIDTH 24 //(4+4+16)
`define OPWIDTH 4 //we have 5 operations(ld,st,nop,end,set)
`define REGWIDTH 4 //one bit to specify register
`define RESTINSWIDTH 16
`define R0 4'd0
`define R1 4'd1
`define REGNUM 4 //two register
`define PCWIDTH 8
`define LD   4'd0
`define ST   4'd1
`define NOP  4'd2
`define SET  4'd3
`define GET  4'd4 //相当于Print函数, 用于传递寄存器数据到外部


`define CPUSTATENUM 3
`define CPUSTATENUMWIDTH 2
`define FETCH 2'd0
`define EXE   2'd1
`define MEM   2'd2
`define ERR   2'd3


`define MEMWORDS 32 //32 word * 2B/word

`define ADDRWIDTH 16
`define WORDWIDTH 16
//`define BLOCKSIZE 8

//需不需要为已经broad cast而其他cache还没有完成写回单独设置一个状态?
//各种状态的WM_RD与RM_RD(inv,shared)似乎可以合并.
`define STATEWIDTH 4
`define ERROR      4'd0     //(done)
`define MODIFIED   4'd1     //(done)
`define M_SRM_WB   4'd2     //modified, snooped read miss,writing back
`define M_SWM_WB   4'd3     //modified, snooped write miss, writing back
`define M_WM_WB    4'd4     //modified, cpu write miss, writing back
`define M_RM_WB    4'd5     //modified, cpu read miss, writing back
`define M_WM_RD    4'd6     //modified, cpu write miss, finished writing back, other cache has write back its copy, reading
`define M_RM_RD    4'd7     //modified, cpu read miss, finished writing back, other cache has write back its copy, reading
`define SHARED     4'd8     //shared.
`define S_RM_RD    4'd9     //shared, cpu read miss, other cache has write back its copy,reading
`define S_WM_RD    4'd10    //shared, cpu write miss, other cache has wrtie back its copy,reading
`define INVALID    4'd11    //INVALID
`define I_RM_RD    4'd12    //invalid, cpu read miss, other cache has write back its copy,reading
`define I_WM_RD    4'd13    //invalid, cpu write miss, other cache has write back its copy, reaading

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

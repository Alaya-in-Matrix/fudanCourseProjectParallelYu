`define CORENUM      2       //dual core
`define REGISTERNUM  32      //32 registers per processor
`define WORDSIZE  8       //8 bit per register
`define BLOCKBYTE    8       //8 byte per block
`define CACHELINENUM 16      //cache size: 16blocks * 8b/block = 128B
`define MEMSIZE      65536   //memory size 4KB
`define ADDRESSBIT   16      //16bit address


// indicate whether a cache want to read or write memory
`define RD 1'b0
`define WT 1'b1
//memory access have 100 cycle delay
`define MEM_ACCESS_DELAY 100 
`define ACCESSING 0
`define ACCESS_SUCCESS 1

`define SNOOPMSGWIDTH 16

`define MODIFIED 2'b00
`define SHARED   2'b01
`define INVALID  2'b10

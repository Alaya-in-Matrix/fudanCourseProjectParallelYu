`define CORENUM      2       //dual core
`define REGISTERNUM  32      //32 registers per processor
`define WORDSIZE  8       //8 bit per register
`define BLOCKBYTE    8       //8 byte per block
`define MEMSIZE      65536   //memory size 4KB

`define CACHELINENUM 16      //cache size: 16blocks * 8b/block = 128B
`define CACHELINEIDXBIT 4

`define ADDRESSBIT   16      //16bit address
`define OFFSETADDRBIT 3
`define BLOCKADDRBIT 13


// indicate whether a cache want to read or write memory
`define RD 1'b0
`define WT 1'b1
//memory access have 100 cycle delay
`define MEM_ACCESS_DELAY 100 

`define ACCESSING 1'b0
`define ACCESS_SUCCESS 1'b1


`define MODIFIED 2'b00
`define SHARED   2'b01
`define INVALID  2'b10

`define READHIT 2'b00
`define READMISS 2'b01
`define WRITEHIT 2'b10
`define WRITEMISS 2'b11


//snoop message
`define SNOOPACTIONWIDTH 3 //0~7
`define MSG_READMISS          3'd0 //one cache read miss
`define MSG_WRITEMISS         3'd1 //one cache write miss
`define MSG_INVALIDATE        3'd2 //cache receives this msg need to invalidate its block
`define MSG_WRITEBACK_SUCCESS 3'd3 //one cache has successfully
`define MSG_READ_SUCCESS      3'd4
`define MSG_NOTHING           3'd5 //no message from bus


`define ERRWIDTH 3
`define NOERR                3'd1
`define CACHE_STATUS_ERR     3'd2
`define CACHE_MEM_ACTION_ERR 3'd3
`define BUS_ACTION_ERR       3'd4
`define MEM_ERR              3'd5

#ifndef __GLOBAL_DEF__
#define __GLOBAL_DEF__

#include <cassert>

#define CORENUM 2       //dual core 
#define REGISTERNUM 32  //32 registers per processor
#define REGISTERBIT 8   //8 bit per register
#define BLOCKBYTE 8     //8 byte per block
#define CACHELINENUM 16 //cache size: 16blocks * 8b/block = 128B
#define MEMSIZE 65536    //memory size 4KB
#define ADDRESSBIT 16   //16bit address
/*
 * address: unsigned short, 16bit address
 * register: unsigned int, 32bit, 1 word
 * block: 8word, 32*8=256bit/32byte
 */

unsigned short fastExpr(unsigned char n)
{
    assert(n <= 16);
    if(n == 0)
        return 1;
    else if(n == 1)
        return 2;
    else if(n % 2 == 0)
        return 2 * fastExpr(n/2);
    else 
        return 2 * fastExpr(n-1);
}
unsigned short getBlockAddress(unsigned short address)
{
    return address / fastExpr(BLOCKBYTE);
}
enum status{
    ERROR_STATUS = 0,
    MODIFIED = 1,
    SHARED   = 2,
    INVALID  = 3,
    WAITING  = 4 //WAITING FOR BUS
};
enum broadCastMsg{
    WRITE_MISS ,
    READ_MISS,
    INVALID
};
#endif

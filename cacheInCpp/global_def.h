#ifndef __GLOBAL_DEF__
#define __GLOBAL_DEF__

#include <cassert>

#define ERROR_STATUS 0;

#define REGISTERNUM 32  //32 registers per processor
#define REGISTERBIT 8   //8 bit per processor
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
    MODIFIED = 0,
    SHARED   = 1,
    INVALID  = 2
};
enum broadCastMsg{
    WRITE_MISS = 0,
    READ_MISS,
    INVALIDATE
};
#endif

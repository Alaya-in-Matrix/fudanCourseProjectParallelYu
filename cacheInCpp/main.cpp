#include<iostream>
#include "global_def.h"
#include "cache.h"
#include "bus.h"
#include "processor.h"
int main()
{
    CacheBus* b = new CacheBus();
    unsigned char* mem = new unsigned char[MEMSIZE];
    Processor P0(0,REGISTERNUM,CACHELINENUM,mem,b);
    Processor P1(1,REGISTERNUM,CACHELINENUM,mem,b);
    delete mem;
    return 0;
}

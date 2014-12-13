#include<iostream>
#include "global_def.h"
#include "bus.h"
#include "cache.h"
#include "processor.h"
int main()
{
    Bus* b = new Bus();
    unsigned char* mem = new char[MEMSIZE];
    Processor P0(0,REGISTERNUM,CACHELINENUM,mem,b);
    Processor P0(1,REGISTERNUM,CACHELINENUM,mem,b);
    delete mem;
    return 0;
}

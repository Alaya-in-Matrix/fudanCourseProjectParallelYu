/*
 * behavior description of the cache coherency mechanism for a two core processor
 */
#include<iostream>
#include "global_def.h"
#include "mem.h"
#include "cache.h"
#include "processor.h"

int main()
{
    Memeory mem(MEM_SIZE);//singleton 
    /* Cache cache(CORE_NUM,CACHE_SIZE); */
    //need to test: false sharing
    Processor *p = new Processor[CORE_NUM];
    for(int i = 0 ; i < CORE_NUM; i++)
    {
        p[i] = new Processor(cache[i]);
    }
    return 0;
}

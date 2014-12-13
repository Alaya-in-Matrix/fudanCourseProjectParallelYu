#include<iostream>
#include<stdio.h>
#include "global_def.h"
#include "cache.h"
#include "bus.h"
#include "processor.h"
int main()
{
    CacheBus* b = new CacheBus();
    unsigned char* mem = new unsigned char[MEMSIZE];
	for(int i=0;i<MEMSIZE;i++)
		mem[i]=0;
    Processor P0(0,REGISTERNUM,CACHELINENUM,mem,b);
    Processor P1(1,REGISTERNUM,CACHELINENUM,mem,b);
	P0.setReg(0,3); //mov p0.r0 val(3)
	P0.store(0,4);  //store addr(4) p0.r0
	P0.load(0,4);	//load p0.r0 addr(4)
	printf("%d\n",mem[4]);
	P0.print(0);   

	P1.setReg(0,9); //mov p1.r0 val(9);
	P1.store(0,5);  //store addr(4) p1.r0;


	P0.load(0,4);
	P0.print(0);
    delete mem;
    return 0;
}

#include"global_def.h"
unsigned short getBlockAddress(unsigned short address)
{
    //return address / fastExpr(BLOCKBYTE);
	unsigned short blockAddr = address;
	for(int i=0; i<BLOCKBYTE;i++)
		blockAddr /= 2;
	return blockAddr;
}

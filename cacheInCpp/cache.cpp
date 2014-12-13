#include<iostream>
#include<cassert>
#include"cache.h"
#include"bus.h"
#include"global_def.h"
Cache::Cache(CacheBus* b,unsigned char* m, int cidx, int bnum)
{
    cacheIdx = cidx;
    blockNum = bnum;
    blocks   = new CacheBlock[bnum];
    bus      = b;
    mem      = m;
    
	for(int i=0;i<bnum;i++)
	{
		blocks[i].block_status = INVALID;
	}
    bus->addCache(cacheIdx,this);
}

Cache::~Cache(){
	delete blocks;
	bus->setNull(cacheIdx);
}
bool Cache::hit(unsigned short blockAddress){
    int cacheLine = blockAddress % blockNum;
    return blockAddress == blocks[cacheLine].blockAddress;
}
void Cache::set_status(unsigned short a, status s)
{
    int cacheLine = a % blockNum;
    blocks[a].block_status = s;
}
void Cache::loadFromMemory(unsigned short blockAddress)
{
    int cacheLine = blockAddress % blockNum;
    std::cout<<"need to check startAddress"<<std::endl;
    unsigned short startAddress = blockAddress * BLOCKBYTE;
    
    blocks[cacheLine].blockAddress = blockAddress;
    for(unsigned short i = 0; i < BLOCKBYTE; i++)
    {
        blocks[cacheLine].block[i] = mem[startAddress+i];
    }
}
void Cache::write_back(int cacheLine)
{
    unsigned short startAddress = blocks[cacheLine].blockAddress * BLOCKBYTE;
    for(int i = 0; i < BLOCKBYTE; i++)
        mem[startAddress+i] = blocks[cacheLine].block[i];
}
void Cache::write(unsigned char data, unsigned short address)
{
    unsigned short blockAddress = getBlockAddress(address);
    unsigned short offset       = address % BLOCKBYTE;
    int cacheLine               = blockAddress % CACHELINENUM;
    switch(blocks[cacheLine].block_status)
    {
        case INVALID:
            bus->broadcast(cacheIdx,WRITE_MISS,blockAddress,INVALID);//putting message to msg queue
            loadFromMemory(blockAddress);
            blocks[cacheLine].block[offset] = data;
            blocks[cacheLine].block_status = MODIFIED;
            break;
        case MODIFIED:
            if(hit(blockAddress))//write hit
            {
                blocks[cacheLine].block[offset] = data;
            }
            else //write miss
            {
                write_back(cacheLine);
                bus->broadcast(cacheIdx,WRITE_MISS,blockAddress,MODIFIED);
                loadFromMemory(blockAddress);
                blocks[cacheLine].block[offset] = data;
            }
            break;
        case SHARED:
            if(hit(blockAddress))//write hit
            {
                blocks[cacheLine].block[offset] = data;
                blocks[cacheLine].block_status  = MODIFIED;
                bus->broadcast(cacheIdx,INVALIDATE,blockAddress,SHARED);
            }
            else //write miss
            {
                bus->broadcast(cacheIdx,WRITE_MISS,blockAddress,SHARED);
                loadFromMemory(blockAddress);
                blocks[cacheLine].block[offset] = data;
                blocks[cacheLine].block_status  = MODIFIED;
            }
            break;
        default:
            assert(ERROR_STATUS);
    }
    assert(blocks[cacheLine].block_status == MODIFIED);
}
unsigned char  Cache::fetch(unsigned short address)
{   //cpu read cache
    unsigned short blockAddress = getBlockAddress(address);
    unsigned short offset       = address % BLOCKBYTE;
    int cacheLine               = blockAddress % CACHELINENUM;
    std::cout<<"need to test the correctness of blockAddress and offset"<<std::endl;
    switch(blocks[cacheLine].block_status)
    {
        case INVALID:
            bus->broadcast(cacheIdx,READ_MISS,blockAddress,INVALID);//putting message to msg queue
            loadFromMemory(blockAddress);
			blocks[cacheLine].block_status = SHARED;
            break;
        case MODIFIED:
            if(hit(blockAddress))//read hit
            {}
            else //read miss
            {
                write_back(cacheLine);
                bus->broadcast(cacheIdx,READ_MISS,blockAddress,INVALID);//putting message to msg queue
                loadFromMemory(blockAddress);
				blocks[cacheLine].block_status = SHARED;
            }
            break;
        case SHARED:
            if(hit(blockAddress))
            {}
            else
            {
                bus->broadcast(cacheIdx,READ_MISS,blockAddress,SHARED);
                loadFromMemory(blockAddress);
				blocks[cacheLine].block_status = SHARED;
            }
            break;
        default:
            assert(ERROR_STATUS);
    }
    assert(blocks[cacheLine].block_status != INVALID);
    return blocks[cacheLine].block[offset];
}
status Cache::getStatus(unsigned short blockAddress){return blocks[blockAddress%blockNum].block_status;}

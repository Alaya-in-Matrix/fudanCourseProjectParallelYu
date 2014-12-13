#ifndef __CACHE_H__
#define __CACHE_H__

#include<iostream>
#include<cassert>
#include<thread>

struct CacheBlock
{
    status block_status;
    unsigned address blockAddress;
    unsigned char block[BLOCKBYTE];
};
class Cache 
{
    friend class Bus;
    private:
        Bus* bus; // a bus, is a cacheIdx array and a message queue
        unsigned char* mem;
        CacheBlock* blocks;
        int blockNum;
        int cacheIdx;

        void snoop();//receive message from bus
        bool hit(unsigned short blockAddress, int cacheLine);
        void loadFromMemory(unsigned short blockAddress);
    public:
        Cache(Bus* bus,unsigned char* mem,int cidx, int bnum);
        ~Cache(){
            delete blocks;
            bus.setNull(cacheIdx);
            //have to remove cache in bus's  cache list
        }//no need to delete bus, it is an outer device
        void write_back(unsigned short blockAddress);
        void write(unsigned char data, unsigned short address);
        int fetch(unsigned short address);
        void set_status(unsigned short blockAddress,status s);
        status getStatus(unsigned short blockAddress){return blocks[blockAddress%blockNum].block_status;}:w

};
Cache::Cache(Bus* b,unsigned char* m, int cidx, int bnum)
{
    cacheIdx = cidx;
    blockNum = bnum;
    blocks   = new CacheBlock[bnum];
    bus      = b;
    mem      = m;
    
    bus.addCache(cacheIdx,this);
}
bool Cache::hit(unsigned short blockAddress){
    int cacheLine = blockAddress % blockNum;
    return blockAddress == blocks[cacheLine].block_status;
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
void write(unsigned char data, unsigned short address)
{
    unsigned short blockAddress = getBlockAddress(address);
    unsigned short offset       = address % BLOCKBYTE;
    int cacheLine               = blockAddress % CACHELINENUM;
    switch(blocks[cacheLine].block_status)
    {
        case INVALID:
            blocks[cacheLine].block_status = WAITING;
            bus.broadcast(cacheIdx,WRITE_MISS,blockAddress,INVALID);//putting message to msg queue
            loadFromMemory(blockAddress);
            blocks[cacheLine].block[offset] = data;
            assert(blocks[cacheLine].block_status == MODIFIED);
            break;
        case MODIFIED:
            if(hit(blockAddress))//write hit
            {
                blocks[cacheLine].block[offset] = data;
            }
            else //write miss
            {
                blocks[cacheLine].block_status = WAITING;
                write_back(cacheLine);
                bus.broadcast(cacheIdx,WRITE_MISS,blockAddress,MODIFIED);
                loadFromMemory(blockAddress);
                blocks[cacheLine].block[offset] = data;
            }
            break;
        case SHARED:
            if(hit(blockAddress))//write hit
            {
                blocks[cacheLine].block[offset] = data;
                blocks[cacheLine].block_status  = MODIFIED;
                bus.broadcast(cacheIdx,INVALID,blockAddress,SHARED);
            }
            else //write miss
            {
                blocks[cacheLine].block_status = WAITING;
                bus.broadcast(cacheIdx,WRITE_MISS,blockAddress,SHARED);
                loadFromMemory(blockAddress);
                blocks[cacheLine].block[offset] = data;
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
            blocks[cacheLine].block_status = WAITING;
            bus.broadcast(cacheIdx,READ_MISS,blockAddress,INVALID);//putting message to msg queue
            loadFromMemory(blockAddress);
            break;
        case MODIFIED:
            if(hit(blockAddress,cacheLine))//read hit
            {}
            else //read miss
            {
                write_back(cacheLine);
                bus.broadcast(cacheIdx,READ_MISS,blockAddress,INVALID);//putting message to msg queue
                loadFromMemory(blockAddress);
            }
            break;
        case SHARED:
            if(hit(blockAddress))
            {}
            else
            {
                bus.broadcast(cacheIdx,READ_MISS,blockAddress,SHARED);
                loadFromMemory(blockAddress);
            }
            break;
        default:
            assert(ERROR_STATUS);
    }
    assert(blocks[cacheLine].block_status != INVALID);
    assert(blocks[cacheLine].block_status != WAITING);
    return blocks[cacheLine].block[offset];
}
#endif

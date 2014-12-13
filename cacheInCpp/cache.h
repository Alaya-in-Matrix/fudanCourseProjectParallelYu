#ifndef __CACHE_H__
#define __CACHE_H__

#include<cassert>

struct CacheBlock
{
    status block_status;
    unsigned address blockAddress;
    unsigned char block[BLOCKBYTE];
};
class Cache 
{
    private:
        Bus* bus; // a bus, is a cacheIdx array and a message queue
        unsigned char* mem;
        CacheBlock* blocks;
        int blockNum;
        int cacheIdx;

        void broadcast();
        void write_back(unsigned short blockAddress);
    public:
        Cache(Bus* bus,unsigned char* mem,int cidx, int bnum);
        ~Cache(){
            //no need to delete bus, it is an outer device
            delete blocks;
        }
        void snoop();//receive message from bus
        void write(unsigned char data, unsigned short address);
        int fetch(unsigned short address);
};

Cache::Cache(Bus* b,unsigned char* m, int cidx, int bnum)
{
    cacheIdx = cidx;
    blockNum = bnum;
    blocks   = new CacheBlock[bnum];
    bus      = b;
    mem      = m;
}
void write(unsigned char data, unsigned short address)
{
    unsigned short blockAddress = getBlockAddress(address);
    unsigned short offset       = address % BLOCKBYTE;
    int cacheLine               = blockAddress % CACHELINENUM;
    
    /* blocks[cacheLine][offset] = data; */
    switch(blocks[cacheLine].block_status)
    {
        case INVALID:
            broadcast(cacheIdx,WRITE_MISS,blockAddress);
            blocks[cacheLine].status = MODIFIED;
            break;
        case MODIFIED:
            if(blockAddress == blocks[cacheLine].blockAddress)//write hit
            {
                blocks[cacheLine][offset] = data;
            }
            else //write miss
            {
                write_back(cacheLine);
                broadcast(cacheIdx,WRITE_MISS,blockAddress);
            }
            break;
        case SHARED:
            if(blockAddress == blocks[cacheLine].blockAddress)
            {

            }
            else 
            {
            }
            break;
        default:
            assert(ERROR_STATUS);
    }
}
#endif

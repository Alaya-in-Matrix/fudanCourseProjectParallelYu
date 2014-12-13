#ifndef __BUS_H__
#define __BUS_H__

#include<iostream>
#include<cassert>
#include<queue>
#include<vector>
#include "cache.h"

class Bus
{
    private:
        cache* caches;
    public:
        Bus(){
            caches = new int[CORENUM];
            for(int i=0;i<CORENUM;i++)
                caches[i] = nullptr;
        };
        ~Bus(){
            delete caches;
        };
        void setNull(int idx){cache[idx] = nullptr;}
        void addCache(int idx,cache* c){caches[idx]=c;}
        void broadcast(int cacheIdx,broadCastMsg msg,unsigned short blockAddress, status cacheStatus);
};
void Bus::broadcast(int cIdx,broadCastMsg msg,unsigned short blockAddress,status cacheStatus)
{
    for(int i = 0; i < caches.size(); i++)
    {
        cache* it = caches[i];
        if(it->hit(blockAddress) && i != cIdx)//has this block
        {
            status = it->getStatus(blockAddres);
            int blockNum = it->blockNum;
            switch(status)
            {
                case INVALID:
                    break;
                case SHARED:
                    if(msg == WRITE_MISS || msg == INVALID)
                    {
                        it->set_status(blockAddress,INVALID);
                    }
                    break;
                case MODIFIED:
                    alert(msg != INVALID);
                    if(msg == READ_MISS)
                    {
                        it->set_status(blockAddress,SHARED);
                    }
                    else if(msg == WRITE_MISS)
                    {
                        it->set_status(blockAddress,INVALID);
                    }
                    it->write_back(blockAddress);
                    break;
                default:
                    assert(ERROR_STATUS);
            }
        }
    }
}
#endif

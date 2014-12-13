#ifndef __BUS_H__
#define __BUS_H__

#include<iostream>
#include<cassert>
#include<vector>
#include"global_def.h"
class Cache;
class CacheBus
{
    private:
		std::vector<Cache*> caches;
    public:
        CacheBus();
        ~CacheBus();
        void setNull(int idx);
        void addCache(int idx,Cache* c);
        void broadcast(int cacheIdx,broadCastMsg msg,unsigned short blockAddress, status cacheStatus);
};
#endif

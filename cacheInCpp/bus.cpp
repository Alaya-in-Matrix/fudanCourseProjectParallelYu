#include<iostream>
#include<cassert>
#include<vector>
#include"bus.h"
#include"cache.h"
#include"global_def.h"

CacheBus::CacheBus(){
	//caches = new Cache[CORENUM];
	for(int i=0;i<CORENUM;i++)
		caches.push_back(NULL);
};
CacheBus::~CacheBus(){
	for(int i=0;i<CORENUM;i++)
		setNull(i);
};
void CacheBus::setNull(int idx){caches[idx] = NULL;}
void CacheBus::addCache(int idx,Cache* c){caches[idx]=c;}
void CacheBus::broadcast(int cIdx,broadCastMsg msg,unsigned short blockAddress,status cacheStatus)
{
    for(int i = 0; i < caches.size(); i++)
    {
        Cache* it = caches[i];
		bool fuck = it->hit(blockAddress);
        if(it!=NULL &&it->hit(blockAddress) && i != cIdx)//has this block
        {
            status s = it->getStatus(blockAddress);
            switch(s)
            {
			case status::INVALID:
				break;
			case status::SHARED:
				if(msg == broadCastMsg::WRITE_MISS || msg == broadCastMsg::INVALIDATE)
				{
					it->set_status(blockAddress,status::INVALID);
				}
				break;
			case status::MODIFIED:
				assert(msg != broadCastMsg::INVALIDATE);
				if(msg == broadCastMsg::READ_MISS)
				{
					it->set_status(blockAddress,status::SHARED);
				}
				else if(msg == WRITE_MISS)
				{
					it->set_status(blockAddress,status::INVALID);
				}
				it->write_back(blockAddress);
                    break;
                default:
                    assert(ERROR_STATUS);
            }
        }
    }
}

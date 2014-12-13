#ifndef __CACHE_H__
#define __CACHE_H__

#include<iostream>
#include<cassert>
#include<thread>
#include"global_def.h"
class CacheBus;
class Cache 
{
private:
	struct CacheBlock
	{
		status block_status;
		unsigned short blockAddress;
		unsigned char block[BLOCKBYTE];
	};
	CacheBus* bus; 
	unsigned char* mem;
	CacheBlock* blocks;
	int blockNum;
	int cacheIdx;

	void loadFromMemory(unsigned short blockAddress);
public:
	Cache(CacheBus* bus,unsigned char* mem,int cidx, int bnum);
	~Cache();
	bool hit(unsigned short blockAddress);
	void write_back(int cacheLine);
	void write(unsigned char data, unsigned short address);
	unsigned char fetch(unsigned short address);
	void set_status(unsigned short blockAddress,status s);
	status getStatus(unsigned short blockAddress);
};
#endif

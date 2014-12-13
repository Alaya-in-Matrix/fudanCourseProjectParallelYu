#ifndef __PROCESSOR_H__
#define __PROCESSOR_H__

#include <iostream>
#include "global_def.h"
#include "cache.h"


// cache一致性模型对CPU是透明的, CPU只管read/write, 
// hit与miss对于cpu而言, 
// 只是stall时间长短而已
class Processor
{
    private:
        unsigned int  regNum = 1;
        unsigned int* regFile;
        Cache* cache;
    public:
        Processor();
        Processor(int);
        ~Processor()
        {
            delete cache;
            delete regFile;
        }
        void load(int regIdx,unsigned char address);
        void store(int regIdx,unsigned char address);
        void print(int regIdx);
};
Processor::Processor()
{
    regFile = new unsigned int[regNum];
    cache   = new Cache();
    for(int i=0; i<regNum;i++)
        regFile[i] = 0;
}
Processor::Processor(int rNum)
{
    regNum  = rNum;
    regFile = new unsigned int[regNum];
    cache   = new Cache();
    for(int i=0; i<regNum;i++)
        regFile[i] = 0;
}
void Processor::load(int regIdx,unsigned char address)
{
    regIdx %= regNum;
    regFile[regIdx] = cache->fetch(address);
}
void Processor::store(int regIdx,unsigned char address)
{
    regIdx %= regNum;
    cache->write(regFile[regIdx],address);
}
void Processor::print(int regIdx)
{
    regIdx %= regNum;
    std::cout<<"value in reg "<<regIdx<<" is "<<regFile[regIdx]<<std::endl;
}
#endif

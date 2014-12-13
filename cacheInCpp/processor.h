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
        Processor(int idx,int rNum,int bNum,unsigned char* mem,Bus*);
        ~Processor()
        {
            delete cache;
            delete regFile;
        }
        //read data from memory
        void load(int regIdx,unsigned char address);
        //write data to memory
        void store(int regIdx,unsigned char address);

        //print data value in one register
        void print(int regIdx);
};
Processor(int idx,int rNum,int bNum,unsigned char* mem,Bus*)
{
    regNum  = rNum;
    regFile = new unsigned int[regNum];
    cache   = new Cache(b,mem,idx,bNum);
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

#ifndef __CACHE_H__
#define __CACHE_H__

// 直接映射/write-back
// cache的行为模型:
// 每个时钟周期, 首先检查总线信息, 然后检查cpu信息, 
// 根据这两个信息, 更新cache, 返回数据, 
// 并向总线发送信息

class Cache 
{
    private:
    public:
        //interface to cpu
        int fetch(int address){return 0;}
        void write(int val,int address){}
};
#endif

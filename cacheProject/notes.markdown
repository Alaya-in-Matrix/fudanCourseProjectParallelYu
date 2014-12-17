# developing notes #

* 就做dual-core, 不用考虑对multi-core的scalability: 但凡需要通信的两个节点, 直接相连
* cpu进行word操作, 而cache与memory的操作均为block级别, 即cache不会向memory请求某个word(byte)
* 能用互连线, 不用解码器
* address->(blockAddress,offset)目前就先用除法/取余操作实现, 重构时再改
* cache在访问内存时, CPU应当是在stall状态, 其他操作全部停住
* 如果RAM没有延时, 不用时钟,认为是个组合电路的话, 那么状态图确实容易实现, 然而给RAM加了一百个CYCLE的延时后, 先write_back, 再read, 就不容易实现了, 必然无法在一个clock cycle中实现.

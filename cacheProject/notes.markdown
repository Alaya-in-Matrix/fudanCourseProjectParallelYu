# developing notes #

* 就做dual-core, 不用考虑对multi-core的scalability: 但凡需要通信的两个节点, 直接相连
* cpu进行word操作, 而cache与memory的操作均为block级别, 即cache不会向memory请求某个word(byte)
* 能用互连线, 不用解码器
* address->(blockAddress,offset)目前就先用除法/取余操作实现, 重构时再改

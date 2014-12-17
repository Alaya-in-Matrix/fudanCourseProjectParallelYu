# parallel_Yu #
* 吕文龙
* Last Modified:2014/12/16 22:52:39 周二

## 1. project ##

### 1. Hardware Project ###

#### Scores ####
占本课程总分40%

#### Hardware Project Description ####
* 设计一个双核的cache coherency系统
    * 系统由两个处理器及一个share memory构成
    * 每个处理器含一个cache
    * Processor不需要完整的功能，但需要简单的读写memory的功能
    * 从MSI/MESI/Directory-based挑选一种protocol；
* 要求：
    * 完成RTL code，testbench验证系统，完成综合。
    * 递交code及文档。文档中要体现设计方案，验证方案及典型结果，综合结果。
    * 最后会有个课堂presentation。
* deadline: 12.26.2014


## 预估需要时间 ##

* hardware project:一周

## Problem ##
1. 同一时刻(时钟上升沿)两个处理器同时写同一地址, 似乎无论如何都无法避免竞争
2. 是同一地址的竞争还是同一cache line的地址的竞争?
3. 两个block在cache上是同一位置则如何?
4. bus!

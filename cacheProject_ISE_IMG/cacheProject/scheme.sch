VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "aspartan2e"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL XLXN_1(23:0)
        SIGNAL XLXN_2(7:0)
        SIGNAL clk
        SIGNAL reset
        SIGNAL XLXN_7
        SIGNAL XLXN_8
        SIGNAL XLXN_9
        SIGNAL XLXN_10(15:0)
        SIGNAL XLXN_11(1:0)
        SIGNAL XLXN_12(15:0)
        SIGNAL XLXN_13(15:0)
        SIGNAL XLXN_16
        SIGNAL XLXN_18
        SIGNAL XLXN_14(23:0)
        SIGNAL XLXN_15(7:0)
        SIGNAL XLXN_27
        BEGIN SIGNAL XLXN_17
        END SIGNAL
        SIGNAL XLXN_29
        BEGIN SIGNAL XLXN_19
        END SIGNAL
        SIGNAL XLXN_20
        SIGNAL XLXN_21(15:0)
        SIGNAL XLXN_22(1:0)
        SIGNAL XLXN_23(15:0)
        SIGNAL XLXN_24(15:0)
        SIGNAL XLXN_36
        SIGNAL XLXN_37
        SIGNAL XLXN_38
        SIGNAL XLXN_39
        SIGNAL XLXN_40
        SIGNAL XLXN_41
        SIGNAL XLXN_42
        SIGNAL XLXN_44
        SIGNAL XLXN_45
        SIGNAL XLXN_46
        SIGNAL XLXN_47
        SIGNAL XLXN_48
        SIGNAL XLXN_49
        SIGNAL XLXN_50
        SIGNAL XLXN_51(1:0)
        SIGNAL XLXN_52(15:0)
        SIGNAL XLXN_53(15:0)
        SIGNAL XLXN_55(15:0)
        SIGNAL XLXN_56(15:0)
        SIGNAL XLXN_57(15:0)
        SIGNAL XLXN_58(15:0)
        SIGNAL XLXN_59(1:0)
        SIGNAL XLXN_60(15:0)
        SIGNAL XLXN_61(15:0)
        SIGNAL XLXN_63(15:0)
        SIGNAL XLXN_64(15:0)
        SIGNAL XLXN_66
        SIGNAL XLXN_67(15:0)
        SIGNAL XLXN_68(15:0)
        SIGNAL XLXN_69(15:0)
        SIGNAL XLXN_70(15:0)
        PORT Input clk
        PORT Input reset
        BEGIN BLOCKDEF cache
            TIMESTAMP 2015 1 2 8 8 39
            RECTANGLE N 64 -896 784 0 
            LINE N 64 -864 0 -864 
            LINE N 64 -800 0 -800 
            LINE N 64 -736 0 -736 
            LINE N 64 -672 0 -672 
            LINE N 64 -608 0 -608 
            LINE N 64 -544 0 -544 
            LINE N 64 -480 0 -480 
            LINE N 64 -416 0 -416 
            RECTANGLE N 0 -364 64 -340 
            LINE N 64 -352 0 -352 
            RECTANGLE N 0 -300 64 -276 
            LINE N 64 -288 0 -288 
            RECTANGLE N 0 -236 64 -212 
            LINE N 64 -224 0 -224 
            RECTANGLE N 0 -172 64 -148 
            LINE N 64 -160 0 -160 
            RECTANGLE N 0 -108 64 -84 
            LINE N 64 -96 0 -96 
            RECTANGLE N 0 -44 64 -20 
            LINE N 64 -32 0 -32 
            LINE N 784 -864 848 -864 
            LINE N 784 -800 848 -800 
            LINE N 784 -736 848 -736 
            LINE N 784 -672 848 -672 
            LINE N 784 -608 848 -608 
            LINE N 784 -544 848 -544 
            RECTANGLE N 784 -492 848 -468 
            LINE N 784 -480 848 -480 
            RECTANGLE N 784 -428 848 -404 
            LINE N 784 -416 848 -416 
            RECTANGLE N 784 -364 848 -340 
            LINE N 784 -352 848 -352 
            RECTANGLE N 784 -300 848 -276 
            LINE N 784 -288 848 -288 
            RECTANGLE N 784 -236 848 -212 
            LINE N 784 -224 848 -224 
            RECTANGLE N 784 -172 848 -148 
            LINE N 784 -160 848 -160 
            RECTANGLE N 784 -108 848 -84 
            LINE N 784 -96 848 -96 
            RECTANGLE N 784 -44 848 -20 
            LINE N 784 -32 848 -32 
        END BLOCKDEF
        BEGIN BLOCKDEF memBus
            TIMESTAMP 2015 1 2 8 25 37
            RECTANGLE N 64 -512 576 0 
            LINE N 64 -480 0 -480 
            LINE N 64 -416 0 -416 
            RECTANGLE N 0 -364 64 -340 
            LINE N 64 -352 0 -352 
            RECTANGLE N 0 -300 64 -276 
            LINE N 64 -288 0 -288 
            RECTANGLE N 0 -236 64 -212 
            LINE N 64 -224 0 -224 
            RECTANGLE N 0 -172 64 -148 
            LINE N 64 -160 0 -160 
            RECTANGLE N 0 -108 64 -84 
            LINE N 64 -96 0 -96 
            RECTANGLE N 0 -44 64 -20 
            LINE N 64 -32 0 -32 
            LINE N 576 -480 640 -480 
            LINE N 576 -416 640 -416 
            RECTANGLE N 576 -364 640 -340 
            LINE N 576 -352 640 -352 
            RECTANGLE N 576 -300 640 -276 
            LINE N 576 -288 640 -288 
            RECTANGLE N 576 -236 640 -212 
            LINE N 576 -224 640 -224 
            RECTANGLE N 576 -172 640 -148 
            LINE N 576 -160 640 -160 
            RECTANGLE N 576 -108 640 -84 
            LINE N 576 -96 640 -96 
        END BLOCKDEF
        BEGIN BLOCKDEF processor
            TIMESTAMP 2015 1 2 8 25 42
            RECTANGLE N 64 -576 512 0 
            LINE N 64 -544 0 -544 
            LINE N 64 -416 0 -416 
            LINE N 64 -288 0 -288 
            RECTANGLE N 0 -172 64 -148 
            LINE N 64 -160 0 -160 
            RECTANGLE N 0 -44 64 -20 
            LINE N 64 -32 0 -32 
            RECTANGLE N 512 -556 576 -532 
            LINE N 512 -544 576 -544 
            RECTANGLE N 512 -492 576 -468 
            LINE N 512 -480 576 -480 
            RECTANGLE N 512 -428 576 -404 
            LINE N 512 -416 576 -416 
            RECTANGLE N 512 -364 576 -340 
            LINE N 512 -352 576 -352 
            RECTANGLE N 512 -300 576 -276 
            LINE N 512 -288 576 -288 
            RECTANGLE N 512 -236 576 -212 
            LINE N 512 -224 576 -224 
            RECTANGLE N 512 -172 576 -148 
            LINE N 512 -160 576 -160 
            RECTANGLE N 512 -108 576 -84 
            LINE N 512 -96 576 -96 
            RECTANGLE N 512 -44 576 -20 
            LINE N 512 -32 576 -32 
        END BLOCKDEF
        BEGIN BLOCKDEF codeRam
            TIMESTAMP 2015 1 2 8 22 51
            RECTANGLE N 64 -64 320 0 
            RECTANGLE N 0 -44 64 -20 
            LINE N 64 -32 0 -32 
            RECTANGLE N 320 -44 384 -20 
            LINE N 320 -32 384 -32 
        END BLOCKDEF
        BEGIN BLOCK XLXI_5 processor
            PIN clk clk
            PIN reset reset
            PIN cacheEn XLXN_9
            PIN instruction(23:0) XLXN_1(23:0)
            PIN dataFromMem(15:0) XLXN_10(15:0)
            PIN data(15:0)
            PIN pcCounter(7:0) XLXN_2(7:0)
            PIN rwToMem(1:0) XLXN_11(1:0)
            PIN addrToMem(15:0) XLXN_12(15:0)
            PIN dataToMem(15:0) XLXN_13(15:0)
            PIN cpuState(1:0)
            PIN regId(3:0)
            PIN r0(15:0)
            PIN r1(15:0)
        END BLOCK
        BEGIN BLOCK XLXI_6 codeRam
            PIN pc(7:0) XLXN_2(7:0)
            PIN ins(23:0) XLXN_1(23:0)
        END BLOCK
        BEGIN BLOCK XLXI_7 cache
            PIN clk clk
            PIN reset reset
            PIN memEn XLXN_36
            PIN havMsgFromCache XLXN_37
            PIN allowReadFromCache XLXN_38
            PIN rmFromCache XLXN_39
            PIN wmFromCache XLXN_40
            PIN invFromCache XLXN_41
            PIN rwFromCPU(1:0) XLXN_11(1:0)
            PIN addrFromCPU(15:0) XLXN_12(15:0)
            PIN dataFromCPU(15:0) XLXN_13(15:0)
            PIN dataFromMem(15:0) XLXN_67(15:0)
            PIN allowReadFromCacheAddr(15:0) XLXN_63(15:0)
            PIN addrFromCache(15:0) XLXN_64(15:0)
            PIN cacheEnToCPU XLXN_9
            PIN havMsgToCache XLXN_42
            PIN allowReadToCache XLXN_44
            PIN rmToCache XLXN_46
            PIN wmToCache XLXN_48
            PIN invToCache XLXN_50
            PIN dataToCPU(15:0) XLXN_10(15:0)
            PIN rwToMem(1:0) XLXN_51(1:0)
            PIN addrToMem(15:0) XLXN_52(15:0)
            PIN dataToMem(15:0) XLXN_53(15:0)
            PIN allowReadToCacheAddr(15:0) XLXN_55(15:0)
            PIN addrToCache(15:0) XLXN_57(15:0)
            PIN debugState(3:0)
            PIN debugCacheLine(15:0)
        END BLOCK
        BEGIN BLOCK XLXI_8 codeRam
            PIN pc(7:0) XLXN_15(7:0)
            PIN ins(23:0) XLXN_14(23:0)
        END BLOCK
        BEGIN BLOCK XLXI_9 processor
            PIN clk clk
            PIN reset reset
            PIN cacheEn XLXN_20
            PIN instruction(23:0) XLXN_14(23:0)
            PIN dataFromMem(15:0) XLXN_21(15:0)
            PIN data(15:0)
            PIN pcCounter(7:0) XLXN_15(7:0)
            PIN rwToMem(1:0) XLXN_22(1:0)
            PIN addrToMem(15:0) XLXN_23(15:0)
            PIN dataToMem(15:0) XLXN_24(15:0)
            PIN cpuState(1:0)
            PIN regId(3:0)
            PIN r0(15:0)
            PIN r1(15:0)
        END BLOCK
        BEGIN BLOCK XLXI_10 cache
            PIN clk clk
            PIN reset reset
            PIN memEn XLXN_66
            PIN havMsgFromCache XLXN_42
            PIN allowReadFromCache XLXN_44
            PIN rmFromCache XLXN_46
            PIN wmFromCache XLXN_48
            PIN invFromCache XLXN_50
            PIN rwFromCPU(1:0) XLXN_22(1:0)
            PIN addrFromCPU(15:0) XLXN_23(15:0)
            PIN dataFromCPU(15:0) XLXN_24(15:0)
            PIN dataFromMem(15:0) XLXN_69(15:0)
            PIN allowReadFromCacheAddr(15:0) XLXN_55(15:0)
            PIN addrFromCache(15:0) XLXN_57(15:0)
            PIN cacheEnToCPU XLXN_20
            PIN havMsgToCache XLXN_37
            PIN allowReadToCache XLXN_38
            PIN rmToCache XLXN_39
            PIN wmToCache XLXN_40
            PIN invToCache XLXN_41
            PIN dataToCPU(15:0) XLXN_21(15:0)
            PIN rwToMem(1:0) XLXN_59(1:0)
            PIN addrToMem(15:0) XLXN_60(15:0)
            PIN dataToMem(15:0) XLXN_61(15:0)
            PIN allowReadToCacheAddr(15:0) XLXN_63(15:0)
            PIN addrToCache(15:0) XLXN_64(15:0)
            PIN debugState(3:0)
            PIN debugCacheLine(15:0)
        END BLOCK
        BEGIN BLOCK XLXI_14 memBus
            PIN clk clk
            PIN reset reset
            PIN rwFromCacheA(1:0) XLXN_51(1:0)
            PIN addrFromCacheA(15:0) XLXN_52(15:0)
            PIN dataFromCacheA(15:0) XLXN_53(15:0)
            PIN rwFromCacheB(1:0) XLXN_59(1:0)
            PIN addrFromCacheB(15:0) XLXN_60(15:0)
            PIN dataFromCacheB(15:0) XLXN_61(15:0)
            PIN memEnA XLXN_36
            PIN memEnB XLXN_66
            PIN dataToCacheA(15:0) XLXN_67(15:0)
            PIN dataToCacheB(15:0) XLXN_69(15:0)
            PIN errReg(3:0)
            PIN debugRwToMem(1:0)
            PIN debugDelay(7:0)
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        BEGIN INSTANCE XLXI_6 288 912 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_5 784 1040 R0
        END INSTANCE
        BEGIN BRANCH XLXN_1(23:0)
            WIRE 672 880 784 880
        END BRANCH
        BEGIN BRANCH XLXN_2(7:0)
            WIRE 208 400 208 880
            WIRE 208 880 288 880
            WIRE 208 400 1424 400
            WIRE 1424 400 1424 560
            WIRE 1360 560 1424 560
        END BRANCH
        BEGIN BRANCH clk
            WIRE 144 496 256 496
            WIRE 256 496 640 496
            WIRE 640 496 784 496
            WIRE 256 496 256 1728
            WIRE 256 1728 640 1728
            WIRE 640 1728 784 1728
            WIRE 256 352 256 496
            WIRE 256 352 2720 352
            WIRE 2720 352 2720 1072
            WIRE 2720 1072 2736 1072
            WIRE 640 240 1584 240
            WIRE 1584 240 1584 400
            WIRE 1584 400 1648 400
            WIRE 640 240 640 496
            WIRE 640 1472 1584 1472
            WIRE 1584 1472 1584 1632
            WIRE 1584 1632 1648 1632
            WIRE 640 1472 640 1728
        END BRANCH
        BEGIN BRANCH reset
            WIRE 144 624 224 624
            WIRE 224 624 224 1856
            WIRE 224 1856 256 1856
            WIRE 256 1856 656 1856
            WIRE 656 1856 784 1856
            WIRE 224 624 240 624
            WIRE 240 624 656 624
            WIRE 656 624 784 624
            WIRE 240 624 240 1584
            WIRE 240 1584 2720 1584
            WIRE 656 256 1536 256
            WIRE 1536 256 1536 464
            WIRE 1536 464 1648 464
            WIRE 656 256 656 624
            WIRE 656 1488 1536 1488
            WIRE 1536 1488 1536 1696
            WIRE 1536 1696 1648 1696
            WIRE 656 1488 656 1856
            WIRE 2720 1136 2720 1584
            WIRE 2720 1136 2736 1136
        END BRANCH
        IOMARKER 144 496 clk R180 28
        IOMARKER 144 624 reset R180 28
        BEGIN INSTANCE XLXI_7 1648 1264 R0
        END INSTANCE
        BEGIN BRANCH XLXN_9
            WIRE 624 224 624 752
            WIRE 624 752 784 752
            WIRE 624 224 2512 224
            WIRE 2512 224 2512 400
            WIRE 2496 400 2512 400
        END BRANCH
        BEGIN BRANCH XLXN_10(15:0)
            WIRE 704 176 2560 176
            WIRE 2560 176 2560 784
            WIRE 704 176 704 1008
            WIRE 704 1008 784 1008
            WIRE 2496 784 2560 784
        END BRANCH
        BEGIN BRANCH XLXN_11(1:0)
            WIRE 1360 624 1504 624
            WIRE 1504 624 1504 912
            WIRE 1504 912 1648 912
        END BRANCH
        BEGIN BRANCH XLXN_12(15:0)
            WIRE 1360 688 1488 688
            WIRE 1488 688 1488 976
            WIRE 1488 976 1648 976
        END BRANCH
        BEGIN BRANCH XLXN_13(15:0)
            WIRE 1360 752 1472 752
            WIRE 1472 752 1472 1040
            WIRE 1472 1040 1648 1040
        END BRANCH
        BEGIN INSTANCE XLXI_8 288 2144 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_9 784 2272 R0
        END INSTANCE
        BEGIN BRANCH XLXN_14(23:0)
            WIRE 672 2112 784 2112
        END BRANCH
        BEGIN BRANCH XLXN_15(7:0)
            WIRE 208 1632 208 2112
            WIRE 208 2112 288 2112
            WIRE 208 1632 1424 1632
            WIRE 1424 1632 1424 1792
            WIRE 1360 1792 1424 1792
        END BRANCH
        BEGIN INSTANCE XLXI_10 1648 2496 R0
        END INSTANCE
        BEGIN BRANCH XLXN_20
            WIRE 624 1456 624 1984
            WIRE 624 1984 784 1984
            WIRE 624 1456 2512 1456
            WIRE 2512 1456 2512 1632
            WIRE 2496 1632 2512 1632
        END BRANCH
        BEGIN BRANCH XLXN_21(15:0)
            WIRE 704 1408 2560 1408
            WIRE 2560 1408 2560 2016
            WIRE 704 1408 704 2240
            WIRE 704 2240 784 2240
            WIRE 2496 2016 2560 2016
        END BRANCH
        BEGIN BRANCH XLXN_22(1:0)
            WIRE 1360 1856 1504 1856
            WIRE 1504 1856 1504 2144
            WIRE 1504 2144 1648 2144
        END BRANCH
        BEGIN BRANCH XLXN_23(15:0)
            WIRE 1360 1920 1488 1920
            WIRE 1488 1920 1488 2208
            WIRE 1488 2208 1648 2208
        END BRANCH
        BEGIN BRANCH XLXN_24(15:0)
            WIRE 1360 1984 1472 1984
            WIRE 1472 1984 1472 2272
            WIRE 1472 2272 1648 2272
        END BRANCH
        BEGIN INSTANCE XLXI_14 2736 1552 R0
        END INSTANCE
        BEGIN BRANCH XLXN_36
            WIRE 1600 288 1600 528
            WIRE 1600 528 1648 528
            WIRE 1600 288 3440 288
            WIRE 3440 288 3440 1072
            WIRE 3376 1072 3440 1072
        END BRANCH
        BEGIN BRANCH XLXN_37
            WIRE 1584 592 1648 592
            WIRE 1584 592 1584 1328
            WIRE 1584 1328 2592 1328
            WIRE 2592 1328 2592 1696
            WIRE 2496 1696 2592 1696
        END BRANCH
        BEGIN BRANCH XLXN_38
            WIRE 1632 304 1632 656
            WIRE 1632 656 1648 656
            WIRE 1632 304 2576 304
            WIRE 2576 304 2576 1760
            WIRE 2496 1760 2576 1760
        END BRANCH
        BEGIN BRANCH XLXN_39
            WIRE 1600 720 1648 720
            WIRE 1600 720 1600 1312
            WIRE 1600 1312 2544 1312
            WIRE 2544 1312 2544 1824
            WIRE 2496 1824 2544 1824
        END BRANCH
        BEGIN BRANCH XLXN_40
            WIRE 1568 784 1648 784
            WIRE 1568 784 1568 1280
            WIRE 1568 1280 2672 1280
            WIRE 2672 1280 2672 1888
            WIRE 2496 1888 2672 1888
        END BRANCH
        BEGIN BRANCH XLXN_41
            WIRE 1616 320 1616 848
            WIRE 1616 848 1648 848
            WIRE 1616 320 2656 320
            WIRE 2656 320 2656 1952
            WIRE 2496 1952 2656 1952
        END BRANCH
        BEGIN BRANCH XLXN_42
            WIRE 1632 1536 1632 1824
            WIRE 1632 1824 1648 1824
            WIRE 1632 1536 2528 1536
            WIRE 2496 464 2528 464
            WIRE 2528 464 2528 1536
        END BRANCH
        BEGIN BRANCH XLXN_44
            WIRE 1552 1296 2592 1296
            WIRE 1552 1296 1552 1888
            WIRE 1552 1888 1648 1888
            WIRE 2496 528 2592 528
            WIRE 2592 528 2592 1296
        END BRANCH
        BEGIN BRANCH XLXN_46
            WIRE 1568 1344 2608 1344
            WIRE 1568 1344 1568 1952
            WIRE 1568 1952 1648 1952
            WIRE 2496 592 2544 592
            WIRE 2544 592 2608 592
            WIRE 2608 592 2608 1344
        END BRANCH
        BEGIN BRANCH XLXN_48
            WIRE 1520 1360 2624 1360
            WIRE 1520 1360 1520 2016
            WIRE 1520 2016 1648 2016
            WIRE 2496 656 2624 656
            WIRE 2624 656 2624 1360
        END BRANCH
        BEGIN BRANCH XLXN_50
            WIRE 1600 1376 2640 1376
            WIRE 1600 1376 1600 2080
            WIRE 1600 2080 1648 2080
            WIRE 2496 720 2544 720
            WIRE 2544 720 2640 720
            WIRE 2640 720 2640 1376
        END BRANCH
        BEGIN BRANCH XLXN_51(1:0)
            WIRE 2496 848 2560 848
            WIRE 2560 848 2560 1200
            WIRE 2560 1200 2736 1200
        END BRANCH
        BEGIN BRANCH XLXN_52(15:0)
            WIRE 2496 912 2544 912
            WIRE 2544 912 2544 1264
            WIRE 2544 1264 2736 1264
        END BRANCH
        BEGIN BRANCH XLXN_53(15:0)
            WIRE 2496 976 2688 976
            WIRE 2688 976 2688 1328
            WIRE 2688 1328 2736 1328
        END BRANCH
        BEGIN BRANCH XLXN_55(15:0)
            WIRE 1456 1392 1472 1392
            WIRE 1472 1392 1504 1392
            WIRE 1504 1392 2512 1392
            WIRE 1456 1392 1456 2400
            WIRE 1456 2400 1648 2400
            WIRE 2496 1040 2512 1040
            WIRE 2512 1040 2512 1392
        END BRANCH
        BEGIN BRANCH XLXN_57(15:0)
            WIRE 1472 1424 1504 1424
            WIRE 1504 1424 2704 1424
            WIRE 1472 1424 1472 1840
            WIRE 1472 1840 1536 1840
            WIRE 1536 1840 1536 2464
            WIRE 1536 2464 1648 2464
            WIRE 2496 1104 2672 1104
            WIRE 2672 1104 2672 1248
            WIRE 2672 1248 2704 1248
            WIRE 2704 1248 2704 1424
        END BRANCH
        BEGIN BRANCH XLXN_59(1:0)
            WIRE 2496 2080 2608 2080
            WIRE 2608 1392 2608 2080
            WIRE 2608 1392 2736 1392
        END BRANCH
        BEGIN BRANCH XLXN_60(15:0)
            WIRE 2496 2144 2688 2144
            WIRE 2688 1456 2688 2144
            WIRE 2688 1456 2736 1456
        END BRANCH
        BEGIN BRANCH XLXN_61(15:0)
            WIRE 2496 2208 2704 2208
            WIRE 2704 1520 2704 2208
            WIRE 2704 1520 2736 1520
        END BRANCH
        BEGIN BRANCH XLXN_63(15:0)
            WIRE 1488 1168 1504 1168
            WIRE 1504 1168 1648 1168
            WIRE 1488 1168 1488 1440
            WIRE 1488 1440 1504 1440
            WIRE 1504 1440 2640 1440
            WIRE 2640 1440 2640 2272
            WIRE 2496 2272 2640 2272
        END BRANCH
        BEGIN BRANCH XLXN_64(15:0)
            WIRE 1440 1232 1504 1232
            WIRE 1504 1232 1648 1232
            WIRE 1440 1232 1440 1504
            WIRE 1440 1504 1504 1504
            WIRE 1504 1504 2624 1504
            WIRE 2624 1504 2624 2336
            WIRE 2496 2336 2624 2336
        END BRANCH
        BEGIN BRANCH XLXN_66
            WIRE 1584 1760 1648 1760
            WIRE 1584 1760 1584 2560
            WIRE 1584 2560 3440 2560
            WIRE 3376 1136 3440 1136
            WIRE 3440 1136 3440 2560
        END BRANCH
        BEGIN BRANCH XLXN_67(15:0)
            WIRE 1552 272 3408 272
            WIRE 3408 272 3408 1200
            WIRE 1552 272 1552 1104
            WIRE 1552 1104 1648 1104
            WIRE 3376 1200 3408 1200
        END BRANCH
        BEGIN BRANCH XLXN_69(15:0)
            WIRE 1600 2336 1648 2336
            WIRE 1600 2336 1600 2512
            WIRE 1600 2512 2720 2512
            WIRE 2720 1600 3408 1600
            WIRE 2720 1600 2720 2512
            WIRE 3376 1264 3408 1264
            WIRE 3408 1264 3408 1600
        END BRANCH
    END SHEET
END SCHEMATIC

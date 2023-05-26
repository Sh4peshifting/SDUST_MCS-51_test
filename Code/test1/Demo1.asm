R EQU 50H ;数据块中起始存储单元的地址
ADR EQU 30H ;存放数据起始地址的存储单元
N EQU 10 ;数据的个数
NUM EQU 31H ;存放数总个数的存储单元地址
TMP EQU 32H ;排序过程中用到的临时存储单元地址
 
ORG 0000H

;片内RAM存入测试数据
MOV 50H,#12D
MOV 51H,#7D
MOV 52H,#21D
MOV 53H,#23D
MOV 54H,#45D
MOV 55H,#33D
MOV 56H,#77D
MOV 57H,#56D
MOV 58H,#39D
MOV 59H,#2D

CLR F0 ;F0=0,表示没有数据交换；F0=1，表示有数据交换
MOV ADR,#50H ;数据块起始地址送入存储单元存放
MOV R7,#N ;参与比较的数据个数，送入 R7 
DEC R7 ;比较次数是数据个数减 1，送入 R7 

LOOP: 
MOV A,R7 ;比较次数送入 A 
MOV R6,A ;比较次数是送入 R6，"MOV R6,R7"是错误指令
MOV R0,ADR ;数据块第一个数的地址送入 R0 
MOV R1,ADR ;数据块第一个数的地址送入 R1 
INC R1 ;数据块第二个数的地址送入 R1 
NEXT: 
MOV A,@R0 ;被比较的两个数中的前一个数送入 A 
MOV TMP,@R1 ;被比较的两个数中的后一个数送入 A 
CJNE A,TMP,NEQ ;相邻的两个数进行比较
NEQ: 
JC NEX ;若 CY=1，则前一个数小于后一个数，符合要求，跳转
XCH A,@R1 ;若 CY=0，则前一个数大于后一个数，交换数据存放位置
MOV A,TMP 
XCH A,@R0 
SETB F0 ;令 F0=1，表示本轮比较过程中发生了数据交换
NEX: 
INC R0 ;前一个数的地址加 1，指向下一次比较的前一个数
INC R1 ;后一个数的地址加 1，指向下一次比较的后一个数
DJNZ R6,NEXT ;(R6)←(R6)-1=剩余比较次数，不为 0，则跳转继续比较
JB F0,GO ;若 F0=1，则本轮比较中有数据交换，跳转继续排序
MOV R7,#1H ;F0=0 表示本轮比较中无数据交换，已排好序，令 R7=1，提前结束排序
GO: 
DJNZ R7,LOOP ;(R6)←(R6)-1=下一轮比较的数据个数，不为0，则进入下一轮比较
SJMP $ ;程序在此暂停
END 
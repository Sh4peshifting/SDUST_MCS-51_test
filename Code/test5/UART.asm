CLOCK EQU 41H ;软时钟，用于存放定时器中断的次数
NUM EQU 10 
TADDR DATA 30H ;待发送数据的片内 RAM 地址
TNUM DATA 17 ;待发送数据的个数
LED BIT P1.0 ;发送结束指示灯，所有数据发送后，灯被点亮


ORG 0000H ;主程序入口地址
LJMP MAIN ;跳转至主程序
ORG 000BH ;T0 中断服务处理程序的入口
LJMP T0_ISR ;跳转至 T0 的中断服务处理程序


MAIN: 
;片内 RAM 30H～40H 中的数据
MOV 30H, #2 
MOV 31H, #1
MOV 32H, #2
MOV 33H, #3
MOV 34H, #4
MOV 35H, #5
MOV 36H, #6
MOV 37H, #7
MOV 38H, #8
MOV 39H, #9
MOV 40H, #1

MOV CLOCK, #0H ;软时钟初始化清 0
MOV R0, #TADDR ;设置发送数据区首地址
MOV R2, #TNUM ;设置发送数据个数

MOV PCON,#00H ;SMOD=0 时，SMOD 不能按位寻址
MOV TMOD, #21H ;设置 T1 作为定时器工作方式 2，用于波特率发生器

MOV TH0,#4CH ;设置定时器0初值，高8位为4CH
MOV TL0,#00H ;设置定时器0初值，低8位为00H
MOV TL1, #0FDH ;设置 T1 的初值（"fosc" =12MHz，9600bit/s）
MOV TH1, #0FDH ;T1 重装初值

CLR ET1 ;禁止 T1 中断，仅用于产生波特率信号
SETB TR1 ;T1 启动，开始产生波特率信号
SETB TR0 ;启动定时器0
SETB ET0 ;使能定时器0中断

MOV SCON, #40H ;设串口工作于方式 1，禁止接收数据 REN=0，TI=0 
CLR ES ;允许串口中断
SETB EA ;允许总中断

SETB LED ;发送结束指示灯
SETB TI ;软件将 TI 置 1，向 CPU 发出串口发送中断请求
SJMP $ 

T0_ISR: 
PUSH PSW ;现场保护
PUSH ACC ;现场保护
MOV TH0,#4CH ;设置定时器0初值，高8位为4CH
MOV TL0,#00H ;设置定时器0初值，低8位为00H
INC CLOCK ;累计进入该中断服务处理程序的次数
MOV A, CLOCK ;将 CLOCK 内存放的数据送入累加器 A 
CJNE A, #NUM, GOON ;若 A 中所存数据不等于预定值，则表明定时时间未到
MOV CLOCK, #0H ;清 0 软时钟 CLOCK，为下一轮定时做准备

SEND:
MOV SBUF,@R0 ;发送一个数据
JNB TI,$ ;等待一个字符数据帧发送完毕
CLR TI ;将发送中断标志位清 0，为下一次发送做准备
INC R0 ;指向下一个待发送数据
DJNZ R2,GOON ;判读是否已发送完所有数据，未发送完则继续发送
CLR LED ;点亮发送结束指示灯
SJMP $ ;所有数据发送完，则程序在此待命

GOON: ;以下是返回主程序的步骤
POP ACC ;现场恢复
POP PSW ;现场恢复
RETI ;从中断返回

END
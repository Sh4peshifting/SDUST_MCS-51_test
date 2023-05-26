;使用MCS-51 汇编语言 定时器中断实现 LED灯(P10)间隔1s闪烁
CLOCK EQU 40H ;软时钟，用于存放定时器中断的次数
NUM EQU 20 
ORG 0000H ;程序起始地址
LJMP MAIN ;跳转到主程序
ORG 001BH ;定时器1中断向量地址
LJMP T1_ISR ;跳转到定时器1中断服务程序

MAIN: SETB P1.0 ;初始化P10引脚为高电平 
MOV CLOCK, #0H ;软时钟初始化清 0
MOV TMOD,#10H 
MOV TH1,#4CH ;设置定时器1初值，高8位为4CH
MOV TL1,#00H ;设置定时器1初值，低8位为00H
SETB TR1 ;启动定时器1
SETB ET1 ;使能定时器1中断
SETB EA ;开总中断
SJMP $ ;无限循环
T1_ISR: 
PUSH PSW ;现场保护
PUSH ACC ;现场保护
INC CLOCK ;累计进入该中断服务处理程序的次数
MOV A, CLOCK ;将 CLOCK 内存放的数据送入累加器 A 
CJNE A, #NUM, GOON ;若 A 中所存数据不等于预定值，则表明定时时间未到， 
MOV CLOCK, #0H ;清 0 软时钟 CLOCK，为下一轮定时做准备
CPL P1.0 ;反转P10引脚的电平，实现LED灯的闪烁

GOON: ;以下是返回主程序的步骤
 POP ACC ;现场恢复
 POP PSW ;现场恢复
RETI ;从中断返回
END ;程序结束

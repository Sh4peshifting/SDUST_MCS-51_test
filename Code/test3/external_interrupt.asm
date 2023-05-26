ORG 0000H        ;程序起始地址
LJMP MAIN
ORG 0003H 
LJMP INT_0 
KEY EQU P3.3
MAIN:
    MOV P0, #0FFH ;P0口初始化为输出低电平，即LED熄灭
    SETB IT0      ;设置外部中断0为下降沿触发
    SETB EA       ;开启总中断
    SETB EX0      ;开启外部中断0
    MOV R0, #0FEH 
LOOP:
    MOV P0, R0   ;将掩码送入P0口
    ACALL DELAY  ;延时
    JB PSW.5, DOWN ;如果标志位为1，则跳转到DOWN
    MOV A,R0    
    RR A
    MOV R0,A
    SJMP LOOP
DOWN:
    MOV A, R0
    RL A
    MOV R0, A
    SJMP LOOP   

DELAY:
	MOV R6,#255D
DL_NEXT: 
	MOV R7,#0F9H
	DJNZ R7,$
	DJNZ R6,DL_NEXT
	RET
KEY_DL:  
	MOV R2,#0FFH
    DJNZ R2,$
    RET

INT_0:       
    ACALL KEY_DL  ;延时去抖
    CPL PSW.5     ;将标志位取反
    RETI         ;中断返回
    
    END
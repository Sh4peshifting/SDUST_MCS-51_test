 KEY_PUSHED BIT F0 ;有按键按下标志，0：有按键按下，1：无按键按下
 KEY_COLUMN EQU P1 ;键盘列扫描信号输出引脚，高 4 位
 KEY_ROW EQU P1 ;键盘行扫描信号输入引脚，低 4 位
 DIS_RAM EQU 30H ;显示缓冲区首地址
 LED_SEG EQU P2 ;LED 数码管段控信号输出引脚，控制
 ;显示键值
 ORG 0000H 
 MOV DIS_RAM,#13H ;显示缓冲单元初始值 13H，显示字母 P 
LOOP: ACALL KEY ;调用键盘扫描子程序
 JB KEY_PUSHED,LSHOW; ;无键按下则不给显示缓冲区赋新的按键键值
 MOV DIS_RAM,A ;被按下按键的键值送入显示缓冲区
LSHOW: ACALL SHOW ;调用显示子程序，显示缓冲区中的键值
 SJMP LOOP 
;子程序名称:KEY 
;功能:识别被按下的按键的键值
;入口参数:无
;出口参数:A 为被按下的按键的键值
KEY: LCALL KEY_OU ;执行扫描键子程序，检查是否有按键按下
 JNZ DE_SHK ;累加器 A 为 0，则有键按下，跳至延时去抖 
 SETB KEY_PUSHED ;置无键标志
 RET ;无键按下，退出子程序
DE_SHK: LCALL DEALY ;去抖
 LCALL KEY_OU ;再次检查是否有按键按下再次扫描键盘
 JNZ KEY_FD ;检测被按下按键的键值
 SETB KEY_PUSHED ;置无键标志
 RET ;无键按下，退出子程序
KEY_FD: CLR KEY_PUSHED ;置有键操作标志
 MOV R2,#0EFH ;列扫描信号，仅第 0 列的 I/O 引脚为低电平
 MOV R4,#00H ;被扫描的列的编号，初始检测的是第 0 列
KEY_NC:MOV KEY_COLUMN,R2 ;送列扫描信号
 MOV A,KEY_ROW ;回读行信息
 JB ACC.0,KR1 ;检查按下的键是否在第 0 行，不是跳转
 MOV A,#00H ;是第0 行的按键按下，第0 行行首按键的键值0 存入累加器A 
 AJMP KEY_SM 
KR1: JB ACC.1,KR2 ;检查按下的键是否在第 1 行，不是跳转
 MOV A,#04H ;是第1 行的按键按下，第1 行行首按键的键值4 存入累加器A 
 AJMP KEY_SM 
KR2: JB ACC.2,KR3 ;检查按下的键是否在第 2 行，不是跳转
 MOV A,#08H ;是第2 行的按键按下，第2 行行首按键的键值8 存入累加器A 
 AJMP KEY_SM 
KR3: JB ACC.3,NEXT_C ;检查按下的键是否在第 3 行，不是跳转
 MOV A,#0CH ;是第3 行的按键按下，第3 行行首按键的键值12 存入累加器A 
KEY_SM:ADD A,R4 ;键值=按键所在行行首按键键值+按键列编号
 PUSH ACC ;保护已经得到的键码
KEY_WT:LCALL KEY_OU ;检查是否有键按下
 JNZ KEY_WT ;A 不为0，则按下的键还未抬起，继续检查，直到无键按下为止
 POP ACC ;恢复累加器 A 中的键值
 RET ;得到键值,子程序返回
NEXT_C:INC R4 ;列号加 1，进入下一列的检测
 MOV A,R2 ;列扫描信号送入累加器 A 
 JNB ACC.3,KEY ;判断是否扫描到了最后一列（即列扫描信号的最后一行电平
               ;为 0），则等待按键抬起，否则进入下一列检测
  RL A ;列扫描信号中的 0 移位至下一列
 MOV R2,A ;列扫描信号送入 R2 
 AJMP KEY_NC ;扫描下一列
;子程序名称:KEY_OU 
;功能:扫描是否有键按下
;入口参数:无
;出口参数:A 为 0 无键按下，不为 0 有键按下
KEY_OU: ANL KEY_COLUMN,#0FH ;送全扫描字（列）
 ORL KEY_ROW,#0FH ;为读数据准备
 MOV A,KEY_ROW ;回读行信息
 CPL A ;累加器 A 中回读行信号按位取反
 ANL A,#0FH ;A=0：无键按下，A≠0：有键按下
 RET ;子程序返回
;子程序名: DEALY 
;功能:软件延时
;延时时间:10023×机器周期，12MHz 晶振时的延时时间约为 10ms 
;入口参数:无
;出口参数:无
DEALY: MOV R6,#14H ;去抖
DL: MOV R7,#0FFH 
 DJNZ R7,$ 
 DJNZ R6,DL 
 RET 
;子程序名:SHOW 
;功能:查找键值对应的字型码,并输出到单片机 I/O 上，以控制数码管显示的字符
;入口参数:地址为 DIS_RAM 的片内 RAM 存储单元
;出口参数: LED_SEG 与数码管笔画段引脚相连的单片机 I/O 口名称(P0～P3) 
SHOW: PUSH ACC ;现场保护，将累加器 A 中的值存入堆栈中
 MOV DPTR, #TAB ;字型码表 TAB 的地址送入 DPTR 
 MOV A,DIS_RAM ;从显示缓冲区取待显示字符字型码在字型码表中的编号
 MOVC A,@A+DPTR ;根据被显示字符在字型码表中的编号，查出字型码
 MOV LED_SEG,A ;字型码送到 I/O 口，控制数码管显示的内容
 POP ACC ;恢复现场，将累加器 A 的值从堆栈中弹出
 RET ;子程序返回
;共阳极数码管的字型码表，显示不带小数点
TAB: DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H ;0～7 的字型码
 DB 80H,90H,88H,83H,0C6H,0A1H,86H,8EH ;8～F 的字型码
 DB 7FH ;10H 小数点的字型码
 DB 0FFH ;11H 灭码的字型码
 DB 8CH ;12H 字母 P 的字型码
 DB 89H ;13H 字母 H 的字型码 
 END ;程序结束

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

MOV DPTR, #2000H ; 将DPTR寄存器设置为2000H
MOV R0, #50H ; 将R0寄存器设置为50H
MOV R1, #0 ; 将R1寄存器设置为0

LOOP:
    MOV A, @R0 ; 将R0指向的内部RAM地址中的数据存储到累加器A中
    MOVX @DPTR, A ; 将累加器A中的数据存储到外部RAM地址DPTR指向的地址中
    INC R0 ; 将R0寄存器加1
    INC DPTR ; 将DPTR寄存器加1
    INC R1 ; 将R1寄存器加1
    CJNE R1, #16, LOOP ; 如果R1寄存器不等于16，则跳转到LOOP标签处
    SJMP   $
    END
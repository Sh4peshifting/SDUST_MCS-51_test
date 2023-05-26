#include <reg52.h>
#define uint unsigned int
#define uchar unsigned char

void delay(uint xms) //延时函数
{
    uint i,j;
    for(i=xms;i>0;i--)
        for(j=110;j>0;j--);
}

void main()
{
    uchar i;
    while(1)
    {
        for(i=0;i<8;i++)
        {
            P0=~(1<<i); //点亮LED
            delay(500); //延时500ms
        }
    }
}
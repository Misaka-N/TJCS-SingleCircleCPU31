`timescale 1ns / 1ps
module DMEM(                    //DMEM根据性能考量，设计成异步读取数据，同步写入数据的形式
    input dm_clk,               //DMEM时钟信号，只在写数据时使用
    input dm_ena,               //使能信号端，高电平有效，有效时才能读取/写入数据
    input dm_r,                 //read读信号，读取时拉高
    input dm_w,                 //write写信号，写入时拉高
    input [10:0] dm_addr,       //11位地址，要读取/写入的地址
    input [31:0] dm_data_in,    //写入时要写入的数据
    output [31:0] dm_data_out   //读取时读取到的数据
    );

reg [31:0] dmem [31:0];//DMEM区域

assign dm_data_out = (dm_ena && dm_r && !dm_w) ? dmem[dm_addr] : 32'bz;//必须是使能端开启、读指令有效且写指令无效时，才将对应地址的数据送出，否则置为高阻抗

always @(negedge dm_clk)//时钟上升沿写入数据
begin
    if(dm_ena && dm_w &&!dm_r)//必须是使能端开启、写指令有效且读指令无效时，才向寄存器中写入数据
        dmem[dm_addr]<=dm_data_in;
end
//如果二者都没拉高/同时拉高，其结果是什么都不做，防止出现又写又读的冲突情况
endmodule

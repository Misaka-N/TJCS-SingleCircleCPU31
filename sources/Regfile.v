`timescale 1ns / 1ps
module regfile(                 //寄存器堆RegFile，写入为同步，读取为异步
    input  reg_clk,             //时钟信号，下降沿有效
    input  reg_ena,             //使能信号端，上升沿有效
    input  rst_n,               //复位信号，高电平有效（检测上升沿）
    input  reg_w,               //写信号，高电平时寄存器可写入，低电平不可写入
    input  [4:0] RdC,           //Rd对应的寄存器的地址（写入端）
    input  [4:0] RtC,           //Rt对应的寄存器的地址（输出端）
    input  [4:0] RsC,           //Rs对应的寄存器的地址（输出端）
    input  [31:0] Rd_data_in,   //要向寄存器中写入的值（需拉高reg_w）
    output [31:0] Rs_data_out,  //Rs对应的寄存器的输出值
    output [31:0] Rt_data_out   //Rt对应的寄存器的输出值
    );
/* 内部用变量 */
reg [31:0] array_reg [31:0];    //定义寄存器堆

/* 赋值，异步读取 */
assign Rs_data_out = reg_ena ? array_reg[RsC] : 32'bz;
assign Rt_data_out = reg_ena ? array_reg[RtC] : 32'bz;  //只要使能端为高电平（启用寄存器堆）就随时可以读取数据

/* 接下来考虑异步写入的问题 */
always @(negedge reg_clk or posedge rst_n)  //复位信号上升沿或时钟下降沿有效
begin
    if(rst_n && reg_ena)    //复位信号高电平，复位，全部置0（这里有两种写法：加ena代表只有启用寄存器堆后才能清空，不加代表随时可以，为了数据安全考虑，这里采用前者，防止寄存器数据被无意中清空）
    begin
        array_reg[0]  <= 32'h0;
        array_reg[1]  <= 32'h0;
        array_reg[2]  <= 32'h0;
        array_reg[3]  <= 32'h0;
        array_reg[4]  <= 32'h0;
        array_reg[5]  <= 32'h0;
        array_reg[6]  <= 32'h0;
        array_reg[7]  <= 32'h0;
        array_reg[8]  <= 32'h0;
        array_reg[9]  <= 32'h0;
        array_reg[10] <= 32'h0;
        array_reg[11] <= 32'h0;
        array_reg[12] <= 32'h0;
        array_reg[13] <= 32'h0;
        array_reg[14] <= 32'h0;
        array_reg[15] <= 32'h0;
        array_reg[16] <= 32'h0;
        array_reg[17] <= 32'h0;
        array_reg[18] <= 32'h0;
        array_reg[19] <= 32'h0;
        array_reg[20] <= 32'h0;
        array_reg[21] <= 32'h0;
        array_reg[22] <= 32'h0;
        array_reg[23] <= 32'h0;
        array_reg[24] <= 32'h0;
        array_reg[25] <= 32'h0;
        array_reg[26] <= 32'h0;
        array_reg[27] <= 32'h0;
        array_reg[28] <= 32'h0;
        array_reg[29] <= 32'h0;
        array_reg[30] <= 32'h0;
        array_reg[31] <= 32'h0;
    end
    else if(reg_ena && reg_w && (RdC != 5'h0)) //reg_ena和reg_w都为高电平，启用寄存器堆且需要写数据，允许写（特别注意：0号寄存器常0，不允许修改，不在写入范围之内）
        array_reg[RdC] <= Rd_data_in;
end

endmodule

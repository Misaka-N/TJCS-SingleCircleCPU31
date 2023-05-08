`timescale 1ns / 1ps
module PC(                      //指令地址寄存器
    input  pc_clk,              //PC寄存器的时钟信号，写入为同步（时钟下降沿有效），读取为异步
    input  pc_ena,              //使能端信号，高电平有效
    input  rst_n,               //复位信号，高电平有效
    input  [31:0] pc_addr_in,   //本次输入PC寄存器的指令地址，也就是下一次要执行的指令
    output [31:0] pc_addr_out   //本次从PC寄存器中传出的指令地址，也就是当前需要执行的指令
    );
/* 内部用变量 */
reg [31:0] pc_reg = 32'h00400000;//起始位置在32'h00400000，因此赋初值也是这个

/* 赋值，异步读取 */
assign pc_addr_out = pc_ena ? pc_reg : 32'hz;   //只要使能端为高电平（启用PC寄存器）就随时可以读取数据

/* 接下来考虑异步写入的问题 */
always @(negedge pc_clk or posedge rst_n)   //复位信号上升沿或时钟下降沿有效
begin
    if(rst_n && pc_ena)         //复位信号高电平，复位，全部置0（这里有两种写法：加ena代表只有启用寄存器堆后才能清空，不加代表随时可以，为了数据安全考虑，这里采用前者，防止寄存器数据被无意中清空）
        pc_reg <= 32'h00400000; //注意起始位置时32'h00400000
    else if(pc_ena)             //能执行到这里说明clk处于下降沿，只要使能端为高电平就可修改PC的值
        pc_reg <= pc_addr_in;

end

endmodule

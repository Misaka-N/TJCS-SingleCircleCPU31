`timescale 1ns / 1ps
module sccomp_dataflow(
    input clk_in,       //时钟信号
    input reset,        //复位信号
    output [31:0] inst, //输出指令
    output [31:0] pc    //执行地址
    );

/* CPU用 */
wire [31:0] pc_out;          //输出指令地址，告诉IMEM要取哪条
wire [31:0] dm_addr_temp;    //DMEM临时地址，需要转化


/* IMEM用 */
wire [31:0] im_addr_in;     //11位指令码地址，从IMEM中读指令
wire [31:0] im_instr_out;   //32位指令码

assign im_addr_in = pc_out - 32'h00400000;

/* DMEM用 */
wire dm_ena;                //是否需要启用DMEM
wire dm_r, dm_w;            //读写指令
wire [31:0] dm_addr;        //需要用到的DMEM地址
wire [31:0] dm_data_out;    //DMEM读取时读取到的数据
wire [31:0] dm_data_w;      //要写入DMEM的内容 

assign dm_addr = (dm_addr_temp -  32'h10010000)/4;

/* 输出用 */
assign pc = pc_out;
assign inst = im_instr_out;


/* IMEM指令存储器调用 */
IMEM imem(
    .im_addr_in(im_addr_in[12:2]),  //11位指令码地址，从IMEM中读指令
    .im_instr_out(im_instr_out)     //32位指令码
    );

/* DMEM数据存储器调用 */
DMEM dmem(                      //DMEM根据性能考量，设计成异步读取数据，同步写入数据的形式
    .dm_clk(clk_in),            //DMEM时钟信号，只在写数据时使用
    .dm_ena(dm_ena),            //使能信号端，高电平有效，有效时才能读取/写入数据
    .dm_r(dm_r),                //read读信号，读取时拉高
    .dm_w(dm_w),                //write写信号，写入时拉高
    .dm_addr(dm_addr[10:0]),    //11位地址，要读取/写入的地址
    .dm_data_in(dm_data_w),     //写入时要写入的数据
    .dm_data_out(dm_data_out)   //读取时读取到的数据
    );

/* CPU调用 */
cpu sccpu(
    .clk(clk_in),               //CPU执行时钟
    .ena(1'b1),                 //使能信号端
    .rst_n(reset),              //复位信号
    .instr_in(im_instr_out),    //当前要执行的指令
    .dm_data(dm_data_out),      //读取到的DMEM的具体内容
    .dm_ena(dm_ena),            //是否需要启用DMEM
    .dm_w(dm_w),                //如果启用DMEM，是否为写入
    .dm_r(dm_r),                //如果启用DMEM，是否为读取
    .pc_out(pc_out),            //输出指令地址，告诉IMEM要取哪条
    .dm_addr(dm_addr_temp),     //需要用到的DMEM地址
    .dm_data_w(dm_data_w)       //要写入DMEM的内容 
    );

endmodule

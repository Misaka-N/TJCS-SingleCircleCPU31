`timescale 1ns / 1ps
module cpu(
    input clk,                  //CPU执行时钟
    input ena,                  //使能信号端
    input rst_n,                //复位信号
    input [31:0] instr_in,      //当前要执行的指令
    input [31:0] dm_data,       //读取到的DMEM的具体内容
    output dm_ena,              //是否需要启用DMEM
    output dm_w,                //如果启用DMEM，是否为写入
    output dm_r,                //如果启用DMEM，是否为读取
    output [31:0] pc_out,       //输出指令地址，告诉IMEM要取哪条
    output [31:0] dm_addr,      //启用DMEM的地址
    output [31:0] dm_data_w     //要写入DMEM的内容 
    );
/* 定义一些内部变量 */
/* Decoder用 */
wire add_flag,  addu_flag, sub_flag, subu_flag, and_flag, or_flag, xor_flag, nor_flag,
     slt_flag,  sltu_flag,
     sll_flag,  srl_flag,  sra_flag, sllv_flag,
     srlv_flag, srav_flag,
     jr_flag,
     addi_flag, addiu_flag,
     andi_flag, ori_flag,  xori_flag,
     lw_flag,   sw_flag,
     beq_flag,  bne_flag,
     slti_flag, sltiu_flag,
     lui_flag,
     j_flag,    jal_flag;       //各个指令的标志信息
wire [4:0] RsC;                 //Rs对应的寄存器的地址
wire [4:0] RtC;                 //Rt对应的寄存器的地址
wire [4:0] RdC;                 //Rd对应的寄存器的地址
wire [4:0] shamt;               //位移偏移量（SLL，SRL，SRA用）
wire [15:0] immediate;          //立即数（I型指令用）
wire [25:0] address;            //跳转地址（J型指令用）

/* Control用 */
wire reg_w;                     //RegFile寄存器堆是否可写入
wire [9:0] mux;                 //9个多路选择器的状态
wire [4:0] ext_ena;             //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
wire cat_ena;                   //是否需要拼接

/* ALU用 */
wire [31:0] a, b;                              //ALU的A、B运算输入端
wire [3:0]  aluc;                       //ALUC四位运算指令
wire [31:0] alu_data_out;               //ALU输出的数据
wire zero, carry, negative, overflow;   //四个标志位

/* 寄存器堆RegFile用 */
wire [31:0] Rd_data_in;     //要向寄存器中写入的值
wire [31:0] Rs_data_out;    //Rs对应的寄存器的输出值
wire [31:0] Rt_data_out;    //Rt对应的寄存器的输出值

/* PC寄存器用 */
wire [31:0] pc_addr_in;     //本次输入PC寄存器的指令地址，也就是下一次要执行的指令
wire [31:0] pc_addr_out;    //本次从PC寄存器中传出的指令地址，也就是当前需要执行的指令

/* 连接各模块 */
/* 符号、数据扩展器线路 */
wire [31:0] ext1_out;
wire [31:0] ext5_out;
wire [31:0] ext16_out;
wire signed [31:0] ext16_out_signed;
wire signed [31:0] ext18_out_signed;

assign ext1_out         = (slt_flag  || sltu_flag) ? negative : (slti_flag || sltiu_flag) ? carry : 32'hz;
assign ext5_out         = (sll_flag  || srl_flag   || sra_flag) ? shamt : 32'hz;
assign ext16_out        = (andi_flag || ori_flag   || xori_flag || lui_flag) ? { 16'h0 , immediate[15:0] } : 32'hz;
assign ext16_out_signed = (addi_flag || addiu_flag || lw_flag || sw_flag || slti_flag || sltiu_flag) ?  { {16{immediate[15]}} , immediate[15:0] } : 32'hz;
assign ext18_out_signed = (beq_flag  || bne_flag) ? {{14{immediate[15]}}, immediate[15:0], 2'b0} : 32'hz;
//注意：Verilog不会显式地将无符号数变为有符号数，只有在运算时才会进行操作。因此我们不能通过赋值的方法完成从无符号数到有符号数的扩展，必须将符号位复制到高位

/* ||拼接器线路 */
wire [31:0] cat_out;

assign cat_out = cat_ena ? {pc_out[31:28], address[25:0], 2'h0} : 32'hz;

/* NPC线路 */
wire [31:0] npc;
assign npc = pc_addr_out + 4;

/* 多路选择器线路 */
wire [31:0] mux1_out;
wire [31:0] mux2_out;
wire [31:0] mux3_out;
wire [31:0] mux4_out;
wire [31:0] mux5_out;
wire [31:0] mux6_out;
wire [31:0] mux7_out;
wire [31:0] mux8_out;
wire [31:0] mux9_out;

assign mux1_out = mux[1] ? cat_out          : mux4_out;
assign mux2_out = mux[2] ? mux9_out         : dm_data;
assign mux3_out = mux[3] ? ext5_out         : ((sllv_flag || srlv_flag || srav_flag) ? { 27'h0, Rs_data_out[4:0] } : Rs_data_out);//特别注意如果是寄存器的移位指令，要对进入a的数据进行处理，只取最后五位
assign mux4_out = mux[4] ? mux6_out         : Rs_data_out;
assign mux5_out = mux[5] ? mux8_out         : Rt_data_out;
assign mux6_out = mux[6] ? npc              : ext18_out_signed + npc;
assign mux7_out = mux[7] ? pc_addr_out + 4  : mux2_out;
assign mux8_out = mux[8] ? ext16_out_signed : ext16_out;
assign mux9_out = mux[9] ? alu_data_out     : ext1_out;

/* PC线路 */
assign pc_addr_in = mux1_out;

/* ALU 接线口 */
assign a = mux3_out;
assign b = mux5_out;

/* IMEM接口 */
assign pc_out = pc_addr_out;

/* DMEM接口 */
assign dm_ena  = (dm_r || dm_w) ? 1'b1 : 1'b0;
assign dm_addr = alu_data_out;
assign dm_data_w = Rt_data_out;

/* 寄存器堆线路 */
assign Rd_data_in = mux7_out;

/* 实例化译码器 */
Decoder Decoder_inst(
    .instr_in(instr_in),        //需要译码的指令，也就是当前要执行的指令
    .add_flag(add_flag),        //指令是否为ADD
    .addu_flag(addu_flag),      //指令是否为ADDU
    .sub_flag(sub_flag),        //指令是否为SUB
    .subu_flag(subu_flag),      //指令是否为SUBU
    .and_flag(and_flag),        //指令是否为AND
    .or_flag(or_flag),          //指令是否为OR
    .xor_flag(xor_flag),        //指令是否为XOR
    .nor_flag(nor_flag),        //指令是否为NOR
    .slt_flag(slt_flag),        //指令是否为SLT
    .sltu_flag(sltu_flag),      //指令是否为SLTU
    .sll_flag(sll_flag) ,       //指令是否为SLL
    .srl_flag(srl_flag),        //指令是否为SRL
    .sra_flag(sra_flag),        //指令是否为SRA
    .sllv_flag(sllv_flag),      //指令是否为SLLV
    .srlv_flag(srlv_flag),      //指令是否为SRLV
    .srav_flag(srav_flag),      //指令是否为SRAV
    .jr_flag(jr_flag),          //指令是否为JR
    .addi_flag(addi_flag),      //指令是否为ADDI
    .addiu_flag(addiu_flag),    //指令是否为ADDIU
    .andi_flag(andi_flag),      //指令是否为ANDI
    .ori_flag(ori_flag),        //指令是否为ORI
    .xori_flag(xori_flag),      //指令是否为XORI
    .lw_flag(lw_flag),          //指令是否为LW
    .sw_flag(sw_flag),          //指令是否为SW
    .beq_flag(beq_flag),        //指令是否为BEQ
    .bne_flag(bne_flag),        //指令是否为BNE
    .slti_flag(slti_flag),      //指令是否为SLTI
    .sltiu_flag(sltiu_flag),    //指令是否为SLTIU
    .lui_flag(lui_flag),        //指令是否为LUI
    .j_flag(j_flag),            //指令是否为J
    .jal_flag(jal_flag),        //指令是否为JAL
    .RsC(RsC),                  //Rs对应的寄存器的地址
    .RtC(RtC),                  //Rt对应的寄存器的地址
    .RdC(RdC),                  //Rd对应的寄存器的地址
    .shamt(shamt),              //位移偏移量（SLL，SRL，SRA用）
    .immediate(immediate),      //立即数（I型指令用）
    .address(address)           //跳转地址（J型指令用）
    );

/* 实例化控制器 */
Controler Controler_inst(              
    .add_flag(add_flag),        //指令是否为ADD
    .addu_flag(addu_flag),      //指令是否为ADDU
    .sub_flag(sub_flag),        //指令是否为SUB
    .subu_flag(subu_flag),      //指令是否为SUBU
    .and_flag(and_flag),        //指令是否为AND
    .or_flag(or_flag),          //指令是否为OR
    .xor_flag(xor_flag),        //指令是否为XOR
    .nor_flag(nor_flag),        //指令是否为NOR
    .slt_flag(slt_flag),        //指令是否为SLT
    .sltu_flag(sltu_flag),      //指令是否为SLTU
    .sll_flag(sll_flag) ,       //指令是否为SLL
    .srl_flag(srl_flag),        //指令是否为SRL
    .sra_flag(sra_flag),        //指令是否为SRA
    .sllv_flag(sllv_flag),      //指令是否为SLLV
    .srlv_flag(srlv_flag),      //指令是否为SRLV
    .srav_flag(srav_flag),      //指令是否为SRAV
    .jr_flag(jr_flag),          //指令是否为JR
    .addi_flag(addi_flag),      //指令是否为ADDI
    .addiu_flag(addiu_flag),    //指令是否为ADDIU
    .andi_flag(andi_flag),      //指令是否为ANDI
    .ori_flag(ori_flag),        //指令是否为ORI
    .xori_flag(xori_flag),      //指令是否为XORI
    .lw_flag(lw_flag),          //指令是否为LW
    .sw_flag(sw_flag),          //指令是否为SW
    .beq_flag(beq_flag),        //指令是否为BEQ
    .bne_flag(bne_flag),        //指令是否为BNE
    .slti_flag(slti_flag),      //指令是否为SLTI
    .sltiu_flag(sltiu_flag),    //指令是否为SLTIU
    .lui_flag(lui_flag),        //指令是否为LUI
    .j_flag(j_flag),            //指令是否为J
    .jal_flag(jal_flag),        //指令是否为JAL
    .zero(zero),                //ALU标志位ZF
    .reg_w(reg_w),              //RegFile寄存器堆是否可写入
    .aluc(aluc),                //ALUC的指令，决定ALUC执行何种操作
    .dm_r(dm_r),                //DMEM是否可写入
    .dm_w(dm_w),                //是否从DMEM中读取数据
    .ext_ena(ext_ena),          //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
    .cat_ena(cat_ena),          //是否需要拼接
    .mux(mux)                   //9个多路选择器的状态（选择0还是选择1）(0没用到，为了使MUX编号和数组下标对应所以多一个)
    );

/* 实例化ALU */
ALU ALU_inst(                      
    .A(a),                      //对应A接口
    .B(b),                      //对应B接口
    .ALUC(aluc),                //ALUC四位操作指令
    .alu_data_out(alu_data_out),//输出数据
    .zero(zero),                //ZF标志位，BEQ/BNE使用
    .carry(carry),              //CF标志位，SLTI/SLTIU使用
    .negative(negative),        //NF(SF)标志位，SLT/SLTU使用
    .overflow(overflow)         //OF标志位，其实没有用到
    );

/* 实例化寄存器堆 */
regfile cpu_ref(                //寄存器堆RegFile，写入为同步，读取为异步
    .reg_clk(clk),              //时钟信号，下降沿有效
    .reg_ena(ena),              //使能信号端，上升沿有效
    .rst_n(rst_n),              //复位信号，高电平有效（检测上升沿）
    .reg_w(reg_w),              //写信号，高电平时寄存器可写入，低电平不可写入
    .RdC(RdC),                  //Rd对应的寄存器的地址（写入端）
    .RtC(RtC),                  //Rt对应的寄存器的地址（输出端）
    .RsC(RsC),                  //Rs对应的寄存器的地址（输出端）
    .Rd_data_in(Rd_data_in),    //要向寄存器中写入的值（需拉高reg_w）
    .Rs_data_out(Rs_data_out),  //Rs对应的寄存器的输出值
    .Rt_data_out(Rt_data_out)   //Rt对应的寄存器的输出值
    );

/* 实例化PC寄存器 */
PC PC_inst(                     //指令地址寄存器
    .pc_clk(clk),               //PC寄存器的时钟信号，写入为同步（时钟下降沿有效），读取为异步
    .pc_ena(ena),               //使能端信号，高电平有效
    .rst_n(rst_n),              //复位信号，高电平有效
    .pc_addr_in(pc_addr_in),    //本次输入PC寄存器的指令地址，也就是下一次要执行的指令
    .pc_addr_out(pc_addr_out)   //本次从PC寄存器中传出的指令地址，也就是当前需要执行的指令
    );

endmodule

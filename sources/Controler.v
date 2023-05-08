`timescale 1ns / 1ps
module Controler(              //控制器，根据当前要执行的指令输出各个元器件的状态
    input add_flag,            //指令是否为ADD
    input addu_flag,           //指令是否为ADDU
    input sub_flag,            //指令是否为SUB
    input subu_flag,           //指令是否为SUBU
    input and_flag,            //指令是否为AND
    input or_flag,             //指令是否为OR
    input xor_flag,            //指令是否为XOR
    input nor_flag,            //指令是否为NOR
    input slt_flag,            //指令是否为SLT
    input sltu_flag,           //指令是否为SLTU
    input sll_flag,            //指令是否为SLL
    input srl_flag,            //指令是否为SRL
    input sra_flag,            //指令是否为SRA
    input sllv_flag,           //指令是否为SLLV
    input srlv_flag,           //指令是否为SRLV
    input srav_flag,           //指令是否为SRAV
    input jr_flag,             //指令是否为JR
    input addi_flag,           //指令是否为ADDI
    input addiu_flag,          //指令是否为ADDIU
    input andi_flag,           //指令是否为ANDI
    input ori_flag,            //指令是否为ORI
    input xori_flag,           //指令是否为XORI
    input lw_flag,             //指令是否为LW
    input sw_flag,             //指令是否为SW
    input beq_flag,            //指令是否为BEQ
    input bne_flag,            //指令是否为BNE
    input slti_flag,           //指令是否为SLTI
    input sltiu_flag,          //指令是否为SLTIU
    input lui_flag,            //指令是否为LUI
    input j_flag,              //指令是否为J
    input jal_flag,            //指令是否为JAL
    input zero,                //ALU标志位ZF
    /* 所有用到的元件和指令这里都会涉及到 */
    output reg_w,              //RegFile寄存器堆是否可写入
    output [3:0] aluc,         //ALUC的指令，决定ALUC执行何种操作
    output dm_r,               //DMEM是否可写入
    output dm_w,               //是否从DMEM中读取数据
    output [4:0] ext_ena,      //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
    output cat_ena,            //是否需要拼接
    output [9:0] mux           //9个多路选择器的状态（选择0还是选择1）(0没用到，为了使MUX编号和数组下标对应所以多一个)
    );
/* 下面是赋值，也就是根据要执行的操作决定各元器件的状态 */
assign reg_w = (!jr_flag && !sw_flag && !beq_flag && !bne_flag && !j_flag) ? 1'b1 : 1'b0;

assign aluc[3] = (slt_flag  || sltu_flag  || sllv_flag || srlv_flag ||
                  srav_flag || sll_flag   || srl_flag  || sra_flag  || 
                  slti_flag || sltiu_flag || lui_flag) ? 1'b1 : 1'b0;
assign aluc[2] = (and_flag  || or_flag    || xor_flag  || nor_flag  ||
                  sllv_flag || srlv_flag  || srav_flag || sll_flag  ||
                  srl_flag  || sra_flag   || andi_flag || ori_flag  ||
                  xori_flag) ? 1'b1 : 1'b0;
assign aluc[1] = (add_flag  || sub_flag   || xor_flag  || nor_flag  ||
                  slt_flag  || sltu_flag  || sllv_flag || sll_flag  ||
                  addi_flag || xori_flag  || slti_flag || sltiu_flag) ? 1'b1 : 1'b0;
assign aluc[0] = (sub_flag  || subu_flag  || or_flag   || nor_flag  ||
                  slt_flag  || sllv_flag  || srlv_flag || sll_flag  ||
                  srl_flag  || ori_flag   || slti_flag || lui_flag  ||
                  beq_flag  || bne_flag) ? 1'b1 : 1'b0;
//aluc[0]中SLLV、SLL、LUI加不加均可

assign dm_r = lw_flag ? 1'b1 : 1'b0;
assign dm_w = sw_flag ? 1'b1 : 1'b0;

assign ext_ena[4] = (beq_flag  || bne_flag) ? 1'b1 : 1'b0;                              //EXT18(S)
assign ext_ena[3] = (addi_flag || addiu_flag || lw_flag   || sw_flag ||
                     slti_flag || sltiu_flag) ? 1'b1 : 1'b0;                            //EXT16(S)
assign ext_ena[2] = (andi_flag || ori_flag   || xori_flag || lui_flag) ? 1'b1 : 1'b0;   //EXT16
assign ext_ena[1] = (sll_flag  || srl_flag   || sra_flag) ? 1'b1 : 1'b0;                //EXT5
assign ext_ena[0] = (slt_flag  || sltu_flag  || slti_flag || sltiu_flag) ? 1'b1 : 1'b0; //EXT1

assign cat_ena = (j_flag || jal_flag) ? 1'b1 : 1'b0;

assign mux[9] = (add_flag   || addu_flag  || sub_flag  || subu_flag  ||
                 and_flag   || or_flag    || xor_flag  || nor_flag   ||
                 sll_flag   || srl_flag   || sra_flag  || sllv_flag  ||
                 srlv_flag  || srav_flag  || lui_flag  || addi_flag  || 
                 addiu_flag || andi_flag  || ori_flag  || xori_flag) ? 1'b1 : 1'b0;
assign mux[8] = (addi_flag  || addiu_flag || lw_flag   || sw_flag    ||
                 slti_flag  || sltiu_flag) ? 1'b1 : 1'b0;
assign mux[7] = jal_flag ? 1'b1 : 1'b0;
assign mux[6] = beq_flag ? ~zero : (bne_flag ? zero : 1'b1);
assign mux[5] = (addi_flag  || addiu_flag || andi_flag || ori_flag  ||
                 xori_flag  || lw_flag    || sw_flag   || slti_flag ||
                 sltiu_flag || lui_flag) ? 1'b1 : 1'b0;
assign mux[4] = (!jr_flag && !j_flag && !jal_flag) ? 1'b1 : 1'b0;
assign mux[3] = (sll_flag   || srl_flag   || sra_flag) ? 1'b1 : 1'b0;
assign mux[2] = !lw_flag ? 1'b1 : 1'b0;
assign mux[1] = (j_flag || jal_flag) ? 1'b1 : 1'b0;

endmodule

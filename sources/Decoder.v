`timescale 1ns / 1ps
module Decoder(                 //所有接口如果当前译码出的指令不需要，置为高阻抗
    input  [31:0] instr_in,     //需要译码的指令，也就是当前要执行的指令
    output add_flag,            //指令是否为ADD
    output addu_flag,           //指令是否为ADDU
    output sub_flag,            //指令是否为SUB
    output subu_flag,           //指令是否为SUBU
    output and_flag,            //指令是否为AND
    output or_flag,             //指令是否为OR
    output xor_flag,            //指令是否为XOR
    output nor_flag,            //指令是否为NOR
    output slt_flag,            //指令是否为SLT
    output sltu_flag,           //指令是否为SLTU
    output sll_flag,            //指令是否为SLL
    output srl_flag,            //指令是否为SRL
    output sra_flag,            //指令是否为SRA
    output sllv_flag,           //指令是否为SLLV
    output srlv_flag,           //指令是否为SRLV
    output srav_flag,           //指令是否为SRAV
    output jr_flag,             //指令是否为JR
    output addi_flag,           //指令是否为ADDI
    output addiu_flag,          //指令是否为ADDIU
    output andi_flag,           //指令是否为ANDI
    output ori_flag,            //指令是否为ORI
    output xori_flag,           //指令是否为XORI
    output lw_flag,             //指令是否为LW
    output sw_flag,             //指令是否为SW
    output beq_flag,            //指令是否为BEQ
    output bne_flag,            //指令是否为BNE
    output slti_flag,           //指令是否为SLTI
    output sltiu_flag,          //指令是否为SLTIU
    output lui_flag,            //指令是否为LUI
    output j_flag,              //指令是否为J
    output jal_flag,            //指令是否为JAL
    output [4:0]  RsC,          //Rs对应的寄存器的地址
    output [4:0]  RtC,          //Rt对应的寄存器的地址
    output [4:0]  RdC,          //Rd对应的寄存器的地址
    output [4:0]  shamt,        //位移偏移量（SLL，SRL，SRA用）
    output [15:0] immediate,    //立即数（I型指令用）
    output [25:0] address       //跳转地址（J型指令用）
    );
/* 定义各指令在原指令中对应的编码 */
/* 下面这些指令经过了扩展，OP段全为0，需要额外的6位FUNC加以区分 */
parameter ADD_OPE   = 6'b100000;
parameter ADDU_OPE  = 6'b100001;
parameter SUB_OPE   = 6'b100010;
parameter SUBU_OPE  = 6'b100011;
parameter AND_OPE   = 6'b100100;
parameter OR_OPE    = 6'b100101;
parameter XOR_OPE   = 6'b100110;
parameter NOR_OPE   = 6'b100111;
parameter SLT_OPE   = 6'b101010;
parameter SLTU_OPE  = 6'b101011;

parameter SLL_OPE   = 6'b000000;
parameter SRL_OPE   = 6'b000010;
parameter SRA_OPE   = 6'b000011;

parameter SLLV_OPE  = 6'b000100;
parameter SRLV_OPE  = 6'b000110;
parameter SRAV_OPE  = 6'b000111;

parameter JR_OPE    = 6'b001000;
/* 下面这些指令通过OP段直接加以区分 */
parameter ADDI_OPE  = 6'b001000;
parameter ADDIU_OPE = 6'b001001;
parameter ANDI_OPE  = 6'b001100;
parameter ORI_OPE   = 6'b001101;
parameter XORI_OPE  = 6'b001110;
parameter LW_OPE    = 6'b100011;
parameter SW_OPE    = 6'b101011;
parameter BEQ_OPE   = 6'b000100;
parameter BNE_OPE   = 6'b000101;
parameter SLTI_OPE  = 6'b001010;
parameter SLTIU_OPE = 6'b001011;

parameter LUI_OPE   = 6'b001111;

parameter J_OPE     = 6'b000010;
parameter JAL_OPE   = 6'b000011;

/* 下面是赋值 */
/* 对指令进行译码，判断是哪个指令 */
assign add_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADD_OPE )) ? 1'b1 : 1'b0;
assign addu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADDU_OPE)) ? 1'b1 : 1'b0;
assign sub_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUB_OPE )) ? 1'b1 : 1'b0;
assign subu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUBU_OPE)) ? 1'b1 : 1'b0;
assign and_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == AND_OPE )) ? 1'b1 : 1'b0;
assign or_flag   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == OR_OPE  )) ? 1'b1 : 1'b0;
assign xor_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == XOR_OPE )) ? 1'b1 : 1'b0;
assign nor_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == NOR_OPE )) ? 1'b1 : 1'b0;
assign slt_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLT_OPE )) ? 1'b1 : 1'b0;
assign sltu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLTU_OPE)) ? 1'b1 : 1'b0;

assign sll_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLL_OPE )) ? 1'b1 : 1'b0;
assign srl_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRL_OPE )) ? 1'b1 : 1'b0;
assign sra_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRA_OPE )) ? 1'b1 : 1'b0;

assign sllv_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLLV_OPE)) ? 1'b1 : 1'b0;
assign srlv_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRLV_OPE)) ? 1'b1 : 1'b0;
assign srav_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRAV_OPE)) ? 1'b1 : 1'b0;
assign jr_flag   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == JR_OPE  )) ? 1'b1 : 1'b0;

assign addi_flag  = (instr_in[31:26] == ADDI_OPE ) ? 1'b1 : 1'b0;
assign addiu_flag = (instr_in[31:26] == ADDIU_OPE) ? 1'b1 : 1'b0;
assign andi_flag  = (instr_in[31:26] == ANDI_OPE ) ? 1'b1 : 1'b0;
assign ori_flag   = (instr_in[31:26] == ORI_OPE  ) ? 1'b1 : 1'b0;
assign xori_flag  = (instr_in[31:26] == XORI_OPE ) ? 1'b1 : 1'b0;
assign lw_flag    = (instr_in[31:26] == LW_OPE   ) ? 1'b1 : 1'b0;
assign sw_flag    = (instr_in[31:26] == SW_OPE   ) ? 1'b1 : 1'b0;
assign beq_flag   = (instr_in[31:26] == BEQ_OPE  ) ? 1'b1 : 1'b0;
assign bne_flag   = (instr_in[31:26] == BNE_OPE  ) ? 1'b1 : 1'b0;
assign slti_flag  = (instr_in[31:26] == SLTI_OPE ) ? 1'b1 : 1'b0;
assign sltiu_flag = (instr_in[31:26] == SLTIU_OPE) ? 1'b1 : 1'b0;

assign lui_flag   = (instr_in[31:26] == LUI_OPE  ) ? 1'b1 : 1'b0;

assign j_flag     = (instr_in[31:26] == J_OPE    ) ? 1'b1 : 1'b0;
assign jal_flag   = (instr_in[31:26] == JAL_OPE  ) ? 1'b1 : 1'b0;

/* 取出指令中各部分的值 */
assign RsC = (add_flag  || addu_flag || sub_flag  || subu_flag  ||
              and_flag  || or_flag   || xor_flag  || nor_flag   ||
              slt_flag  || sltu_flag || sllv_flag || srlv_flag  ||
              srav_flag || jr_flag   || addi_flag || addiu_flag ||
              andi_flag || ori_flag  || xori_flag || lw_flag    ||
              sw_flag   || beq_flag  || bne_flag  || slti_flag  ||
              sltiu_flag) ? instr_in[25:21] : 5'hz;

assign RtC = (add_flag  || addu_flag  || sub_flag   || subu_flag ||
              and_flag  || or_flag    || xor_flag   || nor_flag  ||
              slt_flag  || sltu_flag  || sll_flag   || srl_flag  ||
              sra_flag  || sllv_flag  || srlv_flag  || srav_flag ||
              sw_flag   || beq_flag   || bne_flag ) ? instr_in[20:16] : 5'hz;

assign RdC = (add_flag  || addu_flag  || sub_flag  || subu_flag  ||
              and_flag  || or_flag    || xor_flag  || nor_flag   ||
              slt_flag  || sltu_flag  || sll_flag  || srl_flag   ||
              sra_flag  || sllv_flag  || srlv_flag || srav_flag) ? instr_in[15:11] : ((
              addi_flag || addiu_flag || andi_flag || ori_flag   || 
              xori_flag || lw_flag    || slti_flag || sltiu_flag ||
              lui_flag) ? instr_in[20:16] : (jal_flag ? 5'd31 : 5'hz));

assign shamt = (sll_flag || srl_flag || sra_flag) ? instr_in[10:6] : 5'hz;        

assign immediate = (addi_flag || addiu_flag || andi_flag  || ori_flag || 
                    xori_flag || lw_flag    || sw_flag    || beq_flag || 
                    bne_flag  || slti_flag  || sltiu_flag || lui_flag) ? instr_in[15:0] : 16'hz;

assign address = (j_flag || jal_flag) ? instr_in[25:0] : 26'hz;     

endmodule

`timescale 1ns / 1ps
module IMEM(
    input [10:0] im_addr_in,     //11位指令码地址，从IMEM中读指令
    output [31:0] im_instr_out   //32位指令码
    ); 

dist_mem_gen_0 imem(    //实例化IP核，输入指令码地址返回对应的指令
    .a(im_addr_in),   //接口和IMEM模块对应
    .spo(im_instr_out)
    );
endmodule

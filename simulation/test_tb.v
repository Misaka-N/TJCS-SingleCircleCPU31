`timescale 1ns / 1ps
module cpu_tb;
reg clk;            //时钟信号
reg rst;            //复位信号
wire [31:0] inst;   //要执行的指令
wire [31:0] pc;     //下一条指令的地址
reg  [31:0] cnt;    //计数器，已经执行了几条指令
integer file_open;

initial 
begin
    clk = 1'b0;
    rst = 1'b1;
    #50 rst = 1'b0;
    cnt = 0;
end

always  #50 clk = ~clk;

always @ (posedge clk) begin
    cnt <= cnt + 1'b1;
    file_open = $fopen("C:\\Users\\Lenovo\\Desktop\\Project\\SingleCPU31\\output.txt", "a+");
    $fdisplay(file_open, "OP: %d", cnt);
    $fdisplay(file_open, "Instr_addr = %h", sc_inst.inst);
    $fdisplay(file_open, "$zero = %h", sc_inst.sccpu.cpu_ref.array_reg[0]);
    $fdisplay(file_open, "$at   = %h", sc_inst.sccpu.cpu_ref.array_reg[1]);
    $fdisplay(file_open, "$v0   = %h", sc_inst.sccpu.cpu_ref.array_reg[2]);
    $fdisplay(file_open, "$v1   = %h", sc_inst.sccpu.cpu_ref.array_reg[3]);
    $fdisplay(file_open, "$a0   = %h", sc_inst.sccpu.cpu_ref.array_reg[4]);
    $fdisplay(file_open, "$a1   = %h", sc_inst.sccpu.cpu_ref.array_reg[5]);
    $fdisplay(file_open, "$a2   = %h", sc_inst.sccpu.cpu_ref.array_reg[6]);
    $fdisplay(file_open, "$a3   = %h", sc_inst.sccpu.cpu_ref.array_reg[7]);
    $fdisplay(file_open, "$t0   = %h", sc_inst.sccpu.cpu_ref.array_reg[8]);
    $fdisplay(file_open, "$t1   = %h", sc_inst.sccpu.cpu_ref.array_reg[9]);
    $fdisplay(file_open, "$t2   = %h", sc_inst.sccpu.cpu_ref.array_reg[10]);
    $fdisplay(file_open, "$t3   = %h", sc_inst.sccpu.cpu_ref.array_reg[11]);
    $fdisplay(file_open, "$t4   = %h", sc_inst.sccpu.cpu_ref.array_reg[12]);
    $fdisplay(file_open, "$t5   = %h", sc_inst.sccpu.cpu_ref.array_reg[13]);
    $fdisplay(file_open, "$t6   = %h", sc_inst.sccpu.cpu_ref.array_reg[14]);
    $fdisplay(file_open, "$t7   = %h", sc_inst.sccpu.cpu_ref.array_reg[15]);
    $fdisplay(file_open, "$s0   = %h", sc_inst.sccpu.cpu_ref.array_reg[16]);
    $fdisplay(file_open, "$s1   = %h", sc_inst.sccpu.cpu_ref.array_reg[17]);
    $fdisplay(file_open, "$s2   = %h", sc_inst.sccpu.cpu_ref.array_reg[18]);
    $fdisplay(file_open, "$s3   = %h", sc_inst.sccpu.cpu_ref.array_reg[19]);
    $fdisplay(file_open, "$s4   = %h", sc_inst.sccpu.cpu_ref.array_reg[20]);
    $fdisplay(file_open, "$s5   = %h", sc_inst.sccpu.cpu_ref.array_reg[21]);
    $fdisplay(file_open, "$s6   = %h", sc_inst.sccpu.cpu_ref.array_reg[22]);
    $fdisplay(file_open, "$s7   = %h", sc_inst.sccpu.cpu_ref.array_reg[23]);
    $fdisplay(file_open, "$t8   = %h", sc_inst.sccpu.cpu_ref.array_reg[24]);
    $fdisplay(file_open, "$t9   = %h", sc_inst.sccpu.cpu_ref.array_reg[25]);
    $fdisplay(file_open, "$k0   = %h", sc_inst.sccpu.cpu_ref.array_reg[26]);
    $fdisplay(file_open, "$k1   = %h", sc_inst.sccpu.cpu_ref.array_reg[27]);
    $fdisplay(file_open, "$gp   = %h", sc_inst.sccpu.cpu_ref.array_reg[28]);
    $fdisplay(file_open, "$sp   = %h", sc_inst.sccpu.cpu_ref.array_reg[29]);
    $fdisplay(file_open, "$fp   = %h", sc_inst.sccpu.cpu_ref.array_reg[30]);
    $fdisplay(file_open, "$ra   = %h", sc_inst.sccpu.cpu_ref.array_reg[31]);
//    $fdisplay(file_open, "dmem_addr = %h", sc_inst.dmem.dm_addr);
//    $fdisplay(file_open, "dm_data_in = %h", sc_inst.dmem.dm_data_in);
//    $fdisplay(file_open, "dm_data_out = %h", sc_inst.dmem.dm_data_out);
//    $fdisplay(file_open, "$dmem0 = %h", sc_inst.dmem.dmem[0]);
//    $fdisplay(file_open, "$dmem1 = %h", sc_inst.dmem.dmem[1]);
//    $fdisplay(file_open, "$dmem2 = %h", sc_inst.dmem.dmem[2]);
//    $fdisplay(file_open, "$dmem3 = %h", sc_inst.dmem.dmem[3]);
//    $fdisplay(file_open, "$dmem4 = %h", sc_inst.dmem.dmem[4]);
//    $fdisplay(file_open, "$dmem5 = %h", sc_inst.dmem.dmem[5]);
//    $fdisplay(file_open, "$dmem6 = %h", sc_inst.dmem.dmem[6]);
//    $fdisplay(file_open, "$dmem7 = %h", sc_inst.dmem.dmem[7]);
//    $fdisplay(file_open, "$dmem8 = %h", sc_inst.dmem.dmem[8]);
//    $fdisplay(file_open, "$dmem9 = %h", sc_inst.dmem.dmem[9]);
//    $fdisplay(file_open, "$dmem10 = %h", sc_inst.dmem.dmem[10]);
//    $fdisplay(file_open, "$dmem11 = %h", sc_inst.dmem.dmem[11]);
//    $fdisplay(file_open, "$dmem12 = %h", sc_inst.dmem.dmem[12]);
//    $fdisplay(file_open, "$dmem13 = %h", sc_inst.dmem.dmem[13]);
//    $fdisplay(file_open, "$dmem14 = %h", sc_inst.dmem.dmem[14]);                                                          
//    $fdisplay(file_open, "$dmem15 = %h", sc_inst.dmem.dmem[15]);
//    $fdisplay(file_open, "$dmem16 = %h", sc_inst.dmem.dmem[16]);
//    $fdisplay(file_open, "$dmem17 = %h", sc_inst.dmem.dmem[17]);
//    $fdisplay(file_open, "$dmem18 = %h", sc_inst.dmem.dmem[18]);
//    $fdisplay(file_open, "$dmem19 = %h", sc_inst.dmem.dmem[19]);
//    $fdisplay(file_open, "$dmem20 = %h", sc_inst.dmem.dmem[20]);
//    $fdisplay(file_open, "$dmem21 = %h", sc_inst.dmem.dmem[21]);
//    $fdisplay(file_open, "$dmem22 = %h", sc_inst.dmem.dmem[22]);
//    $fdisplay(file_open, "$dmem23 = %h", sc_inst.dmem.dmem[23]);                                                          
//    $fdisplay(file_open, "$dmem24 = %h", sc_inst.dmem.dmem[24]);
//    $fdisplay(file_open, "$dmem25 = %h", sc_inst.dmem.dmem[25]);
//    $fdisplay(file_open, "$dmem26 = %h", sc_inst.dmem.dmem[26]);
//    $fdisplay(file_open, "$dmem27 = %h", sc_inst.dmem.dmem[27]);
//    $fdisplay(file_open, "$dmem28 = %h", sc_inst.dmem.dmem[28]);
//    $fdisplay(file_open, "$dmem29 = %h", sc_inst.dmem.dmem[29]);
//    $fdisplay(file_open, "$dmem30 = %h", sc_inst.dmem.dmem[30]);
//    $fdisplay(file_open, "$dmem31 = %h", sc_inst.dmem.dmem[31]);
    $fdisplay(file_open, "$pc   = %h\n", sc_inst.pc);
    $fclose(file_open);
end

sccomp_dataflow sc_inst(
    .clk_in(clk),
    .reset(rst),
    .inst(inst),
    .pc(pc)
);

endmodule

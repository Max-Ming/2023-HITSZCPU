`timescale 1ns / 1ps

`include "param.v"

module HAZARD_CONTROL (
    input wire [1:0] wd_sel,//01表示load指令
    input wire rD1_flag,
    input wire rD2_flag,
    //寄存器堆写使能
    input wire rf_we_EX,
    input wire rf_we_MEM,
    input wire rf_we_WB,
    //两个操作数地址
    input wire [4:0] rR1_ID,
    input wire [4:0] rR2_ID,
    //写回数据寄存器号
    input wire [4:0] wR_EX,
    input wire [4:0] wR_MEM,
    input wire [4:0] wR_WB,
    //写回数据
    input wire [31:0] wD_EX,
    input wire [31:0] wD_MEM,
    input wire [31:0] wD_WB,
    //判断是否发生分支冒险
    input wire npc_op,
    
    output reg stop_PC,
    output reg stop_IF_ID,
    output reg flush_IF_ID,
    output reg flush_ID_EX,
    output wire rD1_sel,
    output wire rD2_sel,
    output reg [31:0] rD1_forward,
    output reg [31:0] rD2_forward
);

//以下都是RAW型冒险
//写回的寄存器要和使用的寄存器相同且不能是0号寄存器，要有写回使能并且运算要用到这个寄存器
wire rD1_A = (wR_EX == rR1_ID) && (wR_EX != 5'b0) && (rf_we_EX == 1'b1) && (rD1_flag == 1'b1);
wire rD2_A = (wR_EX == rR2_ID) && (wR_EX != 5'b0) && (rf_we_EX == 1'b1) && (rD2_flag == 1'b1);

wire rD1_B = (wR_MEM == rR1_ID) && (wR_MEM != 5'b0) && (rf_we_MEM == 1'b1) && (rD1_flag == 1'b1);
wire rD2_B = (wR_MEM == rR2_ID) && (wR_MEM != 5'b0) && (rf_we_MEM == 1'b1) && (rD2_flag == 1'b1);

wire rD1_C = (wR_WB == rR1_ID) && (wR_WB != 5'b0) && (rf_we_WB == 1'b1) && (rD1_flag == 1'b1);
wire rD2_C = (wR_WB == rR2_ID) && (wR_WB != 5'b0) && (rf_we_WB == 1'b1) && (rD2_flag == 1'b1);

assign rD1_sel = rD1_A || rD1_B || rD1_C;
assign rD2_sel = rD2_A || rD2_B || rD2_C;

//先判断是否是load型指令
wire load = (wd_sel == `DRAM_RD);
wire load_use_harzard = (rD1_A || rD2_A) && load;

//分支冒险判断
wire branch_harzard = npc_op;

always @ (*) begin
    if (rD1_A)
        rD1_forward = wD_EX;
    else if (rD1_B)
        rD1_forward = wD_MEM;
    else if (rD1_C)
        rD1_forward = wD_WB;
    else
        rD1_forward = 32'h00000000;
end

always @ (*) begin
    if (rD2_A)
        rD2_forward = wD_EX;
    else if (rD2_B)
        rD2_forward = wD_MEM;
    else if (rD2_C)
        rD2_forward = wD_WB;
    else
        rD2_forward = 32'h00000000;
end

always @ (*) begin
    if (load_use_harzard) begin
        stop_PC = 1'b1;
        stop_IF_ID = 1'b1;
    end
    else begin
        stop_PC = 1'b0;
        stop_IF_ID = 1'b0;
    end
end

always @ (*) begin
    if (branch_harzard)
        flush_IF_ID = 1'b1;
    else
        flush_IF_ID = 1'b0;
end

always @ (*) begin
    if (load_use_harzard || branch_harzard)
        flush_ID_EX = 1'b1;
    else
        flush_ID_EX = 1'b0;
end

endmodule
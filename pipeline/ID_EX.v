`timescale 1ns / 1ps

`include "param.v"

module ID_EX (
    input wire clk,
    input wire rst,
    
    input wire flush,
    
    input wire [1:0] wd_sel_i,
    input wire [3:0] alu_op_i,
    input wire alub_sel_i,
    input wire rf_we_i,
    input wire dram_we_i,
    input wire [2:0] branch_i,
    input wire [1:0] jump_i,
    input wire [31:0] pc_imm_i,
    input wire [31:0] imm_i,
    input wire [31:0] pc4_i,
    input wire [4:0] wR_i,
    
    //Ç°µİ²¿·Ö
    input wire [31:0] rD1_i,
    input wire [31:0] rD2_i,
    input wire rD1_sel,
    input wire rD2_sel,
    input wire [31:0] rD1_forward,
    input wire [31:0] rD2_forward,
    
    output reg [1:0] wd_sel_o,
    output reg [3:0] alu_op_o,
    output reg alub_sel_o,
    output reg rf_we_o,
    output reg dram_we_o,
    output reg [2:0] branch_o,
    output reg [1:0] jump_o,
    output reg [31:0] pc_imm_o,
    output reg [31:0] imm_o,
    output reg [31:0] pc4_o,
    output reg [4:0] wR_o,
    
    output reg [31:0] rD1_o,
    output reg [31:0] rD2_o,
    
    input wire [31:0] pc_i,
    output reg [31:0] pc_o,
    
    input wire have_inst_i,
    output reg have_inst_o
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        pc_o <= 32'h00000000;
        have_inst_o <= 1'b0;
    end
    else if (flush) begin
        pc_o <= 32'h00000000;
        have_inst_o <= 1'b0;
    end
    else begin
        pc_o <= pc_i;
        have_inst_o <= have_inst_i;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        wd_sel_o <= 2'b0;
        alu_op_o <= 4'b0;
        alub_sel_o <= 1'b0;
        rf_we_o <= 1'b0;
        dram_we_o <= 1'b0;
        branch_o <= 3'b0;
        jump_o <= 2'b0;
        pc_imm_o <= 32'b0;
        imm_o <= 32'b0;
        pc4_o <= 32'b0;
        wR_o <= 5'b0;
    end
    else if (flush) begin
        wd_sel_o <= 2'b0;
        alu_op_o <= 4'b0;
        alub_sel_o <= 1'b0;
        rf_we_o <= 1'b0;
        dram_we_o <= 1'b0;
        branch_o <= 3'b0;
        jump_o <= 2'b0;
        pc_imm_o <= 32'b0;
        imm_o <= 32'b0;
        pc4_o <= 32'b0;
        wR_o <= 5'b0;
    end
    else begin
        wd_sel_o <= wd_sel_i;
        alu_op_o <= alu_op_i;
        alub_sel_o <= alub_sel_i;
        rf_we_o <= rf_we_i;
        dram_we_o <= dram_we_i;
        branch_o <= branch_i;
        jump_o <= jump_i;
        pc_imm_o <= pc_imm_i;
        imm_o <= imm_i;
        pc4_o <= pc4_i;
        wR_o <= wR_i;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst)
        rD1_o <= 32'b0;
    else if (rD1_sel)
        rD1_o <= rD1_forward;
    else
        rD1_o <= rD1_i;
end

always @ (posedge clk or posedge rst) begin
    if (rst)
        rD2_o <= 32'b0;
    else if (rD2_sel)
        rD2_o <= rD2_forward;
    else
        rD2_o <= rD2_i;
end

endmodule
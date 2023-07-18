`timescale 1ns / 1ps

`include "param.v"

module EX_MEM (
    input wire clk,
    input wire rst,
    
    input wire [1:0] wd_sel_i,
    input wire rf_we_i,
    input wire dram_we_i,
    input wire [31:0] alu_c_i,
    input wire [31:0] wD_i,
    input wire [4:0] wR_i,
    input wire [31:0] rD2_i,
    input wire [31:0] npc_pc4_i,
    input wire [31:0] imm_i,
    
    output reg [1:0] wd_sel_o,
    output reg rf_we_o,
    output reg dram_we_o,
    output reg [31:0] alu_c_o,
    output reg [31:0] wD_o,
    output reg [4:0] wR_o,
    output reg [31:0] rD2_o,
    output reg [31:0] npc_pc4_o,
    output reg [31:0] imm_o,
    
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
    else begin
        pc_o <= pc_i;
        have_inst_o <= have_inst_i;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        wd_sel_o <= 2'b0;
        rf_we_o <= 1'b0;
        dram_we_o <= 1'b0;
        alu_c_o <= 32'b0;
        wD_o <= 32'b0;
        wR_o <= 5'b0;
        rD2_o <= 32'b0;
        npc_pc4_o <= 32'b0;
        imm_o <= 32'b0;
    end
    else begin
        wd_sel_o <= wd_sel_i;
        rf_we_o <= rf_we_i;
        dram_we_o <= dram_we_i;
        alu_c_o <= alu_c_i;
        wD_o <= wD_i;
        wR_o <= wR_i;
        rD2_o <= rD2_i;
        npc_pc4_o <= npc_pc4_i;
        imm_o <= imm_i;
    end
end

endmodule
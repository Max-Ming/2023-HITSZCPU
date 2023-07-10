`timescale 1ns / 1ps

`include "param.v"

module IF (
    input wire clk,
    input wire rst_n,
    input wire [1:0] npc_op,//¿ØÖÆÐÅºÅ
    input wire [31:0] sext_ext,
    input wire [31:0] alu_c,
    output wire [31:0] pc,
    output wire [31:0] npc_pc4
);

wire [31:0] npc;

NPC U_NPC (
    //input
    .op (npc_op),
    .pc (pc),
    .offset (sext_ext),
    .alu_c (alu_c),
    //output
    .npc (npc),
    .pc4 (npc_pc4)
);

PC U_PC (
    //input
    .clk (clk),
    .rst_n (rst_n),
    .din (npc),
    //output
    .pc (pc)
);

endmodule
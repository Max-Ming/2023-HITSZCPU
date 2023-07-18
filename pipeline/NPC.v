`timescale 1ns / 1ps

`include "param.v"

module NPC (
    input wire op,
    input wire [31:0] pc,
    input wire [31:0] npc_result,
    output wire [31:0] npc,
    output wire [31:0] pc4
);

assign pc4 = pc + 4;

//op=1下一条指令地址选择pc+imm或者rd1+imm或者pc+imm
assign npc = op ? npc_result : pc4;

endmodule
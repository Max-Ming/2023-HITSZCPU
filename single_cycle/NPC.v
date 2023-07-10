`timescale 1ns / 1ps

`include "param.v"

module NPC (
    input wire [1:0] op,
    input wire [31:0] pc,
    input wire [31:0] offset,
    input wire [31:0] alu_c,
    output reg [31:0] npc,
    output wire [31:0] pc4
);

assign pc4 = pc + 4;

//×éºÏÂß¼­
always @ (*) begin
    case (op)
        `PC_4 :
            npc = pc4;
        `PC_IMM :
            npc = pc + offset;
        `RD1_IMM :
            npc = {alu_c[31:1], 1'b0};
        default :
            npc = pc4;
    endcase
end

endmodule
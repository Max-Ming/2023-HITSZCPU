`timescale 1ns / 1ps

`include "param.v"

module NPC_CONTROL (
    input wire [2:0] branch,
    input wire [1:0] jump,
    input wire zero,
    input wire sgn,
    input wire [31:0] pc_imm,
    input wire [31:0] alu_c,
    output reg npc_op,
    output reg [31:0] npc_result
);

always @ (*) begin
    if (jump[0])
        npc_op = 1'b1;// jal or jalr һ����ת
    else begin
        case (branch)
            3'b001 :
                npc_op = zero ? 1'b1 : 1'b0;// beq
            3'b011 :
                npc_op = zero ? 1'b0 : 1'b1;// bne
            3'b101 :
                npc_op = sgn ? 1'b1 : 1'b0;// blt
            3'b111 :
                npc_op = sgn ? 1'b0 : 1'b1;// bge
            default :
                npc_op = 1'b0;
        endcase
    end
end

always @ (*) begin
    if (jump == 2'b01) // jalr
        npc_result = {alu_c[31:1], 1'b0};
    else
        npc_result = pc_imm;
end

endmodule
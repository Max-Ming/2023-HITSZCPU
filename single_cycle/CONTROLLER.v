`timescale 1ns / 1ps

`include "param.v"

module CONTROLLER (
    input wire [31:0] inst,
    input wire zero,
    input wire sgn,
    output reg [1:0] npc_op,
    output reg [2:0] sext_op,
    output reg [1:0] rf_wsel,
    output reg rf_we,
    output reg alub_sel,
    output reg [2:0] alu_op,
    output reg dram_we
);

wire [6:0] opcode = inst[6:0];
wire [2:0] funct3 = inst[14:12];
wire [6:0] funct7 = inst[31:25];

//npc_op控制信号
always @ (*) begin
    case (opcode)
        `OP_R :
            npc_op = `PC_4;
        `OP_I :
            npc_op = `PC_4;
        `OP_LOAD :
            npc_op = `PC_4;
        `OP_U :
            npc_op = `PC_4;
        `OP_S :
            npc_op = `PC_4;
        `OP_JAL :
            npc_op = `PC_IMM;
        `OP_JALR :
            npc_op = `RD1_IMM;
        `OP_B : begin
            case (funct3)
                3'b000 ://beq
                    npc_op = zero ? `PC_IMM : `PC_4;
                3'b001 ://bne
                    npc_op = zero ? `PC_4 : `PC_IMM;
                3'b100 ://blt
                    npc_op = sgn ? `PC_IMM : `PC_4;
                3'b101 ://bge
                    npc_op = sgn ? `PC_4 : `PC_IMM;
                default :
                    npc_op = `PC_4;
            endcase
        end
        default :
            npc_op = `PC_4;
    endcase
end

//立即数扩展sext_op控制信号
always @ (*) begin
    case (opcode)
        `OP_I : begin
            case (funct3)
                3'b000 :
                    sext_op = `IMM_I;
                3'b111 :
                    sext_op = `IMM_I;
                3'b110 :
                    sext_op = `IMM_I;
                3'b100 :
                    sext_op = `IMM_I;
                3'b001 :
                    sext_op = `IMM_SHIFT;
                3'b101 :
                    sext_op = `IMM_SHIFT;
                default :
                    sext_op = `IMM_I;
            endcase
        end
        `OP_LOAD :
            sext_op = `IMM_I;
        `OP_JALR :
            sext_op = `IMM_I;
        `OP_S :
            sext_op = `IMM_S;
        `OP_U :
            sext_op = `IMM_U;
        `OP_B :
            sext_op = `IMM_B;
        `OP_JAL :
            sext_op = `IMM_J;
        default :
            sext_op = `IMM_I;
    endcase
end

//选择写回寄存器堆的选择信号rf_sel
always @ (*) begin
    case (opcode)
        `OP_R :
            rf_wsel = `ALU_C;
        `OP_I :
            rf_wsel = `ALU_C;
        `OP_LOAD :
            rf_wsel = `DRAM_RD;
        `OP_JALR :
            rf_wsel = `NPC_PC4;
        `OP_U :
            rf_wsel = `SEXT_EXT;
        `OP_JAL :
            rf_wsel = `NPC_PC4;
        default :
            rf_wsel = `NPC_PC4;
    endcase
end

//寄存器堆写使能信号rf_we
always @ (*) begin
    if (opcode == `OP_S || opcode == `OP_B)
        rf_we = 1'b0;
    else
        rf_we = 1'b1;
end

//ALU.B的输入控制信号alub_sel
always @ (*) begin
    case (opcode)
        `OP_I :
            alub_sel = `ALU_B_SEXT_EXT;
        `OP_LOAD :
            alub_sel = `ALU_B_SEXT_EXT;
        `OP_JALR :
            alub_sel = `ALU_B_SEXT_EXT;
        `OP_S :
            alub_sel = `ALU_B_SEXT_EXT;
        default :
            alub_sel = `ALU_B_RF_RD2;
    endcase
end

//ALU运算方式选择信号alu_op
always @ (*) begin
    case (opcode)
        `OP_R : begin
            case (funct3)
                3'b000 :
                    alu_op = funct7[5] ? `SUB : `ADD;
                3'b111 :
                    alu_op = `AND;
                3'b110 :
                    alu_op = `OR;
                3'b100 :
                    alu_op = `XOR;
                3'b001 :
                    alu_op = `SLL;
                3'b101 :
                    alu_op = funct7[5] ? `SRA : `SRL;
                default :
                    alu_op = `ADD;
            endcase
        end
        `OP_I : begin
            case (funct3)
                3'b000 : 
                    alu_op = `ADD;
                3'b111 :
                    alu_op = `AND;
                3'b110 :
                    alu_op = `OR;
                3'b100 :
                    alu_op = `XOR;
                3'b001 :
                    alu_op = `SLL;
                3'b101 :
                    alu_op = funct7[5] ? `SRA : `SRL;
                default :
                    alu_op = `ADD;
            endcase
        end
        `OP_LOAD :
            alu_op = `ADD;
        `OP_JALR :
            alu_op = `ADD;
        `OP_S :
            alu_op = `ADD;
        `OP_B :
            alu_op = `SUB;
        default :
            alu_op = `ADD;
    endcase
end

//DRAM的控制信号ram_we
always @ (*) begin
    if (opcode == `OP_S)
        dram_we = 1'b1;
    else 
        dram_we = 1'b0;
end

endmodule
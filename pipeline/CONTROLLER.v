`timescale 1ns / 1ps

`include "param.v"

module CONTROLLER (
    input wire [31:0] inst,
    
    output reg [1:0] wd_sel,
    output reg [2:0] sext_op,
    output reg alub_sel,
    output reg [2:0] alu_op,
    output reg dram_we,
    output reg rf_we,
    output wire [2:0] branch,
    output wire [1:0] jump,
    
    //寄存器的值是否被使用
    output wire rD1_flag,
    output wire rD2_flag,
    
    output reg have_inst
);

wire [6:0] opcode = inst[6:0];
wire [2:0] funct3 = inst[14:12];
wire [6:0] funct7 = inst[31:25];

//beq:3'b001; bne:3'b011; blt:3'b101; bge:3'b111
assign branch = {funct3[2], funct3[0], (opcode == `OP_B)};
//jalr:2'b01; jal:2'b11;
assign jump = {opcode[3], (opcode == `OP_JAL || opcode == `OP_JALR)};

assign rD1_flag = ~((opcode == `OP_U) || (opcode == `OP_JAL));
assign rD2_flag = ((opcode == `OP_R) || (opcode == `OP_S) || (opcode == `OP_B));

always @ (*) begin
    case (opcode)
       `OP_R, `OP_I, `OP_LOAD, `OP_JALR, `OP_S, `OP_B, `OP_U, `OP_JAL :
            have_inst = 1'b1;
       default :
            have_inst = 1'b0;
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

//选择写回寄存器堆的选择信号wd_sel
always @ (*) begin
    case (opcode)
        `OP_R :
            wd_sel = `ALU_C;
        `OP_I :
            wd_sel = `ALU_C;
        `OP_LOAD :
            wd_sel = `DRAM_RD;
        `OP_JALR :
            wd_sel = `NPC_PC4;
        `OP_U :
            wd_sel = `SEXT_EXT;
        `OP_JAL :
            wd_sel = `NPC_PC4;
        default :
            wd_sel = `NPC_PC4;
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

//DRAM的控制信号dram_we
always @ (*) begin
    if (opcode == `OP_S)
        dram_we = 1'b1;
    else 
        dram_we = 1'b0;
end

endmodule
`timescale 1ns / 1ps

`include "param.v"

module ALU_MUX (
    input wire [1:0] alub_sel,
    input wire [31:0] rD2,
    input wire [31:0] imm,
    output reg [31:0] alu_b
);

always @ (*) begin
    case (alub_sel)
        `ALU_B_RF_RD2 :
            alu_b = rD2;
        `ALU_B_SEXT_EXT :
            alu_b = imm;
        default :
            alu_b = rD2;
    endcase
end

endmodule
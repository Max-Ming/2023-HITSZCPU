`timescale 1ns / 1ps

`include "param.v"

module IF_ID (
    input wire clk,
    input wire rst,
    
    input wire stop,
    input wire flush,
    
    input wire [31:0] pc_i,
    input wire [31:0] pc4_i,
    input wire [31:0] inst_i,
    output reg [31:0] pc_o,
    output reg [31:0] pc4_o,
    output reg [31:0] inst_o
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        pc_o <= 32'h0;
        pc4_o <= 32'h0;
        inst_o <= 32'h0;
    end
    else if (flush) begin
        pc_o <= 32'h0;
        pc4_o <= 32'h0;
        inst_o <= 32'h0;
    end
    else if (stop) begin
        pc_o <= pc_o;
        pc4_o <= pc4_o;
        inst_o <= inst_o;
    end
    else begin
        pc_o <= pc_i;
        pc4_o <= pc4_i;
        inst_o <= inst_i;
    end
end

endmodule
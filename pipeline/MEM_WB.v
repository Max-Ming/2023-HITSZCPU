`timescale 1ns / 1ps

`include "param.v"

module MEM_WB (
    input wire clk,
    input wire rst,
    
    input wire rf_we_i,
    input wire [31:0] wD_i,
    input wire [4:0] wR_i,
    
    output reg rf_we_o,
    output reg [31:0] wD_o,
    output reg [4:0] wR_o,
    
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
        rf_we_o <= 1'b0;
        wD_o <= 32'b0;
        wR_o <= 5'b0;
    end
    else begin
        rf_we_o <= rf_we_i;
        wD_o <= wD_i;
        wR_o <= wR_i;
    end
end

endmodule
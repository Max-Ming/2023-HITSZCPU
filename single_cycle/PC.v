`timescale 1ns / 1ps

`include "param.v"

module PC (
    input wire clk,
    input wire rst_n,
    input wire [31:0] din,
    output reg [31:0] pc
);

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) 
        pc <= -4;//±ÜÃâ¸²¸Ç
    else
        pc <= din;
end

endmodule
`timescale 1ns / 1ps

`include "param.v"

module PC(
    input wire clk,
    input wire rst,
    input wire stop,
    input wire [31:0] npc,
    output reg [31:0] pc
);

always @ (posedge clk or posedge rst) begin
    if (rst)
        pc <= -4;
    else if (stop)
        pc <= pc;
    else
        pc <= npc;
end

endmodule
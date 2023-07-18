`timescale 1ns / 1ps

`include "param.v"

module RF (
    input wire clk,
    input wire rst,
    //写使能
    input wire rf_we,
    input wire [4:0] rR1,
    input wire [4:0] rR2,
    //写地址
    input wire [4:0] wR,
    //写数据
    input wire [31:0] wD,
    output wire [31:0] rD1,
    output wire [31:0] rD2
);

//寄存器堆
reg [31:0] rf[31:0];

//异步读，组合逻辑
assign rD1 = rf[rR1];
assign rD2 = rf[rR2];

integer i;

//同步写，时序逻辑
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        //寄存器全部置0
        for (i = 0; i <= 31; i = i + 1) begin
            rf[i] <= 32'b0;
        end
    end
        else if (rf_we && wR != 5'b0) 
            //向 x0 中的写入无效
            rf[wR] <= wD; 
        else 
            rf[0] <= 32'b0;
end

endmodule
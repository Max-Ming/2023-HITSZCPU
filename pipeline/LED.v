`timescale 1ns / 1ps

module LED (
    input wire clk,
    input wire rst,
    input wire [11:0] addr,
    input wire wen,
    input wire [31:0] wdata,
    output reg [23:0] led
);

always @ (posedge clk or posedge rst) begin
    if (rst)
        led <= 24'h000000;
    else if (wen)
        led <= wdata[23:0];
end

endmodule
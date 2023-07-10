`timescale 1ns / 1ps

module DIGIT (
    input wire clk,
    input wire rst,
    input wire [11:0] addr,
    input wire wen,
    input wire [31:0] wdata,
    output wire [7:0] led_en,
    output wire led_ca,
    output wire led_cb,
    output wire led_cc,
    output wire led_cd,
    output wire led_ce,
    output wire led_cf,
    output wire led_cg,
    output wire led_dp
);

reg [31:0] data;

always @ (posedge clk or posedge rst) begin
    if (rst)
        data <= 32'h00000000;
    else if (wen)
        data <= wdata;
end

wire rst_n = ~rst;

tub_show U_tub_show (
    .clk (clk),
    .rst_n (rst_n),
    .data (data),
    //output
    .led_en (led_en),
    .led_ca (led_ca),
    .led_cb (led_cb),
    .led_cc (led_cc),
    .led_cd (led_cd),
    .led_ce (led_ce),
    .led_cf (led_cf),
    .led_cg (led_cg),
    .led_dp (led_dp)
);

endmodule
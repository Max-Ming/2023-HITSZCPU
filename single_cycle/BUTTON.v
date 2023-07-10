`timescale 1ns / 1ps

module BUTTON (
    input wire clk,
    input wire rst,
    input wire [11:0] addr,
    input wire [4:0] button,
    output reg [31:0] data_frombutton
);

always @ (posedge clk or posedge rst) begin
    if (rst)
        data_frombutton <= 32'h00000000;
    else if (addr == 12'h078)
        data_frombutton <= {27'h0, button[4:0]};
end

endmodule
 
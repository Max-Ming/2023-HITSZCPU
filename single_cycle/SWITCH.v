`timescale 1ns / 1ps

module SWITCH (
    input wire clk,
    input wire rst,
    input wire [11:0] addr,
    input wire [23:0] sw,
    output reg [31:0] data_fromsw
);

always @ (posedge clk or posedge rst) begin
    if (rst)
        data_fromsw <= 32'h00000000;
    else if (addr == 12'h070)
        data_fromsw <= {8'h00, sw[23:0]};
end

endmodule
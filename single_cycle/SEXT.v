`timescale 1ns / 1ps

`include "param.v"

module SEXT (
    input wire [2:0] op,
    //inst[31:7]
    input wire [24:0] din,
    output reg [31:0] ext
);

//sgn = inst[31]
wire sgn = din[24];

//×éºÏÂß¼­
always @ (*) begin
    case (op)
        `IMM_I :
            //20bit sgn + inst[31:20]  
            ext = {{20{sgn}}, din[24:13]};
        `IMM_SHIFT :
            //27bit 0 + inst[24:20]
            ext = {27'b0, din[17:13]};
        `IMM_S :
            //20bit sgn + inst[31:25] + inst[11:7]
            ext = {{20{sgn}}, din[24:18], din[4:0]};
        `IMM_U :
            //inst[31:12] + 12bit 0
            ext = {din[24:5], 12'b0};
        `IMM_B :
            //19bit sgn + inst[31] + inst[7] + inst[30:25] + inst[11:8] + 1bit 0
            ext = {{19{sgn}}, din[24], din[0], din[23:18], din[4:1], 1'b0};
        `IMM_J :
            //11bit sgn + inst[31] + inst[19:12] + inst[20] + inst[30:21] + 1bit 0
            ext = {{11{sgn}}, din[24], din[12:5], din[13], din[23:14], 1'b0};
        default:
            ext = 32'b0;
    endcase
end

endmodule
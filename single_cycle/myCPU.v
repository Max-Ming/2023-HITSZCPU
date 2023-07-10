`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
    output wire [13:0]  inst_addr,//pc_pc
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_wen,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

wire clk = cpu_clk;
wire rst_n = ~cpu_rst;

//IF
wire [1:0] npc_op;
wire [31:0] npc_pc4;
wire [31:0] pc_pc;

//ID,WB
wire [31:0] sext_ext;
wire [2:0] sext_op;
wire rf_we;
wire [31:0] rf_rd1;
wire [31:0] rf_rd2;
wire [31:0] rf_wd;
wire [1:0] rf_wsel;

//EX
wire [31:0] alu_c;
wire alub_sel;
wire [2:0] alu_op;
wire alu_zero;
wire alu_sgn;

assign inst_addr = pc_pc[15:2];
assign Bus_addr = alu_c;//rd1 + offset
assign Bus_wdata = rf_rd2;//load rd2,offset(rd1)

    // TODO: 瀹屾垚浣犺嚜宸辩殑鍗曞懆鏈烠PU璁捐
    //
IF U_IF (
    //input
    .clk (clk),
    .rst_n (rst_n),
    .npc_op (npc_op),
    .sext_ext (sext_ext),
    .alu_c (alu_c),
    //output
    .pc (pc_pc),
    .npc_pc4 (npc_pc4)
);    
    
ID U_ID (
    //input
    .clk (clk),
    .rst_n (rst_n),
    //控制信号
    .sext_op (sext_op),
    .rf_we (rf_we),
    .rf_wsel (rf_wsel),
    //数据信号
    .irom_inst (inst),
    .alu_c (alu_c),
    .dram_rd (Bus_rdata),
    .npc_pc4 (npc_pc4),
    //output
    .sext_ext (sext_ext),
    .rf_rd1 (rf_rd1),
    .rf_rd2 (rf_rd2),
    .rf_wd (rf_wd)
);

EX U_EX (
    //input
    //控制信号
    .alub_sel (alub_sel),
    .alu_op (alu_op),
    //数据信号
    .rf_rd1 (rf_rd1),
    .rf_rd2 (rf_rd2),
    .sext_ext (sext_ext),
    //output
    .alu_c (alu_c),
    .alu_zero (alu_zero),
    .alu_sgn (alu_sgn)
);

CONTROLLER U_CONTROLLER (
    //input 
    .inst (inst),
    .zero (alu_zero),
    .sgn (alu_sgn),
    //output
    .npc_op (npc_op),
    .sext_op (sext_op),
    .rf_wsel (rf_wsel),
    .rf_we (rf_we),
    .alub_sel (alub_sel),
    .alu_op (alu_op),
    .dram_we (Bus_wen)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = pc_pc;
    assign debug_wb_ena       = rf_we;
    assign debug_wb_reg       = inst[11:7];
    assign debug_wb_value     = rf_wd;
`endif

endmodule

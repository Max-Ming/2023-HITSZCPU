`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,
    
    // Interface to IROM
    output wire [13:0]  inst_addr,
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

//数据信号
wire [31:0] npc;
wire [31:0] pc_IF, pc_ID, pc_EX, pc_MEM, pc_WB;
wire [31:0] pc4_IF, pc4_ID, pc4_EX, pc4_MEM;
wire [31:0] npc_result;
wire [31:0] inst_ID;
wire rD1_flag, rD2_flag;
wire [31:0] imm_ID, imm_EX, imm_MEM;
wire rf_we_MEM, rf_we_WB;
wire [4:0] wR_EX, wR_MEM, wR_WB;
wire [31:0] wD_MEM_temp, wD_MEM, wD_WB;
reg [31:0] wD_EX;
wire [31:0] rD1_ID, rD2_ID;
wire [31:0] rD1_EX, rD2_EX, rD2_MEM;
wire [31:0] alu_b;
wire [31:0] alu_c_EX, alu_c_MEM;
wire [31:0] pc_imm_ID, pc_imm_EX;
wire [4:0] wR_ID;

//控制信号
wire npc_op;
wire [1:0] wd_sel_ID, wd_sel_EX, wd_sel_MEM;
wire [2:0] sext_op_ID;
wire alub_sel_ID, alub_sel_EX;
wire [2:0] alu_op_ID, alu_op_EX;
wire dram_we_ID, dram_we_EX, dram_we_MEM;
wire rf_we_ID, rf_we_EX;
wire [2:0] branch_ID, branch_EX;
wire [1:0] jump_ID, jump_EX;
wire zero, sgn;

//冒险信号
wire stop_PC, stop_IF_ID;
wire flush_IF_ID, flush_ID_EX;
wire rD1_sel, rD2_sel;
wire [31:0] rD1_forward, rD2_forward;

//debug
wire have_inst_ID, have_inst_EX, have_inst_MEM, have_inst_WB;
    
PC U_PC (
    .clk (cpu_clk),
    .rst (cpu_rst),
    .stop (stop_PC),
    .npc (npc),
    //output
    .pc (pc_IF)
);

NPC U_NPC (
    .op (npc_op),
    .pc (pc_IF),
    .npc_result (npc_result),
    //output
    .npc (npc),
    .pc4 (pc4_IF)
);

assign inst_addr = pc_IF[15:2];

IF_ID U_IF_ID (
    .clk (cpu_clk),
    .rst (cpu_rst),
    .stop (stop_IF_ID),
    .flush (flush_IF_ID),
    .pc_i (pc_IF),
    .pc_o (pc_ID),
    .pc4_i (pc4_IF),
    .pc4_o (pc4_ID),
    .inst_i (inst),
    .inst_o (inst_ID)
);

CONTROLLER U_CONTROLLER (
    .inst (inst_ID),
    //output
    .wd_sel (wd_sel_ID),
    .sext_op (sext_op_ID),
    .alub_sel (alub_sel_ID),
    .alu_op (alu_op_ID),
    .dram_we (dram_we_ID),
    .rf_we (rf_we_ID),
    .branch (branch_ID),
    .jump (jump_ID),
    
    .rD1_flag (rD1_flag),
    .rD2_flag (rD2_flag),
    
    .have_inst (have_inst_ID)
);

SEXT U_SEXT (
    .op (sext_op_ID),
    .din (inst_ID[31:7]),
    //output
    .ext (imm_ID)
);

RF U_RF (
    .clk (cpu_clk),
    .rst (cpu_rst),
    .rf_we (rf_we_WB),
    .rR1 (inst_ID[19:15]),
    .rR2 (inst_ID[24:20]),
    .wR (wR_WB),
    .wD (wD_WB),
    //output
    .rD1 (rD1_ID),
    .rD2 (rD2_ID)
);

assign wR_ID = inst_ID[11:7];
assign pc_imm_ID = pc_ID + imm_ID;

ID_EX U_ID_EX (
    .clk (cpu_clk),
    .rst (cpu_rst),
    .flush (flush_ID_EX),
    
    //input
    .wd_sel_i (wd_sel_ID),
    .alu_op_i (alu_op_ID),
    .alub_sel_i (alub_sel_ID),
    .rf_we_i (rf_we_ID),
    .dram_we_i (dram_we_ID),
    .branch_i (branch_ID),
    .jump_i (jump_ID),
    .pc_imm_i (pc_imm_ID),
    .imm_i (imm_ID),
    .pc4_i (pc4_ID),
    .wR_i (wR_ID),
    
    //output
    .wd_sel_o (wd_sel_EX),
    .alu_op_o (alu_op_EX),
    .alub_sel_o (alub_sel_EX),
    .rf_we_o (rf_we_EX),
    .dram_we_o (dram_we_EX),
    .branch_o (branch_EX),
    .jump_o (jump_EX),
    .pc_imm_o (pc_imm_EX),
    .imm_o (imm_EX),
    .pc4_o (pc4_EX),
    .wR_o (wR_EX),
    
    //前递部分
    .rD1_i (rD1_ID),
    .rD2_i (rD2_ID),
    .rD1_sel (rD1_sel),
    .rD2_sel (rD2_sel),
    .rD1_forward (rD1_forward),
    .rD2_forward (rD2_forward),
    
    //output
    .rD1_o (rD1_EX),
    .rD2_o (rD2_EX),
    
    .pc_i (pc_ID),
    .pc_o (pc_EX),
    
    .have_inst_i (have_inst_ID),
    .have_inst_o (have_inst_EX)
);

ALU_MUX U_ALU_MUX (
    .alub_sel (alub_sel_EX),
    .rD2 (rD2_EX),
    .imm (imm_EX),
    //output
    .alu_b (alu_b)
);

ALU U_ALU (
    .op (alu_op_EX),
    .A (rD1_EX),
    .B (alu_b),
    //output
    .C (alu_c_EX),
    .zero (zero),
    .sgn (sgn)
);

NPC_CONTROL U_NPC_CONTROL (
    .branch (branch_EX),
    .jump (jump_EX),
    .zero (zero),
    .sgn (sgn),
    .pc_imm (pc_imm_EX),
    .alu_c (alu_c_EX),
    //output
    .npc_op (npc_op),
    .npc_result (npc_result)
);

always @ (*) begin
    case (wd_sel_EX)
        `SEXT_EXT :
            wD_EX = imm_EX;
        `ALU_C :
            wD_EX = alu_c_EX;
        `NPC_PC4 :
            wD_EX = pc4_EX;
        default :
            wD_EX = 32'b0;
    endcase
end

EX_MEM U_EX_MEM (
    .clk (cpu_clk),
    .rst (cpu_rst),
    
    .wd_sel_i (wd_sel_EX),
    .rf_we_i (rf_we_EX),
    .dram_we_i (dram_we_EX),
    .alu_c_i (alu_c_EX),
    .wD_i (wD_EX),
    .wR_i (wR_EX),
    .rD2_i (rD2_EX),
    .npc_pc4_i (pc4_EX),
    .imm_i (imm_EX),
    
    .wd_sel_o (wd_sel_MEM),
    .rf_we_o (rf_we_MEM),
    .dram_we_o (dram_we_MEM),
    .alu_c_o (alu_c_MEM),
    .wD_o (wD_MEM_temp),
    .wR_o (wR_MEM),
    .rD2_o (rD2_MEM),
    .npc_pc4_o (pc4_MEM),
    .imm_o (imm_MEM),
    
    .pc_i (pc_EX),
    .pc_o (pc_MEM),
    
    .have_inst_i (have_inst_EX),
    .have_inst_o (have_inst_MEM)
);

assign Bus_addr = alu_c_MEM;
assign Bus_wen = dram_we_MEM;
assign Bus_wdata = rD2_MEM;

WD_MUX U_WD_MUX (
    .wd_sel (wd_sel_MEM),
    .pc4 (pc4_MEM),
    .imm (imm_MEM),
    .alu_c (alu_c_MEM),
    .dram_rd (Bus_rdata),
    .wD (wD_MEM)
);

MEM_WB U_MEM_WB (
    .clk (cpu_clk),
    .rst (cpu_rst),
    
    .rf_we_i (rf_we_MEM),
    .wD_i (wD_MEM),
    .wR_i (wR_MEM),
    
    .rf_we_o (rf_we_WB),
    .wD_o (wD_WB),
    .wR_o (wR_WB),
    
    .pc_i (pc_MEM),
    .pc_o (pc_WB),
    
    .have_inst_i (have_inst_MEM),
    .have_inst_o (have_inst_WB)
);

HAZARD_CONTROL U_HAZARD_CONTROL (
    .wd_sel (wd_sel_EX),
    .rD1_flag (rD1_flag),
    .rD2_flag (rD2_flag),
    .rf_we_EX (rf_we_EX),
    .rf_we_MEM (rf_we_MEM),
    .rf_we_WB (rf_we_WB),
    .rR1_ID (inst_ID[19:15]),
    .rR2_ID (inst_ID[24:20]),
    .wR_EX (wR_EX),
    .wR_MEM (wR_MEM),
    .wR_WB (wR_WB),
    .wD_EX (wD_EX),
    .wD_MEM (wD_MEM),
    .wD_WB (wD_WB),
    .npc_op (npc_op),
    //output
    .stop_PC (stop_PC),
    .stop_IF_ID (stop_IF_ID),
    .flush_IF_ID (flush_IF_ID),
    .flush_ID_EX (flush_ID_EX),
    .rD1_sel (rD1_sel),
    .rD2_sel (rD2_sel),
    .rD1_forward (rD1_forward),
    .rD2_forward (rD2_forward)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = have_inst_WB;
    assign debug_wb_pc        = pc_WB;
    assign debug_wb_ena       = rf_we_WB;
    assign debug_wb_reg       = wR_WB;
    assign debug_wb_value     = wD_WB;
`endif

endmodule

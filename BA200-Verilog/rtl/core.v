`include "consts.vh"

module Core (
  input clk,
  input rst,

  input         io_interrupt,
  input  [3:0]  io_hart_id,
  input  [31:0] io_reset_vector,

  output [31:0]               io_imem_addr,
  input  [31:0]               io_imem_rdata,
  output [31:0]               io_dmem_addr,
  output [`MEM_OP_WIDTH-1:0]  io_dmem_op,
  output [3:0]                io_dmem_mask,
  output [31:0]               io_dmem_wdata,
  input  [31:0]               io_dmem_rdata
);

wire [1:0]                  dmem_addr_offset;

wire                        ctl_stall;
wire [`PC_SEL_WIDTH-1:0]    ctl_pc_sel;
wire [`IMM_SEL_WIDTH-1:0]   ctl_imm_sel;
wire                        ctl_op1_sel;
wire                        ctl_op2_sel;
wire [`ALU_SEL_WIDTH-1:0]   ctl_alu_sel;
wire                        ctl_mem_signed;
wire [`WB_SEL_WIDTH-1:0]    ctl_wb_sel;
wire                        ctl_rf_wen;

wire [31:0] dat_inst;
wire        dat_br_eq;
wire        dat_br_lt;
wire        dat_br_ltu;

assign dmem_addr_offset = io_dmem_addr[1:0];


ControlPath ctrlpath (
  .clk(clk),
  .rst(rst),

  .io_dmem_addr_offset(dmem_addr_offset),
  .io_dmem_op(io_dmem_op),
  .io_dmem_mask(io_dmem_mask),

  .io_ctl_stall(ctl_stall),
  .io_ctl_pc_sel(ctl_pc_sel),
  .io_ctl_imm_sel(ctl_imm_sel),
  .io_ctl_op1_sel(ctl_op1_sel),
  .io_ctl_op2_sel(ctl_op2_sel),
  .io_ctl_alu_sel(ctl_alu_sel),
  .io_ctl_mem_signed(ctl_mem_signed),
  .io_ctl_wb_sel(ctl_wb_sel),
  .io_ctl_rf_wen(ctl_rf_wen),

  .io_dat_inst(dat_inst),
  .io_dat_br_eq(dat_br_eq),
  .io_dat_br_lt(dat_br_lt),
  .io_dat_br_ltu(dat_br_ltu)
);

DataPath datapath (
  .clk(clk),
  .rst(rst),
  
  .io_interrupt(io_interrupt),
  .io_hart_id(io_hart_id),
  .io_reset_vector(io_reset_vector),

  .io_imem_addr(io_imem_addr),
  .io_imem_rdata(io_imem_rdata),
  .io_dmem_addr(io_dmem_addr),
  .io_dmem_mask(io_dmem_mask),
  .io_dmem_wdata(io_dmem_wdata),
  .io_dmem_rdata(io_dmem_rdata),

  .io_ctl_stall(ctl_stall),
  .io_ctl_pc_sel(ctl_pc_sel),
  .io_ctl_imm_sel(ctl_imm_sel),
  .io_ctl_op1_sel(ctl_op1_sel),
  .io_ctl_op2_sel(ctl_op2_sel),
  .io_ctl_alu_sel(ctl_alu_sel),
  .io_ctl_mem_signed(ctl_mem_signed),
  .io_ctl_wb_sel(ctl_wb_sel),
  .io_ctl_rf_wen(ctl_rf_wen),

  .io_dat_inst(dat_inst),
  .io_dat_br_eq(dat_br_eq),
  .io_dat_br_lt(dat_br_lt),
  .io_dat_br_ltu(dat_br_ltu)
);

endmodule


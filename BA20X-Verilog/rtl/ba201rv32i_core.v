`include "ba201rv32i_consts.vh"

module Core (
  input clk,
  input rst,

  input         io_interrupt,
  input  [3:0]  io_hart_id,
  input  [31:0] io_reset_vector,

  output [31:0]               io_imem_addr,
  input  [31:0]               io_imem_rdata,
  output [31:0]               io_dmem_addr,
  output                      io_dmem_type,
  output [31:0]               io_dmem_wdata,
  output [`MEM_MSK_WIDTH-1:0] io_dmem_wmask,
  input  [31:0]               io_dmem_rdata
);

wire                        io_ctl_stall;
wire [`PC_SEL_WIDTH-1:0]    io_ctl_pc_sel;
wire [`IMM_SEL_WIDTH-1:0]   io_ctl_imm_sel;
wire                        io_ctl_op1_sel;
wire                        io_ctl_op2_sel;
wire [`ALU_SEL_WIDTH-1:0]   io_ctl_alu_sel;
wire [`WB_SEL_WIDTH-1:0]    io_ctl_wb_sel;
wire                        io_ctl_rf_wen;

wire [31:0] io_dat_inst;
wire        io_dat_br_eq;
wire        io_dat_br_lt;
wire        io_dat_br_ltu;


ControlPath ctrlpath (
  .clk(clk),
  .rst(rst),

  .io_dmem_type(io_dmem_type),
  .io_dmem_wmask(io_dmem_wmask),

  .io_ctl_stall(io_ctl_stall),
  .io_ctl_pc_sel(io_ctl_pc_sel),
  .io_ctl_imm_sel(io_ctl_imm_sel),
  .io_ctl_op1_sel(io_ctl_op1_sel),
  .io_ctl_op2_sel(io_ctl_op2_sel),
  .io_ctl_alu_sel(io_ctl_alu_sel),
  .io_ctl_wb_sel(io_ctl_wb_sel),
  .io_ctl_rf_wen(io_ctl_rf_wen),

  .io_dat_inst(io_dat_inst),
  .io_dat_br_eq(io_dat_br_eq),
  .io_dat_br_lt(io_dat_br_lt),
  .io_dat_br_ltu(io_dat_br_ltu)
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
  .io_dmem_wdata(io_dmem_wdata),
  .io_dmem_rdata(io_dmem_rdata),

  .io_ctl_stall(io_ctl_stall),
  .io_ctl_pc_sel(io_ctl_pc_sel),
  .io_ctl_imm_sel(io_ctl_imm_sel),
  .io_ctl_op1_sel(io_ctl_op1_sel),
  .io_ctl_op2_sel(io_ctl_op2_sel),
  .io_ctl_alu_sel(io_ctl_alu_sel),
  .io_ctl_wb_sel(io_ctl_wb_sel),
  .io_ctl_rf_wen(io_ctl_rf_wen),

  .io_dat_inst(io_dat_inst),
  .io_dat_br_eq(io_dat_br_eq),
  .io_dat_br_lt(io_dat_br_lt),
  .io_dat_br_ltu(io_dat_br_ltu)
);

endmodule


`include "ba201rv32i_consts.vh"

module DataPath (
  input clk,
  input rst,

  input         io_interrupt,
  input  [3:0]  io_hart_id,
  input  [31:0] io_reset_vector,

  output [31:0]               io_imem_addr,
  input  [31:0]               io_imem_rdata,
  output [31:0]               io_dmem_addr,
  input  [3:0]                io_dmem_mask,
  output [31:0]               io_dmem_wdata,
  input  [31:0]               io_dmem_rdata,

  // from control path
  input         io_ctl_stall,
  // input         dmiss,
  input  [`PC_SEL_WIDTH-1:0]  io_ctl_pc_sel,
  input  [`IMM_SEL_WIDTH-1:0] io_ctl_imm_sel,
  input                       io_ctl_op1_sel,  // 0: rs1, 1: immediate
  input                       io_ctl_op2_sel,  // 0: rs2, 1: immediate
  input  [`ALU_SEL_WIDTH-1:0] io_ctl_alu_sel,
  input                       io_ctl_mem_signed,
  input  [`WB_SEL_WIDTH-1:0]  io_ctl_wb_sel,
  input                       io_ctl_rf_wen,
  // input         io_ctl_csr_cmd   = Output(UInt(CSR.SZ.W))
  // input         io_ctl_exception = Output(Bool())
  // input         io_ctl_exception_cause = Output(UInt(32.W))
  // input         io_ctl_pc_sel_no_xept = Output(UInt(PC_4.getWidth.W))    // Use only for instuction misalignment detection

  // to control path
  output [31:0] io_dat_inst,
  // output imiss,
  output io_dat_br_eq,
  output io_dat_br_lt,
  output io_dat_br_ltu
  // output csr_eret = Output(Bool())
  // output csr_interrupt = Output(Bool())
  // output inst_misaligned = Output(Bool())
);


  wire [31:0] pc;
  wire [31:0] pc_next;

  wire [31:0] pc_4;
  wire [31:0] br_target;
  wire [31:0] jump_target;
  wire [31:0] jump_reg_target;
  wire [31:0] exception_target;
  

  // PC Register
  Register_R_CE #(
    .N(32),
    .INIT(32'h00000000)
  ) pc_reg (
    .clk(clk),
    .rst(rst),
    .ce(~io_ctl_stall),
    .d(pc_next),
    .q(pc)
  );

  assign pc_4 = pc + 32'h00000004;

  // TODO: make sure we are word aligned?
  assign pc_next = (
    (io_ctl_pc_sel == `PC_SEL_PC4)  ? pc_4 :
    (io_ctl_pc_sel == `PC_SEL_BR)   ? br_target :
    (io_ctl_pc_sel == `PC_SEL_JAL)  ? jump_target :
    (io_ctl_pc_sel == `PC_SEL_JALR) ? jump_reg_target :
    (io_ctl_pc_sel == `PC_SEL_EXC)  ? exception_target :
    pc_4
  );

  // Instruction memory fetching
  assign io_imem_addr = pc;

  wire [31:0] inst;
  assign inst = io_imem_rdata;

  // Decode
  
  // extract addr fields
  wire [4:0] rd_addr;
  wire [4:0] rs1_addr;
  wire [4:0] rs2_addr;

  assign rd_addr  = inst[11:7];
  assign rs1_addr = inst[19:15];
  assign rs2_addr = inst[24:20];
  

  // Register File
  wire [31:0] rs1_data;
  wire [31:0] rs2_data;
  wire signed [31:0] rs1_data_signed;
  wire signed [31:0] rs2_data_signed;
  wire [31:0] wb_data;
  wire rd_wen;

  assign rs1_data_signed = rs1_data;
  assign rs2_data_signed = rs2_data;

  assign rd_wen = io_ctl_rf_wen;

  RegFile regfile (
    .clk(clk),
    .io_rd_addr(rd_addr),
    .io_rd_wen(rd_wen),
    .io_rd_data(wb_data),
    .io_rs1_addr(rs1_addr),
    .io_rs1_data(rs1_data),
    .io_rs2_addr(rs2_addr),
    .io_rs2_data(rs2_data)
  );

  wire [31:0] imm_i;
  wire [31:0] imm_s;
  wire [31:0] imm_b;
  wire [31:0] imm_u;
  wire [31:0] imm_j;
  wire [31:0] imm_z;
  wire [31:0] imm;

  // immediate number generation
  assign imm_i = {{20{inst[31]}}, inst[31:20]};
  assign imm_s = {{20{inst[31]}}, inst[31:25], inst[11:7]};
  assign imm_b = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
  assign imm_u = {inst[31:12], {12{1'b0}}};
  assign imm_j = {{19{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
  assign imm_z = {{27{1'b0}}, inst[19:15]};

  assign imm = (
    (io_ctl_imm_sel == `IMM_SEL_R) ? imm_i :
    (io_ctl_imm_sel == `IMM_SEL_I) ? imm_i :
    (io_ctl_imm_sel == `IMM_SEL_S) ? imm_s :
    (io_ctl_imm_sel == `IMM_SEL_B) ? imm_b :
    (io_ctl_imm_sel == `IMM_SEL_U) ? imm_u :
    (io_ctl_imm_sel == `IMM_SEL_J) ? imm_j :
    (io_ctl_imm_sel == `IMM_SEL_Z) ? imm_z :
    'h0
  );

  wire [31:0] alu_in_a;
  wire [31:0] alu_in_b;
  wire [31:0] alu_out;

  assign alu_in_a = (
    (io_ctl_op1_sel == `OP1_SEL_RS1) ? rs1_data : 
    (io_ctl_op1_sel == `OP1_SEL_PC)  ? pc : 
    'h0
    );

  assign alu_in_b = (
    (io_ctl_op2_sel == `OP2_SEL_RS2) ? rs2_data :
    (io_ctl_op2_sel == `OP2_SEL_IMM) ? imm :
    'h0
    );
  
  ALU alu (
    .io_sel(io_ctl_alu_sel),
    .io_in_a(alu_in_a),
    .io_in_b(alu_in_b),
    .io_out(alu_out)
  );


  // Branch/Jump Target Calculation
  assign br_target        = pc + imm_b;
  assign jump_target      = pc + imm_j;
  assign jump_reg_target  = rs1_data + imm_i;


  wire [31:0] csr_rdata;


  // Memory load data formatting
  wire [31:0] load_data;

  assign load_data = (
    (io_dmem_mask == 'b1111) ? io_dmem_rdata :
    (io_ctl_mem_signed && (io_dmem_mask == 'b0011)) ? {{16{io_dmem_rdata[15]}}, io_dmem_rdata[15:0]} :
    (io_ctl_mem_signed && (io_dmem_mask == 'b1100)) ? {{16{io_dmem_rdata[31]}}, io_dmem_rdata[31:16]} :
    (io_ctl_mem_signed && (io_dmem_mask == 'b0001)) ? {{24{io_dmem_rdata[7]}},  io_dmem_rdata[7:0]} :
    (io_ctl_mem_signed && (io_dmem_mask == 'b0010)) ? {{24{io_dmem_rdata[15]}}, io_dmem_rdata[15:8]} :
    (io_ctl_mem_signed && (io_dmem_mask == 'b0100)) ? {{24{io_dmem_rdata[23]}}, io_dmem_rdata[23:16]} :
    (io_ctl_mem_signed && (io_dmem_mask == 'b1000)) ? {{24{io_dmem_rdata[31]}}, io_dmem_rdata[31:24]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b0011)) ? {{16'h0}, io_dmem_rdata[15:0]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b1100)) ? {{16'h0}, io_dmem_rdata[31:16]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b0001)) ? {{24'h0},  io_dmem_rdata[7:0]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b0010)) ? {{24'h0}, io_dmem_rdata[15:8]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b0100)) ? {{24'h0}, io_dmem_rdata[23:16]} :
    (!io_ctl_mem_signed && (io_dmem_mask == 'b1000)) ? {{24'h0}, io_dmem_rdata[31:24]} :
    'h0
  );

  assign io_dmem_wdata = rs2_data << (8 * io_dmem_addr[1:0]);

  // WB Mux
  assign wb_data = (
    (io_ctl_wb_sel == `WB_SEL_ALU) ? alu_out :
    (io_ctl_wb_sel == `WB_SEL_MEM) ? load_data :
    (io_ctl_wb_sel == `WB_SEL_PC4) ? pc_4 :
    (io_ctl_wb_sel == `WB_SEL_CSR) ? csr_rdata :
    alu_out
  );

  // datapath to controlpath outputs
  assign io_dat_inst   = inst;
  assign io_dat_br_eq  = rs1_data == rs2_data;
  assign io_dat_br_lt  = rs1_data_signed < rs2_data_signed;
  assign io_dat_br_ltu = rs1_data < rs2_data;


  // datapath to data memory outputs
  assign io_dmem_addr = alu_out;
  assign io_dmem_data = rs2_data;

  


endmodule


`include "ba201rv32i_consts.vh"

module ControlPath (
  input clk,
  input rst,
  

  input  [1:0]                io_dmem_addr_offset,
  output [`MEM_OP_WIDTH-1:0]  io_dmem_op,
  output [3:0]                io_dmem_mask,

  // from data path
  input  [31:0] io_dat_inst,
  // input  imiss,
  input  io_dat_br_eq,
  input  io_dat_br_lt,
  input  io_dat_br_ltu,
  // input  csr_eret = Output(Bool())
  // input  csr_interrupt = Output(Bool())
  // input  inst_misaligned = Output(Bool())

  // to data path
  output        io_ctl_stall,
  // output        dmiss,
  output [`PC_SEL_WIDTH-1:0]  io_ctl_pc_sel,
  output [`IMM_SEL_WIDTH-1:0] io_ctl_imm_sel,
  output                      io_ctl_op1_sel,  // 0: rs1, 1: immediate
  output                      io_ctl_op2_sel,  // 0: rs2, 1: immediate
  output [`ALU_SEL_WIDTH-1:0] io_ctl_alu_sel,
  output                      io_ctl_mem_signed,
  output [`WB_SEL_WIDTH-1:0]  io_ctl_wb_sel,
  output                      io_ctl_rf_wen
  // output        io_ctl_csr_cmd   = Output(UInt(CSR.SZ.W))
  // output        io_ctl_exception = Output(Bool())
  // output        io_ctl_exception_cause = Output(UInt(32.W))
  // output        io_ctl_pc_sel_no_xept = Output(UInt(PC_4.getWidth.W))    // Use only for instuction misalignment detection


);

  // extract instruction fields
  wire [7:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [11:0] funct12;

  assign opcode   = io_dat_inst[6:0];
  assign funct3   = io_dat_inst[14:12];
  assign funct7   = io_dat_inst[31:25];
  assign imm_i    = io_dat_inst[31:20];

  // instruction matching
  wire opcode_is_load;
  wire opcode_is_fence;
  wire opcode_is_alu_i;
  wire opcode_is_auipc;
  wire opcode_is_alu_iw;
  wire opcode_is_store;
  wire opcode_is_alu_r;
  wire opcode_is_lui;
  wire opcode_is_alu_rw;
  wire opcode_is_branch;
  wire opcode_is_jalr;
  wire opcode_is_jal;
  wire opcode_is_sys;

  wire opcode_is_type_r;
  wire opcode_is_type_i;
  wire opcode_is_type_s;
  wire opcode_is_type_b;
  wire opcode_is_type_u;
  wire opcode_is_type_j;
  wire opcode_is_type_z;

  wire inst_is_lb;
  wire inst_is_lh;
  wire inst_is_lw;
  // wire inst_is_ld;
  wire inst_is_lbu;
  wire inst_is_lhu;
  // wire inst_is_lwu;
  wire inst_is_fence;
  wire inst_is_fence_i;
  wire inst_is_addi;
  wire inst_is_slli;
  wire inst_is_slti;
  wire inst_is_sltiu;
  wire inst_is_xori;
  wire inst_is_srli;
  wire inst_is_srai;
  wire inst_is_ori;
  wire inst_is_andi;
  wire inst_is_auipc;
  // wire inst_is_addiw;
  // wire inst_is_slliw;
  // wire inst_is_srliw;
  // wire inst_is_sraiw;
  wire inst_is_sb;
  wire inst_is_sh;
  wire inst_is_sw;
  // wire inst_is_sd;
  wire inst_is_add;
  wire inst_is_sub;
  wire inst_is_sll;
  wire inst_is_slt;
  wire inst_is_sltu;
  wire inst_is_xor;
  wire inst_is_srl;
  wire inst_is_sra;
  wire inst_is_or;
  wire inst_is_and;
  wire inst_is_lui;
  // wire inst_is_addw;
  // wire inst_is_subw;
  // wire inst_is_sllw;
  // wire inst_is_srlw;
  // wire inst_is_sraw;
  wire inst_is_beq;
  wire inst_is_bne;
  wire inst_is_blt;
  wire inst_is_bge;
  wire inst_is_bltu;
  wire inst_is_bgeu;
  wire inst_is_jalr;
  wire inst_is_jal;
  wire inst_is_ecall;
  wire inst_is_ebreak;
  wire inst_is_csrrw;
  wire inst_is_csrrs;
  wire inst_is_csrrc;
  wire inst_is_csrrwi;
  wire inst_is_csrrsi;
  wire inst_is_csrrci;

  assign opcode_is_load     = opcode === 'b0000011;
  assign opcode_is_fence    = opcode === 'b0001111;
  assign opcode_is_alu_i    = opcode === 'b0010011;
  assign opcode_is_auipc    = opcode === 'b0010111;
  assign opcode_is_alu_iw   = opcode === 'b0011011;
  assign opcode_is_store    = opcode === 'b0100011;
  assign opcode_is_alu_r    = opcode === 'b0110011;
  assign opcode_is_lui      = opcode === 'b0110111;
  assign opcode_is_alu_rw   = opcode === 'b0110011;
  assign opcode_is_branch   = opcode === 'b1100011;
  assign opcode_is_jalr     = opcode === 'b1100111;
  assign opcode_is_jal      = opcode === 'b1101111;
  assign opcode_is_sys      = opcode === 'b1110011;  // csr and ecall, ebreak

  assign opcode_is_type_r = opcode_is_alu_rw | opcode_is_alu_r;
  assign opcode_is_type_i = opcode_is_sys | opcode_is_jalr | opcode_is_alu_iw | opcode_is_alu_i | opcode_is_fence | opcode_is_load;
  assign opcode_is_type_s = opcode_is_store;
  assign opcode_is_type_b = opcode_is_branch;
  assign opcode_is_type_u = opcode_is_lui | opcode_is_auipc;
  assign opcode_is_type_j = opcode_is_jal;
  assign opcode_is_type_z = inst_is_csrrwi | inst_is_csrrsi | inst_is_csrrci;

  assign inst_is_lb     = opcode_is_load & (funct3 === 'b000);
  assign inst_is_lh     = opcode_is_load & (funct3 === 'b001);
  assign inst_is_lw     = opcode_is_load & (funct3 === 'b010);
  // assign inst_is_ld     = opcode_is_load & (funct3 === 'b011);
  assign inst_is_lbu    = opcode_is_load & (funct3 === 'b100);
  assign inst_is_lhu    = opcode_is_load & (funct3 === 'b101);
  // assign inst_is_lwu    = opcode_is_load & (funct3 === 'b110);
  assign inst_is_fence  = opcode_is_fence;
  assign inst_is_fence_i= opcode_is_fence & (funct3 === 'b001);
  assign inst_is_addi   = opcode_is_alu_i & (funct3 === 'b000);
  assign inst_is_slli   = opcode_is_alu_i & (funct3 === 'b001) & (funct7 === 'b0000000);
  assign inst_is_slti   = opcode_is_alu_i & (funct3 === 'b010);
  assign inst_is_sltiu  = opcode_is_alu_i & (funct3 === 'b011);
  assign inst_is_xori   = opcode_is_alu_i & (funct3 === 'b100);
  assign inst_is_srli   = opcode_is_alu_i & (funct3 === 'b101) & (funct7 === 'b0000000);
  assign inst_is_srai   = opcode_is_alu_i & (funct3 === 'b101) & (funct7 === 'b0100000);
  assign inst_is_ori    = opcode_is_alu_i & (funct3 === 'b110);
  assign inst_is_andi   = opcode_is_alu_i & (funct3 === 'b111);
  assign inst_is_auipc  = opcode_is_auipc;
  // assign inst_is_addiw  = opcode_is_alu_iw & (funct3 === 'b000);
  // assign inst_is_slliw  = opcode_is_alu_iw & (funct3 === 'b001) & (funct7 === 'b0000000);
  // assign inst_is_srliw  = opcode_is_alu_iw & (funct3 === 'b101) & (funct7 === 'b0000000);
  // assign inst_is_sraiw  = opcode_is_alu_iw & (funct3 === 'b101) & (funct7 === 'b0100000);
  assign inst_is_sb     = opcode_is_store & (funct3 === 'b000);
  assign inst_is_sh     = opcode_is_store & (funct3 === 'b001);
  assign inst_is_sw     = opcode_is_store & (funct3 === 'b010);
  // assign inst_is_sd     = opcode_is_store & (funct3 === 'b011);
  assign inst_is_add    = opcode_is_alu_r & (funct3 === 'b000) & (funct7 === 'b0000000);
  assign inst_is_sub    = opcode_is_alu_r & (funct3 === 'b000) & (funct7 === 'b0100000);
  assign inst_is_sll    = opcode_is_alu_r & (funct3 === 'b001) & (funct7 === 'b0000000);
  assign inst_is_slt    = opcode_is_alu_r & (funct3 === 'b010) & (funct7 === 'b0000000);
  assign inst_is_sltu   = opcode_is_alu_r & (funct3 === 'b011) & (funct7 === 'b0000000);
  assign inst_is_xor    = opcode_is_alu_r & (funct3 === 'b100) & (funct7 === 'b0000000);
  assign inst_is_srl    = opcode_is_alu_r & (funct3 === 'b101) & (funct7 === 'b0000000);
  assign inst_is_sra    = opcode_is_alu_r & (funct3 === 'b101) & (funct7 === 'b0100000);
  assign inst_is_or     = opcode_is_alu_r & (funct3 === 'b110) & (funct7 === 'b0000000);
  assign inst_is_and    = opcode_is_alu_r & (funct3 === 'b111) & (funct7 === 'b0000000);
  assign inst_is_lui    = opcode_is_lui;
  // assign inst_is_addw   = opcode_is_alu_rw & (funct3 === 'b000) & (funct7 === 'b0000000);
  // assign inst_is_subw   = opcode_is_alu_rw & (funct3 === 'b000) & (funct7 === 'b0100000);
  // assign inst_is_sllw   = opcode_is_alu_rw & (funct3 === 'b001) & (funct7 === 'b0000000);
  // assign inst_is_srlw   = opcode_is_alu_rw & (funct3 === 'b101) & (funct7 === 'b0000000);
  // assign inst_is_sraw   = opcode_is_alu_rw & (funct3 === 'b101) & (funct7 === 'b0100000);
  assign inst_is_beq    = opcode_is_branch & (funct3 === 'b000);
  assign inst_is_bne    = opcode_is_branch & (funct3 === 'b001);
  assign inst_is_blt    = opcode_is_branch & (funct3 === 'b100);
  assign inst_is_bge    = opcode_is_branch & (funct3 === 'b101);
  assign inst_is_bltu   = opcode_is_branch & (funct3 === 'b110);
  assign inst_is_bgeu   = opcode_is_branch & (funct3 === 'b111);
  assign inst_is_jalr   = opcode_is_jalr;
  assign inst_is_jal    = opcode_is_jal;
  assign inst_is_ecall  = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000000000000);
  assign inst_is_ebreak = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000000000001);
  assign inst_is_uret   = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000000000010);
  // assign inst_is_sret   = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000100000010);
  // assign inst_is_hret   = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b001000000010);
  assign inst_is_mret   = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b001100000010);
  assign inst_is_sfence_vm = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000100000100);
  assign inst_is_wfi    = opcode_is_sys & (funct3 === 'b000) & (funct12 === 'b000100000101);
  assign inst_is_csrrw  = opcode_is_sys & (funct3 === 'b001) & (funct7 === 'b0000000);
  assign inst_is_csrrs  = opcode_is_sys & (funct3 === 'b010) & (funct7 === 'b0000000);
  assign inst_is_csrrc  = opcode_is_sys & (funct3 === 'b011) & (funct7 === 'b0000000);
  assign inst_is_csrrwi = opcode_is_sys & (funct3 === 'b101) & (funct7 === 'b0000000);
  assign inst_is_csrrsi = opcode_is_sys & (funct3 === 'b110) & (funct7 === 'b0000000);
  assign inst_is_csrrci = opcode_is_sys & (funct3 === 'b111) & (funct7 === 'b0000000);


  wire is_branch_hit;
  assign is_branch_hit = ((inst_is_beq  && io_dat_br_eq)
    || (inst_is_bne  && !io_dat_br_eq)
    || (inst_is_blt  && io_dat_br_lt)
    || (inst_is_bge  && !io_dat_br_lt)
    || (inst_is_bltu && io_dat_br_ltu)
    || (inst_is_bgeu && !io_dat_br_ltu)
  );

  // control signals
  // assign io_ctl_stall = io_dat_imiss || io_ctl_dmiss;
  assign io_ctl_stall = 'b0;

  assign io_ctl_pc_sel = (
    // (io_ctl_exception || io_dat_csr_eret) ? `PC_SEL_EXC : 
    // io_dat_csr_interrupt ? `PC_SEL_EXC :
    opcode_is_jal ? `PC_SEL_JAL :
    opcode_is_jalr ? `PC_SEL_JALR :
    (opcode_is_branch && is_branch_hit) ? `PC_SEL_BR :
    `PC_SEL_PC4
  );

  assign io_ctl_imm_sel = (
    opcode_is_type_r ? `IMM_SEL_R :
    opcode_is_type_i ? `IMM_SEL_I :
    opcode_is_type_s ? `IMM_SEL_S :
    opcode_is_type_b ? `IMM_SEL_B :
    opcode_is_type_u ? `IMM_SEL_U :
    opcode_is_type_j ? `IMM_SEL_J :
    opcode_is_type_z ? `IMM_SEL_Z :
    `IMM_SEL_R
  );

  assign io_ctl_op1_sel = (opcode_is_auipc || opcode_is_type_j || opcode_is_type_b) ? `OP1_SEL_PC : `OP1_SEL_RS1;

  assign io_ctl_op2_sel = opcode_is_type_r ? `OP2_SEL_RS2 : `OP2_SEL_IMM;

  assign io_ctl_alu_sel = (
    inst_is_add  ? `ALU_SEL_ADD :
    inst_is_sub  ? `ALU_SEL_SUB :
    (inst_is_sll || inst_is_slli)   ? `ALU_SEL_SLL :
    (inst_is_srl || inst_is_srli)   ? `ALU_SEL_SRL :
    (inst_is_sra || inst_is_srai)   ? `ALU_SEL_SRA :
    (inst_is_and || inst_is_andi)   ? `ALU_SEL_AND :
    (inst_is_or || inst_is_ori)     ? `ALU_SEL_OR :
    (inst_is_xor || inst_is_xori)   ? `ALU_SEL_XOR :
    (inst_is_slt || inst_is_slti)   ? `ALU_SEL_SLT :
    (inst_is_sltu || inst_is_sltiu) ? `ALU_SEL_SLTU :
    (inst_is_lui || opcode_is_sys)  ? `ALU_SEL_COPYB :
    `ALU_SEL_ADD
  );

  assign io_dmem_op = (
    opcode_is_load ? `MEM_OP_READ :
    opcode_is_store ? `MEM_OP_WRITE :
    `MEM_OP_READ
  );

  assign io_dmem_mask = (
    (inst_is_sw || inst_is_lw) ? 4'b1111 :
    ((inst_is_sh || inst_is_lh || inst_is_lhu) && (io_dmem_addr_offset == 'b00)) ? 4'b0011 :
    // ((inst_is_sh || inst_is_lh || inst_is_lhu) && (io_dmem_addr_offset == 'b01)) ? 4'b0110 :
    ((inst_is_sh || inst_is_lh || inst_is_lhu) && (io_dmem_addr_offset == 'b10)) ? 4'b1100 :
    // ((inst_is_sh || inst_is_lh || inst_is_lhu) && (io_dmem_addr_offset == 'b11)) ? 4'b1001 :
    ((inst_is_sb || inst_is_lb || inst_is_lbu) && (io_dmem_addr_offset == 'b00)) ? 4'b0001 :
    ((inst_is_sb || inst_is_lb || inst_is_lbu) && (io_dmem_addr_offset == 'b01)) ? 4'b0010 :
    ((inst_is_sb || inst_is_lb || inst_is_lbu) && (io_dmem_addr_offset == 'b10)) ? 4'b0100 :
    ((inst_is_sb || inst_is_lb || inst_is_lbu) && (io_dmem_addr_offset == 'b11)) ? 4'b1000 :
    4'b0000
  );

  assign io_ctl_mem_signed = inst_is_lw || inst_is_lh || inst_is_lb;

  assign io_ctl_wb_sel = (
    opcode_is_load ? `WB_SEL_MEM :
    (opcode_is_jal || opcode_is_jalr) ? `WB_SEL_PC4 :
    opcode_is_sys ? `WB_SEL_CSR :
    `WB_SEL_ALU
  );

  assign io_ctl_rf_wen = (
    opcode_is_load ? `WEN_SEL_ENABLE :
    (inst_is_auipc || inst_is_lui) ? `WEN_SEL_ENABLE :
    (opcode_is_alu_i || opcode_is_alu_r) ? `WEN_SEL_ENABLE :
    // (opcode_is_alu_iw || opcode_is_alu_rw) ? `WEN_SEL_ENABLE :
    (opcode_is_jal || opcode_is_jalr) ? `WEN_SEL_ENABLE :
    (inst_is_csrrc || inst_is_csrrs || inst_is_csrrw || inst_is_csrrci || inst_is_csrrsi || inst_is_csrrwi) ? `WEN_SEL_ENABLE :
    `WEN_SEL_DISABLE
  );

endmodule
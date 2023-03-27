`timescale 1ns/1ns

module IDU (
  input  clk,
  input  rst,

  input  [31:0] idu_i_inst,
  output        idu_o_is_jump,

  output [31:0] idu_o_rs1_data,
  output [31:0] idu_o_rs2_data,
  output [31:0] idu_o_imm,

  output [1:0]  idu_o_a_sel,
  output [1:0]  idu_o_b_sel,
  output [10:0] idu_o_alu_sel,
  output [3:0]  idu_o_br_sel,

  output        idu_o_is_store,
  output [4:0]  idu_o_fmt_sel,

  output [2:0]  idu_o_wb_sel,
  input  [31:0] idu_i_rd_data
);

  wire [7:0] opcode;
  wire [4:0] rd_addr;
  wire [2:0] funct3;
  wire [4:0] rs1_addr;
  wire [4:0] rs2_addr;
  wire [6:0] funct7;

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
  
  wire is_csr_w;
  wire is_csr_s;
  wire is_csr_c;
  wire is_csr_op;
  wire regfile_rd_wen;
  wire [31:0] rd_data;
  wire csr_wen;
  wire [11:0] csr_addr;
  wire [31:0] csr_source;
  wire [31:0] csr_wdata;
  
  wire is_loadstore_doubleword;
  wire is_loadstore_word;
  wire is_loadstore_half;
  wire is_loadstore_byte;
  
  wire is_load_unsigned = funct3[2];

  // extract instruction fields
  assign opcode   = idu_i_inst[6:0];
  assign rd_addr  = idu_i_inst[11:7];
  assign funct3   = idu_i_inst[14:12];
  assign rs1_addr = idu_i_inst[19:15];
  assign rs2_addr = idu_i_inst[24:20];
  assign funct7   = idu_i_inst[31:25];

  // instruction matching
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

  // group instructions into type groups
  assign opcode_is_type_r = opcode_is_alu_rw | opcode_is_alu_r;
  assign opcode_is_type_i = opcode_is_sys | opcode_is_jalr | opcode_is_alu_iw | opcode_is_alu_i | opcode_is_fence | opcode_is_load;
  assign opcode_is_type_s = opcode_is_store;
  assign opcode_is_type_b = opcode_is_branch;
  assign opcode_is_type_u = opcode_is_lui | opcode_is_auipc;
  assign opcode_is_type_j = opcode_is_jal;

  // immediate number generation
  assign idu_o_imm = (
    // I type
      ({32{opcode_is_type_i}} & ({{20{idu_i_inst[31]}}, idu_i_inst[31:20]}))
    // S type
    | ({32{opcode_is_type_s}} & ({{20{idu_i_inst[31]}}, idu_i_inst[31:25], idu_i_inst[11:7]}))
    // B type
    | ({32{opcode_is_type_b}} & ({{19{idu_i_inst[31]}}, idu_i_inst[31], idu_i_inst[7], idu_i_inst[30:25], idu_i_inst[11:8], 1'b0}))
    // U type
    | ({32{opcode_is_type_u}} & ({idu_i_inst[31:12], {12{1'b0}}}))
    // J type
    | ({32{opcode_is_type_j}} & ({{11{idu_i_inst[31]}}, idu_i_inst[31], idu_i_inst[19:12], idu_i_inst[20], idu_i_inst[30:21], 1'b0}))
  );

  assign idu_o_is_jump = opcode_is_jalr | opcode_is_jal;


  // idu control signal
  assign is_csr_w  = funct3[1:0] === 'b01;
  assign is_csr_s  = funct3[1:0] === 'b10;
  assign is_csr_c  = funct3[1:0] === 'b11;
  assign is_csr_op = opcode_is_sys & (is_csr_w | is_csr_s | is_csr_c);

  assign regfile_rd_wen = (rd_addr !== 'h00) & (opcode_is_type_j | opcode_is_type_u | opcode_is_type_i | opcode_is_type_r);
  assign rd_data = is_csr_op ? csr_rdata : idu_i_rd_data;

  assign csr_wen = is_csr_op;
  assign csr_addr = idu_i_inst[31:20];
  assign csr_source = funct3[2] ? {27'b0, idu_i_inst[19:15]} : idu_o_rs1_data;
  assign csr_wdata = (
      ({32{is_csr_w}} & csr_source)
    | ({32{is_csr_s}} & (csr_rdata | csr_source))
    | ({32{is_csr_c}} & (csr_rdata & ~csr_source))
  );
  
  // exu control signals
  assign idu_o_a_sel = (opcode_is_auipc | opcode_is_type_j | opcode_is_type_b) ? 'b10 : 'b01;
  assign idu_o_b_sel = (!opcode_is_type_r) ? 'b10 : 'b01;
  assign idu_o_alu_sel = {
    // B thru
    (opcode_is_lui),
    // and
    (opcode_is_alu_r & (funct3 === 'b111) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b111)),
    // or
    (opcode_is_alu_r & (funct3 === 'b110) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b110)),
    // sra
    (opcode_is_alu_r & (funct3 === 'b101) & (funct7 === 'b0100000)) | (opcode_is_alu_i & (funct3 === 'b101) & (funct7 === 'b0100000)),
    // srl
    (opcode_is_alu_r & (funct3 === 'b101) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b101) & (funct7 === 'b0000000)),
    // xor
    (opcode_is_alu_r & (funct3 === 'b100) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b100)),
    // sltu
    (opcode_is_alu_r & (funct3 === 'b011) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b011)),
    // slt
    (opcode_is_alu_r & (funct3 === 'b010) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b010)),
    // sll
    (opcode_is_alu_r & (funct3 === 'b001) & (funct7 === 'b0000000)) | (opcode_is_alu_i & (funct3 === 'b001) & (funct7 === 'b0000000)),
    // sub
    (opcode_is_alu_r & (funct3 === 'b000) & (funct7 === 'b0100000)),
    // add
    (
       (opcode_is_alu_r & (funct3 === 'b000) & (funct7 === 'b0000000))
     | (opcode_is_alu_i & (funct3 === 'b000))
     | (opcode_is_auipc)
     | (opcode_is_jalr)
     | (opcode_is_load)
     | (opcode_is_type_j)
     | (opcode_is_type_b)
     | (opcode_is_type_s)
     )
  };
  assign idu_o_br_sel = {funct3, opcode_is_branch};


  // memu control signals
  assign is_loadstore_doubleword = funct3[1:0] === 'b11;
  assign is_loadstore_word = funct3[1:0] === 'b10;
  assign is_loadstore_half = funct3[1:0] === 'b01;
  assign is_loadstore_byte = funct3[1:0] === 'b00;

  assign idu_o_is_store = opcode_is_store;
  assign idu_o_fmt_sel = {is_load_unsigned, is_loadstore_doubleword, is_loadstore_word, is_loadstore_half, is_loadstore_byte};


  // wbu control signals
  assign idu_o_wb_sel = (idu_o_is_jump) ? 'b100 :
                        (opcode_is_load) ? 'b010 :
                        'b001;

  RegFile u_regfile (
    .clk(clk),
    .regfile_i_rd_addr(rd_addr),
    .regfile_i_rd_wen(regfile_rd_wen),
    .regfile_i_rd_data(rd_data),
    .regfile_i_rs1_addr(rs1_addr),
    .regfile_o_rs1_data(idu_o_rs1_data),
    .regfile_i_rs2_addr(rs2_addr),
    .regfile_o_rs2_data(idu_o_rs2_data)
  );

  CSR u_csr (
    .clk(clk),
    .csr_i_addr(csr_addr),
    .csr_i_wen(csr_wen),
    .csr_i_wdata(csr_wdata),
    .csr_o_rdata(csr_rdata)
  );

endmodule
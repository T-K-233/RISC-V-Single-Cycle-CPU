
module EXU (
  input  clk,
  input  rst,
  input  [31:0] exu_i_pc,
  input  [31:0] exu_i_rs1_data,
  input  [31:0] exu_i_rs2_data,
  input  [31:0] exu_i_imm,
  input  [1:0]  exu_i_a_sel,
  input  [1:0]  exu_i_b_sel,
  input  [10:0] exu_i_alu_sel,
  input  [3:0]  exu_i_br_sel,

  output [31:0] exu_o_exu_data,
  output [31:0] exu_o_rs2_data,
  output        exu_o_branch_taken
);

  wire [31:0] alu_a, alu_b;
  wire br_un, br_eq, br_lt;
  
  // because we are using single stage, we just need to pass the data through
  assign exu_o_rs2_data = exu_i_rs2_data;

  // alu input selection
  assign alu_a = ({32{exu_i_a_sel[0]}} & exu_i_rs1_data)
               | ({32{exu_i_a_sel[1]}} & exu_i_pc);
  assign alu_b = ({32{exu_i_b_sel[0]}} & exu_i_rs2_data)
               | ({32{exu_i_b_sel[1]}} & exu_i_imm);

  // branch unit input selection and output calculation
  assign br_un = exu_i_br_sel[2];
  assign exu_o_branch_taken = (exu_i_br_sel[0] & ((exu_i_br_sel[3] ? br_lt : br_eq) ^ exu_i_br_sel[1]));
  
  ALU u_alu (
    .alu_i_a(alu_a),
    .alu_i_b(alu_b),
    .alu_i_sel(exu_i_alu_sel),
    .alu_o_out(exu_o_exu_data)
  );

  BRU u_bru (
    .bru_i_a(exu_i_rs1_data),
    .bru_i_b(exu_i_rs2_data),
    .bru_i_br_un(br_un),
    .bru_o_br_eq(br_eq),
    .bru_o_br_lt(br_lt)
  );

endmodule

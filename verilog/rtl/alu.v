`include "consts.vh"

/**
  * @brief ALU module
  * 
  * @param io_sel 11-bit ALU operation selection
  * @param io_in_a 32-bit input A
  * @param io_in_b 32-bit input B
  * @param io_out 32-bit output
  * 
  */
module ALU (
  input  [`ALU_SEL_WIDTH-1:0] io_sel,
  input  [31:0] io_in_a, 
  input  [31:0] io_in_b,
  output [31:0] io_out
);
  
  wire [31:0] out_add, out_and, out_or, out_sll, out_slt, 
              out_sltu, out_sra, out_srl, out_sub, out_xor;

  wire signed [31:0] a_signed, b_signed;

  assign a_signed = io_in_a;
  assign b_signed = io_in_b;

  assign out_add  = io_in_a + io_in_b;
  assign out_sub  = io_in_a - io_in_b;
  assign out_sll  = io_in_a << io_in_b[4:0];
  assign out_slt  = (a_signed < b_signed) ? 'h01 : 'h00;
  assign out_sltu = (io_in_a < io_in_b) ? 'h01 : 'h00;
  assign out_xor  = io_in_a ^ io_in_b;
  assign out_srl  = io_in_a >> io_in_b[4:0];
  assign out_sra  = a_signed >>> io_in_b[4:0];
  assign out_or   = io_in_a | io_in_b;
  assign out_and  = io_in_a & io_in_b;

  assign io_out = (
    (io_sel == `ALU_SEL_ADD)  ? out_add  :
    (io_sel == `ALU_SEL_SUB)  ? out_sub  :
    (io_sel == `ALU_SEL_SLL)  ? out_sll  :
    (io_sel == `ALU_SEL_SRL)  ? out_srl  :
    (io_sel == `ALU_SEL_SRA)  ? out_sra  :
    (io_sel == `ALU_SEL_AND)  ? out_and  :
    (io_sel == `ALU_SEL_OR)   ? out_or   :
    (io_sel == `ALU_SEL_XOR)  ? out_xor  :
    (io_sel == `ALU_SEL_SLT)  ? out_slt  :
    (io_sel == `ALU_SEL_SLTU) ? out_sltu :
    (io_sel == `ALU_SEL_COPYB) ? io_in_b :
    'h0);
  
endmodule


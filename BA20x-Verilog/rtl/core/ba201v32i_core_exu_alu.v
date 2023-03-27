
module ALU (
  input  [31:0] alu_i_a, 
  input  [31:0] alu_i_b,
  input  [10:0] alu_i_sel,
  output [31:0] alu_o_out
);
  
  wire [31:0] out_add, out_and, out_or, out_sll, out_slt, out_sltu, out_sra, out_srl, out_sub, out_xor;

  wire signed [31:0] a_signed, b_signed;
  
  assign a_signed = alu_i_a;
  assign b_signed = alu_i_b;

  assign out_add  = alu_i_a + alu_i_b;
  assign out_sub  = alu_i_a - alu_i_b;
  assign out_sll  = alu_i_a << alu_i_b[4:0];
  assign out_slt  = (a_signed < b_signed) ? 'h01 : 'h00;
  assign out_sltu = (alu_i_a < alu_i_b) ? 'h01 : 'h00;
  assign out_xor  = alu_i_a ^ alu_i_b;
  assign out_srl  = alu_i_a >> alu_i_b[4:0];
  assign out_sra  = a_signed >>> alu_i_b[4:0];
  assign out_or   = alu_i_a | alu_i_b;
  assign out_and  = alu_i_a & alu_i_b;

  assign alu_o_out = (
      ({32{alu_i_sel[10]}} & (alu_i_b))
    | ({32{alu_i_sel[9]}} & (out_and))
    | ({32{alu_i_sel[8]}} & (out_or))
    | ({32{alu_i_sel[7]}} & (out_sra))
    | ({32{alu_i_sel[6]}} & (out_srl))
    | ({32{alu_i_sel[5]}} & (out_xor))
    | ({32{alu_i_sel[4]}} & (out_sltu))
    | ({32{alu_i_sel[3]}} & (out_slt))
    | ({32{alu_i_sel[2]}} & (out_sll))
    | ({32{alu_i_sel[1]}} & (out_sub))
    | ({32{alu_i_sel[0]}} & (out_add))
  );
  
endmodule



module BRU (
  input  [31:0] bru_i_a, 
  input  [31:0] bru_i_b,
  input         bru_i_br_un,
  output        bru_o_br_eq, 
  output        bru_o_br_lt
);

  wire signed [31:0] a_signed, b_signed;
  
  assign a_signed = bru_i_a;
  assign b_signed = bru_i_b;
  
  assign bru_o_br_eq = (bru_i_a === bru_i_b);
  assign bru_o_br_lt = bru_i_br_un ? (bru_i_a < bru_i_b) : (a_signed < b_signed);
  
endmodule

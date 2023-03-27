
module WBU (
  input  clk,
  input  rst,
  input  [31:0] wbu_i_pc,
  input  [31:0] wbu_i_exu_data,
  input  [31:0] wbu_i_memu_data,
  input  [2:0]  wbu_i_wb_sel,
  output [31:0] wbu_o_wb_data
);

  assign wbu_o_wb_data = (
      ({32{wbu_i_wb_sel[0]}} & wbu_i_exu_data)
    | ({32{wbu_i_wb_sel[1]}} & wbu_i_memu_data)
    | ({32{wbu_i_wb_sel[2]}} & (wbu_i_pc + 4))
  );

endmodule

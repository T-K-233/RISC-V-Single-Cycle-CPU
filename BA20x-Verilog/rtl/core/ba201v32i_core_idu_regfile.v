
module RegFile (
  input         clk,
  input  [4:0]  regfile_i_rd_addr,
  input         regfile_i_rd_wen,
  input  [31:0] regfile_i_rd_data,
  
  input  [4:0]  regfile_i_rs1_addr,
  output [31:0] regfile_o_rs1_data,
  input  [4:0]  regfile_i_rs2_addr,
  output [31:0] regfile_o_rs2_data
);

  (* ram_style = "distributed" *) reg [31:0] mem[31-1:0];
  
  always @(posedge clk) begin
    if (regfile_i_rd_wen && (regfile_i_rd_addr !== 'h0)) begin
      mem[regfile_i_rd_addr-1] <= regfile_i_rd_data;
    end
  end

  assign regfile_o_rs1_data = regfile_i_rs1_addr !== 'h0 ? mem[regfile_i_rs1_addr-1] : 'h0;
  assign regfile_o_rs2_data = regfile_i_rs2_addr !== 'h0 ? mem[regfile_i_rs2_addr-1] : 'h0;

endmodule

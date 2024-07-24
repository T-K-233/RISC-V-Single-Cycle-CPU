
module RegFile (
  input         clk,
  input  [4:0]  io_rd_addr,
  input         io_rd_wen,
  input  [31:0] io_rd_data,
  
  input  [4:0]  io_rs1_addr,
  output [31:0] io_rs1_data,
  input  [4:0]  io_rs2_addr,
  output [31:0] io_rs2_data
);

  (* ram_style = "distributed" *) reg [31:0] mem[31-1:0];
  
  always @(posedge clk) begin
    if (io_rd_wen && (io_rd_addr !== 'h0)) begin
      mem[io_rd_addr-1] <= io_rd_data;
    end
  end

  assign io_rs1_data = io_rs1_addr !== 'h0 ? mem[io_rs1_addr-1] : 'h0;
  assign io_rs2_data = io_rs2_addr !== 'h0 ? mem[io_rs2_addr-1] : 'h0;

endmodule

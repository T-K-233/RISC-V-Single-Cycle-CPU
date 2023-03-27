
module CSR (
  input         clk,
  input  [11:0] csr_i_addr,
  input         csr_i_wen,
  input  [31:0] csr_i_wdata,
  output [31:0] csr_o_rdata
);

  (* ram_style = "distributed" *) reg [31:0] mem[0:0];
  
  always @(posedge clk) begin
    if (csr_i_wen) begin
      mem[0] <= csr_i_wdata;
    end
  end

  assign csr_o_rdata = mem[0];

endmodule

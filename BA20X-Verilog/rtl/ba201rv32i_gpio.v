`include "ba201rv32i_consts.vh"

module GPIO (
  input clk,
  input rst,

  input  [31:0] io_addr,
  input         io_op,
  input  [3:0]  io_mask,
  input  [31:0] io_wdata,
  output [31:0] io_rdata,
  
  output [1:0] io_gpio
);

  reg [1:0] out_val;

  assign gpio = out_val;

  assign rdata = {30'h0, out_val};

  always @(posedge clk) begin
    if (rst) begin
      out_val <= 2'h0;
    end
    else begin
      if (op) begin
        out_val <= wdata[1:0];
      end
    end
  end

endmodule


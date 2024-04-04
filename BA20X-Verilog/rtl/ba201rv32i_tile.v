`include "ba201rv32i_consts.vh"

module Tile (
  input clk,
  input rst,

  input         io_interrupt,
  input  [3:0]  io_hart_id,
  input  [31:0] io_reset_vector
);

Core core (
  .clk(clk),
  .rst(rst),

  .io_interrupt(io_interrupt),
  .io_hart_id(io_hart_id),
  .io_reset_vector(io_reset_vector),

  .io_imem_addr(),
  .io_imem_rdata(),
  .io_dmem_addr(),
  .io_dmem_op(),
  .io_dmem_mask(),
  .io_dmem_wdata(),
  .io_dmem_rdata()
);

endmodule


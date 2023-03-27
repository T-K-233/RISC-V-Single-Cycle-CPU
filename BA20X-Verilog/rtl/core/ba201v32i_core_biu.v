
`define ITIM_BASE 'h0800_0000
`define ITIM_SIZE 'h0100_0000

`define DTIM_BASE 'h8000_0000
`define DTIM_SIZE 'h1000_0000

`define MMIO_BASE 'h1001_1000
`define MMIO_SIZE 'h0000_1000

module BIU (
  input  clk,
  input  rst,

  input  [31:0] biu_i_iaddr,
  output [31:0] biu_o_idata,

  input  [31:0] biu_i_daddr,
  input  [3:0]  biu_i_dwmask,
  input  [31:0] biu_i_dwdata,
  output [31:0] biu_o_drdata,

  output biu_o_itim_valid,
  output [31:0] biu_o_itim_addr,
  input  [31:0] biu_i_itim_rdata,

  output biu_o_dtim_valid,
  output [31:0] biu_o_dtim_addr,
  output [3:0]  biu_o_dtim_wmask,
  output [31:0] biu_o_dtim_wdata,
  input  [31:0] biu_i_dtim_rdata,
  
  output biu_o_mmio_valid,
  output [31:0] biu_o_mmio_addr,
  output [3:0]  biu_o_mmio_wmask,
  output [31:0] biu_o_mmio_wdata,
  input  [31:0] biu_i_mmio_rdata
);

  wire is_itim_addr;
  wire is_dtim_addr;
  wire is_mmio_addr;

  assign is_itim_addr = ((biu_i_iaddr >= `ITIM_BASE) && (biu_i_iaddr < (`ITIM_BASE + `ITIM_SIZE)));
  assign is_dtim_addr = ((biu_i_daddr >= `DTIM_BASE) && (biu_i_daddr < (`DTIM_BASE + `DTIM_SIZE)));
  assign is_mmio_addr = ((biu_i_daddr >= `MMIO_BASE) && (biu_i_daddr < (`MMIO_BASE + `MMIO_SIZE)));

  assign biu_o_itim_valid = is_itim_addr;
  assign biu_o_dtim_valid = is_dtim_addr;
  assign biu_o_mmio_valid = is_mmio_addr;
  
  assign biu_o_itim_addr = biu_i_iaddr - `ITIM_BASE;
  assign biu_o_idata = biu_i_itim_rdata;

  assign biu_o_dtim_addr = biu_i_daddr - `DTIM_BASE;
  assign biu_o_dtim_wmask = is_dtim_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_dtim_wdata = biu_i_dwdata;
  
  assign biu_o_mmio_addr = biu_i_daddr - `MMIO_BASE;
  assign biu_o_mmio_wmask = is_mmio_addr ? biu_i_dwmask : 'b0000;
  assign biu_o_mmio_wdata = biu_i_dwdata;
  
  assign biu_o_drdata = is_itim_addr ? biu_i_itim_rdata :
                        is_dtim_addr ? biu_i_dtim_rdata :
                        is_mmio_addr ? biu_i_mmio_rdata :
                        'hBAAD_C0DE;

endmodule

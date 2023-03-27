`timescale 1ns/1ns

module BA201V32IChipTop #(
  parameter IMEM_HEX = "C:/Users/TK/Desktop/BAD-RISCV-MCU/BA20X-Verilog/software/build/firmware.hex",
  parameter IMEM_BIN = ""
) (
  input         CLK100MHZ,
  input         ck_rst,
  
  input  [3:0]  sw,
  output [3:0]  led,
  input  [3:0]  btn
);

  wire clk;  // clock is at fixed 100MHz
  wire rst;  // reset signal is active low
  
  assign rst = ~ck_rst;
  

  clk_wiz_0 u_clk_wiz_0 (
    // Clock out ports  
    .clk_out1(clk),
    // Status and control signals               
    .reset(rst), 
  // Clock in ports
    .clk_in1(CLK100MHZ)
  );

  wire [31:0] core2biu_iaddr;
  wire [31:0] biu2core_idata;
  wire [31:0] core2biu_daddr;
  wire [3:0]  core2biu_dwmask;
  wire [31:0] core2biu_dwdata;
  wire [31:0] biu2core_drdata;

  wire biu2itim_valid;
  wire [31:0] biu2itim_addr;
  wire [31:0] itim2biu_rdata;
  
  wire biu2dtim_valid;
  wire [31:0] biu2dtim_addr;
  wire [3:0]  biu2dtim_wmask;
  wire [31:0] biu2dtim_wdata;
  wire [31:0] dtim2biu_rdata;

  wire biu2mmio_valid;
  wire [31:0] biu2mmio_addr;
  wire [3:0]  biu2mmio_wmask;
  wire [31:0] biu2mmio_wdata;
  wire [31:0] mmio2biu_rdata;
  
  //ila_0 u_ila_0 (
  //  .clk(clk),
  //  .probe0(core2itim_addr),
  //  .probe1(itim2core_rdata)
  //);
  
  Core u_core (
    .clk(clk),
    .rst(rst),

    .core_o_iaddr(core2biu_iaddr),
    .core_i_idata(biu2core_idata),

    .core_o_daddr(core2biu_daddr),
    .core_o_dwmask(core2biu_dwmask),
    .core_o_dwdata(core2biu_dwdata),
    .core_i_drdata(biu2core_drdata)
  );

  BIU u_biu (
    .clk(clk),
    .rst(rst),

    .biu_i_iaddr(core2biu_iaddr),
    .biu_o_idata(biu2core_idata),

    .biu_i_daddr(core2biu_daddr),
    .biu_i_dwmask(core2biu_dwmask),
    .biu_i_dwdata(core2biu_dwdata),
    .biu_o_drdata(biu2core_drdata),

    .biu_o_itim_valid(biu2itim_valid),
    .biu_o_itim_addr(biu2itim_addr),
    .biu_i_itim_rdata(itim2biu_rdata),

    .biu_o_dtim_valid(biu2dtim_valid),
    .biu_o_dtim_addr(biu2dtim_addr),
    .biu_o_dtim_wmask(biu2dtim_wmask),
    .biu_o_dtim_wdata(biu2dtim_wdata),
    .biu_i_dtim_rdata(dtim2biu_rdata),
    
    .biu_o_mmio_valid(biu2mmio_valid),
    .biu_o_mmio_addr(biu2mmio_addr),
    .biu_o_mmio_wmask(biu2mmio_wmask),
    .biu_o_mmio_wdata(biu2mmio_wdata),
    .biu_i_mmio_rdata(mmio2biu_rdata)
  );  

  ITIM #(
    .IMEM_HEX(IMEM_HEX),
    .IMEM_BIN(IMEM_BIN)
  ) u_itim (
    .clk(clk),

    .itim_i_valid(biu2itim_valid),
    .itim_i_addr(biu2itim_addr),
    .itim_o_rdata(itim2biu_rdata)
  );

  DTIM u_dtim (
    .clk(clk),
    .rst(rst),

    .dtim_i_valid(biu2dtim_valid),
    .dtim_i_addr(biu2dtim_addr),
    .dtim_i_wmask(biu2dtim_wmask),
    .dtim_i_wdata(biu2dtim_wdata),
    .dtim_o_rdata(dtim2biu_rdata)
  );
  
  MMIO u_mmio (
    .clk(clk),
    .rst(rst),

    .mmio_i_valid(biu2mmio_valid),
    .mmio_i_addr(biu2mmio_addr),
    .mmio_i_wmask(biu2mmio_wmask),
    .mmio_i_wdata(biu2mmio_wdata),
    .mmio_o_rdata(mmio2biu_rdata),
    
    .mmio_o_gpio_led(led),
    .mmio_i_gpio_btn(btn),
    .mmio_i_gpio_sw(sw)
  );

endmodule

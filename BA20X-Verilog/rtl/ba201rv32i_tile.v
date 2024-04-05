
module Tile (
  input clk,
  input rst,

  output [3:0] led
);

  wire clk;
  wire rst;

  wire         io_interrupt;

  wire  [3:0]  io_hart_id;
  wire  [31:0] io_reset_vector;

  parameter DMEM_BASE = 32'h08000000;
  parameter GPIO_BASE = 32'h10010000;

  wire [31:0] imem_addr;
  wire [31:0] imem_rdata;

  wire [31:0] dmem_addr;
  wire        dmem_op;
  wire [3:0]  dmem_mask;
  wire [31:0] dmem_wdata;
  wire [31:0] dmem_rdata;

  wire        dmem_mem_op;
  wire        dmem_gpio_op;

  wire [31:0] dmem_mem_addr;
  wire [31:0] dmem_mem_rdata;
  wire [31:0] dmem_gpio_addr;
  wire [31:0] dmem_gpio_rdata;

  wire gpio_selected = (dmem_addr >= GPIO_BASE) && (dmem_addr < GPIO_BASE + 'h1000);
  wire dmem_selected = (dmem_addr >= DMEM_BASE) && (dmem_addr < DMEM_BASE + 'h1000);

  assign dmem_rdata = gpio_selected ? dmem_gpio_rdata : dmem_mem_rdata;
  assign dmem_mem_op = dmem_selected ? dmem_op : 1'b0;
  assign dmem_gpio_op = gpio_selected ? dmem_op : 1'b0;

  assign dmem_mem_addr = dmem_addr - DMEM_BASE;
  assign dmem_gpio_addr = dmem_addr - GPIO_BASE;
  

  Core core (
    .clk(clk),
    .rst(rst),

    .io_interrupt(io_interrupt),
    .io_hart_id(io_hart_id),
    .io_reset_vector(io_reset_vector),

    .io_imem_addr(imem_addr),
    .io_imem_rdata(imem_rdata),
    .io_dmem_addr(dmem_addr),
    .io_dmem_op(dmem_op),
    .io_dmem_mask(dmem_mask),
    .io_dmem_wdata(dmem_wdata),
    .io_dmem_rdata(dmem_rdata)
  );

  ROM imem (
    .clk(clk),
    .addr(imem_addr[15:2]),
    .dout(imem_rdata)
  );

  RAM_Simple dmem (
    .clk(clk),
    .addr(dmem_mem_addr[15:2]),
    .op(dmem_mem_op),
    .mask(dmem_mask),
    .wdata(dmem_wdata),
    .rdata(dmem_mem_rdata)
  );

  GPIO gpio (
    .clk(clk),
    .rst(rst),

    .io_addr(dmem_gpio_addr),
    .io_op(dmem_gpio_op),
    .io_mask(dmem_mask),
    .io_wdata(dmem_wdata),
    .io_rdata(dmem_gpio_rdata),
    
    .io_gpio(led[1:0])
  );

  assign led[2] = 1'b1;
  assign led[3] = 1'b0;


endmodule



module Top (
  input CLK100MHZ,
  input ck_rst,

  output [3:0] led
);

  wire clk;
  wire rst;

  assign rst = ~ck_rst;
  
  clk_wiz_0 clk_wiz_0 (
    .clk_out1(clk),
    .reset(rst),
    .clk_in1(CLK100MHZ)
 );

  Tile tile (
    .clk(clk),
    .rst(rst),

    // .io_interrupt(io_interrupt),
    // .io_hart_id(io_hart_id),
    // .io_reset_vector(io_reset_vector),

    .led(led)
  );


endmodule


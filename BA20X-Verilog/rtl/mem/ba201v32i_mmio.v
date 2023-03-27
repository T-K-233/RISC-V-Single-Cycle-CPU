
module MMIO (
  input  clk,
  input  rst,
  input  mmio_i_valid,
  input  [31:0] mmio_i_addr,
  input  [3:0]  mmio_i_wmask,
  input  [31:0] mmio_i_wdata,
  output [31:0] mmio_o_rdata,
  
  output [3:0] mmio_o_gpio_led,
  input  [3:0] mmio_i_gpio_btn,
  input  [3:0] mmio_i_gpio_sw
);
  
  wire is_gpio_input_val;
  wire is_gpio_output_val;

  wire [31:0] gpio_input_val_rdata;
  wire [31:0] gpio_output_val_rdata;
  
  wire wen;
  
  assign wen = mmio_i_valid & (mmio_i_wmask !== 'b0000);
  
  assign is_gpio_input_val = mmio_i_addr === 'h0000_0000;
  assign is_gpio_output_val = mmio_i_addr === 'h0000_0004;
   
  assign mmio_o_rdata = is_gpio_input_val ? gpio_input_val_rdata :
                        is_gpio_output_val ? gpio_output_val_rdata : 
                        'hBAAD_C0DE;
  
  assign mmio_o_gpio_led = gpio_output_val_rdata[3:0];
  
  DFF_REG #(.N(32)) u_gpio_input_val_reg (
    .C(clk),
    .D({24'h0, mmio_o_gpio_sw, mmio_o_gpio_btn}),
    .Q(gpio_input_val_rdata)
  );
  
  DFF_REG_RCE #(.N(32)) u_gpio_output_val_reg (
    .C(clk),
    .R(rst),
    .CE(is_gpio_output_val & wen),
    .D(mmio_i_wdata),
    .Q(gpio_output_val_rdata)
  );

endmodule

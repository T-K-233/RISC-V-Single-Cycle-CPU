module RAM_Simple #(
  parameter DEPTH = 16384
)(
   input clk,

   input  [13:0]  addr,
   input          op,
   input  [3:0]   mask,
   input  [31:0]  wdata,
   output [31:0]  rdata
);
  // See page 133 of the Vivado Synthesis Guide for the template
  // https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_4/ug901-vivado-synthesis.pdf

  reg [31:0] mem [DEPTH-1:0];

  assign rdata = mem[addr];

  always @(posedge clk) begin  
    if (op == 'b1) begin
      mem[addr] <= (
        (mask == 'b1111) ? wdata :
        (mask == 'b0011) ? {mem[addr][31:16], wdata[15:0]} :
        (mask == 'b1100) ? {wdata[31:16], mem[addr][15:0]} :
        (mask == 'b0001) ? {mem[addr][31:8], wdata[7:0]} :
        (mask == 'b0010) ? {mem[addr][31:16], wdata[15:8], mem[addr][7:0]} :
        (mask == 'b0100) ? {mem[addr][31:24], wdata[23:16], mem[addr][15:0]} :
        (mask == 'b1000) ? {wdata[31:24], mem[addr][23:0]} :
        mem[addr]
      );
    end
  end
endmodule

module ITIM #(
  parameter ROM_ADDR_BITS = 10,
  parameter IMEM_HEX = "",
  parameter IMEM_BIN = ""
) (
  input  clk,
  input  itim_i_valid,
  input  [31:0] itim_i_addr,
  output [31:0] itim_o_rdata
);

  (* rom_style="block" *) reg [31:0] mem [(2**ROM_ADDR_BITS)-1:0];
  
  wire [ROM_ADDR_BITS-1:0] addr;
  
  assign addr = itim_i_addr[ROM_ADDR_BITS+1:2];
  assign itim_o_rdata = mem[addr];

  initial begin   
    if (IMEM_HEX != "") begin
      $readmemh(IMEM_HEX, mem);
    end
    else begin
      $readmemb(IMEM_BIN, mem, 0, (2**ROM_ADDR_BITS)-1);
    end
  end

endmodule

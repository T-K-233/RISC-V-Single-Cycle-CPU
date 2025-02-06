module ROM #(
  parameter DEPTH = 16384
)(
    input         clk,
    input  [11:0] addr,
    output [31:0] dout
);
  
  reg [31:0] mem [DEPTH-1:0];

  assign dout = mem[addr];

  initial begin
    $readmemh("firmware.mem", mem);
  end

endmodule
`timescale 1ns/1ns

// Register of D-Type Flip-flops
module Register (q, d, clk);
  parameter N = 1;
  input            clk;
  output reg [N-1:0] q;
  input      [N-1:0] d;
  initial q = {N{1'b0}};
  always @(posedge clk)
    q <= d;
endmodule // REGISTER

// Register with clock enable
module Register_CE (q, d, ce, clk);
  parameter N = 1;
  input            clk;
  output reg [N-1:0] q;
  input      [N-1:0] d;
  input 	          ce;
  initial q = {N{1'b0}};
  always @(posedge clk)
    if (ce) q <= d;
endmodule // REGISTER_CE

// Register with reset value
module Register_R (q, d, rst, clk);
  parameter N = 1;
  parameter INIT = {N{1'b0}};
  input            clk;
  input            rst;
  output reg [N-1:0] q;
  input      [N-1:0] d;
  initial q = INIT;
  always @(posedge clk)
    if (rst) q <= INIT;
    else q <= d;
endmodule // REGISTER_R

// Register with reset and clock enable
//  Reset works independently of clock enable
module Register_R_CE (q, d, rst, ce, clk);
  parameter N = 1;
  parameter INIT = {N{1'b0}};
  input            clk;
  input            rst;
  output reg [N-1:0] q;
  input      [N-1:0] d;
  input 	          ce;
  initial q = INIT;
  always @(posedge clk)
    if (rst) q <= INIT;
    else if (ce) q <= d;
endmodule // REGISTER_R_CE
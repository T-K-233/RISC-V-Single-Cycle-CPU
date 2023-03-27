/**
 * register library
 */

// signal naming convention adapted from http://www.ece.uah.edu/~milenka/cpe528-03S/lectures/HDLModels.pdf

/**
 * N-bit register
 */
module DFF_REG #(
  parameter N = 1,
  parameter INIT = {N{1'b0}}
) (
  input               C,  // clock input
  input [N-1:0]       D,  // data input
  output reg [N-1:0]  Q   // data output
);
  initial Q = INIT;
  always @(posedge C)
    Q <= D;
endmodule

/**
 * N-bit register with synchronous reset
 */
module DFF_REG_R #(
  parameter N = 1,
  parameter INIT = {N{1'b0}}
) (
  input               C,  // clock input
  input               R,  // synchronous reset input
  input [N-1:0]       D,  // data input
  output reg [N-1:0]  Q   // data output
);
  initial Q = INIT;
  always @(posedge C)
    if (R) Q <= INIT;
    else Q <= D;
endmodule

/**
 * N-bit register with synchronous reset and clock enable
 */
module DFF_REG_RCE #(
  parameter N = 1,
  parameter INIT = {N{1'b0}}
) (
  input               C,  // clock input
  input               R,  // synchronous reset input
  input               CE, // clock enable input
  input [N-1:0]       D,  // data input
  output reg [N-1:0]  Q   // data output
);
  initial Q = INIT;
  always @(posedge C)
    if (R) Q <= INIT;
    else if (CE) Q <= D;
endmodule

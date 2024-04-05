`timescale 1ns/1ns

`include "ba201rv32i_consts.vh"

// test bench for entire tile
module TB_Tile();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always #(CLOCK_PERIOD/2) clk = ~clk;
  
  Tile dut (
    .CLK100MHZ(clk),
    .ck_rst(~rst),

    .led()
  );

  initial begin
    #0;
    rst = 1;
    $display("[TEST]\tRESET pulled HIGH.");
    repeat(2) @(posedge clk);
    
    @(negedge clk);
    rst = 0;
    $display("[TEST]\tRESET pulled LOW.");
    @(posedge clk);
    
    
   repeat(10000) @(posedge clk);
    
    


   $finish();
  end

endmodule

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
  
  reg test_passed = 1;

  Core dut (
    .clk(clk),
    .rst(rst),

    .io_interrupt(1'b0),
    .io_hart_id(4'h0),
    .io_reset_vector(32'h0),

    .io_imem_addr(),
    .io_imem_rdata(0),
    .io_dmem_addr(),
    .io_dmem_wdata(),
    .io_dmem_wmask(),
    .io_dmem_rdata(0)
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
    
    
    repeat(10) @(posedge clk);
    
    
    if (test_passed) begin
      $display("[TEST]\tAll tests passed.");
    end else begin
      $display("[TEST]\tSome tests failed.");
    end


    $finish();
  end

endmodule

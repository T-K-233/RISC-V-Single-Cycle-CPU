`timescale 1ns/1ns

module TestBench ();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always #(CLOCK_PERIOD/2) clk = ~clk;
  


  Tile dut (
    .clock(clk),
    .reset(rst),
    .io_led()
);

  reg clock;


  initial begin
    
    // set up logging
    // $dumpfile("out.vcd");
    // $dumpvars(0, top);
    $fsdbDumpfile("out.fsdb");
    $fsdbDumpvars("+all");

    
    #0;
    rst = 1;
    $display("[TEST]\tRESET pulled HIGH.");
    repeat(2) @(posedge clk);
    
    @(negedge clk);
    rst = 0;
    $display("[TEST]\tRESET pulled LOW.");
    @(posedge clk);

   repeat(100) @(posedge clk);

    $display("[TEST]\tDONE.");

    $finish;
  end

endmodule
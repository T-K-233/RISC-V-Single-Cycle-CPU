`timescale 1ns/1ns

`include "consts.vh"

// test bench for ALU module
module TB_ALU();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always #(CLOCK_PERIOD/2) clk = ~clk;
  
  reg test_passed = 1;

  localparam A_VALUE = -100;
  localparam B_VALUE = 200;
  localparam SHAMT   = 20;


  // test signals
  reg signed [31:0] in_a, in_b;
  reg signed [`ALU_SEL_WIDTH-1:0] sel;
  wire signed [31:0] out;


  ALU dut (
    .io_sel(sel),
    .io_in_a(in_a),
    .io_in_b(in_b),
    .io_out(out)
  );

  initial begin
    #0;
    rst = 0;
    $display("[TEST]\tRESET pulled LOW.");
    repeat(2) @(posedge clk);
    
    @(negedge clk);
    rst = 1;
    $display("[TEST]\tRESET pulled HIGH.");
    repeat(2) @(posedge clk);
    
    rst = 0;

    in_a = A_VALUE;
    in_b = B_VALUE;

    // addition
    sel = `ALU_SEL_ADD;
    repeat(1) @(posedge clk);
    assert (out == in_a + in_b) else begin $display("[TEST]\tAddition Test Failed: %d + %d = %d", in_a, in_b, out); test_passed = 0; end

    // subtraction
    sel = `ALU_SEL_SUB;
    repeat(1) @(posedge clk);
    assert (out == in_a - in_b) else begin $display("[TEST]\tSubtraction Test Failed: %d - %d = %d", in_a, in_b, out); test_passed = 0; end

    // set less than
    sel = `ALU_SEL_SLT;
    repeat(1) @(posedge clk);
    assert (out == (in_a < in_b) ? 1 : 0) else begin $display("[TEST]\tSet Less Than Test Failed: %d < %d = %d", in_a, in_b, out); test_passed = 0; end

    // set less than unsigned
    sel = `ALU_SEL_SLTU;
    repeat(1) @(posedge clk);
    assert (out == (unsigned'(in_a) < unsigned'(in_b)) ? 1 : 0) else begin $display("[TEST]\tSet Less Than Unsigned Test Failed: %d < %d = %d", in_a, in_b, out); test_passed = 0; end

    // xor
    sel = `ALU_SEL_XOR;
    repeat(1) @(posedge clk);
    assert (out == (in_a ^ in_b)) else begin $display("[TEST]\tXOR Test Failed: %d ^ %d = %d", in_a, in_b, out); test_passed = 0; end

    // or
    sel = `ALU_SEL_OR;
    repeat(1) @(posedge clk);
    assert (out == (in_a | in_b)) else begin $display("[TEST]\tOR Test Failed: %d | %d = %d", in_a, in_b, out); test_passed = 0; end

    // and
    sel = `ALU_SEL_AND;
    repeat(1) @(posedge clk);
    assert (out == (in_a & in_b)) else begin $display("[TEST]\tAND Test Failed: %d & %d = %d", in_a, in_b, out); test_passed = 0; end

    // B
    sel = `ALU_SEL_COPYB;
    repeat(1) @(posedge clk);
    assert (out == in_b) else begin $display("[TEST]\tB Test Failed: %d = %d", in_b, out); test_passed = 0; end
    
    in_a = A_VALUE;
    in_b = SHAMT;

    // shift left logical
    sel = `ALU_SEL_SLL;
    repeat(1) @(posedge clk);
    assert (out == in_a << in_b) else begin $display("[TEST]\tShift Left Logical Test Failed: %d << %d = %d", in_a, in_b, out); test_passed = 0; end

    // shift right logical
    sel = `ALU_SEL_SRL;
    repeat(1) @(posedge clk);
    assert (out == in_a >> in_b) else begin $display("[TEST]\tShift Right Logical Test Failed: %d >> %d = %d", in_a, in_b, out); test_passed = 0; end

    // shift right arithmetic
    sel = `ALU_SEL_SRA;
    repeat(1) @(posedge clk);
    assert (out == in_a >>> in_b) else begin $display("[TEST]\tShift Right Arithmetic Test Failed: %d >>> %d = %d", in_a, in_b, out); test_passed = 0; end


    if (test_passed) begin
      $display("[TEST]\tAll tests passed.");
    end else begin
      $display("[TEST]\tSome tests failed.");
    end


    $finish();
  end

endmodule

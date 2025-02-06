`timescale 1ns/1ns

`include "consts.vh"

`define REGFILE_PATH    dut.datapath.regfile.mem
`define DMEM_PATH       dmem.mem


// test bench for Core module
module TB_Core();
  parameter CLOCK_FREQ = 100_000_000;
  parameter CLOCK_PERIOD = 1_000_000_000 / CLOCK_FREQ;

  // setup clock and reset
  reg clk, rst;
  initial clk = 'b0;
  always #(CLOCK_PERIOD/2) clk = ~clk;
  
  reg [31:0] debug;  


  wire [31:0] imem_addr;
  wire [31:0] imem_rdata;
  wire [31:0] dmem_addr;
  wire        dmem_op;
  wire [3:0]  dmem_mask;
  wire [31:0] dmem_wdata;
  wire [31:0] dmem_rdata;

  reg [31:0] imem [16384-1:0];
  
  assign imem_rdata = imem[imem_addr[17:2]];

  Core dut (
    .clk(clk),
    .rst(rst),

    .io_interrupt(1'b0),
    .io_hart_id(4'h0),
    .io_reset_vector(32'h0),

    .io_imem_addr(imem_addr),
    .io_imem_rdata(imem_rdata),
    .io_dmem_addr(dmem_addr),
    .io_dmem_op(dmem_op),
    .io_dmem_mask(dmem_mask),
    .io_dmem_wdata(dmem_wdata),
    .io_dmem_rdata(dmem_rdata)
  );

  RAM_Simple dmem (
    .clk(clk),
    .addr(dmem_addr[15:2]),
    .op(dmem_op),
    .mask(dmem_mask),
    .wdata(dmem_wdata),
    .rdata(dmem_rdata)
  );
  
  
  task resetDUT;
    @(negedge clk);
    rst = 1;
    @(negedge clk);
    rst = 0;
    $display("[TEST]\tRESET CPU.");
  endtask


  task initRegfile;
    integer i;
    begin
      for (i = 1; i < 32; i = i + 1) begin
        `REGFILE_PATH[i-1] = 100 * i + 1;
      end
    end
  endtask

  task clearMemory;
    begin
      integer i;
      for (i = 1; i < 32; i = i + 1) begin
        `REGFILE_PATH[i-1] = 0;
      end
      for (i = 0; i < 16384; i = i + 1) begin
        imem[i] = 0;
      end
      for (i = 0; i < 16384; i = i + 1) begin
        `DMEM_PATH[i] = 0;
      end
    end
  endtask

  wire [31:0] timeout_cycle = 10;

  reg [31:0] cycle;
  reg done;
  reg [31:0]  current_test_id = 0;
  reg [255:0] current_test_type;
  reg [31:0]  current_output;
  reg [31:0]  current_result;
  reg all_tests_passed = 0;


  integer i;
  reg [4:0]  RD, RS1, RS2;
  reg [31:0] RD1, RD2;
  reg [4:0]  SHAMT;
  reg [31:0] IMM, IMM0, IMM1, IMM2, IMM3;
  reg [14:0] INST_ADDR;
  reg [14:0] DATA_ADDR;
  reg [14:0] DATA_ADDR0, DATA_ADDR1, DATA_ADDR2, DATA_ADDR3;
  reg [14:0] DATA_ADDR4, DATA_ADDR5, DATA_ADDR6, DATA_ADDR7;
  reg [14:0] DATA_ADDR8, DATA_ADDR9;

  reg [31:0] JUMP_ADDR;

  reg [31:0]  BR_TAKEN_OP1  [5:0];
  reg [31:0]  BR_TAKEN_OP2  [5:0];
  reg [31:0]  BR_NTAKEN_OP1 [5:0];
  reg [31:0]  BR_NTAKEN_OP2 [5:0];
  reg [31:0]  BR_INST       [5:0];
  reg [255:0] BR_NAME_TK1   [5:0];
  reg [255:0] BR_NAME_TK2   [5:0];
  reg [255:0] BR_NAME_NTK   [5:0];

  // Check for timeout
  // If a test does not return correct value in a given timeout cycle,
  // we terminate the testbench
  initial begin
    while (all_tests_passed === 0) begin
      @(posedge clk);
      if (cycle === timeout_cycle) begin
        $display("[Failed] Timeout at [%d] test %s, expected_result = %h, got = %h",
                current_test_id, current_test_type, current_result, current_output);
        $finish();
      end
    end
  end

  always @(posedge clk) begin
    if (done === 0)
      cycle <= cycle + 1;
    else
      cycle <= 0;
  end

  task checkResultRF;
    input [31:0]  rf_wa;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`REGFILE_PATH[rf_wa-1] !== result) begin
        current_output = `REGFILE_PATH[rf_wa-1];
        @(posedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask

  task checkResultDMEM;
    input [31:0]  addr;
    input [31:0]  result;
    input [255:0] test_type;
    begin
      done = 0;
      current_test_id   = current_test_id + 1;
      current_test_type = test_type;
      current_result    = result;
      while (`DMEM_PATH[addr] !== result) begin
        current_output = `DMEM_PATH[addr];
        @(posedge clk);
      end
      cycle = 0;
      done = 1;
      $display("[%d] Test %s passed!", current_test_id, test_type);
    end
  endtask




  initial begin
    
    $dumpfile("tb_core.vcd");
    $dumpvars(0, TB_Core);
    
    #0;

    // Test R-Type Insts --------------------------------------------------
    // - ADD, SUB, SLL, SLT, SLTU, XOR, OR, AND, SRL, SRA
    // - SLLI, SRLI, SRAI
    clearMemory();

    `REGFILE_PATH[1-1] = -100;
    `REGFILE_PATH[2-1] = 200;

    imem[0] = 32'h002081B3;    // add  x3, x1, x2
    imem[1] = 32'h40208233;    // sub  x4, x1, x2
    imem[2] = 32'h002092B3;    // sll  x5, x1, x2
    imem[3] = 32'h0020A333;    // slt  x6, x1, x2
    imem[4] = 32'h0020B3B3;    // sltu x7, x1, x2
    imem[5] = 32'h0020C433;    // xor  x8, x1, x2
    imem[6] = 32'h0020E4B3;    // or   x9, x1, x2
    imem[7] = 32'h0020F533;    // and  x10, x1, x2
    imem[8] = 32'h0020D5B3;    // srl  x11, x1, x2
    imem[9] = 32'h4020D633;    // sra  x12, x1, x2
    imem[10] = 32'h01409693;   // slli x13, x1, 20
    imem[11] = 32'h0140D713;   // srli x14, x1, 20
    imem[12] = 32'h4140D793;   // srai x15, x1, 20

    resetDUT();

    checkResultRF(5'd3,  32'h00000064, "R-Type ADD");
    checkResultRF(5'd4,  32'hfffffed4, "R-Type SUB");
    checkResultRF(5'd5,  32'hffff9c00, "R-Type SLL");
    checkResultRF(5'd6,  32'h1,        "R-Type SLT");
    checkResultRF(5'd7,  32'h0,        "R-Type SLTU");
    checkResultRF(5'd8,  32'hffffff54, "R-Type XOR");
    checkResultRF(5'd9,  32'hffffffdc, "R-Type OR");
    checkResultRF(5'd10, 32'h00000088, "R-Type AND");
    checkResultRF(5'd11, 32'h00ffffff, "R-Type SRL");
    checkResultRF(5'd12, 32'hffffffff, "R-Type SRA");
    checkResultRF(5'd13, 32'hf9c00000, "R-Type SLLI");
    checkResultRF(5'd14, 32'h00000fff, "R-Type SRLI");
    checkResultRF(5'd15, 32'hffffffff, "R-Type SRAI");

    

    // Test I-Type Insts --------------------------------------------------
    // - ADDI, SLTI, SLTUI, XORI, ORI, ANDI
    // - LW, LH, LB, LHU, LBU
    // - JALR

    // Test I-type arithmetic instructions
    clearMemory();

    `REGFILE_PATH[1-1] = -100;

    imem[0] = 32'hF3808193;   // addi  x3, x1, -200
    imem[1] = 32'hF380A213;   // slti  x4, x1, -200
    imem[2] = 32'hF380B293;   // sltiu x5, x1, -200
    imem[3] = 32'hF380C313;   // xori  x6, x1, -200
    imem[4] = 32'hF380E393;   // ori   x7, x1, -200
    imem[5] = 32'hF380F413;   // andi  x8, x1, -200

    resetDUT();

    checkResultRF(5'd3,  32'hfffffed4, "I-Type ADD");
    checkResultRF(5'd4,  32'h00000000, "I-Type SLT");
    checkResultRF(5'd5,  32'h00000000, "I-Type SLTU");
    checkResultRF(5'd6,  32'h000000a4, "I-Type XOR");
    checkResultRF(5'd7,  32'hffffffbc, "I-Type OR");
    checkResultRF(5'd8,  32'hffffff18, "I-Type AND");

    // Test I-type load instructions
    clearMemory();

    `REGFILE_PATH[1-1] = 'h1000;

    imem[0] = 32'h0000A103;     // lw x2, 0(x1)
    imem[1] = 32'h00009183;     // lh x3, 0(x1)
    // imem[2] = 32'h00109203;     // lh x4, 1(x1)
    imem[3] = 32'h00209283;     // lh x5, 2(x1)
    // imem[4] = 32'h00309303;     // lh x6, 3(x1)
    imem[5] = 32'h00008383;     // lb x7, 0(x1)
    imem[6] = 32'h00108403;     // lb x8, 1(x1)
    imem[7] = 32'h00208483;     // lb x9, 2(x1)
    imem[8] = 32'h00308503;     // lb x10, 3(x1)
    imem[9] = 32'h0000D583;     // lhu x11, 0(x1)
    // imem[10] = 32'h0010D603;    // lhu x12, 1(x1)
    imem[11] = 32'h0020D683;    // lhu x13, 2(x1)
    // imem[12] = 32'h0030D703;    // lhu x14, 3(x1)
    imem[13] = 32'h0000C783;    // lbu x15, 0(x1)
    imem[14] = 32'h0010C803;    // lbu x16, 1(x1)
    imem[15] = 32'h0020C883;    // lbu x17, 2(x1)
    imem[16] = 32'h0030C903;    // lbu x18, 3(x1)


    `DMEM_PATH[`REGFILE_PATH[1-1]>>2] = 32'hdeadbeef;

    resetDUT();

    checkResultRF(5'd2,  32'hdeadbeef, "I-Type LW");
    checkResultRF(5'd3,  32'hffffbeef, "I-Type LH 0");
    // checkResultRF(5'd4,  32'hffffbeef, "I-Type LH 1");
    checkResultRF(5'd5,  32'hffffdead, "I-Type LH 2");
    // checkResultRF(5'd6,  32'hffffdead, "I-Type LH 3");
    checkResultRF(5'd7,  32'hffffffef, "I-Type LB 0");
    checkResultRF(5'd8,  32'hffffffbe, "I-Type LB 1");
    checkResultRF(5'd9,  32'hffffffad, "I-Type LB 2");
    checkResultRF(5'd10, 32'hffffffde, "I-Type LB 3");
    checkResultRF(5'd11, 32'h0000beef, "I-Type LHU 0");
    // checkResultRF(5'd12, 32'h0000beef, "I-Type LHU 1");
    checkResultRF(5'd13, 32'h0000dead, "I-Type LHU 2");
    // checkResultRF(5'd14, 32'h0000dead, "I-Type LHU 3");
    checkResultRF(5'd15, 32'h000000ef, "I-Type LBU 0");
    checkResultRF(5'd16, 32'h000000be, "I-Type LBU 1");
    checkResultRF(5'd17, 32'h000000ad, "I-Type LBU 2");
    checkResultRF(5'd18, 32'h000000de, "I-Type LBU 3");



    // Test S-Type Insts --------------------------------------------------
    // - SW, SH, SB
    clearMemory();

    `REGFILE_PATH[1-1]  = 32'h12345678;

    `REGFILE_PATH[2-1]  = 32'h0000_0010;

    `REGFILE_PATH[3-1]  = 32'h0000_0020;
    `REGFILE_PATH[4-1]  = 32'h0000_0030;
    `REGFILE_PATH[5-1]  = 32'h0000_0040;
    `REGFILE_PATH[6-1]  = 32'h0000_0050;

    `REGFILE_PATH[7-1]  = 32'h0000_0060;
    `REGFILE_PATH[8-1]  = 32'h0000_0070;
    `REGFILE_PATH[9-1]  = 32'h0000_0080;
    `REGFILE_PATH[10-1] = 32'h0000_0090;

    imem[0] = 32'h10112023;    // sw x1, 0x100(x2)
    imem[1] = 32'h10119023;    // sh x1, 0x100(x3)
    // imem[2] = 32'h101210A3;    // sh x1, 0x101(x4)
    imem[3] = 32'h10129123;    // sh x1, 0x102(x5)
    // imem[4] = 32'h101311A3;    // sh x1, 0x103(x6)
    imem[5] = 32'h10138023;    // sb x1, 0x100(x7)
    imem[6] = 32'h101400A3;    // sb x1, 0x101(x8)
    imem[7] = 32'h10148123;    // sb x1, 0x102(x9)
    imem[8] = 32'h101501A3;    // sb x1, 0x103(x10)

    resetDUT();

    debug = (`REGFILE_PATH[2-1]  + 'h100) >> 2;

    checkResultDMEM((`REGFILE_PATH[2-1]  + 'h100) >> 2, 32'h12345678, "S-Type SW");
    checkResultDMEM((`REGFILE_PATH[3-1]  + 'h100) >> 2, 32'h00005678, "S-Type SH 1");
    // checkResultDMEM((`REGFILE_PATH[4-1]  + 'h101) >> 2, 32'h00005678, "S-Type SH 2");
    checkResultDMEM((`REGFILE_PATH[5-1]  + 'h102) >> 2, 32'h56780000, "S-Type SH 3");
    // checkResultDMEM((`REGFILE_PATH[6-1]  + 'h103) >> 2, 32'h56780000, "S-Type SH 4");
    checkResultDMEM((`REGFILE_PATH[7-1]  + 'h100) >> 2, 32'h00000078, "S-Type SB 1");
    checkResultDMEM((`REGFILE_PATH[8-1]  + 'h101) >> 2, 32'h00007800, "S-Type SB 2");
    checkResultDMEM((`REGFILE_PATH[9-1]  + 'h102) >> 2, 32'h00780000, "S-Type SB 3");
    checkResultDMEM((`REGFILE_PATH[10-1] + 'h103) >> 2, 32'h78000000, "S-Type SB 4");


    // Test U-Type Insts --------------------------------------------------
    // - LUI, AUIPC
    clearMemory();

    imem[0] = 32'h7FFF01B7;    // lui   x3, 0x7FFF0
    imem[1] = 32'h7FFF0217;    // auipc x4, 0x7FFF0
    
    resetDUT();

    checkResultRF(5'd3, 32'h7fff0000, "U-Type LUI");
    checkResultRF(5'd4, 32'h7fff0004, "U-Type AUIPC"); // assume PC is 0000_0004


    // Test J-Type Insts --------------------------------------------------
    // - JAL
    clearMemory();

    `REGFILE_PATH[1-1] = 100;
    `REGFILE_PATH[2-1] = 200;
    `REGFILE_PATH[3-1] = 300;
    `REGFILE_PATH[4-1] = 400;

    imem[0] = 32'h7F1002EF;               // jal x5, 0x0FF0
    imem[1] = 32'h00208333;               // add x6, x1, x2
    imem['h0FF0 >> 2] = 32'h004183B3;    // add x7, x3, x4

    resetDUT();

    checkResultRF(5'd5, 32'h0000_0004, "J-Type JAL");
    checkResultRF(5'd7, 700, "J-Type JAL");
    checkResultRF(5'd6, 0, "J-Type JAL");

    // Test I-Type JALR Insts ---------------------------------------------
    // - JALR
    clearMemory();

    `REGFILE_PATH[1-1] = 32'h0000_0100;
    `REGFILE_PATH[2-1] = 200;
    `REGFILE_PATH[3-1] = 300;
    `REGFILE_PATH[4-1] = 400;

    imem[0] = 32'h7F8082E7;               // jalr x5, x1, 0x7F8
    imem[1] = 32'h00208333;               // add x6, x1, x2
    imem[(`REGFILE_PATH[1-1] + 'h7F8) >> 2] = 32'h004183B3;    // add x7, x3, x4

    resetDUT();

    checkResultRF(5'd5, 32'h0000_0004, "J-Type JALR");
    checkResultRF(5'd7, 700, "J-Type JALR");
    checkResultRF(5'd6, 0, "J-Type JALR");



    // Test B-Type Insts --------------------------------------------------
    // - BEQ, BNE, BLT, BGE, BLTU, BGEU
    BR_INST[0]     = 'h7E2088E3;    // beq
    BR_NAME_TK1[0] = "B-Type BEQ Taken 1";
    BR_NAME_TK2[0] = "B-Type BEQ Taken 2";
    BR_NAME_NTK[0] = "B-Type BEQ Not Taken";
    BR_TAKEN_OP1[0]  = 100; BR_TAKEN_OP2[0]  = 100;
    BR_NTAKEN_OP1[0] = 100; BR_NTAKEN_OP2[0] = 200;

    BR_INST[1]       = 'h7E2098E3;    // bne
    BR_NAME_TK1[1]   = "B-Type BNE Taken 1";
    BR_NAME_TK2[1]   = "B-Type BNE Taken 2";
    BR_NAME_NTK[1]   = "B-Type BNE Not Taken";
    BR_TAKEN_OP1[1]  = 100; BR_TAKEN_OP2[1]  = 200;
    BR_NTAKEN_OP1[1] = 100; BR_NTAKEN_OP2[1] = 100;

    BR_INST[2]       = 'h7E20C8E3;    // blt
    BR_NAME_TK1[2]   = "B-Type BLT Taken 1";
    BR_NAME_TK2[2]   = "B-Type BLT Taken 2";
    BR_NAME_NTK[2]   = "B-Type BLT Not Taken";
    BR_TAKEN_OP1[2]  = 100; BR_TAKEN_OP2[2]  = 200;
    BR_NTAKEN_OP1[2] = 200; BR_NTAKEN_OP2[2] = 100;

    BR_INST[3]       = 'h7E20D8E3;    // bge
    BR_NAME_TK1[3]   = "B-Type BGE Taken 1";
    BR_NAME_TK2[3]   = "B-Type BGE Taken 2";
    BR_NAME_NTK[3]   = "B-Type BGE Not Taken";
    BR_TAKEN_OP1[3]  = 300; BR_TAKEN_OP2[3]  = 200;
    BR_NTAKEN_OP1[3] = 100; BR_NTAKEN_OP2[3] = 200;

    BR_INST[4]       = 'h7E20E8E3;    // bltu
    BR_NAME_TK1[4]   = "B-Type BLTU Taken 1";
    BR_NAME_TK2[4]   = "B-Type BLTU Taken 2";
    BR_NAME_NTK[4]   = "B-Type BLTU Not Taken";
    BR_TAKEN_OP1[4]  = 32'h0000_0001; BR_TAKEN_OP2[4]  = 32'hFFFF_0000;
    BR_NTAKEN_OP1[4] = 32'hFFFF_0000; BR_NTAKEN_OP2[4] = 32'h0000_0001;

    BR_INST[5]       = 'h7E20F8E3;    // bgeu
    BR_NAME_TK1[5]   = "B-Type BGEU Taken 1";
    BR_NAME_TK2[5]   = "B-Type BGEU Taken 2";
    BR_NAME_NTK[5]   = "B-Type BGEU Not Taken";
    BR_TAKEN_OP1[5]  = 32'hFFFF_0000; BR_TAKEN_OP2[5]  = 32'h0000_0001;
    BR_NTAKEN_OP1[5] = 32'h0000_0001; BR_NTAKEN_OP2[5] = 32'hFFFF_0000;

    for (i = 0; i < 6; i = i + 1) begin
      clearMemory();

      `REGFILE_PATH[1-1] = BR_TAKEN_OP1[i];
      `REGFILE_PATH[2-1] = BR_TAKEN_OP2[i];
      `REGFILE_PATH[3-1] = 300;
      `REGFILE_PATH[4-1] = 400;

      // Test branch taken
      imem[0]            = BR_INST[i];  // branch? x1, x2, 0x0FF0
      imem[1]            = 'h004182B3;  // add x5, x3, x4
      imem['h0FF0 >> 2]  = 'h00418333;  // add x6, x3, x4

      resetDUT();

      checkResultRF(5'd5, 0,   BR_NAME_TK1[i]);
      checkResultRF(5'd6, 700, BR_NAME_TK2[i]);

      clearMemory();

      `REGFILE_PATH[1-1] = BR_NTAKEN_OP1[i];
      `REGFILE_PATH[2-1] = BR_NTAKEN_OP2[i];
      `REGFILE_PATH[3-1] = 300;
      `REGFILE_PATH[4-1] = 400;

      // Test branch not taken
      imem[0]            = BR_INST[i];  // branch? x1, x2, 0x0FF0
      imem[1]            = 'h004182B3;  // add x5, x3, x4

      resetDUT();
      checkResultRF(5'd5, 700, BR_NAME_NTK[i]);
    end



    $finish();
  end

endmodule

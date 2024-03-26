
`ifndef __CONSTS_H
`define __CONSTS_H


// PC Select Signal
`define PC_SEL_WIDTH    3
`define PC_SEL_PC4      3'h0
`define PC_SEL_BR       3'h1
`define PC_SEL_JAL      3'h2
`define PC_SEL_JALR     3'h3
`define PC_SEL_EXC      3'h4

// Immediate Generation Type
`define IMM_SEL_WIDTH   3
`define IMM_SEL_R       3'h0
`define IMM_SEL_I       3'h1
`define IMM_SEL_S       3'h2
`define IMM_SEL_B       3'h3
`define IMM_SEL_U       3'h4
`define IMM_SEL_J       3'h5
`define IMM_SEL_Z       3'h6

// ALU OP1 Operand Select Signal
`define OP1_SEL_WIDTH   1
`define OP1_SEL_RS1     'h0
`define OP1_SEL_PC      'h1

// ALU OP2 Operand Select Signal
`define OP2_SEL_WIDTH   1
`define OP2_SEL_RS2     'h0
`define OP2_SEL_IMM     'h1

// Register File Write Enable Signal
`define WEN_SEL_WIDTH   1
`define WEN_SEL_DISABLE 'h0
`define WEN_SEL_ENABLE  'h1


// ALU Operation Signal
`define ALU_SEL_WIDTH   4
`define ALU_SEL_ADD     4'h0
`define ALU_SEL_SUB     4'h1
`define ALU_SEL_SLL     4'h2
`define ALU_SEL_SRL     4'h3
`define ALU_SEL_SRA     4'h4
`define ALU_SEL_AND     4'h5
`define ALU_SEL_OR      4'h6
`define ALU_SEL_XOR     4'h7
`define ALU_SEL_SLT     4'h8
`define ALU_SEL_SLTU    4'h9
`define ALU_SEL_COPYB   4'hA


// Memory Request Type (Read,Write,Fence) Signal
`define MEMREQ_TYPE_WIDTH  1
`define MEMREQ_TYPE_READ   'h0
`define MEMREQ_TYPE_WRITE  'h1

// // Memory Enable Signal
// val MEN_0   = false.B
// val MEN_1   = true.B
// val MEN_X   = false.B

// Memory Mask Type Signal
`define MEM_MSK_WIDTH   3
`define MEM_MSK_B       3'h0
`define MEM_MSK_BU      3'h1
`define MEM_MSK_H       3'h2
`define MEM_MSK_HU      3'h3
`define MEM_MSK_W       3'h4
`define MEM_MSK_X       3'h4

// Writeback Select Signal
`define WB_SEL_WIDTH    2
`define WB_SEL_ALU      2'h0
`define WB_SEL_MEM      2'h1
`define WB_SEL_PC4      2'h2
`define WB_SEL_CSR      2'h3


`endif
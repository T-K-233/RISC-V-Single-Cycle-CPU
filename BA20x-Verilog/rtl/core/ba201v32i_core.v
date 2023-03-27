
module Core #(
  parameter IMEM_HEX = "firmware.hex",
  parameter IMEM_BIN = ""
) (
  input  clk,
  input  rst,
  
  output [31:0] core_o_iaddr,
  input  [31:0] core_i_idata,

  output [31:0] core_o_daddr,
  output [3:0]  core_o_dwmask,
  output [31:0] core_o_dwdata,
  input  [31:0] core_i_drdata
);

  wire [31:0] ifu2idu_inst;
  wire [31:0] ifu2exu_pc;
  wire [31:0] ifu2wbu_pc;
  wire [31:0] ifu2biu_iaddr;

  assign ifu2wbu_pc = ifu2exu_pc;


  wire        idu2ifu_is_jump;
  wire [31:0] idu2exu_rs1_data;
  wire [31:0] idu2exu_rs2_data;
  wire [31:0] idu2exu_imm;
  wire [1:0]  idu2exu_a_sel;
  wire [1:0]  idu2exu_b_sel;
  wire [10:0] idu2exu_alu_sel;
  wire [3:0]  idu2exu_br_sel;
  wire        idu2memu_is_store;
  wire [4:0]  idu2memu_fmt_sel;
  wire [2:0]  idu2wbu_wb_sel;


  wire        exu2ifu_is_branch_taken;
  wire [31:0] exu2ifu_data;
  wire [31:0] exu2memu_data;
  wire [31:0] exu2memu_rs2_data;
  wire [31:0] exu2wbu_data;

  assign exu2ifu_data = exu2memu_data;
  assign exu2wbu_data = exu2memu_data;


  wire [31:0] memu2wbu_data;
  wire [31:0] memu2biu_daddr;
  wire [3:0]  memu2biu_dwmask;
  wire [31:0] memu2biu_dwdata;


  wire [31:0] wbu2idu_rd_data;


  IFU u_ifu (
    .clk(clk),
    .rst(rst),
    .ifu_i_halt('b0),
    .ifu_i_is_jump(idu2ifu_is_jump),
    .ifu_i_is_branch_taken(exu2ifu_is_branch_taken),
    .ifu_i_pc_target(exu2ifu_data),

    .ifu_o_pc(ifu2exu_pc),
    .ifu_o_inst(ifu2idu_inst),

    .ifu_o_iaddr(core_o_iaddr),
    .ifu_i_idata(core_i_idata)
  );

  IDU u_idu (
    .clk(clk),
    .rst(rst),
    .idu_i_inst(ifu2idu_inst),

    .idu_o_is_jump(idu2ifu_is_jump),

    .idu_o_rs1_data(idu2exu_rs1_data),
    .idu_o_rs2_data(idu2exu_rs2_data),
    .idu_o_imm(idu2exu_imm),
    .idu_o_a_sel(idu2exu_a_sel),
    .idu_o_b_sel(idu2exu_b_sel),
    .idu_o_alu_sel(idu2exu_alu_sel),
    .idu_o_br_sel(idu2exu_br_sel),

    .idu_o_is_store(idu2memu_is_store),
    .idu_o_fmt_sel(idu2memu_fmt_sel),

    .idu_i_rd_data(wbu2idu_rd_data),
    .idu_o_wb_sel(idu2wbu_wb_sel)
  );

  EXU u_exu (
    .clk(clk),
    .rst(rst),
    .exu_i_pc(ifu2exu_pc),
    .exu_i_rs1_data(idu2exu_rs1_data),
    .exu_i_rs2_data(idu2exu_rs2_data),
    .exu_i_imm(idu2exu_imm),
    .exu_i_a_sel(idu2exu_a_sel),
    .exu_i_b_sel(idu2exu_b_sel),
    .exu_i_alu_sel(idu2exu_alu_sel),
    .exu_i_br_sel(idu2exu_br_sel),

    .exu_o_exu_data(exu2memu_data),
    .exu_o_rs2_data(exu2memu_rs2_data),
    .exu_o_branch_taken(exu2ifu_is_branch_taken)
  );

  MEMU u_memu (
    .clk(clk),
    .rst(rst),
    .memu_i_addr(exu2memu_data),
    .memu_i_data(exu2memu_rs2_data),
    .memu_i_is_store(idu2memu_is_store),
    .memu_i_fmt_sel(idu2memu_fmt_sel),
    .memu_o_data(memu2wbu_data),

    .memu_o_daddr(core_o_daddr),
    .memu_o_dwmask(core_o_dwmask),
    .memu_o_dwdata(core_o_dwdata),
    .memu_i_drdata(core_i_drdata)
  );

  WBU u_wbu (
    .clk(clk),
    .rst(rst),
    .wbu_i_pc(ifu2wbu_pc),
    .wbu_i_exu_data(exu2wbu_data),
    .wbu_i_memu_data(memu2wbu_data),
    .wbu_i_wb_sel(idu2wbu_wb_sel),
    .wbu_o_wb_data(wbu2idu_rd_data)
  );

endmodule

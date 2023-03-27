
module MEMU (
  input  clk,
  input  rst,
  input  [31:0] memu_i_addr,
  input  [31:0] memu_i_data,
  input         memu_i_is_store,
  input  [4:0]  memu_i_fmt_sel,
  output [31:0] memu_o_data,

  output [31:0] memu_o_daddr,
  output [3:0]  memu_o_dwmask,
  output [31:0] memu_o_dwdata,
  input  [31:0] memu_i_drdata
);

  assign memu_o_daddr = memu_i_addr;

  assign memu_o_dwmask = memu_i_is_store ? (
      ({4{memu_i_fmt_sel[2]}} & 'b1111)
    | ({4{memu_i_fmt_sel[1] & ((memu_i_addr[1:0] == 'b00) | (memu_i_addr[1:0] == 'b01))}} & 'b0011)
    | ({4{memu_i_fmt_sel[1] & ((memu_i_addr[1:0] == 'b10) | (memu_i_addr[1:0] == 'b11))}} & 'b1100)
    | ({4{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b00)}} & 'b0001)
    | ({4{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b01)}} & 'b0010)
    | ({4{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b10)}} & 'b0100)
    | ({4{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b11)}} & 'b1000)
  ) :
  'b0000;

  assign memu_o_dwdata = (
      ({32{memu_i_fmt_sel[2]}} & memu_i_data)
    | ({32{memu_i_fmt_sel[1] & ((memu_i_addr[1:0] == 'b00) | (memu_i_addr[1:0] == 'b01))}} & memu_i_data)
    | ({32{memu_i_fmt_sel[1] & ((memu_i_addr[1:0] == 'b10) | (memu_i_addr[1:0] == 'b11))}} & (memu_i_data << 16))
    | ({32{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b00)}} & memu_i_data)
    | ({32{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b01)}} & (memu_i_data << 8))
    | ({32{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b10)}} & (memu_i_data << 16))
    | ({32{memu_i_fmt_sel[0] & (memu_i_addr[1:0] == 'b11)}} & (memu_i_data << 24))
  );

  assign memu_o_data = (
      ({32{memu_i_fmt_sel[2]}} & memu_i_drdata)
    | ({32{memu_i_fmt_sel[1] & ~memu_i_fmt_sel[4] & ((memu_i_addr[1:0] == 'b00) | (memu_i_addr[1:0] == 'b01))}} & {{16{memu_i_drdata[15]}}, memu_i_drdata[15:0]})
    | ({32{memu_i_fmt_sel[1] & ~memu_i_fmt_sel[4] & ((memu_i_addr[1:0] == 'b10) | (memu_i_addr[1:0] == 'b11))}} & {{16{memu_i_drdata[31]}}, memu_i_drdata[31:16]})
    | ({32{memu_i_fmt_sel[1] &  memu_i_fmt_sel[4] & ((memu_i_addr[1:0] == 'b00) | (memu_i_addr[1:0] == 'b01))}} & {16'b0, memu_i_drdata[15:0]})
    | ({32{memu_i_fmt_sel[1] &  memu_i_fmt_sel[4] & ((memu_i_addr[1:0] == 'b10) | (memu_i_addr[1:0] == 'b11))}} & {16'b0, memu_i_drdata[31:16]})
    | ({32{memu_i_fmt_sel[0] & ~memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b00)}} & {{24{memu_i_drdata[7]}}, memu_i_drdata[7:0]})
    | ({32{memu_i_fmt_sel[0] & ~memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b01)}} & {{24{memu_i_drdata[15]}}, memu_i_drdata[15:8]})
    | ({32{memu_i_fmt_sel[0] & ~memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b10)}} & {{24{memu_i_drdata[23]}}, memu_i_drdata[23:16]})
    | ({32{memu_i_fmt_sel[0] & ~memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b11)}} & {{24{memu_i_drdata[31]}}, memu_i_drdata[31:24]})
    | ({32{memu_i_fmt_sel[0] &  memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b00)}} & {24'b0, memu_i_drdata[7:0]})
    | ({32{memu_i_fmt_sel[0] &  memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b01)}} & {24'b0, memu_i_drdata[15:8]})
    | ({32{memu_i_fmt_sel[0] &  memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b10)}} & {24'b0, memu_i_drdata[23:16]})
    | ({32{memu_i_fmt_sel[0] &  memu_i_fmt_sel[4] & (memu_i_addr[1:0] == 'b11)}} & {24'b0, memu_i_drdata[31:24]})
  );
  
  
  
endmodule


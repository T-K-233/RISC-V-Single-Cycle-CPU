package bad

import chisel3._
import chisel3.util._

class DataPath extends Module {
  val io = IO(new Bundle {
    val imem_addr = Output(UInt(32.W))
  })

  val pc = RegInit(0.U(32.W))

  val pc_4 = Wire(UInt(32.W))

  pc_4 := pc + 4.U

  pc := pc_4

  io.imem_addr := pc
}
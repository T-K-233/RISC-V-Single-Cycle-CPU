
package bad

import chisel3._
import chisel3.util._

class Core extends Module {
  val io = IO(new Bundle {
    val imem_addr = Output(UInt(32.W))
  })

  // val control_path = Module(new ControlPath())
  val data_path = Module(new DataPath())

  io.imem_addr := data_path.io.imem_addr

}
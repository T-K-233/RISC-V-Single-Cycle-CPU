
package bad

import chisel3._
import chisel3.util._

class Tile extends Module {
  val io = IO(new Bundle {
    val led = Output(UInt(4.W))
  })

  val core = Module(new Core())

  io.led := core.io.imem_addr(3, 0)
}
package bad

import chisel3._
import chisel3.util.Decoupled
import circt.stage.ChiselStage

object Main extends App {
  // generate verilog and save as file
  // ChiselStage.emitSystemVerilogFile(new Arty100TTop())
  ChiselStage.emitSystemVerilogFile(new Tile())
}

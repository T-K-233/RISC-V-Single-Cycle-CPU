package bad

import chisel3._
import chisel3.util._

object UARTRegMap {
  val CR1 = 0x00
  val CR2 = 0x04
  val BRR = 0x08
  val ISR = 0x0A
  val ICR = 0x0C
  val RDR = 0x10
  val TDR = 0x14
  val PRESC = 0x18
}


case class UARTParams(
  address: BigInt,
  dataBits: Int = 8,
  stopBits: Int = 2,
  divisorBits: Int = 16,
  oversample: Int = 4,
  nSamples: Int = 3,
  nTxEntries: Int = 8,
  nRxEntries: Int = 8,
  includeFourWire: Boolean = false,
  includeParity: Boolean = false,
  includeIndependentParity: Boolean = false, // Tx and Rx have opposite parity modes
  initBaudRate: BigInt = BigInt(115200),
) {
  def oversampleFactor = 1 << oversample
  require(divisorBits > oversample)
  require(oversampleFactor > nSamples)
  require((dataBits == 8) || (dataBits == 9))
}


class UART(maxDataBits: Int = 8, divisorBits: Int = 16) extends Module {
  val io = IO(new Bundle {
    /** enable signal of the TX module */
    val en = Input(Bool())
    /** data in from memory bus */
    val in = Flipped(Decoupled(UInt(maxDataBits.W)))

    val div = Input(UInt(divisorBits.W))

    val word_length = Input(UInt(2.W))
    val parity = Input(UInt(2.W))
    val stop_bits = Input(UInt(2.W))
    val msb_first = Input(Bool())

    /** TXD pin to external */
    val out = Output(Bool())
  })

  val tx = Module(new UARTTX(maxDataBits, divisorBits))

  tx.io.en := io.en
  tx.io.in <> io.in
  tx.io.div := io.div
  tx.io.word_length := io.word_length
  tx.io.parity := io.parity
  tx.io.stop_bits := io.stop_bits
  tx.io.msb_first := io.msb_first
  io.out := tx.io.out
}


/**
  * UART
  *
  * @param maxDataBits maximum data bits
  * @param divisorBits divisor bits
  * 
  */
class UARTTX(maxDataBits: Int = 8, divisorBits: Int = 16) extends Module {
  val io = IO(new Bundle {
    /** enable signal of the TX module */
    val en = Input(Bool())
    /** data in from memory bus */
    val in = Flipped(Decoupled(UInt(maxDataBits.W)))

    val div = Input(UInt(divisorBits.W))

    val word_length = Input(UInt(2.W))
    val parity = Input(UInt(2.W))
    val stop_bits = Input(UInt(2.W))
    val msb_first = Input(Bool())

    /** TXD pin to external */
    val out = Output(Bool())
  })

  val stop_bits = 1.U
  val parity = 0.U
  val data_bits = 8.U

  val shifter = Reg(UInt(maxDataBits.W))
  val out = RegInit(1.U(1.W))

  val prescaler = RegInit(0.U(divisorBits.W))
  val counter = RegInit(0.U((log2Ceil((1 + maxDataBits + 1 + 2) + 1)).W))
  val sending_stop = counter === 0.U
  val pulse = prescaler === 0.U
  val busy = !(sending_stop && pulse)

  io.in.ready := !busy
  io.out := out

  when (io.in.fire) {
    // admit new data

    // reload prescaler
    prescaler := io.div

    // load counter and shift register with correct data and format
    counter := data_bits + parity + stop_bits
    shifter := Cat(1.U(1.W), Mux(io.msb_first, io.in.bits, Reverse(io.in.bits)))

    // pre-load TXD with start bit
    out := 0.U
  }

  when (pulse && !sending_stop) {
    // send the next bit
    counter := counter - 1.U
    shifter := Cat(1.U(1.W), shifter >> 1)
    out := shifter(0)
  }

  when (busy) {
    // baudrate generator
    prescaler := Mux(pulse, io.div, prescaler - 1.U)
  }

}

class UARTRX extends Module {
  val io = IO(new Bundle {
    val en = Input(Bool())
    val out = Output(Bool())
  })

  val out = RegInit(1.U(1.W))

  io.out := out
}

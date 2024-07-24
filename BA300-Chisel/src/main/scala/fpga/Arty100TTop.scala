package bad

import chisel3._
import chisel3.util._
import chisel3.experimental.Analog

class Arty100TTop extends RawModule {
  val CLK100MHZ = IO(Input(Clock()))
  val ck_rst = IO(Input(Bool()))

  val uart_rxd_out = IO(Output(Bool()))

  val ja = IO(Analog(8.W))




  val uart = withClockAndReset(CLK100MHZ, !ck_rst){ Module(new UART()) }

  uart.io.en := true.B
  uart.io.in.valid := true.B
  uart.io.in.bits := 0x55.U
  
  uart.io.div := 868.U - 1.U

  uart.io.word_length := 8.U
  uart.io.parity := 0.U
  uart.io.stop_bits := 1.U
  uart.io.msb_first := true.B

  uart_rxd_out := uart.io.out
}

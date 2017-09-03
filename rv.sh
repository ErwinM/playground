#!/bin/sh

set -e

cp ~/code/dme_v3/micro/micro.list .
cp ~/code/dme_v3/micro/micro.list ../PLAY

cp ~/code/dme_v3/validation/A_ram.mif ../PLAY
cp ~/code/dme_v3/validation/A_ram.mif .
cp ~/code/dme_v3/validation/A_simple.hex .
cp ~/code/dme_v3/validation/A.bin ../PLAY

iverilog computer_tb.v decoder.v rom.v mem_io.v ram.v register.v bios.v register_posedge.v controlreg.v cpu.v alu.v computer2.v uart_io_wrap.v t16450.v irq_encoder.v sd_io_wrap.v sdspi.v llsdspi.v

vvp a.out

gtkwave computer.vcd
#!/bin/sh

set -e

cp ~/code/dme_v3/micro/micro.list .
cp ~/code/dme_v3/micro/micro.list ../PLAY

cp ~/code/dme_v3/validation/A_ram.mif ../PLAY
cp ~/code/dme_v3/validation/A_ram.mif .
cp ~/code/dme_v3/validation/A_simple.hex .

iverilog computer_tb.v decoder.v rom.v memory_io.v ram.v register.v bios.v register_posedge.v controlreg.v cpu.v alu.v computer.v t16450.v irq_encoder.v

vvp a.out

gtkwave computer.vcd
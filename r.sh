#!/bin/sh

cp ~/code/dme_v3/micro/micro.list .
cp ~/code/dme_v3/micro/micro.list ../PLAY

cp ~/code/dme_v3/asm/A_ram.mif ../PLAY
cp ~/code/dme_v3/asm/A_ram.mif .
cp ~/code/dme_v3/asm/A_simple.hex ./bios.hex

iverilog computer_tb.v decoder.v rom.v memory_io.v ram.v register.v register_posedge.v regfile3.v cpu.v alu.v computer.v t16450.v irq_encoder.v

vvp a.out

gtkwave computer.vcd
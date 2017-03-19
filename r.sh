#!/bin/sh

cp ~/code/dme_v3/micro/micro.list .
cp ~/code/dme_v3/micro/micro.list ../PLAY

cp ~/code/dme_v3/asm/A_ram.mif ../PLAY
cp ~/code/dme_v3/asm/A.hex ./bios.hex

iverilog computer_tb.v decoder.v rom.v memory_io.v ram.v register.v register_posedge.v regfile2.v cpu.v alu.v computer.v uart_ctrl.v uart.v

vvp a.out

gtkwave computer.vcd
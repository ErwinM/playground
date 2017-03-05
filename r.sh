#!/bin/sh

cp ~/code/dme_v3/micro/micro.list .

iverilog computer_tb.v decoder.v rom.v memory_io.v ram.v register.v register_posedge.v regfile.v cpu.v alu.v computer.v

vvp a.out

gtkwave computer.vcd
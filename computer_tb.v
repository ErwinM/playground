module computer_tb;
  reg clk, reset, uart_rx, irq, fault, cont, bios_e;

computer2 U0 (
  .clock_50_b7a   (clk),
	.reset					(reset),
	.uart_rx				(uart_rx),
	.intr						(irq),
	.trap						(fault),
	.cont						(cont),
	.bios_e					(bios_e)
  );

  initial begin
    clk = 0;
    reset = 1;
		cont = 0;
		bios_e = 0;
		#20
		reset = 0;
		#1000
		irq = 1;
		#20
		irq = 0;
		// uart_rx = 1;
// 		#750
// 		uart_rx = 0;
// 		#160
// 		uart_rx =1;
// 		#160
// 		uart_rx =0;
// 		#160
// 		uart_rx =1;
// 		#160
// 		uart_rx =0;
// 		#320
// 		uart_rx =1;
// 		#320;
// 		uart_rx = 0;
// 		#160
// 		uart_rx =1;
// 		uart_rx = 0;
// 		#3000
// 		uart_rx = 1;



  end

  always
    #5 clk = !clk;


  initial  begin
    $dumpfile ("computer.vcd");
    $dumpvars;
    $dumpvars(0,computer_tb.U0.ram.memory[0]);
    $dumpvars(0,computer_tb.U0.ram.memory[1]);
    $dumpvars(0,computer_tb.U0.ram.memory[2]);
    $dumpvars(0,computer_tb.U0.ram.memory[3]);
    $dumpvars(0,computer_tb.U0.ram.memory[4]);
    $dumpvars(0,computer_tb.U0.ram.memory[5]);
    $dumpvars(0,computer_tb.U0.ram.memory[6]);
    $dumpvars(0,computer_tb.U0.ram.memory[7]);
    $dumpvars(0,computer_tb.U0.ram.memory[8]);
    $dumpvars(0,computer_tb.U0.ram.memory[9]);
    $dumpvars(0,computer_tb.U0.ram.memory[10]);
    $dumpvars(0,computer_tb.U0.ram.memory[11]);
    $dumpvars(0,computer_tb.U0.ram.memory[12]);
    $dumpvars(0,computer_tb.U0.ram.memory[128]);
    $dumpvars(0,computer_tb.U0.ram.memory[129]);
    $dumpvars(0,computer_tb.U0.ram.memory[130]);
    $dumpvars(0,computer_tb.U0.cpu.pagetable[0]);
    $dumpvars(0,computer_tb.U0.cpu.pagetable[1]);
    $dumpvars(0,computer_tb.U0.cpu.pagetable[2]);
    $dumpvars(0,computer_tb.U0.cpu.pagetable[3]);

  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #40000 $finish;

  //Rest of testbench code after this line
		//
	// reset = 0;
	// #750
	// uart_rx = 0;
	// #160
	// uart_rx =1;
	// #160
	// uart_rx =0;
	// #160
	// uart_rx =1;
	// #160
	// uart_rx =0;
	// #320
	// uart_rx =1;
	// #320;
	// uart_rx = 0;
	// #160
	// uart_rx =1;


endmodule
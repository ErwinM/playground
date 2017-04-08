module computer_tb;
  reg clk, reset, uart_rx, irq, fault, cont;

computer U0 (
  .clock_50_b7a   (clk),
	.reset					(reset),
	.uart_rx				(uart_rx),
	.intr						(irq),
	.trap						(fault),
	.cont						(cont)
  );

  initial begin
    clk = 0;
    reset = 1;
		cont = 0;
		#20
		reset = 0;
		irq = 1;
		#20
		irq = 0;
// 		#340
// 		fault = 1;
// 		#20
// 		fault = 0;



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
    $dumpvars(0,computer_tb.U0.ram.memory[128]);
    $dumpvars(0,computer_tb.U0.ram.memory[129]);
    $dumpvars(0,computer_tb.U0.ram.memory[130]);
    $dumpvars(0,computer_tb.U0.ram.memory[230]);
    $dumpvars(0,computer_tb.U0.ram.memory[231]);
    $dumpvars(0,computer_tb.U0.ram.memory[232]);
    $dumpvars(0,computer_tb.U0.ram.memory[233]);
    $dumpvars(0,computer_tb.U0.ram.memory[235]);
    $dumpvars(0,computer_tb.U0.ram.memory[236]);
    $dumpvars(0,computer_tb.U0.ram.memory[237]);
    $dumpvars(0,computer_tb.U0.ram.memory[238]);
    $dumpvars(0,computer_tb.U0.ram.memory[239]);
    $dumpvars(0,computer_tb.U0.ram.memory[240]);
    $dumpvars(0,computer_tb.U0.ram.memory[241]);
    $dumpvars(0,computer_tb.U0.ram.memory[242]);
    $dumpvars(0,computer_tb.U0.ram.memory[243]);
    $dumpvars(0,computer_tb.U0.ram.memory[244]);
    $dumpvars(0,computer_tb.U0.ram.memory[245]);
    $dumpvars(0,computer_tb.U0.ram.memory[246]);

  end

  initial  begin
    $display("\t\ttime,\tclk,\ticycle");
    //$monitor("%d,\t%b,\t%b",$time, clk,reset);
  end

  initial
  #10000 $finish;

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
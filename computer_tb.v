module computer_tb;
  reg clk, reset, uart_rx;

computer U0 (
  .clock_50_b7a   (clk),
	.reset					(reset),
	.uart_rx				(uart_rx)
  );

  initial begin
    clk = 0;
    reset = 1;
		uart_rx = 1;

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
    $dumpvars(0,computer_tb.U0.ram.memory[32]);
    $dumpvars(0,computer_tb.U0.ram.memory[34]);
    $dumpvars(0,computer_tb.U0.ram.memory[36]);

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
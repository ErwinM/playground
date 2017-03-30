// Priority encoder

module irq_encoder(
	reset,
	uart_irq,
	timer_irq,
	page_fault,
	prot_fault,
	trapnr,
	irq,
	deassert,
	fault,
	clk
);

input reset, uart_irq, timer_irq, page_fault, prot_fault, deassert, clk;
output irq, fault;
output [3:0] trapnr;

reg [3:0] trapnr;
reg irq, fault;

// this behavior is too simple, it needs to:
// - buffer other irqs while a higher prio is asserted
// - have a de-assert mechanism
// FIXME: it should save multiple traps in a mask - currently it overwrites

always @(posedge clk)
begin
	if (reset == 1) begin
		trapnr = 0;
		irq = 0;
		fault = 0;
	end else if (prot_fault == 1) begin
		trapnr = 4'b0001;
  end else if (page_fault == 1) begin
   	trapnr = 4'b0010;
  end else if (uart_irq == 1) begin
   	trapnr = 4'b0100;
  end else if (timer_irq == 1) begin
   	trapnr = 4'b1000;
	end

	if (trapnr > 0) begin
		if (trapnr[0] == 1 || trapnr[1] == 1) begin
			fault = 1;
		end else if (trapnr[2] == 1 || trapnr[3] == 1) begin
			irq = 1;
		end
	end
end

always @(negedge clk) begin
	if (deassert == 1) begin
		if (trapnr[3] == 1) begin
			trapnr[3] = 0;
		end else if (trapnr[2] == 1) begin
			trapnr[2] = 0;
		end else if (trapnr[1] == 1) begin
			trapnr[1] = 0;
		end else if (trapnr[0] == 1) begin
			trapnr[0] = 0;
		end
	fault = 0;
	irq = 0;
	end
end

endmodule
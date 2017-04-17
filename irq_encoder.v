// Priority encoder

module irq_encoder(
	reset,
	uart_irq,
	timer_irq,
	disk_irq,
	syscall_irq,
	page_fault,
	prot_fault,
	trapnr,
	irq,
	deassert,
	fault,
	clk
);

input reset, uart_irq, timer_irq, disk_irq, syscall_irq, page_fault, prot_fault, deassert, clk;
output irq, fault;
output [7:0] trapnr;

reg [7:0] trapnr;
reg irq, fault;

// this behavior is too simple, it needs to:
// - buffer other irqs while a higher prio is asserted
// - have a de-assert mechanism

always @(posedge clk)
begin
	if (reset == 1) begin
		trapnr <= 0;
		irq <= 0;
		fault <= 0;
	end else if (prot_fault == 1) begin
		trapnr <= trapnr | 8'b00000001;
  end else if (page_fault == 1) begin
   	trapnr <= trapnr | 8'b00000010;
  end else if (uart_irq == 1) begin
   	trapnr <= trapnr | 8'b00000100;
  end else if (disk_irq == 1) begin
   	trapnr <= trapnr | 8'b00001000;
  end else if (syscall_irq == 1) begin
   	trapnr <= trapnr | 8'b00010000;
  end else if (timer_irq == 1) begin
   	trapnr <= trapnr | 8'b00100000;
	end

	if (deassert == 1) begin
		if (trapnr[0] == 1) begin
			trapnr[0] <= 0;
		end else if (trapnr[1] == 1) begin
			trapnr[1] <= 0;
		end else if (trapnr[2] == 1) begin
			trapnr[2] <= 0;
		end else if (trapnr[3] == 1) begin
			trapnr[3] <= 0;
		end else if (trapnr[4] == 1) begin
			trapnr[4] <= 0;
		end else if (trapnr[5] == 1) begin
			trapnr[5] <= 0;
		end else if (trapnr[6] == 1) begin
			trapnr[6] <= 0;
		end else if (trapnr[7] == 1) begin
			trapnr[7] <= 0;
		end
		fault <= 0;
		irq <= 0;
	end

	if (trapnr > 0) begin
		if (trapnr[0] == 1 || trapnr[1] == 1) begin
			fault <= 1;
		end else begin
			irq <= 1;
		end
	end
end

endmodule
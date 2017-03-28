// Priority encoder

module irq_encoder(
	uart_irq,
	timer_irq,
	page_fault,
	prot_fault,
	irq_nr,
	intr
);

input uart_irq, timer_irq, page_fault, prot_fault;
output intr;
output [2:0] irq_nr;

reg [2:0] irq_nr;
reg intr;

always @*
  begin
    irq_nr = 0;
		intr = 0;

	  if (prot_fault == 1) begin
	    irq_nr = 3'h1;
			intr = 1'b1;
    end else if (page_fault == 1) begin
     	irq_nr = 3'h2;
			intr = 1'b1;
    end else if (uart_irq == 1) begin
     	irq_nr = 3'h3;
			intr = 1'b1;
    end else if (timer_irq == 1) begin
     	irq_nr = 3'h4;
			intr = 1'b1;
		end
 	end

endmodule
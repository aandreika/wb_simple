//------------------------------------------------------
// author:	Andrey Antonov
// email:	andrey.antonov@spbpu.com
//------------------------------------------------------
// Wishbone slave for PicoRV32
// Implements simple 32bit system timer. Generates interrupt.
// To simplify the logic has some features:
// - Timer counts down until it reaches all ones (2^32 - 1)
// - Timer generates IRQ when it's value equals zero
// - Every Wishbone transaction with timer resets IRQ
// - Wishbone write transaction restarts timer with the new value. Writing zero generates IRQ immediately, writing all ones stops timer
// - Wishbone read transaction just resets IRQ, no data read back
//------------------------------------------------------

module wb_timer
(
	input clk, 
    input rst,
	
	// Wishbone signals
	input i_wb_cyc,
	input i_wb_stb,
	input i_wb_we,
	input [31:0] i_wb_data,
	output o_wb_ack,
	
	// Timer interrupt signal
	output reg timer_irq
);
	
	reg [31:0] tmr_cnt;
	
	// Combinatorial acknowledge
	assign o_wb_ack = i_wb_stb;
	
	// All Timer operations in one always block
	always @(posedge clk, posedge rst) begin
        if (rst) begin
            tmr_cnt <= 32'hFFFFFFFF;
			timer_irq <= 1'b0;
		end
        else if (i_wb_stb & i_wb_cyc) begin
			if (i_wb_we)						// Writing new value to a timer 
				tmr_cnt <= i_wb_data;	
            else
                tmr_cnt <= 32'hFFFFFFFF;
			timer_irq <= 1'b0;
		end
		else if (~|tmr_cnt)						// Generating IRQ on all zeros
			timer_irq <= 1'b1;
		else if (~&tmr_cnt)						// Stop counting on all ones
			tmr_cnt <= tmr_cnt - 32'b1;		
	end

endmodule

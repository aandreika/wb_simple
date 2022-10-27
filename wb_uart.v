//------------------------------------------------------
// author:	Andrey Antonov
// email:	andrey.antonov@spbpu.com
//------------------------------------------------------
// Wishbone slave for PicoRV32
// Implements supersimple UART for debug output: TX only, baudrate - 115200, 8 data bits, one stop bit, no parity
//------------------------------------------------------

module wb_uart
(
	input clk, 
    input rst,
	
	// Wishbone signals
	input i_wb_cyc,
	input i_wb_stb,
	input i_wb_we,
	input [7:0] i_wb_data,
	output reg o_wb_ack,
	
	// UART Signals
	output uart_tx

);
	localparam DIV_VAL = 8'd177;
	
	reg [7:0] tx_reg;
	reg [7:0] div_cnt;
	reg uart_clk;
	reg [3:0] bit_cnt;
	
	// UART logic: START_BIT, data bits, STOP_BIT
	assign uart_tx = ((bit_cnt == 4'd9) | ~i_wb_stb) ? 1'b1 : ~|bit_cnt ? 1'b0 : tx_reg[bit_cnt - 4'b1];
	
	// Data clock division counter
	always @(posedge clk, posedge rst) begin
		if (rst)
			div_cnt <= 8'b0;
		else if (~i_wb_stb | (div_cnt == DIV_VAL))
			div_cnt <= 8'b0;
		else
			div_cnt <= div_cnt + 8'b1;
	end
	
	// Bit counter
	always @(posedge clk, posedge rst) begin
		if (rst)
			bit_cnt <= 4'b0;
		else if (~i_wb_stb)
			bit_cnt <= 4'b0;
		else if ((div_cnt == DIV_VAL) & (bit_cnt != 4'd9)) 
			bit_cnt <= bit_cnt + 4'b1;
	end
	
	// Generating Wishbone acknowledge when symbol is sent
	always @(posedge clk, posedge rst) begin
		if (rst)
			o_wb_ack <= 1'b0;
		else if ((div_cnt == DIV_VAL) & (bit_cnt == 4'd9))
			o_wb_ack <= 1'b1;
		else
			o_wb_ack <= 1'b0;
	end

	// Writing Wishbone data to TX register
	always @(posedge clk, posedge rst) begin
        if (rst)
            tx_reg <= 8'b0;
        else if (i_wb_stb & i_wb_cyc & i_wb_we)
            tx_reg <= i_wb_data;
	end
	
endmodule
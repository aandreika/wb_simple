# wb_simple
Super simple Wishbone slaves. Minimal functionality, optimized for area.
- wb_uart -- simple 8-N-1 TX-only UART. Baudrate is derivative of system clock frequency and division factor. Division factor (localparam DIV_VAL) should be calculated by user: DIV_VAL = Fclk / (desired baudrate). It was developed for debugging purposes in PicoRV32 processor. It has no FIFO abd it holds WB bus (no o_wb_ack) until UART transaction is compleded (byte it TX register is sent). Uses 33 LUT4 and 21 FF-regs (Gowin GW1N-UV9QN88C6/I5)
- wb_timer -- simple 32-bit timer with reduced functionality. Generates counts from loaded value down to zero and generates IRQ. It was developed for generating delays in PicoRV32 processor. Uses 99 LUT4 and 33 FF-regs (Gowin GW1N-UV9QN88C6/I5)

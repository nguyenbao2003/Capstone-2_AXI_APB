`timescale 1ps / 1ps

module testbench;

   logic i_clk;             // System clock
   logic i_rst;         // Active low reset
	
	/* OUTPUT */
   logic [4:0]  o_apb_paddr_reg;
	logic [31:0] o_apb_pwdata_reg;
	logic [1:0]  o_apb_sel_reg;
	logic [1:0]  o_apb_control_reg;
//	logic						uart_rx;         // UART received data
	
	/* OUTPUT */
	logic		[31:0]  apb_rdata;       // APB read data
	logic            connect;
	logic					apb_ready;       // APB ready signal
	logic		[7:0] uart_data_out;
	logic		[1:0] uart_baud_rate;
	logic		[1:0] uart_parity_type;
	logic		uart_send;
	logic		apb_psel1;

	logic					apb_error;       // APB error signal
	logic					uart_tx_active;  // UART Tx active flag
	logic					uart_tx_done;    // UART Tx done flag
	logic					uart_rx_active;  // UART Rx active flag
	logic					uart_rx_done;    // UART Rx done flag
	logic             baud_clk_w;
	logic    [7:0]    uart_data_in;
//	logic					uart_tx;         // UART Tx data
	
	logic		apb_pwrite_out;
	logic		apb_penable_out;
	logic		[4:0] apb_paddr_out;
	logic		[31:0] apb_pwdata_out;
	
	logic		apb_psel2;
	
	logic		[2:0]   uart_error;       // UART error flags
	
	top dut(
	.i_clk(i_clk),
	.i_rst(i_rst),
	
	.o_apb_paddr_reg(o_apb_paddr_reg),
	.o_apb_pwdata_reg(o_apb_pwdata_reg),
	.o_apb_sel_reg(o_apb_sel_reg),
	.o_apb_control_reg(o_apb_control_reg),
	/* OUTPUT */
	.apb_rdata(apb_rdata),
	.apb_ready(apb_ready),
	.apb_error(apb_error),
	.uart_tx_active(uart_tx_active),
	.uart_tx_done(uart_tx_done),
	.uart_rx_active(uart_rx_active),
	.uart_rx_done(uart_rx_done),
	.uart_data_out(uart_data_out),
	.apb_pwrite_out(apb_pwrite_out),
	.apb_penable_out(apb_penable_out),
	.apb_paddr_out(apb_paddr_out),
	.apb_pwdata_out(apb_pwdata_out),
	.apb_psel1(apb_psel1),
	.apb_psel2(apb_psel2),
	.uart_send(uart_send),
	.uart_baud_rate(uart_baud_rate),
	.uart_parity_type(uart_parity_type),
	.uart_error(uart_error),
	.connect(connect),
	.uart_data_in(uart_data_in),
	.baud_clk_w(baud_clk_w)
	);
	
	
// Clock Generation
	initial begin
		i_clk = 0;
		forever #5 i_clk = ~i_clk;  // 0.5 ns period
	end
	
	initial begin
	  i_rst = 0;
	  @(posedge i_clk);
	  i_rst = 1;
	  	
	  
	  #900000;
		$stop;
	end
	
endmodule
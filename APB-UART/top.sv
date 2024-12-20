module top(
  input  logic         i_clk,
  input  logic         i_rst,
  
  output logic [4:0]  o_apb_paddr_reg,
  output logic [31:0] o_apb_pwdata_reg,
  output logic [1:0]  o_apb_sel_reg,
  output logic [1:0]  o_apb_control_reg,
  
  // APB_UART_TOP
  output logic [31:0]  apb_rdata,       // APB read data
  output logic         apb_ready,       // APB ready signal
  output logic         apb_error,       // APB error signal
  output logic         uart_tx_active,  // UART Tx active flag
  output logic         uart_tx_done,    // UART Tx done flag
  output logic         uart_rx_active,  // UART Rx active flag
  output logic         uart_rx_done,    // UART Rx done flag
//    output logic		   uart_tx,         // UART Tx data
  output logic [7:0] uart_data_out,
  output logic apb_pwrite_out,
  output logic apb_penable_out,
  output logic [4:0] apb_paddr_out,
  output logic [31:0] apb_pwdata_out,
  output logic apb_psel1,
  output logic apb_psel2,
  output logic uart_send, baud_clk_w,
  output logic [1:0] uart_baud_rate,
  output logic [1:0] uart_parity_type,
  output logic [2:0]   uart_error,       // UART error flags
  output logic [7:0] uart_data_in,
  output logic connect
);

  main dut1(
    .i_clk(i_clk),
	 .i_rst(i_rst),
	 .o_apb_paddr_reg(o_apb_paddr_reg),
	 .o_apb_pwdata_reg(o_apb_pwdata_reg),
	 .o_apb_sel_reg(o_apb_sel_reg),
	 .o_apb_control_reg(o_apb_control_reg)
  );
  
  APB_UART_Top dut2(
    .clk(i_clk),
	 .reset_n(i_rst),
	 .apb_en(o_apb_control_reg[0]),
	 .apb_sel(o_apb_sel_reg),
	 .apb_addr(o_apb_paddr_reg),
	 .apb_write(o_apb_control_reg[1]),
	 .apb_wdata(o_apb_pwdata_reg),
	 
	 .apb_rdata(apb_rdata),
	 .apb_ready(apb_ready),
	 .apb_error(apb_error),
	 .uart_tx_active(uart_tx_active),
	 .uart_rx_done(uart_rx_done),
	 .uart_data_out(uart_data_out),
	 .apb_pwrite_out(apb_pwrite_out),
	 .apb_penable_out(apb_penable_out),
	 .apb_paddr_out(apb_paddr_out),
	 .apb_pwdata_out(apb_pwdata_out),
	 .apb_psel1(apb_psel1),
	 .apb_psel2(apb_psel2),
	 .uart_send(uart_send),
	 .baud_clk_w(baud_clk_w),
	 .uart_baud_rate(uart_baud_rate),
	 .uart_parity_type(uart_parity_type),
	 .uart_error(uart_error),
	 .uart_data_in(uart_data_in),
	 .connect(connect)
  );
endmodule
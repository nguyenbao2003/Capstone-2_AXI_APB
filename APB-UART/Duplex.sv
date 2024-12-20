module Duplex (
    input  wire         reset_n,        // Active low reset
    input  wire         send,           // Enable to start sending data
    input  wire         clock,          // The main system's clock
    input  wire  [1:0]  parity_type,    // Parity type agreed upon by the Tx and Rx units
    input  wire  [1:0]  baud_rate,      // Baud rate agreed upon by the Tx and Rx units
    input  wire  [7:0]  data_in,        // Data input to be sent
	 input wire  			  RX,

    output wire         tx_active_flag, // Logic 1 when Tx is in progress
    output wire         tx_done_flag,   // Logic 1 when transmission is done
    output wire         rx_active_flag, // Logic 1 when Rx is in progress
    output wire         rx_done_flag,   // Logic 1 when data is received
    output wire  			 TX,       // 8-bit data output from the FIFO 
	 output wire  [7:0]  data_out, 
//	 output wire 	connect,
	 output  wire [7:0]  fifo_tx_data_out,       // Data output from Tx FIFO to Tx unit
    output wire  [2:0]  error_flag,      // Error flags: Parity, Start, Stop errors
	 output wire        baud_clk_w, tx_fifo_empty, tx_fifo_full // Tx FIFO status flags
);

    // Internal wires
    wire        data_tx_w;              // Serial transmitter's data out
   
    wire [7:0]  fifo_rx_data_in;        // Data input to Rx FIFO from Rx unit

    wire        rx_fifo_empty, rx_fifo_full; // Rx FIFO status flags

    // Transmitter FIFO
    FIFO_Buffer tx_fifo (
        .i_clk(clock),
        .i_reset_n(reset_n),
        .i_data_in(data_in),            // Data input from external source
        .i_write_en(send && !tx_fifo_full), // Write enable controlled by send and FIFO full flag
        .i_read_en(!tx_fifo_empty && tx_done_flag), // Read when FIFO not empty and Tx unit is ready
        .o_data_out(fifo_tx_data_out), // Data output to Tx unit
        .o_empty(tx_fifo_empty),
        .o_full(tx_fifo_full)
    );

    // Receiver FIFO
    FIFO_Buffer rx_fifo (
        .i_clk(clock),
        .i_reset_n(reset_n),
        .i_data_in(fifo_rx_data_in),    // Data input from Rx unit
        .i_write_en(rx_done_flag && !rx_fifo_full), // Write on Rx done and FIFO not full
        .i_read_en(!rx_fifo_empty),     // Read when FIFO is not empty
        .o_data_out(data_out),          // Data output to external consumer
        .o_empty(rx_fifo_empty),
        .o_full(rx_fifo_full)
    );

    // Transmitter unit instance
    TxUnit Transmitter (
        .reset_n(reset_n),
        .send(!tx_fifo_empty),          // Send data only when FIFO has data
        .clock(clock),
        .parity_type(parity_type),
        .baud_rate(baud_rate),
        .data_in(fifo_tx_data_out),     // Data input from Tx FIFO
        .data_tx(TX),            // Serial output
        .active_flag(tx_active_flag),
		  .baud_clk_w(baud_clk_w),
        .done_flag(tx_done_flag)
    );

    // Receiver unit instance
    RxUnit Receiver (
        .reset_n(reset_n),
        .clock(clock),
        .parity_type(parity_type),
        .baud_rate(baud_rate),
        .data_tx(RX),            // Serial data from Tx unit
        .data_out(fifo_rx_data_in),     // Data output to Rx FIFO
        .error_flag(error_flag),
        .active_flag(rx_active_flag),
        .done_flag(rx_done_flag)
    );

endmodule

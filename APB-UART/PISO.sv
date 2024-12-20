//module PISO(
//    input logic         reset_n,         // Active low reset
//    input logic         send,            // Enable to start sending data
//    input logic         baud_clk,        // Clocking signal from the BaudGen unit
//    input logic         parity_bit,      // The parity bit from the Parity unit
//    input logic [1:0]   parity_type,     // Parity type agreed upon by the Tx and Rx units
//    input logic [7:0]   data_in,         // The data input
//
//    output logic        data_tx,         // Serial transmitter's data out
//    output logic        active_flag,     // High when Tx is transmitting, low when idle
//    output logic        done_flag        // High when transmission is done, low when active
//);
//
//    // Internal declarations
//    logic [3:0]   stop_count;  // Counter for stop bits
//    logic [10:0]  frame;       // Frame: {stop bit, parity bit, data, start bit}
//    logic [10:0]  frame_r;     // Shift register for frame transmission
//    logic [7:0]   reg_data;    // Holds the data until transmission is done
//    logic         next_state;  // FSM next state
//
//    // Encoding the states
//    typedef enum logic {
//        IDLE   = 1'b0,
//        ACTIVE = 1'b1
//    } state_t;
//
//    state_t current_state;
//
//    // Set the data and hold it in reset and IDLE state
//    always_ff @(negedge next_state or negedge reset_n) begin
//        if (!reset_n) begin
//            reg_data <= 8'd0;
//        end else if (!next_state) begin
//            reg_data <= data_in;
//        end
//    end
//
//    // Frame generation combinational logic
//    always_comb begin
//        if ((~|parity_type) || (&parity_type)) begin
//            // Frame with no parity bit
//            frame = {2'b11, reg_data, 1'b0};
//        end else begin
//            // Frame with parity bit
//            frame = {1'b1, parity_bit, reg_data, 1'b0};
//        end
//    end
//
//    // Transmission logic FSM with asynchronous reset
//    always_ff @(posedge baud_clk or negedge reset_n) begin
//        if (!reset_n) begin
//            current_state <= IDLE;
//            stop_count    <= 4'd0;
//            data_tx       <= 1'b1;
//            active_flag   <= 1'b0;
//            done_flag     <= 1'b1;
//        end else begin
//            frame_r <= frame;
//            case (current_state)
//                IDLE: begin
//                    data_tx      <= 1'b1;
//                    active_flag  <= 1'b0;
//                    done_flag    <= 1'b1;
//                    stop_count   <= 4'd0;
//
//                    if (send) begin
//                        current_state <= ACTIVE;
//                    end else begin
//                        current_state <= IDLE;
//                    end
//                end
//                ACTIVE: begin
//                    if (stop_count == 4'd11) begin
//                        data_tx      <= 1'b1;
//                        stop_count   <= 4'd0;
//                        active_flag  <= 1'b0;
//                        done_flag    <= 1'b1;
//                        current_state <= IDLE;
//                    end else begin
//                        data_tx      <= frame_r[0];
//                        frame_r      <= frame_r >> 1;
//                        stop_count   <= stop_count + 1;
//                        active_flag  <= 1'b1;
//                        done_flag    <= 1'b0;
//                        current_state <= ACTIVE;
//                    end
//                end
//                default: current_state <= IDLE;
//            endcase
//        end
//    end
//
//endmodule

module PISO(
    input  logic         reset_n,            //  Active low reset.
    input  logic         send,               //  An enable to start sending data.
    input  logic         baud_clk,           //  Clocking signal from the BaudGen unit.
    input  logic         parity_bit,         //  The parity bit from the Parity unit.
	 input  logic 			 parity_type,
    input  logic [7:0]   data_in,            //  The data input.

    output logic         data_tx,            //  Serial transmitter's data out
    output logic         active_flag,        //  High when Tx is transmitting, low when idle.
	 output logic [3:0]   stop_count,
    output logic [10:0]  frame_r,
    output logic [10:0]  frame_man,
    output logic         next_state,
    output logic         count_full,
    output logic         done_flag           //  High when transmission is done, low when active.
);

    // Internal declarations


    // Encoding the states
    typedef enum logic {
        IDLE   = 1'b0,
        ACTIVE = 1'b1
    } state_t;

    // Frame generation
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            frame_r <= {11{1'b1}};
        else if (next_state)
            frame_r <= frame_r;
        else
            frame_r <= {1'b1, parity_bit, data_in, 1'b0};
    end

    // Counter logic
    always_ff @(posedge baud_clk) begin
        if ((!reset_n) || (!next_state) || count_full)
            stop_count <= 4'd0;
        else
            stop_count <= stop_count + 4'd1;
    end

    assign count_full = (stop_count == 4'd11);

    // Transmission logic FSM
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n)
            next_state <= 1'b0;
        else begin
            case (next_state)
                1'b0: begin
                    if (send) begin
                        next_state <= 1'b1;
//								active_flag<= 1'b1;
//								done_flag  <= 1'b0;
                    end else
                        next_state <= 1'b0;
                end
                1'b1: begin
                    if (count_full) begin
                        next_state <= 1'b0;
//								active_flag <= 1'b0;
//								done_flag  <= 1'b1;
                    end else
                        next_state <= 1'b1;
                end
            endcase
        end
    end

    always_comb begin
        if (reset_n && next_state && (stop_count != 4'd0)) begin
            data_tx      = frame_man[0];
            frame_man    = frame_man >> 1;
            active_flag  = 1'b1;
            done_flag    = 1'b0;
        end
        else begin
            data_tx      = 1'b1;
            frame_man    = frame_r;
            active_flag  = 1'b0;
            done_flag    = 1'b1;
        end
    end

endmodule


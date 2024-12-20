//module SIPO(
//    input logic         reset_n,         // Active low reset
//    input logic         data_tx,         // Serial data received from the transmitter
//    input logic         baud_clk,        // Clocking input comes from the sampling unit
//
//    output logic        active_flag,     // Outputs logic 1 when data is in progress
//    output logic        recieved_flag,   // Outputs a signal enabling the deframe unit
//    output logic [10:0] data_parll       // Outputs the 11-bit parallel frame
//);
//
//    // Internal declarations
//    logic [3:0] frame_counter;
//    logic [3:0] stop_count;
//    typedef enum logic [1:0] {
//        IDLE   = 2'b00,
//        CENTER = 2'b01,
//        FRAME  = 2'b10,
//        HOLD   = 2'b11
//    } state_t;
//
//    state_t next_state;
//
//    // FSM with asynchronous reset logic
//    always_ff @(posedge baud_clk or negedge reset_n) begin
//        if (!reset_n) begin
//            next_state    <= IDLE;
//            data_parll    <= 11'b11111111111;
//            stop_count    <= 4'd0;
//            frame_counter <= 4'd0;
//            recieved_flag <= 1'b0;
//            active_flag   <= 1'b0;
//        end else begin
//            case (next_state)
//                IDLE: begin
//                    data_parll    <= 11'b11111111111;
//                    stop_count    <= 4'd0;
//                    frame_counter <= 4'd0;
//                    recieved_flag <= 1'b0;
//                    active_flag   <= 1'b0;
//                    if (!data_tx) begin
//                        next_state  <= CENTER;
//                        active_flag <= 1'b1;
//                    end else begin
//                        next_state  <= IDLE;
//                        active_flag <= 1'b0;
//                    end
//                end
//
//                CENTER: begin
//                    if (stop_count == 4'd7) begin
//                        data_parll[0] <= data_tx;
//                        stop_count    <= 4'd0;
//                        next_state    <= FRAME;
//                    end else begin
//                        stop_count <= stop_count + 4'd1;
//                        next_state <= CENTER;
//                    end
//                end
//
//                FRAME: begin
//                    if (frame_counter == 4'd10) begin
//                        frame_counter <= 4'd0;
//                        recieved_flag <= 1'b1;
//                        next_state    <= HOLD;
//                        active_flag   <= 1'b0;
//                    end else begin
//                        if (stop_count == 4'd15) begin
//                            data_parll[frame_counter + 1] <= data_tx;
//                            frame_counter                <= frame_counter + 4'd1;
//                            stop_count                   <= 4'd0;
//                            next_state                   <= FRAME;
//                        end else begin
//                            stop_count <= stop_count + 4'd1;
//                            next_state <= FRAME;
//                        end
//                    end
//                end
//
//                HOLD: begin
//                    if (stop_count == 4'd15) begin
//                        stop_count    <= 4'd0;
//                        recieved_flag <= 1'b0;
//                        next_state    <= IDLE;
//                    end else begin
//                        stop_count <= stop_count + 4'd1;
//                        next_state <= HOLD;
//                    end
//                end
//
//                default: next_state <= IDLE;
//            endcase
//        end
//    end
//
//endmodule
module SIPO(
    input  logic        reset_n,        //  Active low reset.
    input  logic        data_tx,        //  Serial Data received from the transmitter.
    input  logic        baud_clk,       //  The clocking input comes from the sampling unit.

    output logic        active_flag,    //  Outputs logic 1 when data is in progress.
    output logic        recieved_flag,  //  Outputs a signal enabling the deframe unit. 
    output logic [10:0] data_parll       //  Outputs the 11-bit parallel frame.
);

    // Internal declarations
    logic [10:0] temp, data_parll_temp;
    logic [3:0]  frame_counter, stop_count;
    logic [1:0]  next_state;

    // Encoding the states of the receiver
 
localparam IDLE   = 2'b00,
           CENTER = 2'b01,
           FRAME  = 2'b11,
           GET    = 2'b10;


    // Receiving logic FSM
    always_ff @(posedge baud_clk or negedge reset_n) begin
        if (!reset_n) begin
            next_state    <= IDLE;
            stop_count    <= 4'd0;
            frame_counter <= 4'd0;
            temp          <= {11{1'b1}};
        end else begin
            case (next_state)
                IDLE: begin
                    temp          <= {11{1'b1}};
                    stop_count    <= 4'd0;
                    frame_counter <= 4'd0;
                    if (!data_tx) begin
                        next_state <= CENTER;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                CENTER: begin
                    if (stop_count == 4'd6) begin
                        stop_count  <= 4'd0;
                        next_state  <= GET;
                    end else begin
                        stop_count  <= stop_count + 4'd1;
                        next_state  <= CENTER;
                    end
                end

                FRAME: begin
                    temp <= data_parll_temp;
                    if (frame_counter == 4'd10) begin
                        frame_counter <= 4'd0;
                        next_state    <= IDLE;
                    end else begin
                        if (stop_count == 4'd14) begin
                            frame_counter <= frame_counter + 4'd1;
                            stop_count    <= 4'd0; 
                            next_state    <= GET;
                        end else begin
                            stop_count    <= stop_count + 4'd1;
                            next_state    <= FRAME;
                        end
                    end
                end

                GET: begin 
                    next_state <= FRAME;
                    temp       <= data_parll_temp;
                end
            endcase
        end
    end

    always_comb begin
        case (next_state)
            IDLE, CENTER, FRAME: data_parll_temp = temp;

            GET: begin
                data_parll_temp     = temp >> 1;
                data_parll_temp[10] = data_tx;
            end
        endcase
    end

    assign data_parll    = recieved_flag ? data_parll_temp : {11{1'b1}};
    assign recieved_flag = (frame_counter == 4'd10);
    assign active_flag   = !recieved_flag;

endmodule


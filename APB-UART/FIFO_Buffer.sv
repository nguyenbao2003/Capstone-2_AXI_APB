//module FIFO_Buffer (
//    input logic        i_clk,        // Clock signal
//    input logic        i_reset_n,    // Active low reset
//    input logic [7:0]  i_data_in,    // Data to be written into the FIFO
//    input logic        i_read_en,    // Read enable signal
//    input logic        i_write_en,   // Write enable signal
//
//    output logic [7:0] o_data_out,   // Data read from the FIFO
//    output logic       o_empty,      // FIFO empty flag
//    output logic       o_full        // FIFO full flag
//);
//
//    // Internal registers
//    logic [3:0] counter = 0;               // Count of elements in FIFO
//    logic [7:0] fifo_mem [0:7];             // FIFO memory array
//    logic [2:0] read_ptr = 0, write_ptr = 0; // Read and write pointers
//
//    // Assign flags based on counter
//    assign o_empty = (counter == 0);       // Empty when no data in FIFO
//    assign o_full  = (counter == 8);       // Full when FIFO is at max capacity
//
//    // FIFO logic
//    always_ff @(posedge i_clk or negedge i_reset_n) begin
//        if (!i_reset_n) begin
//            // Reset FIFO
//            read_ptr  <= 0;
//            write_ptr <= 0;
//            counter   <= 0;
//        end else begin
//            // Read operation
//            if (i_read_en && counter != 0) begin
//                o_data_out <= fifo_mem[read_ptr]; // Output data from the read pointer
//                read_ptr   <= (read_ptr + 1) % 8; // Increment and wrap read pointer
//                counter    <= counter - 1;       // Decrement counter
//            end
//
//            // Write operation
//            if (i_write_en && counter < 8)
//                fifo_mem[write_ptr] <= i_data_in; // Store input data at the write pointer
//                write_ptr           <= (write_ptr + 1) % 8; // Increment and wrap write pointer
//                counter             <= counter + 1;         // Increment counter
//            end
//        end
//
//endmodule
module FIFO_Buffer #( 
  parameter DATA_SIZE   = 8,
            SIZE_FIFO   = 8,
            ADDR_WIDTH  = $clog2(SIZE_FIFO)
  )  (
  input                             i_clk, i_reset_n,
  input  [DATA_SIZE - 1 : 0]        i_data_in,
  input                             i_write_en,
  input                             i_read_en,
  output  [DATA_SIZE - 1 : 0]       o_data_out,
  output wire                       o_full,
  output wire                       o_empty     
);

// Signal Declaration
// * Datapath Registers
logic [DATA_SIZE - 1 : 0]   fifo_mem [SIZE_FIFO - 1 : 0];
logic [ADDR_WIDTH -1:0] write_ptr, write_ptr_next, write_ptr_succ;
logic [ADDR_WIDTH -1:0] read_ptr, read_ptr_next, read_ptr_succ;
logic full_reg, full_next;
logic empty_reg, empty_next;

logic write_enable;

// Registers
always @(posedge i_clk or negedge i_reset_n) begin
  if (~i_reset_n) begin
    write_ptr <= 0;
    read_ptr <= 0;
    full_reg <= 0;
    empty_reg <= 1;
  end
  else begin
    if (write_enable) fifo_mem[write_ptr] <= i_data_in;
    write_ptr <= write_ptr_next;
    read_ptr <= read_ptr_next;
    full_reg <= full_next;
    empty_reg <= empty_next;
  end  
end

// Output Logic
assign write_enable = i_write_en & ~full_reg; // Control output logic

assign o_full = full_reg;
assign o_empty = empty_reg;
assign o_data_out = fifo_mem[read_ptr];

// Next-state logic for {i_write_en, i_read_en}
always @(*) begin
  //successive pointer values
  write_ptr_succ = write_ptr + 1'b1;
  read_ptr_succ = read_ptr + 1'b1;
  // default values
  write_ptr_next = write_ptr;
  read_ptr_next = read_ptr;
  full_next = full_reg;
  empty_next = empty_reg;
  case ({i_write_en, i_read_en}) 
    // Skip 2'b00 for no operation is done
    2'b01: begin //read
      if (~empty_reg) begin
        read_ptr_next = read_ptr_succ;
        full_next = 0;
        if (read_ptr_succ == write_ptr) empty_next = 1;
      end
    end
    2'b10: begin //write
      if (~full_reg) begin
        write_ptr_next = write_ptr_succ;
        empty_next = 0;
        if (write_ptr_succ == read_ptr) full_next = 1;
      end
    end
    2'b11: begin //read and write
      write_ptr_next = write_ptr_succ;
      read_ptr_next = read_ptr_succ;
    end
  endcase
end
endmodule

// Asynchronous FIFO 
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
) (
    // Write Interface 
    input  logic                  w_clk,
    input  logic                  w_rst_n,
    input  logic                  w_en,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic                  w_full,
    // Read Interface 
    input  logic                  r_clk,
    input  logic                  r_rst_n,
    input  logic                  r_en,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic                  r_empty
);
    // Address width calculation (log2(16) = 4)
    localparam PTR_WIDTH = $clog2(DEPTH); 
    // Pointer (Width + 1 bit for wrap-around)
    logic [PTR_WIDTH:0] w_ptr_bin, w_ptr_gray;
    logic [PTR_WIDTH:0] w_ptr_gray_synced, w_ptr_bin_synced;
    logic [PTR_WIDTH:0] r_ptr_bin, r_ptr_gray;
    logic [PTR_WIDTH:0] r_ptr_gray_synced, r_ptr_bin_synced;

    // 1. --Write Logic--
    logic [PTR_WIDTH:0] w_ptr_next; 
    assign w_ptr_next = w_ptr_bin + (w_en & !w_full);
    // Binary Pointer Update
    always_ff @(posedge w_clk or negedge w_rst_n) begin
        if (!w_rst_n) w_ptr_bin <= 0;
        else          w_ptr_bin <= w_ptr_next;
    end
    // Binary to Gray Conversion
    bin2gray #(.WIDTH(PTR_WIDTH+1)) u_w_p2g (
        .bin_in   (w_ptr_next), 
        .gray_out (w_ptr_gray)
    );

    // 2.--Read Logic--
    logic [PTR_WIDTH:0] r_ptr_next;
    assign r_ptr_next = r_ptr_bin + (r_en & !r_empty);
    // Binary Pointer Update
    always_ff @(posedge r_clk or negedge r_rst_n) begin
        if (!r_rst_n) r_ptr_bin <= 0;
        else          r_ptr_bin <= r_ptr_next;
    end
    // Binary to Gray Conversion
    bin2gray #(.WIDTH(PTR_WIDTH+1)) u_r_p2g (
        .bin_in   (r_ptr_next),
        .gray_out (r_ptr_gray)
    );

    // 3.--CDC Synchronizers--  
    // Sync Read Pointer to Write Domain
    ptr_sync #(.WIDTH(PTR_WIDTH+1)) u_sync_r2w (
        .clk     (w_clk),
        .rst_n   (w_rst_n),
        .ptr_in  (r_ptr_gray), 
        .ptr_out (r_ptr_gray_synced)
    );
    // Sync Write Pointer to Read Domain
    ptr_sync #(.WIDTH(PTR_WIDTH+1)) u_sync_w2r (
        .clk     (r_clk),
        .rst_n   (r_rst_n),
        .ptr_in  (w_ptr_gray),
        .ptr_out (w_ptr_gray_synced)
    );
    
    // 4.--Gray to Binary-- 
    gray2bin #(.WIDTH(PTR_WIDTH+1)) u_g2b_write (
        .gray_in (r_ptr_gray_synced),
        .bin_out (r_ptr_bin_synced)
    );
    gray2bin #(.WIDTH(PTR_WIDTH+1)) u_g2b_read (
        .gray_in (w_ptr_gray_synced),
        .bin_out (w_ptr_bin_synced)
    );
    
    // 5.--Memory Instantiation--
    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH) 
    ) u_mem (
        .w_clk  (w_clk),
        .w_en   (w_en & !w_full), 
        .w_addr (w_ptr_bin[PTR_WIDTH-1:0]), // Use LSBs for addressing
        .w_data (w_data),
        
        .r_addr (r_ptr_bin[PTR_WIDTH-1:0]), // Use LSBs for addressing
        .r_data (r_data)
    );
    
    // 6.--Flag Generation Logic--
    // Empty Condition: Pointers are identical 
    assign r_empty = (r_ptr_bin == w_ptr_bin_synced);
    // Full Condition: MSB is different (wrapped), LSBs are identical
    assign w_full = (w_ptr_bin[PTR_WIDTH-1:0] == r_ptr_bin_synced[PTR_WIDTH-1:0]) && 
                    (w_ptr_bin[PTR_WIDTH]     != r_ptr_bin_synced[PTR_WIDTH]);
endmodule

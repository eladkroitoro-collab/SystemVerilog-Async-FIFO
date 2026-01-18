// Dual Port RAM
// simultaneous read/write 
module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter PTR_WIDTH  = 4
) (
    //Port A: Write Interface 
    input  logic                  w_clk,
    input  logic                  w_en,
    input  logic [PTR_WIDTH-1:0]  w_addr,
    input  logic [DATA_WIDTH-1:0] w_data, 
    //Port B: Read Interface
    input  logic [PTR_WIDTH-1:0]  r_addr,
    output logic [DATA_WIDTH-1:0] r_data
);
    // Memory Array 
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // Synch Write Process
    always_ff @(posedge w_clk) begin
        if (w_en) begin
            mem[w_addr] <= w_data;
        end
    end 
    // Asynchronous Read Process 
    assign r_data = mem[r_addr];
endmodule

// Module 4: 2-Stage Synchronizer
// Mitigates metastability when transferring signals between clock
module ptr_sync #(parameter WIDTH = 5)
(
    input  logic             clk,      // Destination Clock
    input  logic             rst_n,    // Active Low Reset
    input  logic [WIDTH-1:0] ptr_in,   // Asynchronous Input
    output logic [WIDTH-1:0] ptr_out   // Synchronized Output
);
    logic [WIDTH-1:0] q1; // Intermediate Flip-Flop

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1      <= '0;
            ptr_out <= '0;
        end else begin
            // 2-Stage Shift Register
            q1      <= ptr_in; 
            ptr_out <= q1;
        end
    end
endmodule
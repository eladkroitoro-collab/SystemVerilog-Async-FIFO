// Gray to Binary Converter
// Converts Gray code back to binary for pointer
module gray2bin #(parameter WIDTH = 5)
(
    input  logic [WIDTH-1:0] gray_in,
    output logic [WIDTH-1:0] bin_out
);
    always_comb begin
        // The MSB is always identical in both representations
        bin_out[WIDTH-1] = gray_in[WIDTH-1];  
        // Iterate from MSB-1 down to LSB using XOR chain
        for (int i = WIDTH-2; i >= 0; i--) begin
            bin_out[i] = gray_in[i] ^ bin_out[i+1];
        end
    end
endmodule

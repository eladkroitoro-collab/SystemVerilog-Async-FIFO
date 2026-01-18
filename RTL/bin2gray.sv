// Binary to Gray Converter
// Converts a binary value to Gray code to minimize bit transitions
module bin2gray #(parameter WIDTH = 5) 
(
    input  logic [WIDTH-1:0] bin_in,
    output logic [WIDTH-1:0] gray_out
);
    assign gray_out = (bin_in >> 1) ^ bin_in;
endmodule

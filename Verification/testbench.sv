`timescale 1ns/1ps
module tb_async_fifo;
    // Parameters 
    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    // DUT Signals
    logic w_clk, w_rst_n, w_en;
    logic [DATA_WIDTH-1:0] w_data;
    logic r_clk, r_rst_n, r_en;
    logic [DATA_WIDTH-1:0] r_data;
    logic w_full, r_empty;
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .w_clk(w_clk), .w_rst_n(w_rst_n), .w_en(w_en), .w_data(w_data), .w_full(w_full),
        .r_clk(r_clk), .r_rst_n(r_rst_n), .r_en(r_en), .r_data(r_data), .r_empty(r_empty)
    );

    // Clock Generation
    // Fast Write Clock 100MHz
    initial w_clk = 0;
    always #5 w_clk = ~w_clk; 

    // Slow Read Clock 38MHz
    initial r_clk = 0;
    always #13 r_clk = ~r_clk;

    // Main Process 
    initial begin
        // Waveform Setup
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_async_fifo);
        
        // 1.Test Case: Reset Sequence
        $display("Starting Reset ");
        w_rst_n = 0; r_rst_n = 0;
        w_en = 0; r_en = 0; w_data = 0;
        #50;
        w_rst_n = 1; r_rst_n = 1; // Release Reset
        $display("Reset Done");
        #20;
        
        // 2. Test Case: Filling the FIFO
        $display("Test 1: Filling the FIFO"); 
        for (int i = 0; i < 16; i++) begin
            wait(!w_full); 
            @(posedge w_clk); 
            w_en = 1;
            w_data = i * 10; // Pattern: 0, 10, 20...
            @(posedge w_clk);
            w_en = 0;
        end
        $display("Finished writing 16 items");
        #100; 
        
        // 3. Test Case: Emptying the FIFO
        $display("Test 2: Emptying the FIFO");
        for (int i = 0; i < 16; i++) begin
            wait(!r_empty);   
            @(posedge r_clk);
            r_en = 1;  
            @(posedge r_clk);
            r_en = 0;
            $display("Read Data: %d (Time: %t)", r_data, $time);
        end

        #100;
        $display(" Test Done");
        $finish;
    end
endmodule

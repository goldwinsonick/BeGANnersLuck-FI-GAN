`timescale 1ns / 1ps
// [conv3x3_tb.v] Testbench for 3x3 Convolution Stride 1

module conv3x3_tb;

    parameter DATA_WIDTH = 16;
    parameter IMG_WIDTH  = 32;

    parameter FILE_IN  = "data/v2_test/conv3x3_s1_input.csv";
    parameter FILE_OUT = "data/v2_test/conv3x3_s1_rtl_output.csv";

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    // Interconnect Wires
    wire signed [DATA_WIDTH-1:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, bias;

    // --- 1. Instantiate Weight ROM ---
    w_test_3x3 w_inst (
        .w0(w0), .w1(w1), .w2(w2), 
        .w3(w3), .w4(w4), .w5(w5), 
        .w6(w6), .w7(w7), .w8(w8), 
        .bias(bias)
    );

    // --- 2. Instantiate DUT ---
    conv2d_3x3_layer #(.IMG_WIDTH(IMG_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), 
        .valid_in(valid_in), .data_in(data_in),
        .w0(w0), .w1(w1), .w2(w2), 
        .w3(w3), .w4(w4), .w5(w5), 
        .w6(w6), .w7(w7), .w8(w8), 
        .bias(bias),
        .valid_out(valid_out), .data_out(data_out)
    );

    // --- 3. VCD Dump for Makefile ---
    initial begin
        $dumpfile("build/v2/conv3x3_tb.vcd");
        $dumpvars(0, conv3x3_tb);
    end

    // --- 4. Simulation Logic ---
    integer f_in, f_out, scan_st;
    reg signed [31:0] temp_read;

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        f_in  = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");
        
        if (!f_in) begin $display("Error opening input"); $finish; end

        rst_n = 0; valid_in = 0; data_in = 0;
        #20 rst_n = 1; #10;

        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
            end
        end
        
        @(posedge clk); valid_in <= 0;
        repeat(50) @(posedge clk); // Flush pipeline
        
        $fclose(f_in); $fclose(f_out);
        $display("Conv 3x3 Test Done.");
        $finish;
    end

    always @(posedge clk) begin
        if (valid_out) $fwrite(f_out, "%d\n", data_out);
    end

endmodule
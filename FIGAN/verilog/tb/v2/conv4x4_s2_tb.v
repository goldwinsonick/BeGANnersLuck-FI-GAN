`timescale 1ns / 1ps
// [conv4x4_s2_tb.v] Testbench for 4x4 Convolution Stride 2

module conv4x4_s2_tb;

    parameter DATA_WIDTH = 16;
    parameter IMG_WIDTH  = 32;

    parameter FILE_IN  = "data/v2_test/conv4x4_s2_input.csv";
    parameter FILE_OUT = "data/v2_test/conv4x4_s2_rtl_output.csv";

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    wire signed [DATA_WIDTH-1:0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire signed [DATA_WIDTH-1:0] w8, w9, w10, w11, w12, w13, w14, w15, bias;

    // --- 1. Weights ---
    w_test_4x4_s2 w_inst (
        .w0(w0), .w1(w1), .w2(w2), .w3(w3),
        .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .w8(w8), .w9(w9), .w10(w10), .w11(w11),
        .w12(w12), .w13(w13), .w14(w14), .w15(w15),
        .bias(bias)
    );

    // --- 2. DUT (Stride 2) ---
    conv2d_4x4_stride2_layer #(.IMG_WIDTH(IMG_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in),
        .w0(w0), .w1(w1), .w2(w2), .w3(w3),
        .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .w8(w8), .w9(w9), .w10(w10), .w11(w11),
        .w12(w12), .w13(w13), .w14(w14), .w15(w15),
        .bias(bias),
        .valid_out(valid_out), .data_out(data_out)
    );

    // --- 3. VCD Dump for Makefile ---
    initial begin
        $dumpfile("build/v2/conv4x4_s2_tb.vcd");
        $dumpvars(0, conv4x4_s2_tb);
    end

    // --- 4. Simulation Logic ---
    integer f_in, f_out, scan_st;
    reg signed [31:0] temp_read;

    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    initial begin
        f_in = $fopen(FILE_IN, "r"); f_out = $fopen(FILE_OUT, "w");
        rst_n = 0; valid_in = 0; #20 rst_n = 1; #10;

        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
            end
        end
        @(posedge clk); valid_in <= 0;
        repeat(50) @(posedge clk);
        $fclose(f_in); $fclose(f_out);
        $display("Conv 4x4 Stride 2 Test Done.");
        $finish;
    end

    always @(posedge clk) if (valid_out) $fwrite(f_out, "%d\n", data_out);

endmodule
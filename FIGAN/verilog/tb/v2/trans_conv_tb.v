`timescale 1ns / 1ps
// [trans_conv_tb.v] Testbench for Transposed Conv (Upsample + Conv)

module trans_conv_tb;

    parameter DATA_WIDTH = 16;
    parameter IN_WIDTH   = 16; 

    parameter FILE_IN  = "data/v2_test/trans_conv_input.csv";
    parameter FILE_OUT = "data/v2_test/trans_conv_rtl_output.csv";

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out, ready_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    // Weights
    wire signed [DATA_WIDTH-1:0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire signed [DATA_WIDTH-1:0] w8, w9, w10, w11, w12, w13, w14, w15, bias;

    w_test_trans w_inst (
        .w0(w0), .w1(w1), .w2(w2), .w3(w3), .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .w8(w8), .w9(w9), .w10(w10), .w11(w11), .w12(w12), .w13(w13), .w14(w14), .w15(w15),
        .bias(bias)
    );

    trans_conv2d_4x4_layer #(.IN_WIDTH(IN_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), 
        .valid_in(valid_in), .data_in(data_in), .ready_out(ready_out),
        .w0(w0), .w1(w1), .w2(w2), .w3(w3), .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .w8(w8), .w9(w9), .w10(w10), .w11(w11), .w12(w12), .w13(w13), .w14(w14), .w15(w15),
        .bias(bias),
        .valid_out(valid_out), .data_out(data_out)
    );

    // Update VCD output path sesuai request kamu
    initial begin
        $dumpfile("build/v2/trans_conv_tb.vcd"); 
        $dumpvars(0, trans_conv_tb);
    end

    integer f_in, f_out, scan_st;
    reg signed [31:0] temp_read;
    integer k;

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        f_in = $fopen(FILE_IN, "r"); f_out = $fopen(FILE_OUT, "w");
        rst_n = 0; valid_in = 0; #20 rst_n = 1; #10;

        // 1. KIRIM DATA ASLI
        while (!$feof(f_in)) begin
            while (ready_out == 0) @(posedge clk); // Tunggu Ready
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                valid_in <= 1;
                data_in  <= temp_read[15:0];
                @(posedge clk);
            end
        end

        // 2. [FIX] FLUSHING PIPELINE (Kirim Dummy Zeroes)
        // Kirim beberapa data '0' tambahan untuk memaksa Upsampler menyelesaikan 
        // padding baris terakhir dan mendorong Conv window sampai habis.
        // Kita kirim cukup banyak (misal 1 baris input width) biar aman.
        valid_in <= 1;
        data_in <= 0;
        
        for (k=0; k < IN_WIDTH + 4; k=k+1) begin
             while (ready_out == 0) @(posedge clk);
             @(posedge clk);
        end
        
        valid_in <= 0;
        
        // 3. Tunggu sisa data keluar
        repeat(500) @(posedge clk); 
        
        $fclose(f_in); $fclose(f_out);
        $display("Trans Conv Test Done.");
        $finish;
    end

    always @(posedge clk) if (valid_out) $fwrite(f_out, "%d\n", data_out);

endmodule
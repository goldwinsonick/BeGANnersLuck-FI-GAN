`timescale 1ns / 1ps

module generator_v3_tb;

    parameter DATA_WIDTH = 16;
    parameter DIR_IN  = "data/tests/test2/";
    parameter DIR_OUT = "data/tests/test2/";

    parameter FILE_IN  = {DIR_IN, "test2_input.csv"};
    parameter FILE_OUT = {DIR_OUT, "rtl_out.csv"}; 
    
    // Debug Files
    parameter FILE_DBG_ENC1 = {DIR_OUT, "rtl_enc1.csv"};
    parameter FILE_DBG_ENC2 = {DIR_OUT, "rtl_enc2.csv"};
    parameter FILE_DBG_ENC3 = {DIR_OUT, "rtl_enc3.csv"};
    parameter FILE_DBG_DEC1 = {DIR_OUT, "rtl_dec1.csv"};
    parameter FILE_DBG_DEC2 = {DIR_OUT, "rtl_dec2.csv"};

    parameter PIXELS_PER_FRAME = 32 * 32;

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    integer f_in, f_out, scan_st;
    integer f_e1, f_e2, f_e3, f_d1, f_d2;
    reg signed [31:0] temp_read;
    integer input_pixel_cnt;

    // --- SMART FILTER COUNTERS ---
    // Kita hitung output per layer. Jika melebihi target size, jangan tulis ke CSV (buang sampah flush).
    integer cnt_e1, cnt_e2, cnt_e3, cnt_d1, cnt_d2, cnt_out;
    
    // Target Size per Frame (Sesuai Arsitektur V3)
    // Enc1: 30x30 = 900
    // Enc2: 14x14 = 196
    // Enc3: 6x6   = 36
    // Dec1: 14x14 = 196
    // Dec2: 30x30 = 900
    // Out:  28x28 = 784
    
    generator_v3 #(.DATA_WIDTH(DATA_WIDTH), .TANH_LUT_FILE_PATH("rtl/memory/tanh_lut.mem")) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in), .valid_out(valid_out), .data_out(data_out)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        $dumpfile("build/generator_v3_tb.vcd");
        $dumpvars(0, generator_v3_tb);

        f_in  = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");
        
        f_e1 = $fopen(FILE_DBG_ENC1, "w"); f_e2 = $fopen(FILE_DBG_ENC2, "w"); f_e3 = $fopen(FILE_DBG_ENC3, "w");
        f_d1 = $fopen(FILE_DBG_DEC1, "w"); f_d2 = $fopen(FILE_DBG_DEC2, "w");

        if (!f_in) begin
            $display("ERROR: File input tidak ditemukan di: %s", FILE_IN);
            $finish;
        end

        // 1. Initial Reset
        rst_n = 0; valid_in = 0; data_in = 0; 
        input_pixel_cnt = 0; 
        cnt_e1=0; cnt_e2=0; cnt_e3=0; cnt_d1=0; cnt_d2=0; cnt_out=0;
        
        #20 rst_n = 1; #20;

        $display("--- Starting Simulation ---");
        
        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
                input_pixel_cnt = input_pixel_cnt + 1;

                if (input_pixel_cnt == PIXELS_PER_FRAME) begin
                    // Stop Input
                    @(posedge clk);
                    valid_in <= 0;
                    
                    // Tunggu Pipeline Kuras Habis (Sampah Flush akan keluar disini)
                    $display("Frame Input Done. Waiting for drain...");
                    repeat(30000) @(posedge clk); 
                    
                    // Hardware Reset
                    $display("--- HARDWARE RESET ---");
                    rst_n <= 0;
                    repeat(100) @(posedge clk); 
                    rst_n <= 1;
                    repeat(100) @(posedge clk);
                    
                    // Reset Semua Counter untuk Frame Berikutnya
                    input_pixel_cnt = 0;
                    cnt_e1=0; cnt_e2=0; cnt_e3=0; cnt_d1=0; cnt_d2=0; cnt_out=0;
                end
            end
        end
        
        repeat(5000) @(posedge clk);
        $fclose(f_in); $fclose(f_out);
        $fclose(f_e1); $fclose(f_e2); $fclose(f_e3); $fclose(f_d1); $fclose(f_d2);
        $finish;
    end

    // --- FILTERED OUTPUT CAPTURE ---
    
    // OUTPUT FINAL (Target 784)
    always @(posedge clk) begin
        if (valid_out) begin
            if (cnt_out < 784) begin
                $fwrite(f_out, "%d\n", data_out);
                cnt_out = cnt_out + 1;
            end
        end
    end
    
    // DEBUG LAYERS CAPTURE (With Limits)
    
    // Enc1 (900)
    always @(posedge clk) if (dut.val_act1 && cnt_e1 < 900) begin
        $fwrite(f_e1, "%d\n", dut.dat_act1); cnt_e1 = cnt_e1 + 1;
    end
    
    // Enc2 (196)
    always @(posedge clk) if (dut.val_act2 && cnt_e2 < 196) begin
        $fwrite(f_e2, "%d\n", dut.dat_act2); cnt_e2 = cnt_e2 + 1;
    end

    // Enc3 (36)
    always @(posedge clk) if (dut.val_act3 && cnt_e3 < 36) begin
        $fwrite(f_e3, "%d\n", dut.dat_act3); cnt_e3 = cnt_e3 + 1;
    end

    // Dec1 (196) - Ini yang kemarin geser karena sampah
    always @(posedge clk) if (dut.val_act_d1 && cnt_d1 < 196) begin
        $fwrite(f_d1, "%d\n", dut.dat_act_d1); cnt_d1 = cnt_d1 + 1;
    end

    // Dec2 (900) - Ini yang kemarin kurang data
    always @(posedge clk) if (dut.val_act_d2 && cnt_d2 < 900) begin
        $fwrite(f_d2, "%d\n", dut.dat_act_d2); cnt_d2 = cnt_d2 + 1;
    end

endmodule
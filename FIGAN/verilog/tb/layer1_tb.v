`timescale 1ns / 1ps

module layer1_tb;
    parameter DATA_WIDTH = 16;
    parameter IN_WIDTH   = 13; // INI KUNCINYA (Ganjil)
    
    // File Paths
    parameter FILE_IN      = "data/layer1_unit_test/l1_input.csv";
    parameter FILE_WEIGHTS = "data/layer1_unit_test/l1_weights.txt";
    parameter FILE_OUT     = "data/layer1_unit_test/l1_rtl_out.csv";

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    
    wire valid_mid, valid_out;
    wire signed [DATA_WIDTH-1:0] data_mid, data_out;
    
    reg [DATA_WIDTH-1:0] w_mem [0:100]; 
    integer f_in, f_out, scan_status, px_cnt, row_cnt;
    reg signed [31:0] temp_read;

    // Load Weights
    initial $readmemh(FILE_WEIGHTS, w_mem);

    // --- DUT 1: TRANSPOSED CONV (Layer 1) ---
    trans_conv2d_4x4_layer #(
        .IN_WIDTH(IN_WIDTH), // Set ke 13
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_layer (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in),
        // Weights (Langsung ambil dari memori index 0-16 karena cuma 1 layer)
        .w0(w_mem[0]), .w1(w_mem[1]), .w2(w_mem[2]), .w3(w_mem[3]),
        .w4(w_mem[4]), .w5(w_mem[5]), .w6(w_mem[6]), .w7(w_mem[7]),
        .w8(w_mem[8]), .w9(w_mem[9]), .w10(w_mem[10]), .w11(w_mem[11]),
        .w12(w_mem[12]), .w13(w_mem[13]), .w14(w_mem[14]), .w15(w_mem[15]),
        .bias(w_mem[16]),
        .valid_out(valid_mid), .data_out(data_mid)
    );

    // --- DUT 2: ACTIVATION ---
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) dut_act (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_mid), .data_in(data_mid),
        .valid_out(valid_out), .data_out(data_out)
    );

    // Clock
    initial begin clk = 0; forever #5 clk = ~clk; end

    // Input Process
    initial begin
        f_in = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");
        
        rst_n = 0; valid_in = 0; data_in = 0;
        px_cnt = 0; row_cnt = 0;
        
        #20 rst_n = 1; #20;

        $display("START UNIT TEST LAYER 1 (13x13 Input)...");

        while (!$feof(f_in)) begin
            scan_status = $fscanf(f_in, "%d\n", temp_read);
            if (scan_status == 1) begin
                
                // Kirim 1 Pixel
                @(posedge clk);
                valid_in <= 1; 
                data_in <= temp_read[DATA_WIDTH-1:0];
                @(posedge clk); 
                valid_in <= 0;

                // Hitung posisi pixel
                px_cnt = px_cnt + 1;
                
                if (px_cnt == IN_WIDTH) begin
                    // --- AKHIR BARIS ---
                    $display("Row %0d Sent. Waiting for padding...", row_cnt);
                    
                    // Jeda agak lama agar Upsampler sempat menyisipkan Baris Nol (Vertical Pad)
                    // Input 13 -> Output 26. Butuh min 26 cycle. Kita kasih 100 biar aman.
                    repeat(100) @(posedge clk); 
                    
                    px_cnt = 0;
                    row_cnt = row_cnt + 1;
                end else begin
                    // --- ANTAR PIXEL ---
                    // Jeda dikit untuk Horizontal Pad (Input Pixel -> 0 -> Input Pixel)
                    repeat(5) @(posedge clk); 
                end
            end
        end

        $display("All Inputs Sent. Flushing...");
        repeat(5000) @(posedge clk); 
        $display("DONE.");
        $fclose(f_in); $fclose(f_out); $finish;
    end

    // Capture Output
    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(f_out, "%d\n", data_out);
        end
    end

endmodule
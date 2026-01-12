`timescale 1ns / 1ps

module trans_conv2d_4x4_layer_tb;

    // --- Parameters ---
    parameter DATA_WIDTH = 16;
    parameter IN_WIDTH   = 8; // Input size 8x8
    
    // File Paths
    parameter FILE_IN      = "data/conv_layer_test/trans_input.csv";
    parameter FILE_WEIGHTS = "data/conv_layer_test/trans_weights.txt";
    parameter FILE_OUT     = "data/conv_layer_test/trans_rtl_output.csv";

    // --- Signals ---
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;

    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    reg [DATA_WIDTH-1:0] w_mem [0:16];
    integer f_in, f_out, scan_status;
    reg signed [31:0] temp_read;
    
    // Counter untuk melacak posisi pixel dalam baris
    integer pixel_cnt; 

    // --- DUT ---
    trans_conv2d_4x4_layer #(
        .IN_WIDTH(IN_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .w0 (w_mem[0]),  .w1 (w_mem[1]),  .w2 (w_mem[2]),  .w3 (w_mem[3]),
        .w4 (w_mem[4]),  .w5 (w_mem[5]),  .w6 (w_mem[6]),  .w7 (w_mem[7]),
        .w8 (w_mem[8]),  .w9 (w_mem[9]),  .w10(w_mem[10]), .w11(w_mem[11]),
        .w12(w_mem[12]), .w13(w_mem[13]), .w14(w_mem[14]), .w15(w_mem[15]),
        .bias(w_mem[16]),
        .valid_out(valid_out),
        .data_out(data_out)
    );

    // --- Clock ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- VCD Dump ---
    initial begin
        $dumpfile("build/trans_conv2d_4x4_layer_tb.vcd");
        $dumpvars(0, trans_conv2d_4x4_layer_tb);
    end

    // --- Main Process ---
    initial begin
        $readmemh(FILE_WEIGHTS, w_mem);
        f_in  = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");

        rst_n = 0; valid_in = 0; data_in = 0; pixel_cnt = 0;
        #20; rst_n = 1; #10;

        $display("Starting Transposed Conv Simulation...");

        while (!$feof(f_in)) begin
            scan_status = $fscanf(f_in, "%d\n", temp_read);
            
            if (scan_status == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];

                // Pulse valid 1 cycle
                @(posedge clk);
                valid_in <= 0; 
                
                // Update Counter
                pixel_cnt = pixel_cnt + 1;

                // --- TIMING CONTROL ---
                if (pixel_cnt == IN_WIDTH) begin
                    // SUDAH 1 BARIS (8 Pixel)
                    // Beri waktu Upsampler untuk menyisipkan "Zero Row" (16 cycle)
                    // Kita tunggu 20 cycle biar aman.
                    repeat(20) @(posedge clk);
                    pixel_cnt = 0; // Reset counter untuk baris baru
                end 
                else begin
                    // BELUM 1 BARIS
                    // Jeda antar pixel biasa (untuk sisip nol horizontal)
                    repeat(4) @(posedge clk);
                end
            end
        end
        
        // Flush Pipeline
        repeat(200) @(posedge clk);

        $display("Simulation Done.");
        $fclose(f_in); $fclose(f_out); $finish;
    end

    // --- Capture Output ---
    always @(posedge clk) begin
        if (valid_out) $fwrite(f_out, "%d\n", data_out);
    end

endmodule
`timescale 1ns / 1ps

module generator_tb;
    parameter DATA_WIDTH = 16;
    
    parameter FILE_IN      = "data/generator_test/gen_input.csv";
    parameter FILE_WEIGHTS = "data/generator_test/gen_weights.txt";
    parameter FILE_OUT_L0  = "data/generator_test/rtl_layer0.csv";
    parameter FILE_OUT_L1  = "data/generator_test/rtl_layer1.csv";

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    
    // Wire untuk sadap sinyal internal
    // (Akan direkam via hierarki dut.xxx)
    
    reg [DATA_WIDTH-1:0] w_mem [0:100]; 
    integer f_in, f_out0, f_out1, scan_status, pixel_cnt;
    reg signed [31:0] temp_read;

    initial $readmemh(FILE_WEIGHTS, w_mem);

    // DUT
    generator #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in),
        // L0
        .s0_w0(w_mem[0]), .s0_w1(w_mem[1]), .s0_w2(w_mem[2]), .s0_w3(w_mem[3]),
        .s0_w4(w_mem[4]), .s0_w5(w_mem[5]), .s0_w6(w_mem[6]), .s0_w7(w_mem[7]),
        .s0_w8(w_mem[8]), .s0_w9(w_mem[9]), .s0_w10(w_mem[10]), .s0_w11(w_mem[11]),
        .s0_w12(w_mem[12]), .s0_w13(w_mem[13]), .s0_w14(w_mem[14]), .s0_w15(w_mem[15]),
        .s0_bias(w_mem[16]),
        // L1
        .s1_w0(w_mem[17]), .s1_w1(w_mem[18]), .s1_w2(w_mem[19]), .s1_w3(w_mem[20]),
        .s1_w4(w_mem[21]), .s1_w5(w_mem[22]), .s1_w6(w_mem[23]), .s1_w7(w_mem[24]),
        .s1_w8(w_mem[25]), .s1_w9(w_mem[26]), .s1_w10(w_mem[27]), .s1_w11(w_mem[28]),
        .s1_w12(w_mem[29]), .s1_w13(w_mem[30]), .s1_w14(w_mem[31]), .s1_w15(w_mem[32]),
        .s1_bias(w_mem[33]),
        // Dummy
        .out_w0(w_mem[34]), .out_w1(w_mem[35]), .out_w2(w_mem[36]),
        .out_w3(w_mem[37]), .out_w4(w_mem[38]), .out_w5(w_mem[39]),
        .out_w6(w_mem[40]), .out_w7(w_mem[41]), .out_w8(w_mem[42]),
        .out_bias(w_mem[43])
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        f_in = $fopen(FILE_IN, "r");
        f_out0 = $fopen(FILE_OUT_L0, "w");
        f_out1 = $fopen(FILE_OUT_L1, "w");
        
        rst_n = 0; valid_in = 0; data_in = 0; pixel_cnt = 0;
        #20 rst_n = 1; #20;
        
        $display("Starting SUPER SLOW Simulation...");

        while (!$feof(f_in)) begin
            scan_status = $fscanf(f_in, "%d\n", temp_read);
            if (scan_status == 1) begin
                // 1. KIRIM SATU PIXEL
                @(posedge clk);
                valid_in <= 1; 
                data_in <= temp_read[DATA_WIDTH-1:0];
                @(posedge clk); 
                valid_in <= 0;

                // 2. TUNGGU SANGAT LAMA
                // Ini memberi waktu Layer 1 untuk memproses 1 pixel ini sampai TUNTAS (termasuk padding)
                // sebelum pixel berikutnya datang.
                // 300 cycle > 26 (lebar output layer 1)
                
                pixel_cnt = pixel_cnt + 1;
                
                if (pixel_cnt == 8) begin
                    // Akhir baris: Tunggu lebih lama lagi buat Vertical Padding L1
                    repeat(5000) @(posedge clk);
                    pixel_cnt = 0;
                    $display("Row Finished.");
                end else begin
                    // Antar pixel: Tunggu padding horizontal selesai
                    repeat(300) @(posedge clk);
                end
            end
        end

        $display("Input Done. Flushing...");
        repeat(100000) @(posedge clk); 
        $display("Done.");
        $fclose(f_in); 
        $fclose(f_out0); 
        $fclose(f_out1); 
        $finish;
    end

    // CAPTURE LAYER 0 (Hierarchical Reference)
    always @(posedge clk) begin
        if (dut.act0_valid) $fwrite(f_out0, "%d\n", dut.act0_data);
    end

    // CAPTURE LAYER 1 (Hierarchical Reference)
    always @(posedge clk) begin
        if (dut.act1_valid) $fwrite(f_out1, "%d\n", dut.act1_data);
    end

endmodule
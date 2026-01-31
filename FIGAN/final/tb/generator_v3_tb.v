`timescale 1ns / 1ps

module generator_v3_tb;

    // --- PARAMETERS ---
    parameter DATA_WIDTH = 16;
    
    // Path Config
    parameter TEST_DIR = "data/tests/test1/";
    parameter FILE_IN  = {TEST_DIR, "test1_input.csv"};
    parameter FILE_OUT = {TEST_DIR, "rtl_out.csv"};
    
    // Debug Files
    parameter FILE_DBG_ENC1 = {TEST_DIR, "rtl_enc1.csv"};
    parameter FILE_DBG_ENC2 = {TEST_DIR, "rtl_enc2.csv"};
    parameter FILE_DBG_ENC3 = {TEST_DIR, "rtl_enc3.csv"};
    parameter FILE_DBG_DEC1 = {TEST_DIR, "rtl_dec1.csv"};
    parameter FILE_DBG_DEC2 = {TEST_DIR, "rtl_dec2.csv"};

    // Frame Config (Untuk Auto-Reset)
    parameter PIXELS_PER_FRAME = 32 * 32; // 1024

    // --- SIGNALS ---
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    // File Handles & Variables
    integer f_in, f_out, scan_st;
    integer f_e1, f_e2, f_e3, f_d1, f_d2;
    reg signed [31:0] temp_read;
    integer input_pixel_cnt;

    // --- DUT INSTANTIATION ---
    generator_v3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .TANH_LUT_FILE_PATH("rtl/memory/tanh_lut.mem") 
    ) dut (
        .clk(clk), 
        .rst_n(rst_n),
        .valid_in(valid_in), 
        .data_in(data_in),
        .valid_out(valid_out), 
        .data_out(data_out)
    );

    // --- CLOCK ---
    initial begin clk = 0; forever #5 clk = ~clk; end

    // --- MAIN TEST PROCESS ---
    initial begin
        $dumpfile("build/generator_v3_tb.vcd");
        $dumpvars(0, generator_v3_tb);

        f_in = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");
        
        // Debug Files
        f_e1 = $fopen(FILE_DBG_ENC1, "w");
        f_e2 = $fopen(FILE_DBG_ENC2, "w");
        f_e3 = $fopen(FILE_DBG_ENC3, "w");
        f_d1 = $fopen(FILE_DBG_DEC1, "w");
        f_d2 = $fopen(FILE_DBG_DEC2, "w");

        if (!f_in) begin
            $display("ERROR: File input tidak ditemukan!");
            $finish;
        end

        // 1. Initial Reset
        rst_n = 0; valid_in = 0; data_in = 0; input_pixel_cnt = 0;
        #20 rst_n = 1; #20;

        $display("--- Starting Simulation ---");

        // Loop Streaming
        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            
            if (scan_st == 1) begin
                // Kirim 1 Pixel
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
                input_pixel_cnt = input_pixel_cnt + 1;
            end
        end
        
        $display("--- All Inputs Done ---");
        repeat(2000) @(posedge clk); // Sisa flush terakhir
        
        // Cleanup
        $fclose(f_in);
        $fclose(f_out);
        $fclose(f_e1); $fclose(f_e2); $fclose(f_e3);
        $fclose(f_d1); $fclose(f_d2);
        $finish;
    end

    // --- CAPTURE OUTPUT UTAMA ---
    always @(posedge clk) begin
        if (valid_out) $fwrite(f_out, "%d\n", data_out);
    end

    // Layer 1: Enc1
    always @(posedge clk) if (dut.val_act1) $fwrite(f_e1, "%d\n", dut.dat_act1);

    // Layer 2: Enc2
    always @(posedge clk) if (dut.val_act2) $fwrite(f_e2, "%d\n", dut.dat_act2);

    // Layer 3: Enc3
    always @(posedge clk) if (dut.val_act3) $fwrite(f_e3, "%d\n", dut.dat_act3);

    // Layer 4: Dec1 (OUTPUT of Padded TransConv -> Leaky)
    always @(posedge clk) if (dut.val_act_d1) $fwrite(f_d1, "%d\n", dut.dat_act_d1);

    // Layer 5: Dec2 (OUTPUT of Padded TransConv -> Leaky)
    always @(posedge clk) if (dut.val_act_d2) $fwrite(f_d2, "%d\n", dut.dat_act_d2);

endmodule
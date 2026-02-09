
`timescale 1ns / 1ps

module master_tb;

    parameter DATA_WIDTH = 16;
    
    // PATHS INJECTED FROM PYTHON
    parameter FILE_IN  = "simulation/02_input_vectors/test_vector.csv";
    parameter FILE_OUT = "simulation/03_rtl_output/rtl_out.csv"; 

    parameter PIXELS_PER_FRAME = 32 * 32; // 1024
    parameter TARGET_OUT_PIXELS = 28 * 28; // 784 (V3 Output)

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    integer f_in, f_out, scan_st;
    reg signed [31:0] temp_read;
    integer input_pixel_cnt;
    integer out_pixel_cnt;

    // DUT INSTANTIATION
    generator_v3 #(.DATA_WIDTH(DATA_WIDTH), .TANH_LUT_FILE_PATH("rtl/memory/tanh_lut.mem")) dut (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in), 
        .valid_out(valid_out), .data_out(data_out)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        f_in = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");

        if (!f_in) begin $display("Error opening input file"); $finish; end

        // 1. Initial Reset
        rst_n = 0; valid_in = 0; data_in = 0; 
        input_pixel_cnt = 0; out_pixel_cnt = 0;
        #20 rst_n = 1; #20;

        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
                input_pixel_cnt = input_pixel_cnt + 1;

                // --- END OF FRAME DETECTION ---
                if (input_pixel_cnt == PIXELS_PER_FRAME) begin
                    // A. Stop Input
                    @(posedge clk);
                    valid_in <= 0;
                    
                    // B. Pipeline Drain (Tunggu Flush dari ZeroPad selesai)
                    // Wait time 35000 cycle (sangat aman)
                    repeat(35000) @(posedge clk); 
                    
                    // C. Hardware Reset (Clean State for Next Frame)
                    rst_n <= 0; repeat(100) @(posedge clk); 
                    rst_n <= 1; repeat(100) @(posedge clk);
                    
                    // D. Reset Counters
                    input_pixel_cnt = 0;
                    out_pixel_cnt = 0; // Reset output counter per frame
                end
            end
        end
        
        repeat(5000) @(posedge clk);
        $fclose(f_in); $fclose(f_out);
        $finish;
    end

    // --- SMART OUTPUT FILTER ---
    // Hanya tulis data jika jumlah pixel output belum mencapai target (784).
    // Ini membuang sampah flush (0) yang mungkin keluar di akhir frame.
    always @(posedge clk) begin
        if (valid_out) begin
            if (out_pixel_cnt < TARGET_OUT_PIXELS) begin
                $fwrite(f_out, "%d\n", data_out);
                out_pixel_cnt = out_pixel_cnt + 1;
            end
        end
    end

endmodule

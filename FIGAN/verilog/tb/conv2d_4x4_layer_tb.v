`timescale 1ns / 1ps

module conv2d_4x4_layer_tb;

    // --- Parameters ---
    parameter DATA_WIDTH = 16;
    parameter IMG_WIDTH  = 16; // Input image size (16x16)

    // File Paths
    parameter FILE_IN      = "data/conv_layer_test/conv4x4_input.csv";
    parameter FILE_WEIGHTS = "data/conv_layer_test/conv4x4_weights.txt";
    parameter FILE_OUT     = "data/conv_layer_test/conv4x4_rtl_output.csv";

    // --- Signals ---
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;

    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    // --- Weight Memory ---
    // 4x4 Kernel = 16 weights + 1 bias = 17 values
    reg [DATA_WIDTH-1:0] w_mem [0:16];

    // --- File Handling ---
    integer f_in, f_out;
    integer scan_status;
    reg signed [31:0] temp_read;

    // --- 1. Load Weights from File ---
    initial begin
        $readmemh(FILE_WEIGHTS, w_mem);
    end

    // --- 2. DUT Instantiation ---
    conv2d_4x4_layer #(
        .IMG_WIDTH(IMG_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        
        // Map 16 weights
        .w0 (w_mem[0]),  .w1 (w_mem[1]),  .w2 (w_mem[2]),  .w3 (w_mem[3]),
        .w4 (w_mem[4]),  .w5 (w_mem[5]),  .w6 (w_mem[6]),  .w7 (w_mem[7]),
        .w8 (w_mem[8]),  .w9 (w_mem[9]),  .w10(w_mem[10]), .w11(w_mem[11]),
        .w12(w_mem[12]), .w13(w_mem[13]), .w14(w_mem[14]), .w15(w_mem[15]),
        .bias(w_mem[16]), // Bias is the last element (Index 16)

        .valid_out(valid_out),
        .data_out(data_out)
    );

    // --- 3. Clock ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 4. VCD Dump ---
    initial begin
        $dumpfile("build/conv2d_4x4_layer_tb.vcd");
        $dumpvars(0, conv2d_4x4_layer_tb);
    end

    // --- 5. Main Test Process ---
    initial begin
        f_in  = $fopen(FILE_IN, "r");
        f_out = $fopen(FILE_OUT, "w");

        if (f_in == 0) begin
            $display("Error: Failed to open input file %s", FILE_IN);
            $finish;
        end

        // Reset
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        #20;
        rst_n = 1;
        #10;

        $display("Starting Conv 4x4 Simulation...");

        // Loop Input
        while (!$feof(f_in)) begin
            scan_status = $fscanf(f_in, "%d\n", temp_read);
            
            if (scan_status == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
            end
        end

        // Stop Input
        @(posedge clk);
        valid_in <= 0;
        data_in  <= 0;

        // Tambah delay flush
        repeat(20) @(posedge clk);

        $display("Simulation Done.");
        $fclose(f_in);
        $fclose(f_out);
        $finish;
    end

    // --- 6. Output Capture ---
    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(f_out, "%d\n", data_out);
        end
    end

endmodule
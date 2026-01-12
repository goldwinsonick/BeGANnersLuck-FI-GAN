`timescale 1ns/1ps

module activation_layer_tb;

    // --- Parameters ---
    parameter DATA_WIDTH = 16;
    
    // File Paths (Relative to Makefile root)
    parameter FILE_IN       = "data/activation_layer_test/activation_input.csv";
    parameter FILE_OUT_SIG  = "data/activation_layer_test/sigmoid_output.csv";
    parameter FILE_OUT_TANH = "data/activation_layer_test/tanh_output.csv";
    
    // Memory Paths (LUTs)
    parameter LUT_SIGMOID   = "data/memory/sigmoid_lut.mem";
    parameter LUT_TANH      = "data/memory/tanh_lut.mem";

    // --- Signals ---
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;

    // Output wires
    wire valid_out_sig;
    wire signed [DATA_WIDTH-1:0] data_out_sig;
    
    wire valid_out_tanh;
    wire signed [DATA_WIDTH-1:0] data_out_tanh;

    // File Handling
    integer f_in, f_sig, f_tanh;
    integer scan_status;
    reg signed [31:0] temp_read; // Buffer baca integer 32-bit

    // --- DUT Instantiation ---

    // 1. Sigmoid Instance
    activation_layer #(
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_FILE(LUT_SIGMOID), 
        .IS_TANH(0)
    ) dut_sigmoid (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .valid_out(valid_out_sig),
        .data_out(data_out_sig)
    );

    // 2. Tanh Instance
    activation_layer #(
        .DATA_WIDTH(DATA_WIDTH),
        .LUT_FILE(LUT_TANH),
        .IS_TANH(1)
    ) dut_tanh (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .valid_out(valid_out_tanh),
        .data_out(data_out_tanh)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz (Period 10ns)
    end

    // --- VCD Dump (Waveform) ---
    initial begin
        // Sesuai request: Output VCD ke folder build/
        $dumpfile("build/activation_layer_tb.vcd");
        $dumpvars(0, activation_layer_tb);
    end

    // --- Main Test Process ---
    initial begin
        // 1. Open CSV Files
        f_in = $fopen(FILE_IN, "r");
        f_sig = $fopen(FILE_OUT_SIG, "w");
        f_tanh = $fopen(FILE_OUT_TANH, "w");

        if (f_in == 0) begin
            $display("Error: Failed to open input file %s", FILE_IN);
            $finish;
        end

        // 2. Header Display
        $display("Time\t\tInput (Int)\tSigmoid Out\tTanh Out");
        $display("---------------------------------------------------------");

        // 3. Reset Sequence
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        #20;
        rst_n = 1;
        #10;

        // 4. Loop Read-Write
        while (!$feof(f_in)) begin
            scan_status = $fscanf(f_in, "%d\n", temp_read);
            
            if (scan_status == 1) begin
                // --- Drive Input ---
                @(posedge clk); // Sinkron dengan rising edge
                data_in <= temp_read[15:0];
                valid_in <= 1;

                @(posedge clk);
                valid_in <= 0; // Pulse valid cuma 1 cycle

                // --- Wait for Output ---
                // Tunggu sampai kedua modul mengeluarkan valid_out
                wait(valid_out_sig && valid_out_tanh);
                
                // --- Write to CSV & Display ---
                $fwrite(f_sig, "%d\n", data_out_sig);
                $fwrite(f_tanh, "%d\n", data_out_tanh);
                
                // Tampilkan beberapa sample ke terminal (biar tidak spam jika file besar)
                if ($time % 100 == 0) begin
                    $display("%0t\t%d\t\t%d\t\t%d", $time, data_in, data_out_sig, data_out_tanh);
                end
            end
        end

        // 5. Cleanup
        #100;
        $display("---------------------------------------------------------");
        $display("Simulation Finished. VCD saved to build/activation_layer_tb.vcd");
        $fclose(f_in);
        $fclose(f_sig);
        $fclose(f_tanh);
        $finish;
    end

endmodule
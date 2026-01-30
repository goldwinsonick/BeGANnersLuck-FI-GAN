`timescale 1ns / 1ps

module generator_v3_tb;

    parameter DATA_WIDTH = 16;
    
    // Paths (Adjusted for V3)
    parameter BASE_DIR = "data/v3_test/";
    parameter FILE_IN  = {BASE_DIR, "generator_v3_input.csv"};
    
    // Output Files
    integer f_e1, f_e2, f_e3, f_d1, f_d2, f_out;

    reg clk, rst_n, valid_in;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire valid_out;
    wire signed [DATA_WIDTH-1:0] data_out;

    // --- DUT INSTANTIATION ---
    generator_v3 #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk), 
        .rst_n(rst_n),
        .valid_in(valid_in), 
        .data_in(data_in),
        .valid_out(valid_out), 
        .data_out(data_out)
    );

    // --- CLOCK ---
    initial begin clk = 0; forever #5 clk = ~clk; end

    // --- VCD DUMP ---
    initial begin
        $dumpfile("build/v3/generator_v3_tb.vcd");
        $dumpvars(0, generator_v3_tb);
    end

    // --- MAIN PROCESS ---
    integer f_in, scan_st;
    reg signed [31:0] temp_read;
    integer i;

    initial begin
        // Open Output Files for Debugging Layers
        f_in = $fopen(FILE_IN, "r");
        f_e1 = $fopen({BASE_DIR, "1_enc1_rtl.csv"}, "w");
        f_e2 = $fopen({BASE_DIR, "2_enc2_rtl.csv"}, "w");
        f_e3 = $fopen({BASE_DIR, "3_enc3_rtl.csv"}, "w");
        f_d1 = $fopen({BASE_DIR, "4_dec1_rtl.csv"}, "w");
        f_d2 = $fopen({BASE_DIR, "5_dec2_rtl.csv"}, "w");
        f_out= $fopen({BASE_DIR, "generator_v3_rtl_output.csv"}, "w");

        if (!f_in) begin $display("Error opening input file: %s", FILE_IN); $finish; end

        // Reset
        rst_n = 0; valid_in = 0; data_in = 0;
        #20 rst_n = 1; #10;

        $display("Starting Generator V3 (Padded) System Test...");

        // 1. STREAM INPUT DATA
        while (!$feof(f_in)) begin
            scan_st = $fscanf(f_in, "%d\n", temp_read);
            if (scan_st == 1) begin
                @(posedge clk);
                valid_in <= 1;
                data_in  <= temp_read[15:0];
            end
        end

        // 2. ACTIVE FLUSH
        // Karena padding layer nambah latency dan butuh extra cycles untuk border bawah,
        // kita flush agak banyak.
        $display("Input done. Starting Active Flush...");
        valid_in <= 1;
        data_in  <= 0;
        
        // Push 300 zeros (Secure amount)
        for (i=0; i<300; i=i+1) begin
            @(posedge clk);
        end
        
        valid_in <= 0;

        // 3. Wait for pipeline to drain
        repeat(3000) @(posedge clk);

        $display("Simulation Done.");
        $fclose(f_in);
        $fclose(f_e1); $fclose(f_e2); $fclose(f_e3);
        $fclose(f_d1); $fclose(f_d2); $fclose(f_out);
        $finish;
    end

    // --- MATA-MATA (Snooping Internal Signals) ---
    // Pastikan nama signal sesuai dengan generator_v3.v

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

    // Layer 6: Final Output
    always @(posedge clk) if (valid_out) $fwrite(f_out, "%d\n", data_out);

endmodule
`timescale 1ns / 1ps

// [gan_tb.v] Testbench for GAN Level 2
// Reads weights and inputs from CSV, writes output to CSV.
module gan_tb;

    // --- Signals ---
    reg clk;
    reg rst_n;
    reg valid_in;

    // Inputs (Noise)
    reg signed [15:0] z1, z2;

    // Weight Buses (Flattened)
    reg [143:0] tb_gen_w1; // Gen L1 (9 params)
    reg [575:0] tb_gen_w2; // Gen L2 (36 params)
    reg [479:0] tb_disc_w1;// Disc L1 (30 params)
    reg [63:0]  tb_disc_w2;// Disc L2 (4 params)

    // Interconnects & Outputs
    wire signed [15:0] w_pix1, w_pix2, w_pix3;
    wire signed [15:0] w_pix4, w_pix5, w_pix6;
    wire signed [15:0] w_pix7, w_pix8, w_pix9;
    wire gen_done, disc_done;
    wire signed [15:0] final_score;

    // --- Instantiations ---
    generator u_gen (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in),
        .z1(z1), .z2(z2),
        .flat_weights_L1(tb_gen_w1),
        .flat_weights_L2(tb_gen_w2),
        .valid_out(gen_done),
        .o_pix1(w_pix1), .o_pix2(w_pix2), .o_pix3(w_pix3),
        .o_pix4(w_pix4), .o_pix5(w_pix5), .o_pix6(w_pix6),
        .o_pix7(w_pix7), .o_pix8(w_pix8), .o_pix9(w_pix9)
    );

    discriminator u_disc (
        .clk(clk), .rst_n(rst_n), .valid_in(gen_done),
        .i_pix1(w_pix1), .i_pix2(w_pix2), .i_pix3(w_pix3),
        .i_pix4(w_pix4), .i_pix5(w_pix5), .i_pix6(w_pix6),
        .i_pix7(w_pix7), .i_pix8(w_pix8), .i_pix9(w_pix9),
        .flat_weights_D1(tb_disc_w1),
        .flat_weights_D2(tb_disc_w2),
        .valid_out(disc_done),
        .o_score(final_score)
    );

    // --- Clock Generation ---
    initial clk = 0;
    always #5 clk = ~clk;

    // --- Variables for File I/O ---
    integer f_weights, f_in, f_out;
    integer i, status, val;
    reg signed [15:0] w_mem [0:127];

    // --- Main Process ---
    initial begin
        // 1. Setup VCD Dump
        $dumpfile("build/gan_tb.vcd");
        $dumpvars(0, gan_tb);

        // Initialize signals
        rst_n = 0;
        valid_in = 0;
        z1 = 0;
        z2 = 0;

        // -----------------------------------------------------------
        // 2. Load Weights from CSV
        // -----------------------------------------------------------
        f_weights = $fopen("data/weights.csv", "r");
        if (f_weights == 0) begin
            $display("ERROR: Cannot open data/weights.csv");
            $finish;
        end

        // Read 79 parameters
        for (i = 0; i < 79; i = i + 1) begin
            status = $fscanf(f_weights, "%d", val);
            w_mem[i] = val[15:0];
        end
        $fclose(f_weights);

        // Pack weights into buses
        // Gen L1 (9 params)
        for (i=0; i<9; i=i+1) tb_gen_w1[16*i +: 16] = w_mem[i];
        // Gen L2 (36 params)
        for (i=0; i<36; i=i+1) tb_gen_w2[16*i +: 16] = w_mem[9+i];
        // Disc L1 (30 params)
        for (i=0; i<30; i=i+1) tb_disc_w1[16*i +: 16] = w_mem[9+36+i];
        // Disc L2 (4 params)
        for (i=0; i<4; i=i+1) tb_disc_w2[16*i +: 16] = w_mem[9+36+30+i];

        $display("STATUS: Weights loaded successfully.");

        // -----------------------------------------------------------
        // 3. Load Inputs from CSV (2 lines: z1, z2)
        // -----------------------------------------------------------
        f_in = $fopen("data/inputs.csv", "r");
        if (f_in == 0) begin
            $display("ERROR: Cannot open data/input.csv");
            $finish;
        end
        
        // Read z1 and z2
        status = $fscanf(f_in, "%d", val); z1 = val[15:0];
        status = $fscanf(f_in, "%d", val); z2 = val[15:0];
        $fclose(f_in);
        
        $display("STATUS: Inputs loaded: z1=%d, z2=%d", z1, z2);

        // -----------------------------------------------------------
        // 4. Run Simulation
        // -----------------------------------------------------------
        #20 rst_n = 1;      // Release Reset
        #10 valid_in = 1;   // Start Pulse
        #10 valid_in = 0;

        // Wait for Discriminator to finish
        wait(disc_done);
        #10; 

        // -----------------------------------------------------------
        // 5. Write Outputs to CSV
        // -----------------------------------------------------------
        f_out = $fopen("data/outputs_verilog.csv", "w");
        if (f_out == 0) begin
            $display("ERROR: Cannot open data/output_verilog.csv for writing");
            $finish;
        end

        // Write 9 Pixels + 1 Score
        $fdisplay(f_out, "%d", w_pix1);
        $fdisplay(f_out, "%d", w_pix2);
        $fdisplay(f_out, "%d", w_pix3);
        $fdisplay(f_out, "%d", w_pix4);
        $fdisplay(f_out, "%d", w_pix5);
        $fdisplay(f_out, "%d", w_pix6);
        $fdisplay(f_out, "%d", w_pix7);
        $fdisplay(f_out, "%d", w_pix8);
        $fdisplay(f_out, "%d", w_pix9);
        $fdisplay(f_out, "%d", final_score);

        $fclose(f_out);
        
        $display("---------------------------------------------------");
        $display("STATUS: Simulation Finished.");
        $display("        Results saved to data/output_verilog.csv");
        $display("        Score: %d", final_score);
        $display("---------------------------------------------------");

        $finish;
    end

endmodule
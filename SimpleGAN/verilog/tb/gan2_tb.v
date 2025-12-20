`timescale 1ns / 1ps

// [gan2_tb.v] Batch Processing Testbench
// Reads inputs2.csv (multiple lines), writes outputs2.csv (multiple lines)
module gan2_tb;

    // --- Signals ---
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [15:0] z1, z2;

    // Weight Buses
    reg [143:0] tb_gen_w1;
    reg [575:0] tb_gen_w2;
    reg [479:0] tb_disc_w1;
    reg [63:0]  tb_disc_w2;

    // Outputs
    wire signed [15:0] w_pix1, w_pix2, w_pix3;
    wire signed [15:0] w_pix4, w_pix5, w_pix6;
    wire signed [15:0] w_pix7, w_pix8, w_pix9;
    wire gen_done, disc_done;
    wire signed [15:0] final_score;

    // --- Instantiations ---
    generator u_gen (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in),
        .z1(z1), .z2(z2),
        .flat_weights_L1(tb_gen_w1), .flat_weights_L2(tb_gen_w2),
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
        .flat_weights_D1(tb_disc_w1), .flat_weights_D2(tb_disc_w2),
        .valid_out(disc_done), .o_score(final_score)
    );

    // --- Clock ---
    initial clk = 0;
    always #5 clk = ~clk;

    // --- File Handles ---
    integer f_w, f_in, f_out;
    integer i, status, val;
    reg signed [15:0] w_mem [0:127];
    integer case_count;

    initial begin
        $dumpfile("build/gan2_tb.vcd");
        $dumpvars(0, gan2_tb);

        // Init
        rst_n = 0; valid_in = 0; z1 = 0; z2 = 0; case_count = 0;

        // ------------------------------------------------
        // 1. LOAD WEIGHTS (Once)
        // ------------------------------------------------
        f_w = $fopen("data/weights.csv", "r");
        if (!f_w) begin $display("Error: weights.csv missing"); $finish; end
        
        for (i=0; i<79; i=i+1) begin
            status = $fscanf(f_w, "%d", val);
            w_mem[i] = val[15:0];
        end
        $fclose(f_w);

        // Pack weights
        for (i=0; i<9; i=i+1) tb_gen_w1[16*i +: 16] = w_mem[i];
        for (i=0; i<36; i=i+1) tb_gen_w2[16*i +: 16] = w_mem[9+i];
        for (i=0; i<30; i=i+1) tb_disc_w1[16*i +: 16] = w_mem[9+36+i];
        for (i=0; i<4; i=i+1) tb_disc_w2[16*i +: 16] = w_mem[9+36+30+i];

        // ------------------------------------------------
        // 2. OPEN DATA FILES
        // ------------------------------------------------
        f_in = $fopen("data/inputs2.csv", "r");
        f_out = $fopen("data/outputs2.csv", "w");
        
        if (!f_in) begin $display("Error: inputs2.csv missing"); $finish; end

        // Reset System
        #20 rst_n = 1; #10;

        // ------------------------------------------------
        // 3. BATCH PROCESSING LOOP
        // ------------------------------------------------
        // Loop until End of File
        while (!$feof(f_in)) begin
            // Read 2 values (z1, z2)
            status = $fscanf(f_in, "%d", val);
            if (status == 1) begin
                z1 = val[15:0];
                status = $fscanf(f_in, "%d", val);
                z2 = val[15:0];
                
                // Trigger Simulation
                #10 valid_in = 1;
                #10 valid_in = 0;

                // Wait for Result
                wait(disc_done);
                #10; // Margin

                // Write Output (All on one line)
                $fdisplay(f_out, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d", 
                    w_pix1, w_pix2, w_pix3, 
                    w_pix4, w_pix5, w_pix6, 
                    w_pix7, w_pix8, w_pix9, 
                    final_score);
                
                case_count = case_count + 1;
                $display("Processed Case %d: Score = %d", case_count, final_score);
            end
        end

        $fclose(f_in);
        $fclose(f_out);
        $display("Batch Simulation Complete. %d cases processed.", case_count);
        $finish;
    end
endmodule
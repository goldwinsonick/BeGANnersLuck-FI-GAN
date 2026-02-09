module generator_v3 #(
    parameter DATA_WIDTH = 16,
    parameter TANH_LUT_FILE_PATH = "rtl/memory/tanh_lut.mem"
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire valid_out,
    output wire signed [DATA_WIDTH-1:0] data_out
);

    // [WEIGHTS INSTANTIATION - TETAP SAMA]
    wire signed [DATA_WIDTH-1:0] w_e1 [0:8];  wire signed [DATA_WIDTH-1:0] b_e1;
    w_enc1 w_e1_inst (.w0(w_e1[0]), .w1(w_e1[1]), .w2(w_e1[2]), .w3(w_e1[3]), .w4(w_e1[4]), .w5(w_e1[5]), .w6(w_e1[6]), .w7(w_e1[7]), .w8(w_e1[8]), .bias(b_e1));
    
    wire signed [DATA_WIDTH-1:0] w_e2 [0:15]; wire signed [DATA_WIDTH-1:0] b_e2;
    w_enc2 w_e2_inst (.w0(w_e2[0]), .w1(w_e2[1]), .w2(w_e2[2]), .w3(w_e2[3]), .w4(w_e2[4]), .w5(w_e2[5]), .w6(w_e2[6]), .w7(w_e2[7]), .w8(w_e2[8]), .w9(w_e2[9]), .w10(w_e2[10]), .w11(w_e2[11]), .w12(w_e2[12]), .w13(w_e2[13]), .w14(w_e2[14]), .w15(w_e2[15]), .bias(b_e2));
    
    wire signed [DATA_WIDTH-1:0] w_e3 [0:15]; wire signed [DATA_WIDTH-1:0] b_e3;
    w_enc3 w_e3_inst (.w0(w_e3[0]), .w1(w_e3[1]), .w2(w_e3[2]), .w3(w_e3[3]), .w4(w_e3[4]), .w5(w_e3[5]), .w6(w_e3[6]), .w7(w_e3[7]), .w8(w_e3[8]), .w9(w_e3[9]), .w10(w_e3[10]), .w11(w_e3[11]), .w12(w_e3[12]), .w13(w_e3[13]), .w14(w_e3[14]), .w15(w_e3[15]), .bias(b_e3));
    
    wire signed [DATA_WIDTH-1:0] w_d1 [0:15]; wire signed [DATA_WIDTH-1:0] b_d1;
    w_dec1 w_d1_inst (.w0(w_d1[0]), .w1(w_d1[1]), .w2(w_d1[2]), .w3(w_d1[3]), .w4(w_d1[4]), .w5(w_d1[5]), .w6(w_d1[6]), .w7(w_d1[7]), .w8(w_d1[8]), .w9(w_d1[9]), .w10(w_d1[10]), .w11(w_d1[11]), .w12(w_d1[12]), .w13(w_d1[13]), .w14(w_d1[14]), .w15(w_d1[15]), .bias(b_d1));
    
    wire signed [DATA_WIDTH-1:0] w_d2 [0:15]; wire signed [DATA_WIDTH-1:0] b_d2;
    w_dec2 w_d2_inst (.w0(w_d2[0]), .w1(w_d2[1]), .w2(w_d2[2]), .w3(w_d2[3]), .w4(w_d2[4]), .w5(w_d2[5]), .w6(w_d2[6]), .w7(w_d2[7]), .w8(w_d2[8]), .w9(w_d2[9]), .w10(w_d2[10]), .w11(w_d2[11]), .w12(w_d2[12]), .w13(w_d2[13]), .w14(w_d2[14]), .w15(w_d2[15]), .bias(b_d2));
    
    wire signed [DATA_WIDTH-1:0] w_out [0:8]; wire signed [DATA_WIDTH-1:0] b_out;
    w_out w_out_inst (.w0(w_out[0]), .w1(w_out[1]), .w2(w_out[2]), .w3(w_out[3]), .w4(w_out[4]), .w5(w_out[5]), .w6(w_out[6]), .w7(w_out[7]), .w8(w_out[8]), .bias(b_out));

    // =========================================================================
    // 1. ENCODER PATH
    // =========================================================================
    // ... (Code Encoder Sama Persis) ...
    wire val_e1, val_act1; wire signed [DATA_WIDTH-1:0] dat_e1, dat_act1;
    conv2d_3x3_layer #(.IMG_WIDTH(32), .DATA_WIDTH(DATA_WIDTH)) enc1 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in), .w0(w_e1[0]), .w1(w_e1[1]), .w2(w_e1[2]), .w3(w_e1[3]), .w4(w_e1[4]), .w5(w_e1[5]), .w6(w_e1[6]), .w7(w_e1[7]), .w8(w_e1[8]), .bias(b_e1), .valid_out(val_e1), .data_out(dat_e1));
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) act1 (.clk(clk), .rst_n(rst_n), .valid_in(val_e1), .data_in(dat_e1), .valid_out(val_act1), .data_out(dat_act1));

    wire val_e2, val_act2; wire signed [DATA_WIDTH-1:0] dat_e2, dat_act2;
    conv2d_4x4_stride2_layer #(.IMG_WIDTH(30), .DATA_WIDTH(DATA_WIDTH)) enc2 (.clk(clk), .rst_n(rst_n), .valid_in(val_act1), .data_in(dat_act1), .w0(w_e2[0]), .w1(w_e2[1]), .w2(w_e2[2]), .w3(w_e2[3]), .w4(w_e2[4]), .w5(w_e2[5]), .w6(w_e2[6]), .w7(w_e2[7]), .w8(w_e2[8]), .w9(w_e2[9]), .w10(w_e2[10]), .w11(w_e2[11]), .w12(w_e2[12]), .w13(w_e2[13]), .w14(w_e2[14]), .w15(w_e2[15]), .bias(b_e2), .valid_out(val_e2), .data_out(dat_e2));
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) act2 (.clk(clk), .rst_n(rst_n), .valid_in(val_e2), .data_in(dat_e2), .valid_out(val_act2), .data_out(dat_act2));

    wire val_e3, val_act3; wire signed [DATA_WIDTH-1:0] dat_e3, dat_act3;
    conv2d_4x4_stride2_layer #(.IMG_WIDTH(14), .DATA_WIDTH(DATA_WIDTH)) enc3 (.clk(clk), .rst_n(rst_n), .valid_in(val_act2), .data_in(dat_act2), .w0(w_e3[0]), .w1(w_e3[1]), .w2(w_e3[2]), .w3(w_e3[3]), .w4(w_e3[4]), .w5(w_e3[5]), .w6(w_e3[6]), .w7(w_e3[7]), .w8(w_e3[8]), .w9(w_e3[9]), .w10(w_e3[10]), .w11(w_e3[11]), .w12(w_e3[12]), .w13(w_e3[13]), .w14(w_e3[14]), .w15(w_e3[15]), .bias(b_e3), .valid_out(val_e3), .data_out(dat_e3));
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) act3 (.clk(clk), .rst_n(rst_n), .valid_in(val_e3), .data_in(dat_e3), .valid_out(val_act3), .data_out(dat_act3));

    // =========================================================================
    // 2. FIFO BRIDGE 1 (Encoder -> Dec1)
    // =========================================================================
    wire fifo1_empty, fifo1_ren, dec1_ready;
    wire signed [DATA_WIDTH-1:0] fifo1_rdata;
    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(1024)) bridge_fifo1 (.clk(clk), .rst_n(rst_n), .wr_en(val_act3), .wr_data(dat_act3), .rd_en(fifo1_ren), .rd_data(fifo1_rdata), .empty(fifo1_empty), .full());
    
    reg b1_valid_out; reg signed [DATA_WIDTH-1:0] b1_data_out; reg [1:0] b1_state; localparam S_WAIT=0, S_SEND=1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin b1_valid_out <= 0; b1_state <= S_WAIT; end 
        else case(b1_state)
            S_WAIT: begin b1_valid_out <= 0; if (!fifo1_empty) b1_state <= S_SEND; end
            S_SEND: begin if (dec1_ready) begin b1_valid_out <= 1; b1_data_out <= fifo1_rdata; if (!fifo1_empty) b1_state <= S_SEND; else b1_state <= S_WAIT; end else b1_valid_out <= 1; end
        endcase
    end
    assign fifo1_ren = (!fifo1_empty) && (b1_state == S_WAIT || (b1_state == S_SEND && dec1_ready));

    // =========================================================================
    // 3. DECODER 1: 6x6 -> 14x14 (MATCHED)
    // =========================================================================
    wire val_d1, val_act_d1; wire signed [DATA_WIDTH-1:0] dat_d1, dat_act_d1;
    trans_conv2d_padded_layer #(
        .IN_WIDTH(6), .DATA_WIDTH(DATA_WIDTH),
        .PAD_TOP(2), .PAD_BOTTOM(3), .PAD_LEFT(2), .PAD_RIGHT(3) // Output 14x14
    ) dec1 (
        .clk(clk), .rst_n(rst_n), .valid_in(b1_valid_out), .data_in(b1_data_out), .ready_out(dec1_ready),
        .w0(w_d1[0]), .w1(w_d1[1]), .w2(w_d1[2]), .w3(w_d1[3]), .w4(w_d1[4]), .w5(w_d1[5]), .w6(w_d1[6]), .w7(w_d1[7]), .w8(w_d1[8]), .w9(w_d1[9]), .w10(w_d1[10]), .w11(w_d1[11]), .w12(w_d1[12]), .w13(w_d1[13]), .w14(w_d1[14]), .w15(w_d1[15]), .bias(b_d1), .valid_out(val_d1), .data_out(dat_d1)
    );
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) act_d1 (.clk(clk), .rst_n(rst_n), .valid_in(val_d1), .data_in(dat_d1), .valid_out(val_act_d1), .data_out(dat_act_d1));

    // =========================================================================
    // 4. FIFO BRIDGE 2 (Dec1 -> Dec2)
    // =========================================================================
    wire fifo2_empty, fifo2_ren, dec2_ready; wire signed [DATA_WIDTH-1:0] fifo2_rdata;
    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(1024)) bridge_fifo2 (.clk(clk), .rst_n(rst_n), .wr_en(val_act_d1), .wr_data(dat_act_d1), .rd_en(fifo2_ren), .rd_data(fifo2_rdata), .empty(fifo2_empty), .full());
    
    reg b2_valid_out; reg signed [DATA_WIDTH-1:0] b2_data_out; reg [1:0] b2_state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin b2_valid_out <= 0; b2_state <= S_WAIT; end 
        else case(b2_state)
            S_WAIT: begin b2_valid_out <= 0; if (!fifo2_empty) b2_state <= S_SEND; end
            S_SEND: begin if (dec2_ready) begin b2_valid_out <= 1; b2_data_out <= fifo2_rdata; if (!fifo2_empty) b2_state <= S_SEND; else b2_state <= S_WAIT; end else b2_valid_out <= 1; end
        endcase
    end
    assign fifo2_ren = (!fifo2_empty) && (b2_state == S_WAIT || (b2_state == S_SEND && dec2_ready));

    // =========================================================================
    // 5. DECODER 2: 14x14 -> 30x30 (FIXED)
    // =========================================================================
    // Logic Baru:
    // Input 14x14 -> Upsample 28x28.
    // Target Output: 30x30.
    // Conv Kernel 4x4 (-3 pixel).
    // Required Input Conv: 30 + 3 = 33x33.
    // Padding Need: 33 - 28 = 5 Pixel.
    // Config: Left=2, Right=3, Top=2, Bottom=3 (Total 5).
    
    wire val_d2, val_act_d2; wire signed [DATA_WIDTH-1:0] dat_d2, dat_act_d2;

    trans_conv2d_padded_layer #(
        .IN_WIDTH(14), .DATA_WIDTH(DATA_WIDTH),
        .PAD_TOP(2), .PAD_BOTTOM(3),  // TOTAL 5 VERTICAL PADDING
        .PAD_LEFT(2), .PAD_RIGHT(3)   // TOTAL 5 HORIZONTAL PADDING
    ) dec2 (
        .clk(clk), .rst_n(rst_n), .valid_in(b2_valid_out), .data_in(b2_data_out), .ready_out(dec2_ready),
        .w0(w_d2[0]), .w1(w_d2[1]), .w2(w_d2[2]), .w3(w_d2[3]), .w4(w_d2[4]), .w5(w_d2[5]), .w6(w_d2[6]), .w7(w_d2[7]), .w8(w_d2[8]), .w9(w_d2[9]), .w10(w_d2[10]), .w11(w_d2[11]), .w12(w_d2[12]), .w13(w_d2[13]), .w14(w_d2[14]), .w15(w_d2[15]), .bias(b_d2), .valid_out(val_d2), .data_out(dat_d2)
    );
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) act_d2 (.clk(clk), .rst_n(rst_n), .valid_in(val_d2), .data_in(dat_d2), .valid_out(val_act_d2), .data_out(dat_act_d2));

    // =========================================================================
    // 6. FIFO BRIDGE 3 & OUTPUT LAYER: 30x30 -> 28x28 (CLEANED)
    // =========================================================================
    // Input sekarang 30x30. Conv 3x3 Valid -> 28x28.
    // TIDAK PERLU PADDING TAMBAHAN DI SINI.
    
    wire fifo3_empty, fifo3_ren; wire signed [DATA_WIDTH-1:0] fifo3_rdata;
    
    // Output Layer (Conv 3x3) biasanya selalu siap (feed-forward), atau kita bisa hardcode ready.
    wire out_layer_ready = 1'b1; 

    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(1024)) bridge_fifo3 (.clk(clk), .rst_n(rst_n), .wr_en(val_act_d2), .wr_data(dat_act_d2), .rd_en(fifo3_ren), .rd_data(fifo3_rdata), .empty(fifo3_empty), .full());

    reg b3_valid_out; reg signed [DATA_WIDTH-1:0] b3_data_out; reg [1:0] b3_state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin b3_valid_out <= 0; b3_state <= S_WAIT; end 
        else case(b3_state)
            S_WAIT: begin b3_valid_out <= 0; if (!fifo3_empty) b3_state <= S_SEND; end
            S_SEND: begin 
                // Karena out_layer_ready hardcoded 1, logic lebih simple
                b3_valid_out <= 1; b3_data_out <= fifo3_rdata; 
                if (!fifo3_empty) b3_state <= S_SEND; else b3_state <= S_WAIT; 
            end
        endcase
    end
    assign fifo3_ren = (!fifo3_empty) && (b3_state == S_WAIT || b3_state == S_SEND);

    wire val_final; wire signed [DATA_WIDTH-1:0] dat_final;
    
    // Perhatikan: IMG_WIDTH disini adalah INPUT width = 30
    conv2d_3x3_layer #(.IMG_WIDTH(30), .DATA_WIDTH(DATA_WIDTH)) out_layer (
        .clk(clk), .rst_n(rst_n), .valid_in(b3_valid_out), .data_in(b3_data_out),
        .w0(w_out[0]), .w1(w_out[1]), .w2(w_out[2]), .w3(w_out[3]), .w4(w_out[4]), .w5(w_out[5]), .w6(w_out[6]), .w7(w_out[7]), .w8(w_out[8]), .bias(b_out),
        .valid_out(val_final), .data_out(dat_final)
    );

    activation_tanh #(.DATA_WIDTH(DATA_WIDTH), .LUT_FILE(TANH_LUT_FILE_PATH)) act_final (
        .clk(clk), .rst_n(rst_n), .valid_in(val_final), .data_in(dat_final), .valid_out(valid_out), .data_out(data_out)
    );

endmodule
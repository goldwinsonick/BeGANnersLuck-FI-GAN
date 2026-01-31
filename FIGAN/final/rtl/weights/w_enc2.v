module w_enc2 #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'hffd7; // -0.039982256
    assign w1 = 16'h0082; // 0.12679538
    assign w2 = 16'h0166; // 0.3494203
    assign w3 = 16'h004d; // 0.07508272
    assign w4 = 16'hff78; // -0.13280845
    assign w5 = 16'h00ef; // 0.23363534
    assign w6 = 16'h0193; // 0.39358726
    assign w7 = 16'h012b; // 0.29157487
    assign w8 = 16'h00c6; // 0.19298354
    assign w9 = 16'h0078; // 0.1175291
    assign w10 = 16'h0174; // 0.36340296
    assign w11 = 16'h012b; // 0.2919459
    assign w12 = 16'hffc3; // -0.05922883
    assign w13 = 16'h0077; // 0.115981355
    assign w14 = 16'h015f; // 0.34280795
    assign w15 = 16'h017f; // 0.37400633
    assign bias = 16'hfe4d; // -0.42497796
endmodule

module w_dec1 #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'h0049; // 0.07108475
    assign w1 = 16'hff43; // -0.18421693
    assign w2 = 16'h00ce; // 0.20094444
    assign w3 = 16'h0072; // 0.110861614
    assign w4 = 16'hffd2; // -0.044974573
    assign w5 = 16'h010d; // 0.26237184
    assign w6 = 16'hff50; // -0.17228301
    assign w7 = 16'hff39; // -0.19432153
    assign w8 = 16'h005a; // 0.08797099
    assign w9 = 16'h00a7; // 0.16284074
    assign w10 = 16'hf8fe; // -1.752122
    assign w11 = 16'h007e; // 0.12302382
    assign w12 = 16'hff14; // -0.23057143
    assign w13 = 16'h0019; // 0.024225872
    assign w14 = 16'hff9e; // -0.09571835
    assign w15 = 16'h0014; // 0.019340357
    assign bias = 16'hfffd; // -0.0026870945
endmodule

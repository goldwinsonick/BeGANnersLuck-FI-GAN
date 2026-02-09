module w_enc3 #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'hffed; // -0.018594407
    assign w1 = 16'h002a; // 0.041222993
    assign w2 = 16'h0062; // 0.09599133
    assign w3 = 16'h009e; // 0.15386139
    assign w4 = 16'h021f; // 0.5303651
    assign w5 = 16'h01f6; // 0.4905897
    assign w6 = 16'h0016; // 0.021607483
    assign w7 = 16'hff77; // -0.13415845
    assign w8 = 16'h023e; // 0.5605095
    assign w9 = 16'h02ab; // 0.6666529
    assign w10 = 16'hffd6; // -0.040852595
    assign w11 = 16'h0095; // 0.1451826
    assign w12 = 16'hffe3; // -0.028626751
    assign w13 = 16'h0099; // 0.14893115
    assign w14 = 16'h0050; // 0.07855176
    assign w15 = 16'h00c4; // 0.19098553
    assign bias = 16'hff14; // -0.23080572
endmodule

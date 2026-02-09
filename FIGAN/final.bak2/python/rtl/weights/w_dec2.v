module w_dec2 #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'h0114; // 0.2694348
    assign w1 = 16'h0108; // 0.2577914
    assign w2 = 16'h00ee; // 0.23290657
    assign w3 = 16'h00fa; // 0.24374965
    assign w4 = 16'h00e9; // 0.2274598
    assign w5 = 16'h00dd; // 0.21556038
    assign w6 = 16'h00cf; // 0.20173699
    assign w7 = 16'h00d9; // 0.21193857
    assign w8 = 16'h00ed; // 0.23102364
    assign w9 = 16'h00d6; // 0.20860985
    assign w10 = 16'h00e7; // 0.22562516
    assign w11 = 16'h00f3; // 0.23734564
    assign w12 = 16'h010e; // 0.26321673
    assign w13 = 16'h00fa; // 0.24426194
    assign w14 = 16'h0104; // 0.254205
    assign w15 = 16'h0106; // 0.2562604
    assign bias = 16'h0001; // 0.0007060909
endmodule

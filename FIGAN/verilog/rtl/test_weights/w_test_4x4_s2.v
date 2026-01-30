// [w_test_4x4_s2.v] Auto-generated weight module
module w_test_4x4_s2 #(
    parameter DATA_WIDTH = 16
)(
    output wire signed [DATA_WIDTH-1:0] w0,
    output wire signed [DATA_WIDTH-1:0] w1,
    output wire signed [DATA_WIDTH-1:0] w2,
    output wire signed [DATA_WIDTH-1:0] w3,
    output wire signed [DATA_WIDTH-1:0] w4,
    output wire signed [DATA_WIDTH-1:0] w5,
    output wire signed [DATA_WIDTH-1:0] w6,
    output wire signed [DATA_WIDTH-1:0] w7,
    output wire signed [DATA_WIDTH-1:0] w8,
    output wire signed [DATA_WIDTH-1:0] w9,
    output wire signed [DATA_WIDTH-1:0] w10,
    output wire signed [DATA_WIDTH-1:0] w11,
    output wire signed [DATA_WIDTH-1:0] w12,
    output wire signed [DATA_WIDTH-1:0] w13,
    output wire signed [DATA_WIDTH-1:0] w14,
    output wire signed [DATA_WIDTH-1:0] w15,
    output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0  = 16'h0150; // 0.3282
    assign w1  = 16'h01ff; // 0.4992
    assign w2  = 16'h0153; // 0.3310
    assign w3  = 16'hff4c; // -0.1753
    assign w4  = 16'h000a; // 0.0095
    assign w5  = 16'hff1f; // -0.2193
    assign w6  = 16'hff68; // -0.1488
    assign w7  = 16'h0107; // 0.2566
    assign w8  = 16'h0055; // 0.0829
    assign w9  = 16'h012b; // 0.2925
    assign w10 = 16'hffd4; // -0.0431
    assign w11 = 16'h01fa; // 0.4942
    assign w12 = 16'h002c; // 0.0434
    assign w13 = 16'hff7d; // -0.1280
    assign w14 = 16'hfee2; // -0.2796
    assign w15 = 16'hfeb0; // -0.3278
    assign bias = 16'hff33; // -0.2000

endmodule

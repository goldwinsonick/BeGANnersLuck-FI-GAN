// [w_test_3x3.v] Auto-generated weight module
module w_test_3x3 #(
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
    output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0  = 16'h002b; // 0.0419
    assign w1  = 16'hfe4d; // -0.4247
    assign w2  = 16'hfe8b; // -0.3645
    assign w3  = 16'hfe97; // -0.3523
    assign w4  = 16'h0155; // 0.3332
    assign w5  = 16'hfed0; // -0.2972
    assign w6  = 16'hfeb1; // -0.3271
    assign w7  = 16'h000c; // 0.0115
    assign w8  = 16'h01ef; // 0.4831
    assign bias = 16'h009a; // 0.1500

endmodule

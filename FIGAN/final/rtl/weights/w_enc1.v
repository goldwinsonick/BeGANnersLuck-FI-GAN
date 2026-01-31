module w_enc1 #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'hffe7; // -0.02436036
    assign w1 = 16'h0011; // 0.016166644
    assign w2 = 16'h0166; // 0.34977525
    assign w3 = 16'h0097; // 0.14731516
    assign w4 = 16'h0038; // 0.05467805
    assign w5 = 16'h004f; // 0.07686999
    assign w6 = 16'h010c; // 0.26139614
    assign w7 = 16'h01ce; // 0.45074344
    assign w8 = 16'h002d; // 0.04383374
    assign bias = 16'hffa2; // -0.09191805
endmodule

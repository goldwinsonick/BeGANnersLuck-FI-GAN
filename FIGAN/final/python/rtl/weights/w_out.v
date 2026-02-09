module w_out #(parameter DATA_WIDTH=16)(
    output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] bias
);

    assign w0 = 16'h010c; // 0.26219544
    assign w1 = 16'h0110; // 0.2654319
    assign w2 = 16'h00f4; // 0.23848183
    assign w3 = 16'h0090; // 0.1406726
    assign w4 = 16'h0040; // 0.06252538
    assign w5 = 16'h00f0; // 0.23415898
    assign w6 = 16'h0064; // 0.0980321
    assign w7 = 16'h0017; // 0.022261728
    assign w8 = 16'h012a; // 0.29091346
    assign bias = 16'h007c; // 0.12064393
endmodule

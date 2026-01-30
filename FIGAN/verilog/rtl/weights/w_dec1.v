module w_dec1 #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'hff33;
assign w1 = 16'hff0a;
assign w2 = 16'h01ab;
assign w3 = 16'h00b0;
assign w4 = 16'hffbd;
assign w5 = 16'hff32;
assign w6 = 16'h0098;
assign w7 = 16'hff09;
assign w8 = 16'h011b;
assign w9 = 16'h01cd;
assign w10 = 16'hfe1a;
assign w11 = 16'hff38;
assign w12 = 16'h0086;
assign w13 = 16'h0115;
assign w14 = 16'hff44;
assign w15 = 16'hfe9c;
assign bias = 16'h0066;
endmodule

module w_dec2 #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'h01f4;
assign w1 = 16'hfe2a;
assign w2 = 16'hfeaf;
assign w3 = 16'hff88;
assign w4 = 16'hfee0;
assign w5 = 16'hfeed;
assign w6 = 16'hffca;
assign w7 = 16'h00c7;
assign w8 = 16'h00d8;
assign w9 = 16'hff9b;
assign w10 = 16'hfe51;
assign w11 = 16'hff2d;
assign w12 = 16'hfe42;
assign w13 = 16'hff02;
assign w14 = 16'h0074;
assign w15 = 16'hffed;
assign bias = 16'hff9a;
endmodule

module w_enc3 #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'hff44;
assign w1 = 16'hff00;
assign w2 = 16'h00f4;
assign w3 = 16'h019c;
assign w4 = 16'h00d1;
assign w5 = 16'hfeb7;
assign w6 = 16'hff0e;
assign w7 = 16'h00a0;
assign w8 = 16'hff54;
assign w9 = 16'hfeb1;
assign w10 = 16'hfe73;
assign w11 = 16'hffc6;
assign w12 = 16'h01ea;
assign w13 = 16'hfefd;
assign w14 = 16'h00f4;
assign w15 = 16'hffee;
assign bias = 16'h0033;
endmodule

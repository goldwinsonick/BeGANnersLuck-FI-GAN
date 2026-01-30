module w_enc2 #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] w9, output wire signed [DATA_WIDTH-1:0] w10, output wire signed [DATA_WIDTH-1:0] w11, output wire signed [DATA_WIDTH-1:0] w12, output wire signed [DATA_WIDTH-1:0] w13, output wire signed [DATA_WIDTH-1:0] w14, output wire signed [DATA_WIDTH-1:0] w15, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'h0175;
assign w1 = 16'hfe29;
assign w2 = 16'hff22;
assign w3 = 16'h01e6;
assign w4 = 16'hffb8;
assign w5 = 16'hfffe;
assign w6 = 16'h01f0;
assign w7 = 16'h006a;
assign w8 = 16'hfe9a;
assign w9 = 16'h00eb;
assign w10 = 16'h0154;
assign w11 = 16'hfe87;
assign w12 = 16'h01de;
assign w13 = 16'h0127;
assign w14 = 16'hffad;
assign w15 = 16'h00d3;
assign bias = 16'hffcd;
endmodule

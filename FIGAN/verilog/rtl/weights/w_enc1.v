module w_enc1 #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'hfee3;
assign w1 = 16'hfeee;
assign w2 = 16'h01a7;
assign w3 = 16'h0056;
assign w4 = 16'h0016;
assign w5 = 16'hfe89;
assign w6 = 16'h00fc;
assign w7 = 16'hfeb8;
assign w8 = 16'hfe17;
assign bias = 16'h0066;
endmodule

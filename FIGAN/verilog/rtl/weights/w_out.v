module w_out #(parameter DATA_WIDTH=16)(
output wire signed [DATA_WIDTH-1:0] w0, output wire signed [DATA_WIDTH-1:0] w1, output wire signed [DATA_WIDTH-1:0] w2, output wire signed [DATA_WIDTH-1:0] w3, output wire signed [DATA_WIDTH-1:0] w4, output wire signed [DATA_WIDTH-1:0] w5, output wire signed [DATA_WIDTH-1:0] w6, output wire signed [DATA_WIDTH-1:0] w7, output wire signed [DATA_WIDTH-1:0] w8, output wire signed [DATA_WIDTH-1:0] bias);
assign w0 = 16'hfee5;
assign w1 = 16'h003a;
assign w2 = 16'h01f2;
assign w3 = 16'hfe18;
assign w4 = 16'hffb3;
assign w5 = 16'hff0a;
assign w6 = 16'hfeb6;
assign w7 = 16'h019b;
assign w8 = 16'hff76;
assign bias = 16'h0000;
endmodule

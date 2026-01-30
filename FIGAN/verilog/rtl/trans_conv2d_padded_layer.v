module trans_conv2d_padded_layer #(
    parameter IN_WIDTH   = 7,
    parameter DATA_WIDTH = 16,
    parameter PAD_TOP    = 1,
    parameter PAD_BOTTOM = 2,
    parameter PAD_LEFT   = 1,
    parameter PAD_RIGHT  = 2
)(
    input  wire clk, rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire ready_out, // Backpressure ke module sebelumnya

    // Weights
    input  wire signed [DATA_WIDTH-1:0] w0,w1,w2,w3,w4,w5,w6,w7,
    input  wire signed [DATA_WIDTH-1:0] w8,w9,w10,w11,w12,w13,w14,w15,
    input  wire signed [DATA_WIDTH-1:0] bias,

    output wire valid_out,
    output wire signed [DATA_WIDTH-1:0] data_out
);
    
    // 1. Upsample 2D (Updated)
    wire up_valid, up_ready;
    wire signed [DATA_WIDTH-1:0] up_data;

    // PENTING: Pakai upsample_layer_2d
    upsample_layer_2d #(
        .IN_WIDTH(IN_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH)
    ) upsample_inst (
        .clk(clk), .rst_n(rst_n),
        .valid_in(valid_in), .data_in(data_in), .ready_in(ready_out),
        .ready_out(up_ready), .valid_out(up_valid), .data_out(up_data)
    );

    // 2. Zero Padding (Sama seperti sebelumnya)
    wire pad_valid, pad_ready;
    wire signed [DATA_WIDTH-1:0] pad_data;
    
    zero_pad_layer #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IN_WIDTH * 2),   
        .IMG_HEIGHT(IN_WIDTH * 2),  
        .PAD_TOP(PAD_TOP), .PAD_BOTTOM(PAD_BOTTOM),
        .PAD_LEFT(PAD_LEFT), .PAD_RIGHT(PAD_RIGHT)
    ) pad_inst (
        .clk(clk), .rst_n(rst_n),
        .valid_in(up_valid), .data_in(up_data), .ready_in(up_ready),
        .ready_out(pad_ready), .valid_out(pad_valid), .data_out(pad_data)
    );

    // 3. Conv2d (Sama seperti sebelumnya)
    localparam CONV_IN_WIDTH = (IN_WIDTH * 2) + PAD_LEFT + PAD_RIGHT;

    conv2d_4x4_layer #(
        .IMG_WIDTH(CONV_IN_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH)
    ) conv_inst (
        .clk(clk), .rst_n(rst_n),
        .valid_in(pad_valid), .data_in(pad_data), 
        .w0(w0), .w1(w1), .w2(w2), .w3(w3), .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .w8(w8), .w9(w9), .w10(w10), .w11(w11), .w12(w12), .w13(w13), .w14(w14), .w15(w15),
        .bias(bias),
        .valid_out(valid_out), .data_out(data_out)
    );
    
    assign pad_ready = 1'b1; 

endmodule
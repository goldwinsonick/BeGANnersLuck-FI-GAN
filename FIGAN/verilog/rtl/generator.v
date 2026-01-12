module generator #(
    parameter DATA_WIDTH = 16
)(
    input  wire clk, rst_n, valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    // Weights L0
    input wire signed [DATA_WIDTH-1:0] s0_w0, s0_w1, s0_w2, s0_w3, s0_w4, s0_w5, s0_w6, s0_w7,
    input wire signed [DATA_WIDTH-1:0] s0_w8, s0_w9, s0_w10, s0_w11, s0_w12, s0_w13, s0_w14, s0_w15,
    input wire signed [DATA_WIDTH-1:0] s0_bias,
    // Weights L1
    input wire signed [DATA_WIDTH-1:0] s1_w0, s1_w1, s1_w2, s1_w3, s1_w4, s1_w5, s1_w6, s1_w7,
    input wire signed [DATA_WIDTH-1:0] s1_w8, s1_w9, s1_w10, s1_w11, s1_w12, s1_w13, s1_w14, s1_w15,
    input wire signed [DATA_WIDTH-1:0] s1_bias,
    // Dummy Weights Out
    input wire signed [DATA_WIDTH-1:0] out_w0, out_w1, out_w2, out_w3, out_w4, out_w5, out_w6, out_w7, out_w8,
    input wire signed [DATA_WIDTH-1:0] out_bias,

    output wire valid_out,
    output wire signed [DATA_WIDTH-1:0] data_out
);

    // Sinyal Internal Layer 0
    wire l0_valid, act0_valid;
    wire signed [DATA_WIDTH-1:0] l0_data, act0_data;

    // Sinyal FIFO Bridge
    wire fifo_empty, fifo_full;
    wire signed [DATA_WIDTH-1:0] fifo_rdata;
    wire fifo_ren;
    
    // Sinyal Internal Layer 1
    wire l1_valid, act1_valid;
    wire signed [DATA_WIDTH-1:0] l1_data, act1_data;
    
    // Sinyal Ready dari Layer 1 (Backpressure)
    wire l1_ready_in;

    // --- LAYER 0 (Input 8 -> Output 13) ---
    // Layer 0 jalan terus (Producer)
    trans_conv2d_4x4_layer #(.IN_WIDTH(8), .DATA_WIDTH(DATA_WIDTH)) syn0 (
        .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .data_in(data_in),
        .w0(s0_w0), .w1(s0_w1), .w2(s0_w2), .w3(s0_w3), .w4(s0_w4), .w5(s0_w5), .w6(s0_w6), .w7(s0_w7),
        .w8(s0_w8), .w9(s0_w9), .w10(s0_w10), .w11(s0_w11), .w12(s0_w12), .w13(s0_w13), .w14(s0_w14), .w15(s0_w15),
        .bias(s0_bias), .valid_out(l0_valid), .data_out(l0_data)
    );
    
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) relu0 (
        .clk(clk), .rst_n(rst_n), .valid_in(l0_valid), .data_in(l0_data), 
        .valid_out(act0_valid), .data_out(act0_data)
    );

    // --- FIFO BRIDGE (PENYELAMAT) ---
    // Menampung data dari Layer 0 saat Layer 1 sibuk
    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(1024)) bridge_fifo (
        .clk(clk), .rst_n(rst_n),
        .wr_en(act0_valid),   // Tulis saat Layer 0 punya data
        .wr_data(act0_data),
        .rd_en(fifo_ren),     // Baca saat diminta logic di bawah
        .rd_data(fifo_rdata),
        .empty(fifo_empty),
        .full(fifo_full)      // Idealnya Layer 0 dicegah kalau full, tapi 1024 cukup besar
    );

    // Logic Baca FIFO:
    // Baca HANYA JIKA: Ada isi (empty=0) DAN Layer 1 Siap (l1_ready_in=1)
    assign fifo_ren = (!fifo_empty) && l1_ready_in;

    // --- LAYER 1 (Input 13 -> Output 23) ---
    // Kita perlu modifikasi sedikit trans_conv2d untuk mengeluarkan port 'ready_in'
    // Tapi karena kamu pakai modul standar, kita asumsikan kamu perlu UPDATE trans_conv2d DULU.
    // TUNGGU, Upsample punya ready_in, tapi trans_conv2d wrapper tidak mengeksposnya.
    
    // SOLUSI: KITA BONGKAR WRAPPERNYA DI SINI (Instantiate manual Upsample + Conv)
    // ATAU: Update trans_conv2d_4x4_layer.v agar punya output ready_for_input
    
    // Mari kita pakai cara paling bersih: Update trans_conv2d untuk expose ready signal
    trans_conv2d_4x4_layer #(.IN_WIDTH(13), .DATA_WIDTH(DATA_WIDTH)) syn1 (
        .clk(clk), .rst_n(rst_n),
        
        // Input dari FIFO
        // Perhatikan: Data FIFO keluar 1 cycle setelah rd_en. 
        // Logic 'fifo_ren' di atas sudah menangani handshake sederhana.
        // Kita butuh buffer kecil atau logic skid buffer, TAPI
        // Karena kita pakai logic sederhana: 
        // Saat fifo_ren high, cycle depannya data valid.
        
        .valid_in(fifo_ren),    // Valid telat 1 cycle (sama kayak latency FIFO read)
        .data_in(fifo_rdata),   // Data dari FIFO
        .ready_out(l1_ready_in), // Sinyal READY dari Upsampler di dalam Layer 1
        
        .w0(s1_w0), .w1(s1_w1), .w2(s1_w2), .w3(s1_w3), .w4(s1_w4), .w5(s1_w5), .w6(s1_w6), .w7(s1_w7),
        .w8(s1_w8), .w9(s1_w9), .w10(s1_w10), .w11(s1_w11), .w12(s1_w12), .w13(s1_w13), .w14(s1_w14), .w15(s1_w15),
        .bias(s1_bias), .valid_out(l1_valid), .data_out(l1_data)
    );
    
    leaky_relu_layer #(.DATA_WIDTH(DATA_WIDTH)) relu1 (
        .clk(clk), .rst_n(rst_n), .valid_in(l1_valid), .data_in(l1_data), 
        .valid_out(act1_valid), .data_out(act1_data)
    );

    assign valid_out = act1_valid;
    assign data_out  = act1_data;

endmodule
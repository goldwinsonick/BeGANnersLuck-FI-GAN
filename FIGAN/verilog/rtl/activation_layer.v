module activation_layer #(
    parameter DATA_WIDTH = 16,
    parameter LUT_FILE   = "data/memory/sigmoid_lut.mem", // Ganti "tanh_lut.mem" saat instansiasi
    parameter IS_TANH    = 0                  // 0 = Sigmoid, 1 = Tanh
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // --- Konfigurasi Konstanta Q6.10 ---
    // 1.0 dalam Q6.10 = 1024 (0x0400)
    localparam signed [15:0] ONE_VAL  = 16'h0400; 
    localparam signed [15:0] ZERO_VAL = 16'h0000;
    localparam signed [15:0] NEG_ONE  = 16'hfc00; // -1.0 dalam Two's comp
    
    // --- Batas Range Tabel ---
    // Kita generate tabel untuk range -4.0 s.d 4.0
    // 4.0 dalam Q6.10 = 4 * 1024 = 4096 (0x1000)
    localparam signed [15:0] MAX_LIMIT = 16'h1000;
    localparam signed [15:0] MIN_LIMIT = -16'h1000; // 0xF000

    // --- Definisi ROM/RAM ---
    // 1024 baris, lebar 16-bit
    reg [15:0] lut_mem [0:1023];

    // Load file .mem saat inisialisasi FPGA
    initial begin
        $readmemh(LUT_FILE, lut_mem);
    end

    // --- Logic Address Calculation ---
    // Kita perlu memetakan input range [-4, 4] ke index [0, 1023]
    // Rumus pendekatan: index = (data_in - MIN_LIMIT) >> shift_factor
    // Agar simple, kita ambil bit-bit tertentu saja.
    // Range total = 8.0. Jumlah entry = 1024. Resolusi = 8/1024 = 1/128.
    // Di Q6.10, bit ke-0 bernilai 1/1024. 
    // Jadi kita ambil 10 bit dari posisi tertentu.
    
    reg [9:0] rom_addr;
    wire signed [15:0] offset_data;
    
    // Geser data input supaya -4.0 menjadi 0 (untuk index array)
    assign offset_data = data_in - MIN_LIMIT; 
    
    // Kita buang 3 bit LSB untuk scaling ke 1024 entry (Mapping kasar tapi cepat)
    // Sesuaikan shifting ini dengan step size python script tadi.
    // Script step ~0.0078 (1/128). Q6.10 LSB = 1/1024.
    // 1/128 adalah 8x dari 1/1024. Jadi geser kanan 3 bit.
    wire [9:0] calc_index = offset_data[12:3]; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out  <= 0;
        end else if (valid_in) begin
            valid_out <= 1;

            // --- Cek Saturasi (Clamping) ---
            if (data_in >= MAX_LIMIT) begin
                // Jika input > 4.0
                data_out <= ONE_VAL; 
            end 
            else if (data_in <= MIN_LIMIT) begin
                // Jika input < -4.0
                if (IS_TANH) 
                    data_out <= NEG_ONE; // Tanh min -1
                else 
                    data_out <= ZERO_VAL; // Sigmoid min 0
            end 
            else begin
                // Jika input di area aktif, baca tabel
                data_out <= lut_mem[calc_index];
            end
        end else begin
            valid_out <= 0;
        end
    end

endmodule
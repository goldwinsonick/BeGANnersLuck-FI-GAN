module upsample_layer #(
    parameter IN_WIDTH   = 16, 
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output reg  ready_in, 

    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // Parameter
    localparam OUT_WIDTH = IN_WIDTH * 2; // 26 jika Input 13

    // State Definition
    localparam S_IDLE       = 0;
    localparam S_EMIT_ZERO  = 1; // Kirim 0 setelah pixel (Horizontal)
    localparam S_PAD_ROW    = 2; // Kirim baris 0 (Vertical)

    reg [1:0] state;
    
    // Counter Pixel dalam satu baris (0 sampai IN_WIDTH)
    reg [15:0] px_count; 
    // Counter untuk Vertical Padding (0 sampai OUT_WIDTH)
    reg [15:0] pad_count;

    // Buffer data input biar stabil
    reg signed [DATA_WIDTH-1:0] data_buffer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            valid_out   <= 0;
            data_out    <= 0;
            ready_in    <= 1; // Siap terima
            px_count    <= 0;
            pad_count   <= 0;
            data_buffer <= 0;
        end else begin
            case (state)
                // ---------------------------------------------------------
                // 1. IDLE: Tunggu Data Masuk
                // ---------------------------------------------------------
                S_IDLE: begin
                    if (valid_in && ready_in) begin
                        // Simpan data, langsung kirim keluar (Pixel Asli)
                        valid_out   <= 1;
                        data_out    <= data_in;
                        data_buffer <= data_in; // Backup (opsional)
                        
                        ready_in    <= 0; // Tutup pintu, kita mau sibuk
                        state       <= S_EMIT_ZERO;
                        
                        // Update counter pixel
                        if (px_count == IN_WIDTH - 1) begin
                            px_count <= 0; // Reset utk baris baru
                            // Tandai flag khusus di state berikutnya kalau ini akhir baris
                        end else begin
                            px_count <= px_count + 1;
                        end
                    end else begin
                        valid_out <= 0;
                        ready_in  <= 1; // Pastikan pintu terbuka
                    end
                end

                // ---------------------------------------------------------
                // 2. EMIT ZERO: Kirim angka 0 (Horizontal Upsample)
                // ---------------------------------------------------------
                S_EMIT_ZERO: begin
                    valid_out <= 1;
                    data_out  <= 0; // Kirim Nol
                    ready_in  <= 0;

                    // Cek logic: Apakah baris tadi sudah selesai?
                    // Kita cek px_count. Karena di step IDLE tadi sudah di-reset jadi 0 
                    // JIKA baris selesai, maka px_count sekarang pasti 0.
                    if (px_count == 0) begin
                        state <= S_PAD_ROW; // Lanjut bikin baris kosong
                    end else begin
                        state <= S_IDLE;    // Balik terima pixel berikutnya
                        ready_in <= 1;      // Buka pintu
                    end
                end

                // ---------------------------------------------------------
                // 3. PAD ROW: Kirim 1 baris penuh isinya 0 (Vertical Upsample)
                // ---------------------------------------------------------
                S_PAD_ROW: begin
                    valid_out <= 1;
                    data_out  <= 0;
                    ready_in  <= 0;

                    // Kita harus kirim sebanyak OUT_WIDTH (26 kali)
                    if (pad_count == OUT_WIDTH - 1) begin
                        pad_count <= 0;
                        state     <= S_IDLE; // Selesai padding, balik terima data
                        ready_in  <= 1;      // Buka pintu
                    end else begin
                        pad_count <= pad_count + 1;
                    end
                end
            endcase
        end
    end

endmodule
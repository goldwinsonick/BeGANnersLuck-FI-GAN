module upsample_layer_2d #(
    parameter IN_WIDTH   = 14, 
    parameter DATA_WIDTH = 16
)(
    input  wire clk, rst_n,
    
    // Upstream
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire ready_in, 

    // Downstream
    input  wire ready_out, 
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    localparam OUT_WIDTH = IN_WIDTH * 2;
    localparam S_READ_PIXEL  = 0;
    localparam S_EMIT_H_ZERO = 1; 
    localparam S_EMIT_V_ROW  = 2; 
    
    reg [1:0] state;
    reg [15:0] col_cnt; 
    reg [15:0] row_cnt; 

    // Combinational Ready: Hanya minta data saat kita di state baca DAN downstream aman
    // Kita tambahkan proteksi (!valid_out) agar tidak minta data baru kalau data lama masih nyangkut
    assign ready_in = (state == S_READ_PIXEL) && ready_out && (!valid_out || ready_out);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_READ_PIXEL;
            valid_out <= 0; data_out <= 0;
            col_cnt <= 0; row_cnt <= 0;
        end else begin
            // ============================================================
            // CRITICAL FIX: FREEZE LOGIC
            // Jika kita sedang assert Valid, TAPI downstream tidak Ready,
            // Kita HARUS menahan state dan data output. Jangan berubah!
            // ============================================================
            if (valid_out && !ready_out) begin
                // HOLD EVERYTHING (Stall)
                valid_out <= 1; 
                // data_out keep previous value
                // state keep previous value
            end else begin
                // ========================================================
                // NORMAL OPERATION
                // ========================================================
                valid_out <= 0; // Default low kecuali di-set di bawah

                case (state)
                    // 1. BACA PIXEL (P)
                    S_READ_PIXEL: begin
                        if (valid_in && ready_out) begin
                            valid_out <= 1;
                            data_out  <= data_in;
                            state     <= S_EMIT_H_ZERO;
                        end
                    end

                    // 2. KIRIM ZERO HORIZONTAL (0)
                    // Output sequence jadi: P, 0, P, 0...
                    S_EMIT_H_ZERO: begin
                        // Kita bisa langsung kirim karena ini generate data internal
                        // (Backpressure sudah dicek di blok Freeze di atas)
                        valid_out <= 1;
                        data_out  <= 0;

                        if (col_cnt == IN_WIDTH - 1) begin
                            col_cnt <= 0;
                            state   <= S_EMIT_V_ROW;
                        end else begin
                            col_cnt <= col_cnt + 1;
                            state   <= S_READ_PIXEL;
                        end
                    end

                    // 3. KIRIM FULL BARIS ZERO (Vertical Stride)
                    S_EMIT_V_ROW: begin
                        valid_out <= 1;
                        data_out  <= 0;
                        
                        if (row_cnt == OUT_WIDTH - 1) begin
                            row_cnt <= 0;
                            state   <= S_READ_PIXEL;
                        end else begin
                            row_cnt <= row_cnt + 1;
                        end
                    end
                endcase
            end
        end
    end
endmodule
// [activation_tanh.v]
// Dedicated Tanh Activation for Q6.10 Fixed-Point
// Range: -4.0 to +4.0 mapped to 1024 LUT entries.
// Outside range: Clamped to -1.0 or +1.0.

module activation_tanh #(
    parameter DATA_WIDTH = 16,
    parameter LUT_FILE   = "data/memory/tanh_lut.mem"
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // --- Konstanta Q6.10 ---
    // 1.0 = 1024 (0x0400)
    localparam signed [15:0] ONE_VAL  = 16'h0400; 
    localparam signed [15:0] NEG_ONE  = -16'h0400; // 0xFC00

    // --- Batas Input LUT ---
    // Range -4.0 s.d 4.0
    // 4.0 * 1024 = 4096 (0x1000)
    localparam signed [15:0] MAX_IN =  16'h1000;
    localparam signed [15:0] MIN_IN = -16'h1000; // 0xF000

    // --- ROM Definition ---
    reg [15:0] lut_mem [0:1023];

    initial begin
        $readmemh(LUT_FILE, lut_mem);
    end

    // --- Address Calculation ---
    // Mapping: [-4096 ... 4096] -> [0 ... 1023]
    // Step size calculation:
    // Total Range = 8192. LUT Size = 1024.
    // Divisor = 8192 / 1024 = 8.
    // Index = (data_in - MIN_IN) / 8  --> (data_in - MIN_IN) >> 3
    
    wire signed [16:0] offset_calc; // Pakai 1 bit extra buat safe arithmetic
    assign offset_calc = data_in - MIN_IN;
    
    wire [9:0] addr;
    assign addr = offset_calc[12:3]; // Ambil bit [12:3] sama dengan div 8

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out  <= 0;
        end else if (valid_in) begin
            valid_out <= 1;

            if (data_in >= MAX_IN) begin
                // Saturasi Positif (> 4.0) -> Output 1.0
                data_out <= ONE_VAL;
            end 
            else if (data_in <= MIN_IN) begin
                // Saturasi Negatif (< -4.0) -> Output -1.0
                data_out <= NEG_ONE;
            end 
            else begin
                // Area Aktif -> Baca LUT
                data_out <= lut_mem[addr];
            end
        end else begin
            valid_out <= 0;
        end
    end

endmodule
module leaky_relu_layer #(
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // --- Internal Signals for Calculation ---
    wire signed [DATA_WIDTH-1:0] val_shift_3;
    wire signed [DATA_WIDTH-1:0] val_shift_4;
    wire signed [DATA_WIDTH-1:0] val_shift_6;
    wire signed [DATA_WIDTH-1:0] neg_result;

    // --- Optimization Logic (Approximation of 0.2) ---
    // Target: 0.2
    // Approx: 13/64 = 0.203125 (Sangat dekat dengan 0.2)
    // 13x = 8x + 4x + 1x
    // Result = (x >>> 3) + (x >>> 4) + (x >>> 6)
    
    assign val_shift_3 = data_in >>> 3; // x / 8
    assign val_shift_4 = data_in >>> 4; // x / 16
    assign val_shift_6 = data_in >>> 6; // x / 64
    
    // Penjumlahan Sederhana
    assign neg_result = val_shift_3 + val_shift_4 + val_shift_6;

    // --- Main Process ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out  <= 0;
        end 
        else if (valid_in) begin
            valid_out <= 1;
            
            // Check sign of input
            if (data_in >= 0) begin
                // Positive case: Output equals Input
                data_out <= data_in;
            end else begin
                // Negative case: Output equals Input * 0.2 (approx)
                data_out <= neg_result;
            end
        end 
        else begin
            valid_out <= 0;
        end
    end

endmodule
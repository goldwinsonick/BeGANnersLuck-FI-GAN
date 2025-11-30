// [pwl_tanh_3.v] PWL Tanh Function 3 Slice/Gradient

module pwl_tanh_3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Q8.8 constants
// 1.0 = 256, 0.5 = 128
localparam signed [15:0] ONE      = 16'sd256;    // 1.0
localparam signed [15:0] NEG_ONE  = -16'sd256;   // -1.0
localparam signed [15:0] SLOPE    = 16'sd128;    // 0.5 (slope for middle region)

// Boundary points for 3 segments: x < -1, -1 <= x <= 1, x > 1
localparam signed [15:0] BOUND_NEG = -16'sd256;  // -1.0
localparam signed [15:0] BOUND_POS = 16'sd256;   // 1.0

// Internal signals
reg signed [31:0] mult_result;
reg signed [15:0] y_next;

// Combinational: PWL approximation
// Tanh(x) ≈ -1 if x < -1
//         ≈ 0.5*x if -1 <= x <= 1
//         ≈ 1 if x > 1
always @(*) begin
    if (x_in < BOUND_NEG) begin
        // Region 1: saturate to -1
        y_next = NEG_ONE;
    end
    else if (x_in > BOUND_POS) begin
        // Region 3: saturate to 1
        y_next = ONE;
    end
    else begin
        // Region 2: linear approximation y = 0.5*x
        mult_result = x_in * SLOPE;
        y_next = mult_result[23:8]; // Shift right by 8 for Q8.8
    end
end

// Sequential: register outputs
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_out <= 1'b0;
        y_out     <= 16'sd0;
    end
    else begin
        valid_out <= valid_in;
        y_out     <= y_next;
    end
end

endmodule
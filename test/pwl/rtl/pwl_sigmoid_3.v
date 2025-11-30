// [pwl_sigmoid_3.v] PWL Sigmoid Function 3 Slice/Gradient

module pwl_sigmoid_3 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Q8.8 constants
// 1.0 = 256, 0.5 = 128, 0.25 = 64
localparam signed [15:0] ONE      = 16'sd256;   // 1.0
localparam signed [15:0] HALF     = 16'sd128;   // 0.5
localparam signed [15:0] SLOPE    = 16'sd64;    // 0.25 (slope for middle region)

// Boundary points for 3 segments: x < -2, -2 <= x <= 2, x > 2
localparam signed [15:0] BOUND_NEG = -16'sd512; // -2.0
localparam signed [15:0] BOUND_POS = 16'sd512;  // 2.0

// Internal signals
reg signed [31:0] mult_result;
reg signed [15:0] y_next;
reg valid_next;

// Combinational: PWL approximation
// Sigmoid(x) ≈ 0 if x < -2
//            ≈ 0.25*x + 0.5 if -2 <= x <= 2
//            ≈ 1 if x > 2
always @(*) begin
    if (x_in < BOUND_NEG) begin
        // Region 1: saturate to 0
        y_next = 16'sd0;
    end
    else if (x_in > BOUND_POS) begin
        // Region 3: saturate to 1
        y_next = ONE;
    end
    else begin
        // Region 2: linear approximation y = 0.25*x + 0.5
        mult_result = x_in * SLOPE;
        y_next = mult_result[23:8] + HALF; // Shift right by 8 for Q8.8
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
// [pwl_tanh_5.v] PWL Tanh Function 5 Slice/Gradient

module pwl_tanh_5 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Boundary points: -2, -0.5, 0.5, 2
localparam signed [15:0] BOUND_N2   = -16'sd512;   // -2.0
localparam signed [15:0] BOUND_N0_5 = -16'sd128;   // -0.5
localparam signed [15:0] BOUND_P0_5 = 16'sd128;    // 0.5
localparam signed [15:0] BOUND_P2   = 16'sd512;    // 2.0

// Tanh values at boundaries (Q8.8):
// tanh(-2)   = -0.964 -> -247
// tanh(-0.5) = -0.462 -> -118
// tanh(0.5)  = 0.462  -> 118
// tanh(2)    = 0.964  -> 247

// Slopes (Q8.8):
// Seg 2: -2 to -0.5, slope = (-118-(-247))/(384) = 129/384 = 0.336 -> 86
// Seg 3: -0.5 to 0.5, slope = (118-(-118))/(256) = 236/256 = 0.922 -> 236
// Seg 4: 0.5 to 2, slope = (247-118)/(384) = 129/384 = 0.336 -> 86

localparam signed [15:0] SLOPE_OUTER = 16'sd86;
localparam signed [15:0] SLOPE_CENTER = 16'sd236;

// Intercepts (tanh is odd, passes through origin):
// Seg 2: at x=-2 (-512), y=-247: intercept = -247 - 86*(-512)/256 = -247 + 172 = -75
// Seg 3: at x=0, y=0: intercept = 0
// Seg 4: at x=2 (512), y=247: intercept = 247 - 86*512/256 = 247 - 172 = 75

localparam signed [15:0] INTCP_2 = -16'sd75;
localparam signed [15:0] INTCP_3 = 16'sd0;
localparam signed [15:0] INTCP_4 = 16'sd75;

reg signed [31:0] mult_result;
reg signed [15:0] y_next;

always @(*) begin
    if (x_in < BOUND_N2) begin
        y_next = -16'sd256;
    end
    else if (x_in < BOUND_N0_5) begin
        mult_result = x_in * SLOPE_OUTER;
        y_next = mult_result[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_P0_5) begin
        mult_result = x_in * SLOPE_CENTER;
        y_next = mult_result[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_P2) begin
        mult_result = x_in * SLOPE_OUTER;
        y_next = mult_result[23:8] + INTCP_4;
    end
    else begin
        y_next = 16'sd256;
    end
end

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
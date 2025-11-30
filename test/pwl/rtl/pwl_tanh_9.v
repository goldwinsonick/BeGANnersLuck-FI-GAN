// [pwl_tanh_9.v] PWL Tanh Function 9 Slice/Gradient

module pwl_tanh_9 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Boundary points: -3, -2, -1, -0.5, 0.5, 1, 2, 3
localparam signed [15:0] BOUND_N3   = -16'sd768;   // -3.0
localparam signed [15:0] BOUND_N2   = -16'sd512;   // -2.0
localparam signed [15:0] BOUND_N1   = -16'sd256;   // -1.0
localparam signed [15:0] BOUND_N0_5 = -16'sd128;   // -0.5
localparam signed [15:0] BOUND_P0_5 = 16'sd128;    // 0.5
localparam signed [15:0] BOUND_P1   = 16'sd256;    // 1.0
localparam signed [15:0] BOUND_P2   = 16'sd512;    // 2.0
localparam signed [15:0] BOUND_P3   = 16'sd768;    // 3.0

// Tanh values at boundaries (Q8.8):
// tanh(-3)   = -0.995 -> -255
// tanh(-2)   = -0.964 -> -247
// tanh(-1)   = -0.762 -> -195
// tanh(-0.5) = -0.462 -> -118
// tanh(0.5)  = 0.462  -> 118
// tanh(1)    = 0.762  -> 195
// tanh(2)    = 0.964  -> 247
// tanh(3)    = 0.995  -> 255

// Slopes (Q8.8):
// Seg 2: -3 to -2, slope = (-247-(-255))/(256) = 8/256 = 0.031 -> 8
// Seg 3: -2 to -1, slope = (-195-(-247))/(256) = 52/256 = 0.203 -> 52
// Seg 4: -1 to -0.5, slope = (-118-(-195))/(128) = 77/128 = 0.602 -> 154
// Seg 5: -0.5 to 0.5, slope = (118-(-118))/(256) = 236/256 = 0.922 -> 236
// Seg 6: 0.5 to 1, slope = 154
// Seg 7: 1 to 2, slope = 52
// Seg 8: 2 to 3, slope = 8

localparam signed [15:0] SLOPE_1 = 16'sd8;
localparam signed [15:0] SLOPE_2 = 16'sd52;
localparam signed [15:0] SLOPE_3 = 16'sd154;
localparam signed [15:0] SLOPE_4 = 16'sd236;

// Intercepts:
// Seg 2: at x=-3 (-768), y=-255: intercept = -255 - 8*(-768)/256 = -255 + 24 = -231
// Seg 3: at x=-2 (-512), y=-247: intercept = -247 - 52*(-512)/256 = -247 + 104 = -143
// Seg 4: at x=-1 (-256), y=-195: intercept = -195 - 154*(-256)/256 = -195 + 154 = -41
// Seg 5: at x=0, y=0: intercept = 0
// Seg 6: at x=1 (256), y=195: intercept = 195 - 154*256/256 = 195 - 154 = 41
// Seg 7: at x=2 (512), y=247: intercept = 247 - 52*512/256 = 247 - 104 = 143
// Seg 8: at x=3 (768), y=255: intercept = 255 - 8*768/256 = 255 - 24 = 231

localparam signed [15:0] INTCP_2 = -16'sd231;
localparam signed [15:0] INTCP_3 = -16'sd143;
localparam signed [15:0] INTCP_4 = -16'sd41;
localparam signed [15:0] INTCP_5 = 16'sd0;
localparam signed [15:0] INTCP_6 = 16'sd41;
localparam signed [15:0] INTCP_7 = 16'sd143;
localparam signed [15:0] INTCP_8 = 16'sd231;

reg signed [31:0] mult_result;
reg signed [15:0] y_next;

always @(*) begin
    if (x_in < BOUND_N3) begin
        y_next = -16'sd256;
    end
    else if (x_in < BOUND_N2) begin
        mult_result = x_in * SLOPE_1;
        y_next = mult_result[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_N1) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_N0_5) begin
        mult_result = x_in * SLOPE_3;
        y_next = mult_result[23:8] + INTCP_4;
    end
    else if (x_in < BOUND_P0_5) begin
        mult_result = x_in * SLOPE_4;
        y_next = mult_result[23:8] + INTCP_5;
    end
    else if (x_in < BOUND_P1) begin
        mult_result = x_in * SLOPE_3;
        y_next = mult_result[23:8] + INTCP_6;
    end
    else if (x_in < BOUND_P2) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_7;
    end
    else if (x_in < BOUND_P3) begin
        mult_result = x_in * SLOPE_1;
        y_next = mult_result[23:8] + INTCP_8;
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
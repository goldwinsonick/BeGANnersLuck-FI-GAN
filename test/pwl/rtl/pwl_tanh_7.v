// [pwl_tanh_7.v] PWL Tanh Function 7 Slice/Gradient

module pwl_tanh_7 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Boundary points: -3, -1.5, -0.5, 0.5, 1.5, 3
localparam signed [15:0] BOUND_N3   = -16'sd768;   // -3.0
localparam signed [15:0] BOUND_N1_5 = -16'sd384;   // -1.5
localparam signed [15:0] BOUND_N0_5 = -16'sd128;   // -0.5
localparam signed [15:0] BOUND_P0_5 = 16'sd128;    // 0.5
localparam signed [15:0] BOUND_P1_5 = 16'sd384;    // 1.5
localparam signed [15:0] BOUND_P3   = 16'sd768;    // 3.0

// Tanh values at boundaries (Q8.8):
// tanh(-3)   = -0.995 -> -255
// tanh(-1.5) = -0.905 -> -232
// tanh(-0.5) = -0.462 -> -118
// tanh(0.5)  = 0.462  -> 118
// tanh(1.5)  = 0.905  -> 232
// tanh(3)    = 0.995  -> 255

// Slopes (Q8.8):
// Seg 2: -3 to -1.5, slope = (-232-(-255))/(384) = 23/384 = 0.060 -> 15
// Seg 3: -1.5 to -0.5, slope = (-118-(-232))/(256) = 114/256 = 0.445 -> 114
// Seg 4: -0.5 to 0.5, slope = (118-(-118))/(256) = 236/256 = 0.922 -> 236
// Seg 5: 0.5 to 1.5, slope = 114
// Seg 6: 1.5 to 3, slope = 15

localparam signed [15:0] SLOPE_1 = 16'sd15;
localparam signed [15:0] SLOPE_2 = 16'sd114;
localparam signed [15:0] SLOPE_3 = 16'sd236;

// Intercepts:
// Seg 2: at x=-3 (-768), y=-255: intercept = -255 - 15*(-768)/256 = -255 + 45 = -210
// Seg 3: at x=-1.5 (-384), y=-232: intercept = -232 - 114*(-384)/256 = -232 + 171 = -61
// Seg 4: at x=0, y=0: intercept = 0
// Seg 5: at x=1.5 (384), y=232: intercept = 232 - 114*384/256 = 232 - 171 = 61
// Seg 6: at x=3 (768), y=255: intercept = 255 - 15*768/256 = 255 - 45 = 210

localparam signed [15:0] INTCP_2 = -16'sd210;
localparam signed [15:0] INTCP_3 = -16'sd61;
localparam signed [15:0] INTCP_4 = 16'sd0;
localparam signed [15:0] INTCP_5 = 16'sd61;
localparam signed [15:0] INTCP_6 = 16'sd210;

reg signed [31:0] mult_result;
reg signed [15:0] y_next;

always @(*) begin
    if (x_in < BOUND_N3) begin
        y_next = -16'sd256;
    end
    else if (x_in < BOUND_N1_5) begin
        mult_result = x_in * SLOPE_1;
        y_next = mult_result[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_N0_5) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_P0_5) begin
        mult_result = x_in * SLOPE_3;
        y_next = mult_result[23:8] + INTCP_4;
    end
    else if (x_in < BOUND_P1_5) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_5;
    end
    else if (x_in < BOUND_P3) begin
        mult_result = x_in * SLOPE_1;
        y_next = mult_result[23:8] + INTCP_6;
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
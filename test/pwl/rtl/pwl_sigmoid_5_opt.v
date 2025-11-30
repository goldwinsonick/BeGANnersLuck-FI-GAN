// [pwl_sigmoid_5_opt.v] Optimized PWL Sigmoid Function 5 Slice
// Uses shift-and-add instead of multiplication

module pwl_sigmoid_5_opt (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Boundary points: -2.5, -1, 1, 2.5
localparam signed [15:0] BOUND_N2_5 = -16'sd640;  // -2.5
localparam signed [15:0] BOUND_N1   = -16'sd256;  // -1.0
localparam signed [15:0] BOUND_P1   = 16'sd256;   // 1.0
localparam signed [15:0] BOUND_P2_5 = 16'sd640;   // 2.5

// Intercepts (Q8.8)
localparam signed [15:0] INTCP_2 = 16'sd101;
localparam signed [15:0] INTCP_3 = 16'sd128;
localparam signed [15:0] INTCP_4 = 16'sd155;

// Internal signals
reg signed [31:0] slope_mult;
reg signed [15:0] y_next;

// Shift-add approximations:
// SLOPE_OUTER = 33 ≈ 32 + 1 = (1 << 5) + 1
// SLOPE_CENTER = 59 ≈ 64 - 4 - 1 = (1 << 6) - (1 << 2) - 1

wire signed [31:0] mult_outer  = (x_in <<< 5) + x_in;                    // x * 33
wire signed [31:0] mult_center = (x_in <<< 6) - (x_in <<< 2) - x_in;     // x * 59

always @(*) begin
    if (x_in < BOUND_N2_5) begin
        y_next = 16'sd0;
    end
    else if (x_in < BOUND_N1) begin
        // Region 2: slope = 33
        y_next = mult_outer[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_P1) begin
        // Region 3: slope = 59
        y_next = mult_center[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_P2_5) begin
        // Region 4: slope = 33
        y_next = mult_outer[23:8] + INTCP_4;
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
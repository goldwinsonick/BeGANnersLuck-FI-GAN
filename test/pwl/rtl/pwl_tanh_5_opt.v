// [pwl_tanh_5_opt.v] Optimized PWL Tanh Function 5 Slice
// Uses shift-and-add instead of multiplication

module pwl_tanh_5_opt (
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

// Intercepts (Q8.8)
localparam signed [15:0] INTCP_2 = -16'sd75;
localparam signed [15:0] INTCP_3 = 16'sd0;
localparam signed [15:0] INTCP_4 = 16'sd75;

// Internal signals
reg signed [15:0] y_next;

// Shift-add approximations:
// SLOPE_OUTER = 86 ≈ 64 + 16 + 4 + 2 = (1 << 6) + (1 << 4) + (1 << 2) + (1 << 1)
// SLOPE_CENTER = 236 ≈ 256 - 16 - 4 = (1 << 8) - (1 << 4) - (1 << 2)

wire signed [31:0] mult_outer  = (x_in <<< 6) + (x_in <<< 4) + (x_in <<< 2) + (x_in <<< 1);  // x * 86
wire signed [31:0] mult_center = (x_in <<< 8) - (x_in <<< 4) - (x_in <<< 2);                 // x * 236

always @(*) begin
    if (x_in < BOUND_N2) begin
        y_next = -16'sd256;
    end
    else if (x_in < BOUND_N0_5) begin
        // Region 2: slope = 86
        y_next = mult_outer[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_P0_5) begin
        // Region 3: slope = 236
        y_next = mult_center[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_P2) begin
        // Region 4: slope = 86
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
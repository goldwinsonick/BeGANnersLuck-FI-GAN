// [pwl_sigmoid_5.v] PWL Sigmoid Function 5 Slice/Gradient

module pwl_sigmoid_5 (
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

// Slopes calculated from actual sigmoid values
localparam signed [15:0] SLOPE_OUTER = 16'sd33;   // ~0.13
localparam signed [15:0] SLOPE_CENTER = 16'sd59;  // ~0.23

// Intercepts for continuity
localparam signed [15:0] INTCP_2 = 16'sd101;
localparam signed [15:0] INTCP_3 = 16'sd128;
localparam signed [15:0] INTCP_4 = 16'sd155;

reg signed [31:0] mult_result;
reg signed [15:0] y_next;

always @(*) begin
    if (x_in < BOUND_N2_5) begin
        y_next = 16'sd0;
    end
    else if (x_in < BOUND_N1) begin
        mult_result = x_in * SLOPE_OUTER;
        y_next = mult_result[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_P1) begin
        mult_result = x_in * SLOPE_CENTER;
        y_next = mult_result[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_P2_5) begin
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
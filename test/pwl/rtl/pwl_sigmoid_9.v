// [pwl_sigmoid_9.v] PWL Sigmoid Function 9 Slice/Gradient

module pwl_sigmoid_9 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,
    input  wire signed [15:0] x_in,   // Q8.8 fixed-point
    
    output reg         valid_out,
    output reg  signed [15:0] y_out   // Q8.8 fixed-point
);

// Boundary points: -5, -3, -2, -1, 1, 2, 3, 5
localparam signed [15:0] BOUND_N5 = -16'sd1280;
localparam signed [15:0] BOUND_N3 = -16'sd768;
localparam signed [15:0] BOUND_N2 = -16'sd512;
localparam signed [15:0] BOUND_N1 = -16'sd256;
localparam signed [15:0] BOUND_P1 = 16'sd256;
localparam signed [15:0] BOUND_P2 = 16'sd512;
localparam signed [15:0] BOUND_P3 = 16'sd768;
localparam signed [15:0] BOUND_P5 = 16'sd1280;

// Slopes
localparam signed [15:0] SLOPE_1 = 16'sd5;    // outermost
localparam signed [15:0] SLOPE_2 = 16'sd18;   // outer
localparam signed [15:0] SLOPE_3 = 16'sd39;   // mid
localparam signed [15:0] SLOPE_4 = 16'sd59;   // center

// Intercepts
localparam signed [15:0] INTCP_2 = 16'sd27;
localparam signed [15:0] INTCP_3 = 16'sd66;
localparam signed [15:0] INTCP_4 = 16'sd108;
localparam signed [15:0] INTCP_5 = 16'sd128;
localparam signed [15:0] INTCP_6 = 16'sd148;
localparam signed [15:0] INTCP_7 = 16'sd190;
localparam signed [15:0] INTCP_8 = 16'sd229;

reg signed [31:0] mult_result;
reg signed [15:0] y_next;

always @(*) begin
    if (x_in < BOUND_N5) begin
        y_next = 16'sd0;
    end
    else if (x_in < BOUND_N3) begin
        mult_result = x_in * SLOPE_1;
        y_next = mult_result[23:8] + INTCP_2;
    end
    else if (x_in < BOUND_N2) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_3;
    end
    else if (x_in < BOUND_N1) begin
        mult_result = x_in * SLOPE_3;
        y_next = mult_result[23:8] + INTCP_4;
    end
    else if (x_in < BOUND_P1) begin
        mult_result = x_in * SLOPE_4;
        y_next = mult_result[23:8] + INTCP_5;
    end
    else if (x_in < BOUND_P2) begin
        mult_result = x_in * SLOPE_3;
        y_next = mult_result[23:8] + INTCP_6;
    end
    else if (x_in < BOUND_P3) begin
        mult_result = x_in * SLOPE_2;
        y_next = mult_result[23:8] + INTCP_7;
    end
    else if (x_in < BOUND_P5) begin
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
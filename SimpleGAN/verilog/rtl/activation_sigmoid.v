// 2. Activation Tanh (Cleaned Up)
module activation_tanh (
    input  wire                clk,
    input  wire                rst_n,
    input  wire                valid_in,
    input  wire signed [15:0]  x_in,  // Q8.8
    output reg                 valid_out,
    output reg  signed [15:0]  y_out  // Q8.8
);
    // Constants
    localparam signed [15:0] BOUND_N2   = -16'sd512; // -2.0
    localparam signed [15:0] BOUND_N0_5 = -16'sd128; // -0.5
    localparam signed [15:0] BOUND_P0_5 = 16'sd128;  // 0.5
    localparam signed [15:0] BOUND_P2   = 16'sd512;  // 2.0
    localparam signed [15:0] INTCP_2    = -16'sd75;
    localparam signed [15:0] INTCP_3    = 16'sd0;
    localparam signed [15:0] INTCP_4    = 16'sd75;

    reg signed [15:0] y_next;
    wire signed [31:0] mult_outer  = (x_in <<< 6) + (x_in <<< 4) + (x_in <<< 2) + (x_in <<< 1); 
    wire signed [31:0] mult_center = (x_in <<< 8) - (x_in <<< 4) - (x_in <<< 2);             

    always @(*) begin
        if (x_in < BOUND_N2)          y_next = -16'sd256; // -1.0
        else if (x_in < BOUND_N0_5)   y_next = mult_outer[23:8] + INTCP_2;
        else if (x_in < BOUND_P0_5)   y_next = mult_center[23:8] + INTCP_3;
        else if (x_in < BOUND_P2)     y_next = mult_outer[23:8] + INTCP_4;
        else                          y_next = 16'sd256;  // 1.0
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 1'b0;
            y_out     <= 16'sd0;
        end else begin
            valid_out <= valid_in;
            y_out     <= y_next;
        end
    end
endmodule
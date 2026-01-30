module conv2d_3x3_layer #(
    parameter IMG_WIDTH  = 16,
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    // Weights Input
    input  wire signed [DATA_WIDTH-1:0] w0, w1, w2,
    input  wire signed [DATA_WIDTH-1:0] w3, w4, w5,
    input  wire signed [DATA_WIDTH-1:0] w6, w7, w8,
    input  wire signed [DATA_WIDTH-1:0] bias,

    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // --- Internal Memory ---
    reg signed [DATA_WIDTH-1:0] line_buff_0 [0:IMG_WIDTH-1];
    reg signed [DATA_WIDTH-1:0] line_buff_1 [0:IMG_WIDTH-1];

    reg signed [DATA_WIDTH-1:0] win [0:8]; 
    wire signed [DATA_WIDTH-1:0] p[0:8]; 
    wire signed [DATA_WIDTH-1:0] sum;
    
    // Counters
    reg [9:0] x_cnt;
    reg [9:0] y_cnt;
    integer i;

    // Pipeline Register
    reg valid_req; 

    // --- Instantiate Multipliers ---
    qmult m0(win[8], w0, p[0]);
    qmult m1(win[7], w1, p[1]);
    qmult m2(win[6], w2, p[2]);
    qmult m3(win[5], w3, p[3]);
    qmult m4(win[4], w4, p[4]);
    qmult m5(win[3], w5, p[5]);
    qmult m6(win[2], w6, p[6]);
    qmult m7(win[1], w7, p[7]);
    qmult m8(win[0], w8, p[8]);

    // --- Adder ---
    assign sum = p[0] + p[1] + p[2] + 
                 p[3] + p[4] + p[5] + 
                 p[6] + p[7] + p[8] + bias;

    // --- Main Logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt <= 0;
            y_cnt <= 0;
            valid_req <= 0; // Reset pipeline request
            valid_out <= 0;
            data_out  <= 0;
            
            for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                line_buff_0[i] <= 0;
                line_buff_1[i] <= 0;
            end
            for (i = 0; i < 9; i = i + 1) begin
                win[i] <= 0;
            end
        end 
        else if (valid_in) begin
            // 1. Shift Line Buffers
            line_buff_0[0] <= data_in;
            line_buff_1[0] <= line_buff_0[IMG_WIDTH-1];
            
            for (i = 1; i < IMG_WIDTH; i = i + 1) begin
                line_buff_0[i] <= line_buff_0[i-1];
                line_buff_1[i] <= line_buff_1[i-1];
            end

            // 2. Update Window (Shift Register)
            win[0] <= data_in;                  
            win[1] <= win[0]; win[2] <= win[1];
            
            win[3] <= line_buff_0[IMG_WIDTH-1]; 
            win[4] <= win[3]; win[5] <= win[4];
            
            win[6] <= line_buff_1[IMG_WIDTH-1]; 
            win[7] <= win[6]; win[8] <= win[7];

            // 3. Update Counters
            if (x_cnt == IMG_WIDTH-1) begin
                x_cnt <= 0;
                y_cnt <= y_cnt + 1;
            end else begin
                x_cnt <= x_cnt + 1;
            end

            // 4. Output Logic (PIPELINED)
            if (y_cnt >= 2 && x_cnt >= 2) begin
                valid_req <= 1;
            end else begin
                valid_req <= 0;
            end

            // Stage 2: Valid signal & Data keluar bersamaan
            valid_out <= valid_req;
            data_out  <= sum;

        end 
        else begin
            valid_out <= valid_req; 
            data_out  <= sum;

            valid_req <= 0;
        end
    end

endmodule
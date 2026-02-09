module conv2d_4x4_layer #(
    parameter IMG_WIDTH  = 16,
    parameter DATA_WIDTH = 16
)(
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    
    // Weights (0-15) flattened
    input  wire signed [DATA_WIDTH-1:0] w0, w1, w2, w3,
    input  wire signed [DATA_WIDTH-1:0] w4, w5, w6, w7,
    input  wire signed [DATA_WIDTH-1:0] w8, w9, w10, w11,
    input  wire signed [DATA_WIDTH-1:0] w12, w13, w14, w15,
    input  wire signed [DATA_WIDTH-1:0] bias,

    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    // --- Internal Memory (3 Line Buffers for 4x4 kernel) ---
    // Butuh 3 buffer karena kernel 4x4 mengakses 4 baris data (3 dari buffer, 1 input langsung)
    reg signed [DATA_WIDTH-1:0] line_buff_0 [0:IMG_WIDTH-1];
    reg signed [DATA_WIDTH-1:0] line_buff_1 [0:IMG_WIDTH-1];
    reg signed [DATA_WIDTH-1:0] line_buff_2 [0:IMG_WIDTH-1];

    // 4x4 Window Register (16 pixels)
    reg signed [DATA_WIDTH-1:0] win [0:15]; 

    // --- Calculation Signals ---
    wire signed [DATA_WIDTH-1:0] p[0:15]; 
    wire signed [DATA_WIDTH-1:0] sum;
    
    reg [9:0] x_cnt, y_cnt;
    integer i;

    // --- Step 1: Instantiate 16 Multipliers (FULL) ---
    qmult m0 (win[15], w0,  p[0]);
    qmult m1 (win[14], w1,  p[1]);
    qmult m2 (win[13], w2,  p[2]);
    qmult m3 (win[12], w3,  p[3]);
    
    qmult m4 (win[11], w4,  p[4]);
    qmult m5 (win[10], w5,  p[5]);
    qmult m6 (win[9],  w6,  p[6]);
    qmult m7 (win[8],  w7,  p[7]);
    
    qmult m8 (win[7],  w8,  p[8]);
    qmult m9 (win[6],  w9,  p[9]);
    qmult m10(win[5],  w10, p[10]);
    qmult m11(win[4],  w11, p[11]);
    
    qmult m12(win[3],  w12, p[12]);
    qmult m13(win[2],  w13, p[13]);
    qmult m14(win[1],  w14, p[14]);
    qmult m15(win[0],  w15, p[15]);

    // --- Step 2: Adder Tree ---
    assign sum = p[0] + p[1] + p[2] + p[3] + 
                 p[4] + p[5] + p[6] + p[7] + 
                 p[8] + p[9] + p[10] + p[11] +
                 p[12] + p[13] + p[14] + p[15] + bias;
    
    reg valid_req;

    // --- Main Logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_req <= 0;
            valid_out <= 0;
            data_out  <= 0;
            x_cnt <= 0;
            y_cnt <= 0;
            
            for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                line_buff_0[i] <= 0;
                line_buff_1[i] <= 0;
                line_buff_2[i] <= 0;
            end
            for (i = 0; i < 16; i = i + 1) begin
                win[i] <= 0;
            end
        end 
        else if (valid_in) begin
            // --- Step 3: Shift Line Buffers ---
            line_buff_0[0] <= data_in;
            line_buff_1[0] <= line_buff_0[IMG_WIDTH-1];
            line_buff_2[0] <= line_buff_1[IMG_WIDTH-1];
            
            for (i = 1; i < IMG_WIDTH; i = i + 1) begin
                line_buff_0[i] <= line_buff_0[i-1];
                line_buff_1[i] <= line_buff_1[i-1];
                line_buff_2[i] <= line_buff_2[i-1];
            end

            // --- Step 4: Update 4x4 Window ---
            // Row 0 (Newest/Input)
            win[0] <= data_in; 
            win[1] <= win[0]; win[2] <= win[1]; win[3] <= win[2];
            
            // Row 1
            win[4] <= line_buff_0[IMG_WIDTH-1];
            win[5] <= win[4]; win[6] <= win[5]; win[7] <= win[6];

            // Row 2
            win[8] <= line_buff_1[IMG_WIDTH-1];
            win[9] <= win[8]; win[10] <= win[9]; win[11] <= win[10];

            // Row 3 (Oldest)
            win[12] <= line_buff_2[IMG_WIDTH-1];
            win[13] <= win[12]; win[14] <= win[13]; win[15] <= win[14];

            // --- Step 5: Coordinate Tracking ---
            if (x_cnt == IMG_WIDTH-1) begin
                x_cnt <= 0;
                y_cnt <= y_cnt + 1;
            end else begin
                x_cnt <= x_cnt + 1;
            end

            // --- Step 6: Check Valid ---
            // Buffer full after 3 rows + 3 pixels
            if (y_cnt >= 3 && x_cnt >= 3) 
                valid_req <= 1;
            else
                valid_req <= 0;

            // Delay 1 cycle agar sinkron dengan data_out <= sum
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
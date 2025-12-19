// [discriminator.v] GAN Discriminator Level 2 (9 Input -> 3 Hidden -> 1 Output)
module discriminator (
    input wire clk,
    input wire rst_n,
    input wire valid_in,

    // Data Inputs (9 Pixels)
    input wire signed [15:0] i_pix1, i_pix2, i_pix3,
    input wire signed [15:0] i_pix4, i_pix5, i_pix6,
    input wire signed [15:0] i_pix7, i_pix8, i_pix9,

    // Weight Inputs (Flattened Q8.8)
    input wire [479:0] flat_weights_D1, // 30 params (3 neurons * 10)
    input wire [63:0]  flat_weights_D2, // 4 params (1 neuron * 4)

    // Output
    output wire valid_out,
    output wire signed [15:0] o_score
);

    // --- Pack Inputs ---
    wire signed [15:0] pixels [0:8];
    assign pixels[0] = i_pix1; assign pixels[1] = i_pix2; assign pixels[2] = i_pix3;
    assign pixels[3] = i_pix4; assign pixels[4] = i_pix5; assign pixels[5] = i_pix6;
    assign pixels[6] = i_pix7; assign pixels[7] = i_pix8; assign pixels[8] = i_pix9;

    // --- Unpack Weights ---
    wire signed [15:0] wd1 [0:2][0:9]; // [Neuron][9 Weights + Bias]
    wire signed [15:0] wd2 [0:3];      // [3 Weights + Bias]

    genvar i, k;
    generate
        for(i=0; i<3; i=i+1) begin : UPK_D1
            for(k=0; k<10; k=k+1) begin : UPK_INNER
                assign wd1[i][k] = flat_weights_D1[16*(i*10 + k + 1)-1 : 16*(i*10 + k)];
            end
        end
        assign wd2[0] = flat_weights_D2[15:0];
        assign wd2[1] = flat_weights_D2[31:16];
        assign wd2[2] = flat_weights_D2[47:32];
        assign wd2[3] = flat_weights_D2[63:48];
    endgenerate

    // --- Layer 1: Hidden (Tanh) ---
    wire signed [15:0] d1_sum [0:2];
    wire signed [15:0] d1_out [0:2];
    wire [2:0] d1_valid;
    wire signed [15:0] mul_d1 [0:2][0:8];

    generate
        for(i=0; i<3; i=i+1) begin : D1_CALC
            for (k=0; k<9; k=k+1) begin : M
                qmult mult (pixels[k], wd1[i][k], mul_d1[i][k]);
            end
            
            // Sum 9 results + Bias
            assign d1_sum[i] = mul_d1[i][0] + mul_d1[i][1] + mul_d1[i][2] +
                               mul_d1[i][3] + mul_d1[i][4] + mul_d1[i][5] +
                               mul_d1[i][6] + mul_d1[i][7] + mul_d1[i][8] + 
                               wd1[i][9]; 

            activation_tanh act_d1 (
                .clk(clk), .rst_n(rst_n), .valid_in(valid_in), 
                .x_in(d1_sum[i]), .valid_out(d1_valid[i]), .y_out(d1_out[i])
            );
        end
    endgenerate

    // --- Layer 2: Output (Sigmoid) ---
    wire D2_start = &d1_valid;
    wire signed [15:0] d2_sum;
    wire signed [15:0] mul_d2 [0:2];

    qmult md2_1 (d1_out[0], wd2[0], mul_d2[0]);
    qmult md2_2 (d1_out[1], wd2[1], mul_d2[1]);
    qmult md2_3 (d1_out[2], wd2[2], mul_d2[2]);

    assign d2_sum = mul_d2[0] + mul_d2[1] + mul_d2[2] + wd2[3];

    activation_sigmoid act_d2 (
        .clk(clk), .rst_n(rst_n), .valid_in(D2_start), 
        .x_in(d2_sum), .valid_out(valid_out), .y_out(o_score)
    );

endmodule
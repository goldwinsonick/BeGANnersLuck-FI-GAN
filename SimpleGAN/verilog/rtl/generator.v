// [generator.v] GAN Generator Level 2 (2 Input -> 3 Hidden -> 9 Output)
module generator (
    input wire clk,
    input wire rst_n,
    input wire valid_in,
    
    // Data Inputs (Noise)
    input wire signed [15:0] z1, z2,

    // Weight Inputs (Flattened Q8.8)
    input wire [143:0] flat_weights_L1, // 9 params (3 neurons * 3)L2, // 36 params (9 neurons * 4)
    input wire [575:0] flat_weights_

    // Outputs
    output wire valid_out,
    output wire signed [15:0] o_pix1, o_pix2, o_pix3,
    output wire signed [15:0] o_pix4, o_pix5, o_pix6,
    output wire signed [15:0] o_pix7, o_pix8, o_pix9
);

    // --- Unpack Weights ---
    wire signed [15:0] w1 [0:2][0:2]; // L1: [Neuron][W1, W2, Bias]
    wire signed [15:0] w2 [0:8][0:3]; // L2: [Neuron][W1, W2, W3, Bias]

    genvar i;
    generate
        for(i=0; i<3; i=i+1) begin : UPK_L1
            assign w1[i][0] = flat_weights_L1[16*(i*3+1)-1 : 16*(i*3)];
            assign w1[i][1] = flat_weights_L1[16*(i*3+2)-1 : 16*(i*3+1)];
            assign w1[i][2] = flat_weights_L1[16*(i*3+3)-1 : 16*(i*3+2)];
        end
        for(i=0; i<9; i=i+1) begin : UPK_L2
            assign w2[i][0] = flat_weights_L2[16*(i*4+1)-1 : 16*(i*4)];
            assign w2[i][1] = flat_weights_L2[16*(i*4+2)-1 : 16*(i*4+1)];
            assign w2[i][2] = flat_weights_L2[16*(i*4+3)-1 : 16*(i*4+2)];
            assign w2[i][3] = flat_weights_L2[16*(i*4+4)-1 : 16*(i*4+3)];
        end
    endgenerate

    // --- Layer 1: Hidden (Tanh) ---
    wire signed [15:0] h1_sum [0:2];
    wire signed [15:0] h1_out [0:2];
    wire [2:0] h1_valid;
    wire signed [15:0] mul_L1 [0:2][0:1];

    generate
        for(i=0; i<3; i=i+1) begin : L1_CALC
            // Matrix Mult
            qmult m1 (z1, w1[i][0], mul_L1[i][0]);
            qmult m2 (z2, w1[i][1], mul_L1[i][1]);
            
            // Accumulate
            assign h1_sum[i] = mul_L1[i][0] + mul_L1[i][1] + w1[i][2];

            activation_tanh act1 (
                .clk(clk), .rst_n(rst_n), .valid_in(valid_in), 
                .x_in(h1_sum[i]), .valid_out(h1_valid[i]), .y_out(h1_out[i])
            );
        end
    endgenerate

    // --- Layer 2: Output (Tanh) ---
    wire L2_start = &h1_valid; // Wait L1
    wire signed [15:0] h2_sum [0:8];
    wire signed [15:0] h2_out [0:8];
    wire [8:0] h2_valid;
    wire signed [15:0] mul_L2 [0:8][0:2];

    generate
        for(i=0; i<9; i=i+1) begin : L2_CALC
            // Matrix Mult
            qmult m2_1 (h1_out[0], w2[i][0], mul_L2[i][0]);
            qmult m2_2 (h1_out[1], w2[i][1], mul_L2[i][1]);
            qmult m2_3 (h1_out[2], w2[i][2], mul_L2[i][2]);

            // Accumulate
            assign h2_sum[i] = mul_L2[i][0] + mul_L2[i][1] + mul_L2[i][2] + w2[i][3];

            activation_tanh act2 (
                .clk(clk), .rst_n(rst_n), .valid_in(L2_start), 
                .x_in(h2_sum[i]), .valid_out(h2_valid[i]), .y_out(h2_out[i])
            );
        end
    endgenerate

    // --- Output Assign ---
    assign valid_out = &h2_valid;
    assign o_pix1 = h2_out[0]; assign o_pix2 = h2_out[1]; assign o_pix3 = h2_out[2];
    assign o_pix4 = h2_out[3]; assign o_pix5 = h2_out[4]; assign o_pix6 = h2_out[5];
    assign o_pix7 = h2_out[6]; assign o_pix8 = h2_out[7]; assign o_pix9 = h2_out[8];

endmodule
// [qmult.v] Fixed Point Q8.8 Multiplier
module qmult (
    input  signed [15:0] i_a,
    input  signed [15:0] i_b,
    output signed [15:0] o_res
);
    wire signed [31:0] temp;

    assign temp = i_a * i_b;
    assign o_res = temp[23:8]; // Truncate to Q8.8
endmodule
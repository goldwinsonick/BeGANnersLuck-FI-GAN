// [qmult.v] Module for Q6.10 fixed-point multiplication
module qmult #(
    parameter N = 16,
    parameter Q = 10
)(
    input signed [N-1:0] a,
    input signed [N-1:0] b,
    output signed [N-1:0] out
);
    wire signed [2*N-1:0] temp;
    assign temp = a * b;
    
    assign out = temp[Q+N-1 : Q]; 
endmodule
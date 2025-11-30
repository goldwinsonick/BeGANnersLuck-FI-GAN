`timescale 1ns/1ps

module pwl_sigmoid_3_tb;

  reg clk;
  reg rst_n;
  reg valid_in;
  reg signed [15:0] x_in;
  wire valid_out;
  wire signed [15:0] y_out;

  pwl_sigmoid_3 dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .x_in(x_in),
    .valid_out(valid_out),
    .y_out(y_out)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Helper: convert Q8.8 to real for display
  real x_real, y_real;
  always @(*) begin
    x_real = x_in / 256.0;
    y_real = y_out / 256.0;
  end

  initial begin
    $dumpfile("build/pwl_sigmoid_3_tb.vcd");
    $dumpvars(0, pwl_sigmoid_3_tb);

    $display("Time\t\tx_in(Q8.8)\tx_real\t\ty_out(Q8.8)\ty_real\t\tvalid");
    $monitor("%0t\t%0d\t\t%0.4f\t\t%0d\t\t%0.4f\t\t%b",
      $time, x_in, x_real, y_out, y_real, valid_out);

    // Initialize
    rst_n = 0;
    valid_in = 0;
    x_in = 0;
    #20;
    rst_n = 1;
    #10;

    // Test 1: x = 0.0 (Q8.8: 0)
    // Expected: sigmoid(0) ≈ 0.25*0 + 0.5 = 0.5 (Q8.8: 128)
    valid_in = 1;
    x_in = 16'sd0;
    #10;

    // Test 2: x = 1.0 (Q8.8: 256)
    // Expected: sigmoid(1) ≈ 0.25*1 + 0.5 = 0.75 (Q8.8: 192)
    x_in = 16'sd256;
    #10;

    // Test 3: x = -1.0 (Q8.8: -256)
    // Expected: sigmoid(-1) ≈ 0.25*(-1) + 0.5 = 0.25 (Q8.8: 64)
    x_in = -16'sd256;
    #10;

    // Test 4: x = 2.0 (Q8.8: 512)
    // Expected: sigmoid(2) ≈ 0.25*2 + 0.5 = 1.0 (Q8.8: 256)
    x_in = 16'sd512;
    #10;

    // Test 5: x = -2.0 (Q8.8: -512)
    // Expected: sigmoid(-2) ≈ 0.25*(-2) + 0.5 = 0.0 (Q8.8: 0)
    x_in = -16'sd512;
    #10;

    // Test 6: x = 3.0 (Q8.8: 768) - beyond boundary
    // Expected: saturate to 1.0 (Q8.8: 256)
    x_in = 16'sd768;
    #10;

    // Test 7: x = -3.0 (Q8.8: -768) - beyond boundary
    // Expected: saturate to 0.0 (Q8.8: 0)
    x_in = -16'sd768;
    #10;

    // Test 8: x = 0.5 (Q8.8: 128)
    // Expected: sigmoid(0.5) ≈ 0.25*0.5 + 0.5 = 0.625 (Q8.8: 160)
    x_in = 16'sd128;
    #10;

    // Test 9: x = -0.5 (Q8.8: -128)
    // Expected: sigmoid(-0.5) ≈ 0.25*(-0.5) + 0.5 = 0.375 (Q8.8: 96)
    x_in = -16'sd128;
    #10;

    // Test 10: x = 5.0 (Q8.8: 1280) - far beyond boundary
    // Expected: saturate to 1.0 (Q8.8: 256)
    x_in = 16'sd1280;
    #10;

    valid_in = 0;
    #20;

    $finish;
  end

endmodule
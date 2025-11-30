`timescale 1ns/1ps

module pwl_sigmoid_3_tb;

  reg clk;
  reg rst_n;
  reg valid_in;
  reg signed [15:0] x_in;
  wire valid_out;
  wire signed [15:0] y_out;

  // File handles
  integer file_in, file_out;
  integer scan_result;
  reg signed [15:0] x_read;

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

  initial begin
    $dumpfile("build/pwl_sigmoid_3_tb.vcd");
    $dumpvars(0, pwl_sigmoid_3_tb);

    // Open input file
    file_in = $fopen("data/input_test.csv", "r");
    if (file_in == 0) begin
      $display("Error: Cannot open data/input_test.csv");
      $finish;
    end

    // Open output file
    file_out = $fopen("data/output_pwl_sigmoid_3_tb.csv", "w");
    $fdisplay(file_out, "x_in,y_out");

    $display("  x_in   |  y_out  ");

    // Skip header line
    scan_result = $fscanf(file_in, "%s\n", x_read);

    // Initialize
    rst_n = 0;
    valid_in = 0;
    x_in = 0;
    #20;
    rst_n = 1;
    #10;

    // Read and process all inputs
    valid_in = 1;
    while (!$feof(file_in)) begin
      scan_result = $fscanf(file_in, "%d\n", x_read);
      if (scan_result == 1) begin
        x_in = x_read;
        #10;  // Wait one clock cycle
        $display("%8d | %8d", x_in, y_out);
        $fdisplay(file_out, "%0d,%0d", x_in, y_out);
      end
    end

    valid_in = 0;
    #20;

    // Close files
    $fclose(file_in);
    $fclose(file_out);
    $finish;
  end

endmodule
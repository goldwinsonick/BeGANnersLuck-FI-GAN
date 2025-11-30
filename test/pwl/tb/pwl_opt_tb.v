`timescale 1ns/1ps

module pwl_opt_tb;

  reg clk;
  reg rst_n;
  reg valid_in;
  reg signed [15:0] x_in;
  
  // Original outputs
  wire valid_out_sig5, valid_out_tanh5;
  wire signed [15:0] y_sig5, y_tanh5;
  
  // Optimized outputs
  wire valid_out_sig5_opt, valid_out_tanh5_opt;
  wire signed [15:0] y_sig5_opt, y_tanh5_opt;

  // File handles
  integer file_in;
  integer file_sig5, file_sig5_opt;
  integer file_tanh5, file_tanh5_opt;
  integer scan_result;
  reg signed [15:0] x_read;

  // Original modules
  pwl_sigmoid_5 u_sig5 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig5), .y_out(y_sig5));
  pwl_tanh_5 u_tanh5 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh5), .y_out(y_tanh5));

  // Optimized modules
  pwl_sigmoid_5_opt u_sig5_opt (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig5_opt), .y_out(y_sig5_opt));
  pwl_tanh_5_opt u_tanh5_opt (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh5_opt), .y_out(y_tanh5_opt));

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("build/pwl_opt_tb.vcd");
    $dumpvars(0, pwl_opt_tb);

    // Open input file
    file_in = $fopen("data/input_test.csv", "r");
    if (file_in == 0) begin
      $display("Error: Cannot open data/input_test.csv");
      $finish;
    end

    // Open output files
    file_sig5 = $fopen("data/output_pwl_sigmoid_5.csv", "w");
    file_sig5_opt = $fopen("data/output_pwl_sigmoid_5_opt.csv", "w");
    file_tanh5 = $fopen("data/output_pwl_tanh_5.csv", "w");
    file_tanh5_opt = $fopen("data/output_pwl_tanh_5_opt.csv", "w");

    // Write headers
    $fdisplay(file_sig5, "x_in,y_out");
    $fdisplay(file_sig5_opt, "x_in,y_out");
    $fdisplay(file_tanh5, "x_in,y_out");
    $fdisplay(file_tanh5_opt, "x_in,y_out");

    $display("============================================================");
    $display("  x_in   | sig5  | sig5_opt | diff | tanh5 | tanh5_opt | diff");
    $display("============================================================");

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
        
        // Display with diff
        $display("%8d | %5d | %8d | %4d | %5d | %9d | %4d",
          x_in, y_sig5, y_sig5_opt, y_sig5 - y_sig5_opt,
          y_tanh5, y_tanh5_opt, y_tanh5 - y_tanh5_opt);
        
        // Write to files
        $fdisplay(file_sig5, "%0d,%0d", x_in, y_sig5);
        $fdisplay(file_sig5_opt, "%0d,%0d", x_in, y_sig5_opt);
        $fdisplay(file_tanh5, "%0d,%0d", x_in, y_tanh5);
        $fdisplay(file_tanh5_opt, "%0d,%0d", x_in, y_tanh5_opt);
      end
    end

    $display("============================================================");

    valid_in = 0;
    #20;

    // Close all files
    $fclose(file_in);
    $fclose(file_sig5);
    $fclose(file_sig5_opt);
    $fclose(file_tanh5);
    $fclose(file_tanh5_opt);
    
    $finish;
  end

endmodule
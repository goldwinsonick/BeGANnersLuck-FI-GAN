`timescale 1ns/1ps

module pwl_all_tb;

  reg clk;
  reg rst_n;
  reg valid_in;
  reg signed [15:0] x_in;
  
  // Sigmoid outputs
  wire valid_out_sig3, valid_out_sig5, valid_out_sig7, valid_out_sig9;
  wire signed [15:0] y_sig3, y_sig5, y_sig7, y_sig9;
  
  // Tanh outputs
  wire valid_out_tanh3, valid_out_tanh5, valid_out_tanh7, valid_out_tanh9;
  wire signed [15:0] y_tanh3, y_tanh5, y_tanh7, y_tanh9;

  // File handles
  integer file_in;
  integer file_sig3, file_sig5, file_sig7, file_sig9;
  integer file_tanh3, file_tanh5, file_tanh7, file_tanh9;
  integer scan_result;
  reg signed [15:0] x_read;

  // Instantiate all sigmoid modules
  pwl_sigmoid_3 u_sig3 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig3), .y_out(y_sig3));
  pwl_sigmoid_5 u_sig5 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig5), .y_out(y_sig5));
  pwl_sigmoid_7 u_sig7 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig7), .y_out(y_sig7));
  pwl_sigmoid_9 u_sig9 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_sig9), .y_out(y_sig9));

  // Instantiate all tanh modules
  pwl_tanh_3 u_tanh3 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh3), .y_out(y_tanh3));
  pwl_tanh_5 u_tanh5 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh5), .y_out(y_tanh5));
  pwl_tanh_7 u_tanh7 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh7), .y_out(y_tanh7));
  pwl_tanh_9 u_tanh9 (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), .x_in(x_in), .valid_out(valid_out_tanh9), .y_out(y_tanh9));

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("build/pwl_all_tb.vcd");
    $dumpvars(0, pwl_all_tb);

    // Open input file
    file_in = $fopen("data/input_test.csv", "r");
    if (file_in == 0) begin
      $display("Error: Cannot open data/input_test.csv");
      $finish;
    end

    // Open output files - Sigmoid
    file_sig3 = $fopen("data/output_pwl_sigmoid_3.csv", "w");
    file_sig5 = $fopen("data/output_pwl_sigmoid_5.csv", "w");
    file_sig7 = $fopen("data/output_pwl_sigmoid_7.csv", "w");
    file_sig9 = $fopen("data/output_pwl_sigmoid_9.csv", "w");
    
    // Open output files - Tanh
    file_tanh3 = $fopen("data/output_pwl_tanh_3.csv", "w");
    file_tanh5 = $fopen("data/output_pwl_tanh_5.csv", "w");
    file_tanh7 = $fopen("data/output_pwl_tanh_7.csv", "w");
    file_tanh9 = $fopen("data/output_pwl_tanh_9.csv", "w");

    // Write headers
    $fdisplay(file_sig3, "x_in,y_out");
    $fdisplay(file_sig5, "x_in,y_out");
    $fdisplay(file_sig7, "x_in,y_out");
    $fdisplay(file_sig9, "x_in,y_out");
    $fdisplay(file_tanh3, "x_in,y_out");
    $fdisplay(file_tanh5, "x_in,y_out");
    $fdisplay(file_tanh7, "x_in,y_out");
    $fdisplay(file_tanh9, "x_in,y_out");

    $display("=======================================================");
    $display("  x_in   | sig3  | sig5  | sig7  | sig9  | tanh3 | tanh5 | tanh7 | tanh9 ");
    $display("=======================================================");

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
        
        // Display
        $display("%8d | %5d | %5d | %5d | %5d | %5d | %5d | %5d | %5d",
          x_in, y_sig3, y_sig5, y_sig7, y_sig9, y_tanh3, y_tanh5, y_tanh7, y_tanh9);
        
        // Write to files
        $fdisplay(file_sig3, "%0d,%0d", x_in, y_sig3);
        $fdisplay(file_sig5, "%0d,%0d", x_in, y_sig5);
        $fdisplay(file_sig7, "%0d,%0d", x_in, y_sig7);
        $fdisplay(file_sig9, "%0d,%0d", x_in, y_sig9);
        $fdisplay(file_tanh3, "%0d,%0d", x_in, y_tanh3);
        $fdisplay(file_tanh5, "%0d,%0d", x_in, y_tanh5);
        $fdisplay(file_tanh7, "%0d,%0d", x_in, y_tanh7);
        $fdisplay(file_tanh9, "%0d,%0d", x_in, y_tanh9);
      end
    end

    $display("=======================================================");

    valid_in = 0;
    #20;

    // Close all files
    $fclose(file_in);
    $fclose(file_sig3);
    $fclose(file_sig5);
    $fclose(file_sig7);
    $fclose(file_sig9);
    $fclose(file_tanh3);
    $fclose(file_tanh5);
    $fclose(file_tanh7);
    $fclose(file_tanh9);
    
    $finish;
  end

endmodule
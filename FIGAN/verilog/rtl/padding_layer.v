// [padding_layer.v] - FIXED: Combinational Ready to prevent Data Drop
module padding_layer #(
    parameter DATA_WIDTH = 16,
    parameter IMG_WIDTH  = 12, // Input width
    parameter PAD_TOP    = 2,
    parameter PAD_BOTTOM = 3,
    parameter PAD_LEFT   = 2,
    parameter PAD_RIGHT  = 3
)(
    input  wire clk, rst_n,
    
    // Input Stream
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire ready_in, // [CHANGED] Changed from reg to wire (Combinational)

    // Output Stream
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out,
    input  wire ready_out
);

    localparam TOTAL_WIDTH = PAD_LEFT + IMG_WIDTH + PAD_RIGHT;
    localparam S_TOP    = 0;
    localparam S_LEFT   = 1;
    localparam S_DATA   = 2;
    localparam S_RIGHT  = 3;
    localparam S_BOTTOM = 4;

    reg [2:0] state;
    reg [15:0] x_cnt;
    reg [15:0] y_cnt;
    reg [15:0] r_cnt;

    // [CRITICAL FIX] Combinational Backpressure
    // Kita hanya siap terima data jika State == S_DATA DAN Downstream (Conv) siap.
    // Ini menghilangkan delay 1-cycle yang menyebabkan data drop.
    assign ready_in = (state == S_DATA) && ready_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_TOP; x_cnt <= 0; y_cnt <= 0; r_cnt <= 0;
            valid_out <= 0; data_out <= 0;
        end else begin
            valid_out <= 0; // Default

            case (state)
                // 1. TOP PADDING
                S_TOP: begin
                    if (PAD_TOP == 0) state <= S_LEFT;
                    else begin
                        if (ready_out) begin
                            valid_out <= 1; data_out <= 0; // Emit Zero
                            if (x_cnt == TOTAL_WIDTH - 1) begin
                                x_cnt <= 0;
                                if (r_cnt == PAD_TOP - 1) begin
                                    r_cnt <= 0; state <= S_LEFT;
                                end else r_cnt <= r_cnt + 1;
                            end else x_cnt <= x_cnt + 1;
                        end
                    end
                end

                // 2. LEFT PADDING
                S_LEFT: begin
                    if (PAD_LEFT == 0) state <= S_DATA;
                    else begin
                        if (ready_out) begin
                            valid_out <= 1; data_out <= 0; // Emit Zero
                            if (x_cnt == PAD_LEFT - 1) begin
                                x_cnt <= 0; state <= S_DATA;
                            end else x_cnt <= x_cnt + 1;
                        end
                    end
                end

                // 3. PASS DATA (Center)
                S_DATA: begin
                    // Backpressure handled by 'assign ready_in' logic
                    // Logic flow: Jika valid_in ada DAN ready_out ada -> teruskan.
                    if (valid_in && ready_out) begin
                        valid_out <= 1; data_out <= data_in; // Pass Through
                        if (x_cnt == IMG_WIDTH - 1) begin
                            x_cnt <= 0; state <= S_RIGHT;
                        end else x_cnt <= x_cnt + 1;
                    end
                end

                // 4. RIGHT PADDING
                S_RIGHT: begin
                    if (PAD_RIGHT == 0) begin 
                         y_cnt <= y_cnt + 1; state <= S_LEFT;
                    end else begin
                        if (ready_out) begin
                            valid_out <= 1; data_out <= 0; // Emit Zero
                            if (x_cnt == PAD_RIGHT - 1) begin
                                x_cnt <= 0;
                                if (y_cnt == IMG_WIDTH - 1) begin
                                    y_cnt <= 0; state <= S_BOTTOM;
                                end else begin
                                    y_cnt <= y_cnt + 1; state <= S_LEFT;
                                end
                            end else x_cnt <= x_cnt + 1;
                        end
                    end
                end

                // 5. BOTTOM PADDING
                S_BOTTOM: begin
                    if (PAD_BOTTOM == 0) state <= S_TOP;
                    else begin
                        if (ready_out) begin
                            valid_out <= 1; data_out <= 0; // Emit Zero
                            if (x_cnt == TOTAL_WIDTH - 1) begin
                                x_cnt <= 0;
                                if (r_cnt == PAD_BOTTOM - 1) begin
                                    r_cnt <= 0; state <= S_TOP;
                                end else r_cnt <= r_cnt + 1;
                            end else x_cnt <= x_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
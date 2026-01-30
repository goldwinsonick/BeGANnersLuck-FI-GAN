module zero_pad_layer #(
    parameter DATA_WIDTH = 16,
    parameter IMG_WIDTH  = 14, 
    parameter IMG_HEIGHT = 14,
    parameter PAD_TOP    = 1,
    parameter PAD_BOTTOM = 2,
    parameter PAD_LEFT   = 1,
    parameter PAD_RIGHT  = 2
)(
    input  wire clk, rst_n,
    input  wire valid_in,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output wire ready_in,

    input  wire ready_out,
    output reg  valid_out,
    output reg  signed [DATA_WIDTH-1:0] data_out
);

    localparam TOTAL_WIDTH = IMG_WIDTH + PAD_LEFT + PAD_RIGHT;
    
    localparam S_PAD_TOP    = 0;
    localparam S_PAD_LEFT   = 1;
    localparam S_PASS_DATA  = 2;
    localparam S_PAD_RIGHT  = 3;
    localparam S_PAD_BOTTOM = 4;

    reg [2:0] state;
    reg [15:0] x_cnt, y_cnt, pad_cnt;

    // Ready in hanya high kalau kita siap terima data (PASS_DATA)
    // DAN downstream siap terima output kita.
    assign ready_in = (state == S_PASS_DATA) && ready_out && (!valid_out || ready_out);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= S_PAD_TOP;
            valid_out <= 0; data_out <= 0;
            x_cnt <= 0; y_cnt <= 0; pad_cnt <= 0;
        end else begin
            // --- FREEZE LOGIC ---
            if (valid_out && !ready_out) begin
                valid_out <= 1; // Keep holding data
            end else begin
                // --- NORMAL LOGIC ---
                valid_out <= 0;
                
                case(state)
                    // 1. TOP PADDING
                    S_PAD_TOP: begin
                        valid_out <= 1;
                        data_out  <= 0;
                        
                        if (pad_cnt == (PAD_TOP * TOTAL_WIDTH) - 1) begin
                             pad_cnt <= 0;
                             if (IMG_HEIGHT == 0) state <= S_PAD_BOTTOM;
                             else state <= S_PAD_LEFT;
                        end else begin
                             pad_cnt <= pad_cnt + 1;
                        end
                    end

                    // 2. LEFT PADDING
                    S_PAD_LEFT: begin
                        valid_out <= 1;
                        data_out  <= 0;
                        
                        if (pad_cnt == PAD_LEFT - 1) begin
                            pad_cnt <= 0;
                            x_cnt   <= 0; // Pastikan counter X reset disini
                            state   <= S_PASS_DATA;
                        end else begin
                            pad_cnt <= pad_cnt + 1;
                        end
                    end

                    // 3. PASS REAL DATA
                    S_PASS_DATA: begin
                        // Syarat: Ada Valid In DAN Downstream Ready
                        if (valid_in && ready_out) begin
                            valid_out <= 1;
                            data_out  <= data_in;
                            
                            if (x_cnt == IMG_WIDTH - 1) begin
                                state <= S_PAD_RIGHT;
                            end else begin
                                x_cnt <= x_cnt + 1;
                            end
                        end
                    end

                    // 4. RIGHT PADDING
                    S_PAD_RIGHT: begin
                        valid_out <= 1;
                        data_out  <= 0;

                        if (pad_cnt == PAD_RIGHT - 1) begin
                            pad_cnt <= 0;
                            if (y_cnt == IMG_HEIGHT - 1) begin
                                state <= S_PAD_BOTTOM;
                            end else begin
                                y_cnt <= y_cnt + 1;
                                state <= S_PAD_LEFT;
                            end
                        end else begin
                            pad_cnt <= pad_cnt + 1;
                        end
                    end

                    // 5. BOTTOM PADDING
                    S_PAD_BOTTOM: begin
                        valid_out <= 1;
                        data_out  <= 0;
                        
                        if (pad_cnt == (PAD_BOTTOM * TOTAL_WIDTH) - 1) begin
                            pad_cnt <= 0;
                            y_cnt   <= 0;
                            state   <= S_PAD_TOP; 
                        end else begin
                            pad_cnt <= pad_cnt + 1;
                        end
                    end
                endcase
            end
        end
    end
endmodule
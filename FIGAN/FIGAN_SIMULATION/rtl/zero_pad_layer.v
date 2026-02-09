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

    localparam TOTAL_WIDTH  = PAD_LEFT + IMG_WIDTH + PAD_RIGHT;
    localparam TOTAL_HEIGHT = PAD_TOP + IMG_HEIGHT + PAD_BOTTOM;

    reg [15:0] out_x;
    reg [15:0] out_y;
    reg frame_done; 
    
    // Tetap 1024 agar pipeline bersih total
    reg [11:0] flush_cnt; 
    localparam FLUSH_CYCLES = 1024; 

    wire region_active_x = (out_x >= PAD_LEFT) && (out_x < PAD_LEFT + IMG_WIDTH);
    wire region_active_y = (out_y >= PAD_TOP)  && (out_y < PAD_TOP + IMG_HEIGHT);
    wire inside_content  = region_active_x && region_active_y;

    always @(*) begin
        if (frame_done) begin
            valid_out = 1'b0;
            data_out  = 0;
        end 
        else if (inside_content) begin
            valid_out = valid_in;
            data_out  = data_in;
        end else begin
            valid_out = 1'b1; 
            data_out  = {DATA_WIDTH{1'b0}};
        end
    end

    assign ready_in = !frame_done && (flush_cnt == 0) && inside_content && ready_out;
    wire fire_out = valid_out && ready_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_x <= 0; out_y <= 0; frame_done <= 0; flush_cnt <= 0;
        end else begin
            if (flush_cnt > 0) begin
                if (fire_out) begin
                    if (flush_cnt == FLUSH_CYCLES) frame_done <= 1;
                    else flush_cnt <= flush_cnt + 1;
                end
            end
            else if (fire_out) begin
                if (out_x == TOTAL_WIDTH - 1) begin
                    out_x <= 0;
                    if (out_y == TOTAL_HEIGHT - 1) flush_cnt <= 1; 
                    else out_y <= out_y + 1;
                end else out_x <= out_x + 1;
            end
        end
    end
endmodule
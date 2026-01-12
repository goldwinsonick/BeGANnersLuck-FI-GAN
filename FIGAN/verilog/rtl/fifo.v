module fifo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 1024 // Ukuran aman
)(
    input  wire clk, rst_n,
    input  wire wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    input  wire rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire empty,
    output wire full
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    reg [$clog2(DEPTH):0] count;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0; rd_ptr <= 0; count <= 0; rd_data <= 0;
        end else begin
            // Write
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= (wr_ptr == DEPTH-1) ? 0 : wr_ptr + 1;
            end
            // Read
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= (rd_ptr == DEPTH-1) ? 0 : rd_ptr + 1;
            end
            // Count
            if (wr_en && !full && !(rd_en && !empty)) count <= count + 1;
            else if (rd_en && !empty && !(wr_en && !full)) count <= count - 1;
        end
    end
endmodule
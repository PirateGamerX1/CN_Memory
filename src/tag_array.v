module tag_array (
    input wire clk,
    input wire reset,
    input wire [6:0] index,
    input wire [18:0] tag_in,
    input wire write_enable,
    input wire [1:0] write_way,
    output wire [18:0] tag_out_0,
    output wire [18:0] tag_out_1,
    output wire [18:0] tag_out_2,
    output wire [18:0] tag_out_3,
    output wire [3:0] valid_bits
);

    parameter NUM_SETS = 128;
    parameter TAG_BITS = 19;

    // Tag memory arrays for each way
    reg [TAG_BITS-1:0] tag_memory [3:0] [NUM_SETS-1:0];
    reg valid_memory [3:0] [NUM_SETS-1:0];

    integer i, j;

    // Initialize memory
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < NUM_SETS; j = j + 1) begin
                tag_memory[i][j] = 0;
                valid_memory[i][j] = 0;
            end
        end
    end

    // Read operation - assign individual outputs
    assign tag_out_0 = tag_memory[0][index];
    assign tag_out_1 = tag_memory[1][index];
    assign tag_out_2 = tag_memory[2][index];
    assign tag_out_3 = tag_memory[3][index];
    
    assign valid_bits[0] = valid_memory[0][index];
    assign valid_bits[1] = valid_memory[1][index];
    assign valid_bits[2] = valid_memory[2][index];
    assign valid_bits[3] = valid_memory[3][index];

    // Write operation
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < NUM_SETS; j = j + 1) begin
                    tag_memory[i][j] <= 0;
                    valid_memory[i][j] <= 0;
                end
            end
        end else if (write_enable) begin
            // Write to the specified way
            tag_memory[write_way][index] <= tag_in;
            valid_memory[write_way][index] <= 1'b1;
        end
    end

endmodule
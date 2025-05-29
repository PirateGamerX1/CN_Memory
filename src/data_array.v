module data_array (
    input wire clk,
    input wire reset,
    input wire [6:0] index,
    input wire [511:0] data_in,
    input wire [31:0] word_data_in,
    input wire [3:0] word_offset, // Changed to 4 bits
    input wire write_enable,
    input wire word_write_enable,
    input wire [1:0] write_way,
    input wire [3:0] hit_way,
    output wire [511:0] data_out_0,
    output wire [511:0] data_out_1,
    output wire [511:0] data_out_2,
    output wire [511:0] data_out_3
);

    parameter NUM_SETS = 128;
    parameter BLOCK_SIZE = 512;

    // Data memory arrays for each way
    reg [BLOCK_SIZE-1:0] data_memory [3:0] [NUM_SETS-1:0];

    integer i, j;

    // Initialize memory
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < NUM_SETS; j = j + 1) begin
                data_memory[i][j] = 0;
            end
        end
    end

    // Read operation - assign individual outputs
    assign data_out_0 = data_memory[0][index];
    assign data_out_1 = data_memory[1][index];
    assign data_out_2 = data_memory[2][index];
    assign data_out_3 = data_memory[3][index];

    // FIXED: Write operation with proper debugging
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < NUM_SETS; j = j + 1) begin
                    data_memory[i][j] <= 0;
                end
            end
        end else if (write_enable) begin
            // Write entire block (from memory)
            data_memory[write_way][index] <= data_in;
            $display("DATA_ARRAY: Block write to way %d, index %d, data=%h", 
                     write_way, index, data_in);
        end else if (word_write_enable) begin
            // FIXED: Write single word with debugging
            $display("DATA_ARRAY: Word write enable, hit_way=%b, word_offset=%d, data=%h", 
                     hit_way, word_offset, word_data_in);
            if (hit_way[0]) begin
                data_memory[0][index][word_offset*32 +: 32] <= word_data_in;
                $display("DATA_ARRAY: Writing to way 0");
            end
            if (hit_way[1]) begin
                data_memory[1][index][word_offset*32 +: 32] <= word_data_in;
                $display("DATA_ARRAY: Writing to way 1");
            end
            if (hit_way[2]) begin
                data_memory[2][index][word_offset*32 +: 32] <= word_data_in;
                $display("DATA_ARRAY: Writing to way 2");
            end
            if (hit_way[3]) begin
                data_memory[3][index][word_offset*32 +: 32] <= word_data_in;
                $display("DATA_ARRAY: Writing to way 3");
            end
        end
    end

endmodule
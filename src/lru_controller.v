module lru_controller (
    input wire clk,
    input wire reset,
    input wire [6:0] index,
    input wire [3:0] access_way,
    input wire update_lru,
    output reg [3:0] lru_way
);

    parameter NUM_SETS = 128;

    // LRU counters for each way in each set
    reg [1:0] lru_counters [3:0] [NUM_SETS-1:0];

    integer i, j;

    // Initialize LRU counters
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < NUM_SETS; j = j + 1) begin
                lru_counters[i][j] = i[1:0]; // Initialize with different values
            end
        end
    end

    // Find LRU way (the one with highest counter value)
    always @(*) begin
        lru_way = 4'b0001; // Default to way 0
        
        // Find the way with the highest LRU counter (least recently used)
        if ((lru_counters[0][index] >= lru_counters[1][index]) &&
            (lru_counters[0][index] >= lru_counters[2][index]) &&
            (lru_counters[0][index] >= lru_counters[3][index]))
            lru_way = 4'b0001;
        else if ((lru_counters[1][index] >= lru_counters[0][index]) &&
                 (lru_counters[1][index] >= lru_counters[2][index]) &&
                 (lru_counters[1][index] >= lru_counters[3][index]))
            lru_way = 4'b0010;
        else if ((lru_counters[2][index] >= lru_counters[0][index]) &&
                 (lru_counters[2][index] >= lru_counters[1][index]) &&
                 (lru_counters[2][index] >= lru_counters[3][index]))
            lru_way = 4'b0100;
        else
            lru_way = 4'b1000;
    end

    // Update LRU on access
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < NUM_SETS; j = j + 1) begin
                    lru_counters[i][j] <= i[1:0];
                end
            end
        end else if (update_lru) begin
            // Update LRU counters based on accessed way
            for (i = 0; i < 4; i = i + 1) begin
                if (access_way[i]) begin
                    lru_counters[i][index] <= 2'b00; // Most recently used
                end else if (lru_counters[i][index] < 2'b11) begin
                    lru_counters[i][index] <= lru_counters[i][index] + 1;
                end
            end
        end
    end

endmodule
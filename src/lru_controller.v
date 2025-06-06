module lru_controller (
    input wire clk,
    input wire reset,
    input wire [6:0] index,
    input wire [3:0] access_way,
    input wire update_lru,
    output reg [3:0] lru_way
);

    parameter NUM_SETS = 128;

    reg [1:0] lru_counters [3:0] [NUM_SETS-1:0];

    integer i, j;

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < NUM_SETS; j = j + 1) begin
                lru_counters[i][j] = i[1:0];
            end
        end
    end

    always @(*) begin
        lru_way = 4'b0001;
        
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

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < NUM_SETS; j = j + 1) begin
                    lru_counters[i][j] <= i[1:0];
                end
            end
        end else if (update_lru) begin
            for (i = 0; i < 4; i = i + 1) begin
                if (access_way[i]) begin
                    lru_counters[i][index] <= 2'b00;
                end else if (lru_counters[i][index] < 2'b11) begin
                    lru_counters[i][index] <= lru_counters[i][index] + 1;
                end
            end
        end
    end

endmodule
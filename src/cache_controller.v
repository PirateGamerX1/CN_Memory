module cache_controller (
    input wire clk,
    input wire reset,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire read_enable,
    input wire write_enable,
    output reg [31:0] read_data,
    output reg cache_hit,
    output reg cache_ready,
    output reg [31:0] mem_address,
    output reg [511:0] mem_write_data,
    input wire [511:0] mem_read_data,
    output reg mem_read_enable,
    output reg mem_write_enable,
    input wire mem_ready
);

    parameter CACHE_SIZE = 32768;
    parameter BLOCK_SIZE = 64;
    parameter WORD_SIZE = 4;
    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;
    parameter OFFSET_BITS = 6;
    parameter INDEX_BITS = 7;
    parameter TAG_BITS = 19;

    parameter IDLE = 3'b000;
    parameter READ_HIT = 3'b001;
    parameter READ_MISS = 3'b010;
    parameter WRITE_HIT = 3'b011;
    parameter WRITE_MISS = 3'b100;
    parameter EVICT = 3'b101;

    reg [2:0] current_state, next_state;

    wire [TAG_BITS-1:0] tag;
    wire [INDEX_BITS-1:0] index;
    wire [OFFSET_BITS-1:0] offset;
    
    assign tag = address[31:13];
    assign index = address[12:6];
    assign offset = address[5:0];

    wire [3:0] hit_way;
    wire cache_hit_internal;
    wire [511:0] cache_data_out;
    wire [3:0] lru_way;
    wire [31:0] cache_read_data;
    
    wire cache_block_write_enable;
    wire cache_word_write_enable;
    
    assign cache_block_write_enable = (current_state == READ_MISS || current_state == WRITE_MISS) && mem_ready;
    assign cache_word_write_enable = (current_state == WRITE_HIT); 

    reg [31:0] read_data_reg;

    cache_memory cache_mem_inst (
        .clk(clk),
        .reset(reset),
        .address(address),
        .write_data(write_data),
        .mem_data_in(mem_read_data),
        .write_enable(cache_word_write_enable),
        .mem_write_enable(cache_block_write_enable),
        .lru_way(lru_way),
        .hit_way(hit_way),
        .cache_hit(cache_hit_internal),
        .data_out(cache_read_data),
        .cache_data_out(cache_data_out)
    );

    lru_controller lru_inst (
        .clk(clk),
        .reset(reset),
        .index(index),
        .access_way(hit_way),
        .update_lru(cache_hit_internal && (current_state == READ_HIT || current_state == WRITE_HIT)),
        .lru_way(lru_way)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            read_data_reg <= 32'b0;
        end else begin
            current_state <= next_state;
            
            if (current_state == READ_HIT) begin
                read_data_reg <= cache_read_data;
            end
            
            if (current_state == READ_MISS && next_state == IDLE) begin
                read_data_reg <= cache_read_data;
            end
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (read_enable && cache_hit_internal) 
                    next_state = READ_HIT;
                else if (read_enable && !cache_hit_internal)
                    next_state = READ_MISS;
                else if (write_enable && cache_hit_internal)
                    next_state = WRITE_HIT;
                else if (write_enable && !cache_hit_internal)
                    next_state = WRITE_MISS;
            end
            
            READ_HIT: next_state = IDLE;
            
            READ_MISS: begin
                if (mem_ready)
                    next_state = IDLE;
            end
            
            WRITE_HIT: next_state = IDLE;
            
            WRITE_MISS: begin
                if (mem_ready)
                    next_state = IDLE;
            end
            
            EVICT: begin
                if (mem_ready)
                    next_state = WRITE_MISS;
            end
        endcase
    end

    always @(*) begin
        cache_hit = 1'b0;
        cache_ready = 1'b0;
        mem_address = 32'b0;
        mem_write_data = 512'b0;
        mem_read_enable = 1'b0;
        mem_write_enable = 1'b0;
        read_data = read_data_reg;

        case (current_state)
            IDLE: begin
                cache_ready = 1'b1;
                if (cache_hit_internal) begin
                    read_data = cache_read_data;
                end
            end
            
            READ_HIT: begin
                cache_hit = 1'b1;
                cache_ready = 1'b1;
                read_data = cache_read_data; 
            end
            
            READ_MISS: begin
                mem_address = {address[31:6], 6'b0};
                mem_read_enable = 1'b1;
                cache_ready = mem_ready;
                if (mem_ready) begin
                    read_data = cache_read_data;
                end
            end
            
            WRITE_HIT: begin
                cache_hit = 1'b1;
                cache_ready = 1'b1;
            end
            
            WRITE_MISS: begin
                mem_address = {address[31:6], 6'b0};
                mem_read_enable = 1'b1;
                cache_ready = mem_ready;
            end
            
            EVICT: begin
                mem_address = {address[31:6], 6'b0};
                mem_write_data = cache_data_out;
                mem_write_enable = 1'b1;
            end
        endcase
    end

endmodule
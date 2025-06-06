module cache_memory (
    input wire clk,
    input wire reset,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire [511:0] mem_data_in,
    input wire write_enable,
    input wire mem_write_enable,
    input wire [3:0] lru_way,
    output wire [3:0] hit_way,
    output wire cache_hit,
    output reg [31:0] data_out,
    output reg [511:0] cache_data_out
);

    parameter INDEX_BITS = 7;
    parameter TAG_BITS = 19;
    parameter OFFSET_BITS = 6;
    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;

    wire [TAG_BITS-1:0] tag = address[31:13];
    wire [INDEX_BITS-1:0] index = address[12:6];
    wire [OFFSET_BITS-1:0] offset = address[5:0];
    wire [3:0] word_offset = offset[5:2];

    wire [TAG_BITS-1:0] tag_out_0, tag_out_1, tag_out_2, tag_out_3;
    wire [3:0] valid_bits;

    wire [1:0] write_way_select;
    assign write_way_select = (lru_way == 4'b0001) ? 2'b00 :
                             (lru_way == 4'b0010) ? 2'b01 :
                             (lru_way == 4'b0100) ? 2'b10 : 2'b11;

    tag_array tag_array_inst (
        .clk(clk),
        .reset(reset),
        .index(index),
        .tag_in(tag),
        .write_enable(mem_write_enable),
        .write_way(write_way_select),
        .tag_out_0(tag_out_0),
        .tag_out_1(tag_out_1),
        .tag_out_2(tag_out_2),
        .tag_out_3(tag_out_3),
        .valid_bits(valid_bits)
    );

    wire [511:0] data_out_0, data_out_1, data_out_2, data_out_3;

    data_array data_array_inst (
        .clk(clk),
        .reset(reset),
        .index(index),
        .data_in(mem_data_in),
        .word_data_in(write_data),
        .word_offset(word_offset),
        .write_enable(mem_write_enable),
        .word_write_enable(write_enable),
        .write_way(write_way_select),
        .hit_way(hit_way),
        .data_out_0(data_out_0),
        .data_out_1(data_out_1),
        .data_out_2(data_out_2),
        .data_out_3(data_out_3)
    );

    wire [3:0] way_hit;
    assign way_hit[0] = valid_bits[0] && (tag_out_0 == tag);
    assign way_hit[1] = valid_bits[1] && (tag_out_1 == tag);
    assign way_hit[2] = valid_bits[2] && (tag_out_2 == tag);
    assign way_hit[3] = valid_bits[3] && (tag_out_3 == tag);

    assign cache_hit = |way_hit;
    assign hit_way = way_hit;

    always @(*) begin
        data_out = 32'b0;
        cache_data_out = 512'b0;
        
        if (way_hit[0]) begin
            data_out = data_out_0[word_offset*32 +: 32];
            cache_data_out = data_out_0;
        end else if (way_hit[1]) begin
            data_out = data_out_1[word_offset*32 +: 32];
            cache_data_out = data_out_1;
        end else if (way_hit[2]) begin
            data_out = data_out_2[word_offset*32 +: 32];
            cache_data_out = data_out_2;
        end else if (way_hit[3]) begin
            data_out = data_out_3[word_offset*32 +: 32];
            cache_data_out = data_out_3;
        end else begin
            case (lru_way)
                4'b0001: begin
                    data_out = data_out_0[word_offset*32 +: 32];
                    cache_data_out = data_out_0;
                end
                4'b0010: begin
                    data_out = data_out_1[word_offset*32 +: 32];
                    cache_data_out = data_out_1;
                end
                4'b0100: begin
                    data_out = data_out_2[word_offset*32 +: 32];
                    cache_data_out = data_out_2;
                end
                4'b1000: begin
                    data_out = data_out_3[word_offset*32 +: 32];
                    cache_data_out = data_out_3;
                end
                default: begin
                    data_out = data_out_0[word_offset*32 +: 32];
                    cache_data_out = data_out_0;
                end
            endcase
        end
        
        if (|way_hit || |lru_way) begin
            $display("CACHE_MEMORY: way_hit=%b, lru_way=%b, word_offset=%d, data_out=%h", 
                     way_hit, lru_way, word_offset, data_out);
        end
    end

endmodule
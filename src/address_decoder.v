module address_decoder (
    input wire [31:0] address,
    output wire [18:0] tag,
    output wire [6:0] index,
    output wire [5:0] offset,
    output wire [1:0] word_offset
);

    parameter TAG_BITS = 19;
    parameter INDEX_BITS = 7;
    parameter OFFSET_BITS = 6;

    assign tag = address[31:31-TAG_BITS+1];
    assign index = address[12:6];
    assign offset = address[5:0];
    assign word_offset = address[3:2];

endmodule
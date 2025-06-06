module test_vectors;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter BLOCK_SIZE = 64;
    parameter NUM_SETS = 128;
    parameter NUM_WAYS = 4;

    reg clk;
    reg reset;

    reg [31:0] address;
    reg [31:0] write_data;
    reg read_enable;
    reg write_enable;

    wire [31:0] read_data;
    wire cache_hit;
    wire cache_ready;

    wire [31:0] mem_address;
    wire [511:0] mem_write_data;
    reg [511:0] mem_read_data;
    wire mem_read_enable;
    wire mem_write_enable;
    reg mem_ready;

    cache_controller uut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .write_data(write_data),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .read_data(read_data),
        .cache_hit(cache_hit),
        .cache_ready(cache_ready),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data),
        .mem_read_data(mem_read_data),
        .mem_read_enable(mem_read_enable),
        .mem_write_enable(mem_write_enable),
        .mem_ready(mem_ready)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        address = 0;
        write_data = 0;
        read_enable = 0;
        write_enable = 0;
        mem_read_data = 0;
        mem_ready = 1;

        #20 reset = 0;
        #10;

        $display("=== Cache Controller Test Vectors ===");

        $display("Test 1: Read miss from empty cache");
        address = 32'h00001000;
        read_enable = 1;
        mem_read_data = {16{32'hDEADBEEF}};
        #10;
        read_enable = 0;
        #20;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        $display("Test 2: Read hit (same address)");
        address = 32'h00001000;
        read_enable = 1;
        #10;
        read_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        $display("Test 3: Write hit");
        address = 32'h00001000;
        write_data = 32'hCAFEBABE;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Write Data: %h", 
                 address, cache_hit, cache_ready, write_data);

        $display("Test 4: Read back written data");
        address = 32'h00001000;
        read_enable = 1;
        #10;
        read_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        $display("Test 5: Write miss (different set)");
        address = 32'h00002000;
        write_data = 32'h12345678;
        write_enable = 1;
        mem_read_data = {16{32'h87654321}};
        #10;
        write_enable = 0;
        #20;
        $display("Address: %h, Hit: %b, Ready: %b, Write Data: %h", 
                 address, cache_hit, cache_ready, write_data);

        $display("Test 6: Testing LRU replacement");
        address = 32'h00010000;
        read_enable = 1;
        mem_read_data = {16{32'hAAAABBBB}};
        #20; read_enable = 0; #10;
        
        address = 32'h00020000;
        read_enable = 1;
        mem_read_data = {16{32'hCCCCDDDD}};
        #20; read_enable = 0; #10;
        
        address = 32'h00030000;
        read_enable = 1;
        mem_read_data = {16{32'hEEEEFFFF}};
        #20; read_enable = 0; #10;

        $display("=== Test Vectors Complete ===");
        #50;
        $finish;
    end

    initial begin
        $monitor("Time=%0t, State=%0d, Addr=%h, R=%b, W=%b, Hit=%b, Ready=%b", 
                 $time, uut.current_state, address, read_enable, write_enable, 
                 cache_hit, cache_ready);
    end

endmodule
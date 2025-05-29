// Test vectors for cache controller
// This file contains predefined test data
module test_vectors;

    // Parameters matching cache controller
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter BLOCK_SIZE = 64;
    parameter NUM_SETS = 128;
    parameter NUM_WAYS = 4;

    // Clock and reset
    reg clk;
    reg reset;

    // Input signals matching cache_controller interface
    reg [31:0] address;
    reg [31:0] write_data;
    reg read_enable;
    reg write_enable;

    // Output signals from cache controller
    wire [31:0] read_data;
    wire cache_hit;
    wire cache_ready;

    // Memory interface signals
    wire [31:0] mem_address;
    wire [511:0] mem_write_data;
    reg [511:0] mem_read_data;
    wire mem_read_enable;
    wire mem_write_enable;
    reg mem_ready;

    // Instantiate the cache controller with correct interface
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

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test vector generation
    initial begin
        // Initialize all signals
        reset = 1;
        address = 0;
        write_data = 0;
        read_enable = 0;
        write_enable = 0;
        mem_read_data = 0;
        mem_ready = 1;

        // Reset sequence
        #20 reset = 0;
        #10;

        $display("=== Cache Controller Test Vectors ===");

        // Test vector 1: Read miss from empty cache
        $display("Test 1: Read miss from empty cache");
        address = 32'h00001000;
        read_enable = 1;
        mem_read_data = {16{32'hDEADBEEF}}; // Fill 512-bit block
        #10;
        read_enable = 0;
        #20;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        // Test vector 2: Read hit (same address)
        $display("Test 2: Read hit (same address)");
        address = 32'h00001000;
        read_enable = 1;
        #10;
        read_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        // Test vector 3: Write hit
        $display("Test 3: Write hit");
        address = 32'h00001000;
        write_data = 32'hCAFEBABE;
        write_enable = 1;
        #10;
        write_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Write Data: %h", 
                 address, cache_hit, cache_ready, write_data);

        // Test vector 4: Read back written data
        $display("Test 4: Read back written data");
        address = 32'h00001000;
        read_enable = 1;
        #10;
        read_enable = 0;
        #10;
        $display("Address: %h, Hit: %b, Ready: %b, Data: %h", 
                 address, cache_hit, cache_ready, read_data);

        // Test vector 5: Write miss (different set)
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

        // Test vector 6: Multiple accesses to test LRU
        $display("Test 6: Testing LRU replacement");
        // Access way 0
        address = 32'h00010000; // Set 0, different tag
        read_enable = 1;
        mem_read_data = {16{32'hAAAABBBB}};
        #20; read_enable = 0; #10;
        
        // Access way 1
        address = 32'h00020000; // Set 0, different tag
        read_enable = 1;
        mem_read_data = {16{32'hCCCCDDDD}};
        #20; read_enable = 0; #10;
        
        // Access way 2
        address = 32'h00030000; // Set 0, different tag
        read_enable = 1;
        mem_read_data = {16{32'hEEEEFFFF}};
        #20; read_enable = 0; #10;

        $display("=== Test Vectors Complete ===");
        #50;
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t, State=%0d, Addr=%h, R=%b, W=%b, Hit=%b, Ready=%b", 
                 $time, uut.current_state, address, read_enable, write_enable, 
                 cache_hit, cache_ready);
    end

endmodule
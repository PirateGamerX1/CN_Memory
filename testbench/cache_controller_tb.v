module cache_controller_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CACHE_SIZE = 32 * 1024; // 32 KB
    parameter BLOCK_SIZE = 64; // 64 bytes
    parameter NUM_SETS = 128; // 128 sets
    parameter ASSOC = 4; // 4-way set associative

    // Clock and reset
    reg clk;
    reg reset;

    // Cache controller interface
    reg [31:0] address;
    reg [31:0] write_data;
    reg read_enable;
    reg write_enable;
    wire [31:0] read_data;
    wire cache_hit;
    wire cache_ready;

    // Memory interface
    wire [31:0] mem_address;
    wire [511:0] mem_write_data;
    reg [511:0] mem_read_data;
    wire mem_read_enable;
    wire mem_write_enable;
    reg mem_ready;

    // Instantiate cache controller
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

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        address = 0;
        write_data = 0;
        read_enable = 0;
        write_enable = 0;
        mem_read_data = 0;
        mem_ready = 1;

        // Reset
        #20 reset = 0;
        #10;

        $display("=== Cache Controller Testbench ===");
        $display("Time=%0t: Starting cache controller tests", $time);

        // Test case 1: Read miss from empty cache
        $display("\n=== Test 1: Read miss from empty cache ===");
        address = 32'h00001000;
        mem_read_data = {16{32'hDEADBEEF}}; // All words are DEADBEEF for simplicity
        
        $display("Before READ_MISS: Setting mem_read_data to first 32 bits: %h", mem_read_data[31:0]);
        
        read_enable = 1;
        @(posedge clk); // Wait for FSM transition
        
        // Wait for operation to complete
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk); // Let FSM return to IDLE
        @(posedge clk); // FIXED: Extra cycle for data to be captured
        @(posedge clk); // FIXED: Another cycle to ensure data is available
        
        $display("After READ_MISS: read_data=%h", read_data);
        $display("cache_hit_internal=%b, cache_block_write_enable=%b", 
                 uut.cache_hit_internal, uut.cache_block_write_enable);
        $display("cache_read_data=%h", uut.cache_read_data);
        $display("Expected: DEADBEEF, Got: %h %s", read_data, 
                 (read_data == 32'hDEADBEEF) ? "PASS" : "FAIL");

        // Test case 2: Read hit (same address)
        $display("\n=== Test 2: Read hit (same address) ===");
        address = 32'h00001000;
        
        read_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk);
        
        $display("After READ_HIT: read_data=%h, cache_hit=%b", read_data, cache_hit);
        $display("cache_read_data=%h", uut.cache_read_data);
        $display("Expected: DEADBEEF, Got: %h %s", read_data,
                 (read_data == 32'hDEADBEEF) ? "PASS" : "FAIL");

        // Test case 3: Write hit with DIFFERENT data
        $display("\n=== Test 3: Write hit with NEW data ===");
        address = 32'h00001000;
        write_data = 32'hAAAABBBB;
        
        $display("Writing %h to address %h", write_data, address);
        $display("Before write: cache_word_write_enable=%b", uut.cache_word_write_enable);
        
        write_enable = 1;
        @(posedge clk);
        
        $display("During write: current_state=%d, cache_word_write_enable=%b", 
                 uut.current_state, uut.cache_word_write_enable);
        
        while (!cache_ready) @(posedge clk);
        
        write_enable = 0;
        @(posedge clk);
        @(posedge clk); // Extra cycle to ensure write completes
        
        $display("After WRITE_HIT: cache_hit=%b", cache_hit);

        // Test case 4: Read back written data IMMEDIATELY
        $display("\n=== Test 4: Read back written data ===");
        address = 32'h00001000;
        
        read_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk);
        
        $display("After reading written data: read_data=%h, cache_hit=%b", read_data, cache_hit);
        $display("cache_read_data=%h", uut.cache_read_data);
        $display("Expected: AAAABBBB, Got: %h %s", read_data,
                 (read_data == 32'hAAAABBBB) ? "PASS" : "FAIL");

        // Test case 5: Read miss from different address
        $display("\n=== Test 5: Read miss from different address ===");
        address = 32'h00002000;
        mem_read_data = {16{32'h12345678}}; // Different pattern
        
        $display("Setting mem_read_data to first 32 bits: %h for address %h", mem_read_data[31:0], address);
        
        read_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk); // FIXED: Wait for FSM to return to IDLE
        @(posedge clk); // FIXED: Wait for cache data to be available
        
        $display("After READ_MISS: read_data=%h", read_data);
        $display("cache_read_data=%h", uut.cache_read_data);
        $display("Expected: 12345678, Got: %h %s", read_data,
                 (read_data == 32'h12345678) ? "PASS" : "FAIL");

        // Test case 6: Write to new address
        $display("\n=== Test 6: Write to second address ===");
        address = 32'h00002000;
        write_data = 32'hCCCCDDDD;
        
        write_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        write_enable = 0;
        @(posedge clk);
        @(posedge clk);

        // Read back
        read_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk);
        
        $display("After writing and reading back: read_data=%h", read_data);
        $display("Expected: CCCCDDDD, Got: %h %s", read_data,
                 (read_data == 32'hCCCCDDDD) ? "PASS" : "FAIL");

        // Test case 7: Verify first address still has written data
        $display("\n=== Test 7: Verify first address data persistence ===");
        address = 32'h00001000;
        
        read_enable = 1;
        @(posedge clk);
        
        while (!cache_ready) @(posedge clk);
        
        read_enable = 0;
        @(posedge clk);
        
        $display("Reading first address again: read_data=%h", read_data);
        $display("Expected: AAAABBBB, Got: %h %s", read_data,
                 (read_data == 32'hAAAABBBB) ? "PASS" : "FAIL");

        $display("\n=== Summary ===");
        $display("Cache controller comprehensive test completed");
        
        #50;
        $finish;
    end

    // Enhanced monitor with more debugging info
    always @(posedge clk) begin
        if (uut.current_state != uut.next_state || read_enable || write_enable) begin
            $display("Clock: State=%0d->%0d, Addr=%h, R=%b, W=%b, Hit_int=%b, Hit=%b, Data=%h", 
                     uut.current_state, uut.next_state, address, read_enable, write_enable, 
                     uut.cache_hit_internal, cache_hit, read_data);
            $display("       cache_read_data=%h, block_we=%b, word_we=%b", 
                     uut.cache_read_data, uut.cache_block_write_enable, uut.cache_word_write_enable);
        end
    end

    // Generate VCD file for waveform analysis
    initial begin
        $dumpfile("cache_controller.vcd");
        $dumpvars(0, cache_controller_tb);
    end

endmodule
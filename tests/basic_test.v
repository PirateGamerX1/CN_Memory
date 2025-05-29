module basic_test;
    reg clk;
    reg reset;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire hit;

    // Instantiate the cache controller
    cache_controller uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .hit(hit)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data_in = 8'b0;

        // Apply reset
        #5 reset = 0;

        // Test case 1: Write data to cache
        data_in = 8'b10101010;
        #10; // Wait for some time
        // Add assertions here to check if data_out and hit are as expected

        // Test case 2: Read data from cache
        data_in = 8'b0; // Assuming read operation
        #10; // Wait for some time
        // Add assertions here to check if data_out and hit are as expected

        // Finish simulation
        #10 $finish;
    end

    always #5 clk = ~clk; // Clock generation

endmodule
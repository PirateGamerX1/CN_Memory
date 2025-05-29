# Makefile for Cache Controller Project

# Define the Verilog source files
SRC = src/cache_controller.v src/cache_memory.v src/tag_array.v src/data_array.v src/lru_controller.v src/address_decoder.v

# Define the testbench files - using only the working testbench
TB = testbench/cache_controller_tb.v

# Define the simulation tool
SIM_TOOL = iverilog

# Define the output executable name
OUTPUT = cache_controller_sim

# Default target
all: compile simulate

# Compile the Verilog files
compile:
	$(SIM_TOOL) -o $(OUTPUT) $(SRC) $(TB)

# Run the simulation
simulate:
	vvp $(OUTPUT)

# Test target - compile and run simulation
test: compile simulate

# Clean up generated files
clean:
	rm -f $(OUTPUT) *.vcd

# Phony targets
.PHONY: all compile simulate test clean
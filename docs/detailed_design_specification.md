# Detailed Design Specification
## 4-Way Set-Associative Cache Controller

**Project Title:** Implementation of a Cache Controller using Hardware Description Language  
**Authors:** Cache Controller Development Team  
**Date:** June 2025  
**Version:** 1.0  

---

## 1. Introduction

This document presents the detailed design specification for a 4-way set-associative cache controller implemented in Verilog HDL. The cache controller is designed to manage a 32KB cache system with 64-byte blocks, implementing a Least Recently Used (LRU) replacement policy and write-back with write-allocate strategy. The design utilizes a finite state machine (FSM) architecture to efficiently handle cache operations and ensure optimal performance in computer memory hierarchy systems.

## 2. System Architecture Overview

The cache controller system consists of six primary modules working in coordination to provide efficient memory access management:

- **Cache Controller (Main FSM):** Central control unit managing all cache operations
- **Cache Memory:** Coordinating module interfacing with tag and data arrays
- **Tag Array:** Storage for address tags and valid bits across all cache ways
- **Data Array:** Storage for actual cache data blocks
- **LRU Controller:** Implementation of Least Recently Used replacement algorithm
- **Address Decoder:** Address field extraction and organization

## 3. Cache Specifications

The implemented cache controller adheres to the following technical specifications:

**Cache Architecture Parameters:**
- Cache Type: 4-way set associative
- Total Cache Size: 32 KB
- Block Size: 64 bytes
- Word Size: 4 bytes (32 bits)
- Number of Sets: 128 sets
- Associativity Level: 4 ways per set
- Replacement Policy: Least Recently Used (LRU)
- Write Policy: Write-back with write-allocate

**Address Organization:**
- Address Width: 32 bits
- Tag Field: 19 bits (address[31:13])
- Index Field: 7 bits (address[12:6])
- Block Offset: 6 bits (address[5:0])
- Word Offset: 4 bits (derived from block offset)

## 4. Finite State Machine Design

### 4.1 State Definitions

The cache controller implements a six-state finite state machine with the following state encoding:

| State | Encoding | Description |
|-------|----------|-------------|
| IDLE | 3'b000 | Waiting for new memory requests |
| READ_HIT | 3'b001 | Processing read requests with cache hits |
| READ_MISS | 3'b010 | Handling read requests with cache misses |
| WRITE_HIT | 3'b011 | Managing write operations with cache hits |
| WRITE_MISS | 3'b100 | Processing write operations with cache misses |
| EVICT | 3'b101 | Evicting dirty cache lines (reserved for future implementation) |

### 4.2 State Transition Logic

**From IDLE State:**
- Transition to READ_HIT when read_enable is asserted and cache_hit_internal is true
- Transition to READ_MISS when read_enable is asserted and cache_hit_internal is false
- Transition to WRITE_HIT when write_enable is asserted and cache_hit_internal is true
- Transition to WRITE_MISS when write_enable is asserted and cache_hit_internal is false

**From READ_HIT State:**
- Always return to IDLE state in the next clock cycle

**From READ_MISS State:**
- Return to IDLE state when mem_ready signal is asserted (memory operation complete)

**From WRITE_HIT State:**
- Always return to IDLE state in the next clock cycle

**From WRITE_MISS State:**
- Return to IDLE state when mem_ready signal is asserted (memory operation complete)

**From EVICT State:**
- Transition to WRITE_MISS state when mem_ready is asserted (future implementation)

### 4.3 FSM Diagram

```
                    [reset]
                       |
                       v
         +-------------+-------------+
         |            IDLE           |
         |          (3'b000)         |
         +--+--+---------------+--+--+
            |  |               |  |
    [R&H]   |  |[R&!H]  [W&!H]|  |   [W&H]
            |  |               |  |
            v  v               v  v
    +----------+          +----------+
    | READ_HIT |          | WRITE_HIT|
    | (3'b001) |          | (3'b011) |
    +----------+          +----------+
         |                     |
         |[always]             |[always]
         |                     |
         +-----+         +-----+
               |         |
            +--v---------v--+
            |     IDLE      |
            +---------------+
            
    +----------+          +----------+
    |READ_MISS |          |WRITE_MISS|
    | (3'b010) |          | (3'b100) |
    +----------+          +----------+
         |                     |
         |[mem_ready]          |[mem_ready]
         |                     |
         +-----+         +-----+
               |         |
            +--v---------v--+
            |     IDLE      |
            +---------------+

Legend: R=read_enable, W=write_enable, H=cache_hit_internal
```

## 5. Functional Block Diagram

```
                    CPU INTERFACE
                          |
                          v
            +-----------------------------+
            |      Cache Controller       |
            |         (Main FSM)          |
            +----+---+---------------+----+
                 |   |               |
                 |   v               v
                 | +---+           +-------+
                 | |LRU|           |Address|
                 | |Ctl|           |Decoder|
                 | +---+           +-------+
                 |   |               |
                 v   v               v
            +-----------------------------+
            |       Cache Memory          |
            |      (Coordinator)          |
            +----+---+---------------+----+
                 |   |               |
                 v   v               v
            +--------+ +--------+ +--------+ +--------+
            | Tag    | | Tag    | | Tag    | | Tag    |
            | Array  | | Array  | | Array  | | Array  |
            | Way 0  | | Way 1  | | Way 2  | | Way 3  |
            +--------+ +--------+ +--------+ +--------+
            +--------+ +--------+ +--------+ +--------+
            | Data   | | Data   | | Data   | | Data   |
            | Array  | | Array  | | Array  | | Array  |
            | Way 0  | | Way 1  | | Way 2  | | Way 3  |
            +--------+ +--------+ +--------+ +--------+
                                  |
                                  v
                           MEMORY INTERFACE
```

### 5.1 Component Descriptions

**Cache Controller Module:**
- Central FSM managing all cache operations
- Handles CPU interface signals (read_enable, write_enable, address, write_data)
- Generates memory interface signals (mem_read_enable, mem_write_enable, mem_address)
- Coordinates data flow between CPU and cache memory subsystem

**Cache Memory Module:**
- Interfaces between cache controller and storage arrays
- Implements hit detection logic across all four ways
- Manages data multiplexing and selection
- Coordinates write operations to appropriate cache ways

**Tag Array Module:**
- Stores address tags for all cache lines
- Maintains valid bits for each cache line
- Supports simultaneous read from all ways
- Implements selective write operations based on way selection

**Data Array Module:**
- Stores actual cache data blocks (512 bits per block)
- Supports both block-level and word-level write operations
- Provides parallel read access across all ways
- Implements proper data alignment and selection

**LRU Controller Module:**
- Maintains LRU counters for each set
- Implements aging algorithm for replacement decisions
- Updates counters on cache accesses
- Provides LRU way selection for cache line replacement

**Address Decoder Module:**
- Extracts tag, index, and offset fields from CPU addresses
- Provides proper bit alignment for cache array indexing
- Supports different addressing modes and offset calculations

## 6. Hardware Description Language Selection

### 6.1 Language Choice: Verilog HDL

The implementation utilizes Verilog HDL for the following technical and practical reasons:

**Technical Advantages:**
- Well-suited for finite state machine implementations with clear state encoding
- Excellent support for memory array modeling and initialization
- Comprehensive bit manipulation capabilities for address field extraction
- Strong simulation and synthesis tool compatibility

**Design Considerations:**
- Simplified syntax compared to VHDL for educational and development purposes
- Extensive industry adoption ensuring tool availability and community support
- Clear separation between behavioral and structural modeling paradigms
- Robust debugging capabilities with VCD waveform generation

**Implementation Benefits:**
- Modular design approach supporting hierarchical instantiation
- Parameterizable modules enabling design scalability
- Comprehensive simulation support with timing analysis
- Industry-standard synthesis compatibility for FPGA and ASIC targets

### 6.2 Design Methodology

The Verilog implementation follows structured design principles:

- **Modular Architecture:** Each functional unit implemented as separate module
- **Parameterization:** Key design parameters defined as module parameters
- **Synchronous Design:** All sequential elements driven by common clock
- **Reset Strategy:** Comprehensive reset implementation for all storage elements
- **Simulation Support:** Extensive debug output and waveform generation

## 7. Interface Specifications

### 7.1 CPU Interface

**Input Signals:**
- clk: System clock signal
- reset: Asynchronous reset (active high)
- address[31:0]: CPU memory address
- write_data[31:0]: Data to be written
- read_enable: Read operation request
- write_enable: Write operation request

**Output Signals:**
- read_data[31:0]: Data returned to CPU
- cache_hit: Cache hit indication
- cache_ready: Cache operation completion

### 7.2 Memory Interface

**Output Signals:**
- mem_address[31:0]: Memory address for cache line operations
- mem_write_data[511:0]: Cache line data for memory writes
- mem_read_enable: Memory read request
- mem_write_enable: Memory write request

**Input Signals:**
- mem_read_data[511:0]: Cache line data from memory
- mem_ready: Memory operation completion

## 8. Performance Characteristics

The cache controller design targets the following performance metrics:

- **Access Latency:** Single cycle for cache hits
- **Miss Penalty:** Variable based on memory response time
- **Throughput:** One operation per clock cycle for hits
- **Hit Rate:** Dependent on application access patterns
- **Power Efficiency:** Minimized through selective array activation

## 9. Verification Strategy

The design verification encompasses comprehensive testing scenarios:

- **Functional Testing:** All FSM states and transitions
- **Corner Cases:** Reset conditions, simultaneous operations
- **Performance Testing:** Hit/miss scenarios, LRU behavior
- **Integration Testing:** CPU and memory interface protocols
- **Waveform Analysis:** Signal timing and protocol compliance

This detailed design specification provides the foundation for implementation, verification, and validation of the 4-way set-associative cache controller system.

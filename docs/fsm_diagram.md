# FSM Diagram for Cache Controller

## Overview
This document provides a detailed visual representation of the finite state machine (FSM) used in the cache controller design. The FSM manages cache operations efficiently using a 6-state architecture compatible with Digital circuit simulator by hneemann.

## Digital Simulator Compatibility
This FSM design is structured to be compatible with the Digital circuit simulator by hneemann, following the simulator's FSM representation standards:
- States are numbered for binary encoding
- Transitions include condition expressions
- Output values are clearly defined per state

## State Definitions

### State Encoding (3-bit)
```
IDLE       = 3'b000 (State 0)
READ_HIT   = 3'b001 (State 1) 
READ_MISS  = 3'b010 (State 2)
WRITE_HIT  = 3'b011 (State 3)
WRITE_MISS = 3'b100 (State 4)
EVICT      = 3'b101 (State 5) [Reserved]
```

### State Descriptions
1. **IDLE (000)**: Initial state waiting for memory requests
   - **Outputs**: `cache_hit=0, mem_read=0, mem_write=0`
   - **Actions**: Monitor for read/write enable signals

2. **READ_HIT (001)**: Processing successful read from cache
   - **Outputs**: `cache_hit=1, mem_read=0, mem_write=0`
   - **Actions**: Return data from cache, update LRU

3. **READ_MISS (010)**: Handling cache read miss
   - **Outputs**: `cache_hit=0, mem_read=1, mem_write=0`
   - **Actions**: Fetch block from memory, allocate cache line

4. **WRITE_HIT (011)**: Processing successful write to cache
   - **Outputs**: `cache_hit=1, mem_read=0, mem_write=0`
   - **Actions**: Update cache data, mark dirty, update LRU

5. **WRITE_MISS (100)**: Handling cache write miss
   - **Outputs**: `cache_hit=0, mem_read=1, mem_write=0`
   - **Actions**: Fetch block, allocate, then write

6. **EVICT (101)**: Cache line eviction (reserved for future use)
   - **Outputs**: `cache_hit=0, mem_read=0, mem_write=1`
   - **Actions**: Write back dirty cache line

## State Transition Diagram

### Digital Simulator Format
```
States: S0(IDLE), S1(READ_HIT), S2(READ_MISS), S3(WRITE_HIT), S4(WRITE_MISS), S5(EVICT)

Transitions:
S0 -> S1: read_enable & cache_hit
S0 -> S2: read_enable & !cache_hit  
S0 -> S3: write_enable & cache_hit
S0 -> S4: write_enable & !cache_hit

S1 -> S0: !read_enable
S2 -> S0: mem_data_ready
S3 -> S0: !write_enable
S4 -> S0: mem_data_ready
S5 -> S0: evict_complete
```

### Visual Representation
```
                    read_enable & cache_hit
               ┌─────────────────────────────┐
               │                             │
               │         ┌─────────────┐     ▼
        reset  │         │             │ ┌───────────┐
        ──────►│         │   READ_HIT  │ │  (S1)     │
               │         │   (S1)      │ │cache_hit=1│
               │         │             │ └───────────┘
    ┌──────────▼──┐      └─────────────┘     │
    │             │                          │ !read_enable
    │    IDLE     │                          │
    │    (S0)     │                          ▼
    │  cache_hit=0│      ┌─────────────┐ ◄───┘
    └─────────────┘      │             │
               │         │ READ_MISS   │
               │         │   (S2)      │
               │         │ mem_read=1  │
               │         └─────────────┘
               │                 │
               │                 │ mem_data_ready
               │                 ▼
               │ read_enable &   ┌─────────────┐
               │ !cache_hit      │             │
               └────────────────►│             │
                                │             │
               ┌─────────────────┘             │
               │                               │
               │ write_enable & cache_hit      │
               │                               │
               ▼         ┌─────────────┐       │
           ┌───────────┐ │             │       │
           │WRITE_HIT  │ │ WRITE_MISS  │       │
           │  (S3)     │ │   (S4)      │       │
           │cache_hit=1│ │ mem_read=1  │       │
           └───────────┘ └─────────────┘       │
               │                 │             │
               │ !write_enable   │ mem_data_ready
               │                 │             │
               └─────────────────┼─────────────┘
                                 │
               write_enable &    │
               !cache_hit        │
               ──────────────────┘
```

## Control Signal Generation

### State-Based Output Logic
```verilog
always @(*) begin
    case (current_state)
        IDLE: begin
            cache_hit = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b0;
        end
        READ_HIT: begin
            cache_hit = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
        end
        READ_MISS: begin
            cache_hit = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
        end
        WRITE_HIT: begin
            cache_hit = 1'b1;
            mem_read = 1'b0;
            mem_write = 1'b0;
        end
        WRITE_MISS: begin
            cache_hit = 1'b0;
            mem_read = 1'b1;
            mem_write = 1'b0;
        end
        EVICT: begin
            cache_hit = 1'b0;
            mem_read = 1'b0;
            mem_write = 1'b1;
        end
    endcase
end
```

## Timing Analysis

### State Duration
- **IDLE**: Persistent until request
- **READ_HIT**: 1 clock cycle
- **READ_MISS**: 2-3 clock cycles (memory dependent)
- **WRITE_HIT**: 1 clock cycle
- **WRITE_MISS**: 2-3 clock cycles (memory dependent)
- **EVICT**: 1-2 clock cycles (write-back dependent)

### Critical Path Analysis
1. **Hit Detection**: Tag comparison + way selection
2. **Data Output**: Cache data array read + multiplexing
3. **LRU Update**: LRU logic + register update

## Implementation Notes for Digital Simulator

### FSM Component Configuration
When implementing in Digital simulator:
1. Use 3-bit state register (supports 8 states)
2. Input signals: `read_enable`, `write_enable`, `cache_hit`
3. Output signals: `cache_hit`, `mem_read`, `mem_write`
4. Clock and reset connections for sequential logic

### State Variable Naming
- State signal name: `cache_state`
- State bit names: `cache_state[2]`, `cache_state[1]`, `cache_state[0]`

This FSM design ensures efficient cache operation while maintaining compatibility with digital design tools and simulators.

## Conclusion
This FSM diagram serves as a guide for understanding the operational flow of the cache controller. It is essential for implementing the state transitions in the HDL code and ensuring that the cache operates efficiently according to the specified requirements.
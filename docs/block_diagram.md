# Cache Controller Block Diagram

## System Overview
This document provides the functional block diagram for the 4-way set-associative cache controller, designed to be compatible with Digital circuit simulator by hneemann.

## Top-Level System Architecture

```
                    CPU INTERFACE
                         │
                    ┌────▼────┐
                    │  CPU    │
                    │Interface│
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   [Address]        [Write Data]    [Control Signals]
   (32-bit)         (32-bit)       (read_en, write_en)
        │                │                │
        └────────────────┼────────────────┘
                         │
                    ┌────▼────┐
                    │ CACHE   │
                    │CONTROL  │
                    │  FSM    │
                    └────┬────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌─────────┐    ┌─────────────┐    ┌─────────┐
   │ADDRESS  │    │   CACHE     │    │   LRU   │
   │DECODER  │    │  MEMORY     │    │CONTROL  │
   └─────────┘    └─────────────┘    └─────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │
                    ┌────▼────┐
                    │MEMORY   │
                    │INTERFACE│
                    └─────────┘
```

## Detailed Component Architecture

### 1. Cache Controller FSM
```
Inputs:  clk, reset, read_enable, write_enable, cache_hit, mem_data_ready
Outputs: cache_read, cache_write, mem_read, mem_write, block_write_enable
States:  IDLE, READ_HIT, READ_MISS, WRITE_HIT, WRITE_MISS, EVICT

FSM State Register: 3-bit (cache_state[2:0])
```

### 2. Address Decoder
```
Input:   address[31:0]
Outputs: tag[18:0], index[6:0], word_offset[3:0], block_offset[5:0]

Address Breakdown:
┌─────────────┬─────────┬───────────────┐
│ Tag[31:13]  │Index[12:6]│Block Offset[5:0]│
│   19 bits   │  7 bits  │    6 bits     │
└─────────────┴─────────┴───────────────┘
```

### 3. Cache Memory Subsystem
```
                 ┌─────────────────────────────────┐
                 │         CACHE MEMORY            │
                 │                                 │
    address ────►│  ┌─────────┐  ┌─────────────┐  │◄──── write_data
                 │  │   TAG   │  │    DATA     │  │
                 │  │  ARRAY  │  │   ARRAY     │  │────► read_data
    way_select ──│  │         │  │             │  │
                 │  │4×128×19 │  │4×128×512bit │  │◄──── block_data
                 │  └─────────┘  └─────────────┘  │
                 │         │            │         │
                 │         ▼            ▼         │
                 │  ┌─────────────────────────┐   │
                 │  │     HIT DETECTION       │   │────► cache_hit
                 │  │   (Tag Comparison)      │   │
                 │  └─────────────────────────┘   │────► hit_way[3:0]
                 └─────────────────────────────────┘
```

### 4. LRU Controller
```
Input:   index[6:0], hit_way[3:0], access_enable
Output:  lru_way[3:0], update_lru

LRU Storage: 128 sets × 2 bits = 256 bits total
Encoding: 2-bit pseudo-LRU for 4-way associativity

LRU Update Logic:
┌─────────────┐
│  LRU Logic  │ ← access_enable
│             │ ← hit_way[3:0]
│ 128×2 bits  │ ← index[6:0]
│             │
└─────────────┘
       │
       ▼
   lru_way[3:0]
```

## Signal Flow Diagram

### Read Operation Flow
```
CPU Read Request
       │
       ▼
   ┌─────────┐    ┌──────────────┐    ┌─────────┐
   │Address  │───►│Cache Memory  │───►│Hit?     │
   │Decode   │    │Tag Compare   │    │         │
   └─────────┘    └──────────────┘    └─────────┘
                                           │
                    ┌─────────────────────────┐
                    │                         │
                    ▼ HIT                     ▼ MISS
            ┌─────────────┐            ┌─────────────┐
            │Return Cache │            │Fetch from  │
            │Data to CPU  │            │Memory      │
            └─────────────┘            └─────────────┘
                    │                         │
                    ▼                         ▼
            ┌─────────────┐            ┌─────────────┐
            │Update LRU   │            │Allocate     │
            │             │            │Cache Line   │
            └─────────────┘            └─────────────┘
```

### Write Operation Flow
```
CPU Write Request
       │
       ▼
   ┌─────────┐    ┌──────────────┐    ┌─────────┐
   │Address  │───►│Cache Memory  │───►│Hit?     │
   │Decode   │    │Tag Compare   │    │         │
   └─────────┘    └──────────────┘    └─────────┘
                                           │
                    ┌─────────────────────────┐
                    │                         │
                    ▼ HIT                     ▼ MISS
            ┌─────────────┐            ┌─────────────┐
            │Write to     │            │Fetch from  │
            │Cache Line   │            │Memory      │
            └─────────────┘            └─────────────┘
                    │                         │
                    ▼                         ▼
            ┌─────────────┐            ┌─────────────┐
            │Update LRU   │            │Allocate &   │
            │Mark Dirty   │            │Write Data   │
            └─────────────┘            └─────────────┘
```

## Memory Interface

### External Memory Connection
```
Cache Controller          External Memory
┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │
│ mem_address[31:0] ────►│ Address Input   │
│                 │      │                 │
│ mem_read        ├─────►│ Read Enable     │
│ mem_write       ├─────►│ Write Enable    │
│                 │      │                 │
│ mem_write_data  ├─────►│ Write Data      │
│ [511:0]         │      │ (64 bytes)      │
│                 │      │                 │
│ mem_read_data   │◄─────┤ Read Data       │
│ [511:0]         │      │ (64 bytes)      │
│                 │      │                 │
│ mem_data_ready  │◄─────┤ Data Ready      │
└─────────────────┘      └─────────────────┘
```

## Digital Simulator Implementation Notes

### For Digital Circuit Simulator by hneemann:

1. **Component Hierarchy**:
   - Top Level: cache_controller
   - Sub-components: address_decoder, cache_memory, lru_controller
   - FSM: Implement as sequential circuit with state register

2. **Signal Naming Convention**:
   - Clock: `clk`
   - Reset: `reset`
   - State signal: `cache_state[2:0]`
   - Control outputs: `cache_hit`, `mem_read`, `mem_write`

3. **Bus Widths**:
   - Address bus: 32 bits
   - Data bus: 32 bits (CPU interface), 512 bits (memory interface)
   - Control signals: 1 bit each

4. **Memory Components**:
   - Tag array: Use ROM/RAM components for tag storage
   - Data array: Use RAM components for data storage
   - LRU array: Use register components for LRU state

### Component Instantiation Example:
```
Cache Controller (Main)
├── Address Decoder (Combinational)
├── FSM Controller (Sequential)
├── Cache Memory
│   ├── Tag Array (4×128×19 bits)
│   ├── Data Array (4×128×512 bits)
│   └── Hit Detection Logic
├── LRU Controller (Sequential)
└── Memory Interface (Combinational)
```

This block diagram provides a complete architectural view suitable for implementation in Digital circuit simulator while maintaining compatibility with the actual HDL implementation.

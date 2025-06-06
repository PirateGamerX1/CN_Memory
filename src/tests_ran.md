vvp cache_controller_sim
VCD info: dumpfile cache_controller.vcd opened for output.
CACHE_MEMORY: way_hit=xxxx, lru_way=1000, word_offset= x, data_out=xxxxxxxx
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=00000000
=== Cache Controller Testbench ===
Time=30: Starting cache controller tests

=== Test 1: Read miss from empty cache ===
Before READ_MISS: Setting mem_read_data to first 32 bits: deadbeef
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=00000000
Clock: State=0->2, Addr=00001000, R=0, W=0, Hit_int=0, Hit=0, Data=00000000
       cache_read_data=00000000, block_we=0, word_we=0
Clock: State=2->0, Addr=00001000, R=0, W=0, Hit_int=0, Hit=0, Data=00000000
       cache_read_data=00000000, block_we=1, word_we=0
DATA_ARRAY: Block write to way 3, index  64, data=deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=deadbeef
CACHE_MEMORY: way_hit=1000, lru_way=1000, word_offset= 0, data_out=deadbeef
After READ_MISS: read_data=deadbeef
cache_hit_internal=1, cache_block_write_enable=0
cache_read_data=deadbeef
Expected: DEADBEEF, Got: deadbeef PASS

=== Test 2: Read hit (same address) ===
Clock: State=0->1, Addr=00001000, R=0, W=0, Hit_int=1, Hit=0, Data=deadbeef
       cache_read_data=deadbeef, block_we=0, word_we=0
Clock: State=1->0, Addr=00001000, R=0, W=0, Hit_int=1, Hit=1, Data=deadbeef
       cache_read_data=deadbeef, block_we=0, word_we=0
After READ_HIT: read_data=deadbeef, cache_hit=1
cache_read_data=deadbeef
Expected: DEADBEEF, Got: deadbeef PASS

=== Test 3: Write hit with NEW data ===
Writing aaaabbbb to address 00001000
Before write: cache_word_write_enable=0
CACHE_MEMORY: way_hit=1000, lru_way=0100, word_offset= 0, data_out=deadbeef
During write: current_state=0, cache_word_write_enable=0
Clock: State=0->3, Addr=00001000, R=0, W=0, Hit_int=1, Hit=0, Data=deadbeef
       cache_read_data=deadbeef, block_we=0, word_we=0
Clock: State=3->0, Addr=00001000, R=0, W=0, Hit_int=1, Hit=1, Data=deadbeef
       cache_read_data=deadbeef, block_we=0, word_we=1
DATA_ARRAY: Word write enable, hit_way=1000, word_offset= 0, data=aaaabbbb
DATA_ARRAY: Writing to way 3
CACHE_MEMORY: way_hit=1000, lru_way=0010, word_offset= 0, data_out=aaaabbbb
After WRITE_HIT: cache_hit=0

=== Test 4: Read back written data ===
Clock: State=0->0, Addr=00001000, R=1, W=0, Hit_int=1, Hit=0, Data=aaaabbbb
       cache_read_data=aaaabbbb, block_we=0, word_we=0
Clock: State=0->1, Addr=00001000, R=1, W=0, Hit_int=1, Hit=0, Data=aaaabbbb
       cache_read_data=aaaabbbb, block_we=0, word_we=0
After reading written data: read_data=aaaabbbb, cache_hit=1
cache_read_data=aaaabbbb
Expected: AAAABBBB, Got: aaaabbbb PASS

=== Test 5: Read miss from different address ===
Setting mem_read_data to first 32 bits: 12345678 for address 00002000
Clock: State=1->0, Addr=00002000, R=1, W=0, Hit_int=1, Hit=1, Data=aaaabbbb
       cache_read_data=aaaabbbb, block_we=0, word_we=0
CACHE_MEMORY: way_hit=1000, lru_way=0010, word_offset= 0, data_out=00000000
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=00000000
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=00000000
Clock: State=0->2, Addr=00002000, R=1, W=0, Hit_int=0, Hit=0, Data=aaaabbbb
       cache_read_data=00000000, block_we=0, word_we=0
DATA_ARRAY: Block write to way 3, index   0, data=12345678123456781234567812345678123456781234567812345678123456781234567812345678123456781234567812345678123456781234567812345678
Clock: State=2->0, Addr=00002000, R=0, W=0, Hit_int=0, Hit=0, Data=00000000
       cache_read_data=00000000, block_we=1, word_we=0
CACHE_MEMORY: way_hit=0000, lru_way=1000, word_offset= 0, data_out=12345678
CACHE_MEMORY: way_hit=1000, lru_way=1000, word_offset= 0, data_out=12345678
After READ_MISS: read_data=12345678
cache_read_data=12345678
Expected: 12345678, Got: 12345678 PASS

=== Test 6: Write to second address ===
Clock: State=0->3, Addr=00002000, R=0, W=0, Hit_int=1, Hit=0, Data=12345678
       cache_read_data=12345678, block_we=0, word_we=0
Clock: State=3->0, Addr=00002000, R=0, W=0, Hit_int=1, Hit=1, Data=00000000
       cache_read_data=12345678, block_we=0, word_we=1
DATA_ARRAY: Word write enable, hit_way=1000, word_offset= 0, data=ccccdddd
DATA_ARRAY: Writing to way 3
CACHE_MEMORY: way_hit=1000, lru_way=0100, word_offset= 0, data_out=ccccdddd
Clock: State=0->0, Addr=00002000, R=1, W=0, Hit_int=1, Hit=0, Data=ccccdddd
       cache_read_data=ccccdddd, block_we=0, word_we=0
Clock: State=0->1, Addr=00002000, R=1, W=0, Hit_int=1, Hit=0, Data=ccccdddd
       cache_read_data=ccccdddd, block_we=0, word_we=0
After writing and reading back: read_data=ccccdddd
Expected: CCCCDDDD, Got: ccccdddd PASS

=== Test 7: Verify first address data persistence ===
Clock: State=1->0, Addr=00001000, R=1, W=0, Hit_int=1, Hit=1, Data=ccccdddd
       cache_read_data=ccccdddd, block_we=0, word_we=0
CACHE_MEMORY: way_hit=1000, lru_way=0100, word_offset= 0, data_out=aaaabbbb
CACHE_MEMORY: way_hit=1000, lru_way=0001, word_offset= 0, data_out=aaaabbbb
Clock: State=0->1, Addr=00001000, R=1, W=0, Hit_int=1, Hit=0, Data=aaaabbbb
       cache_read_data=aaaabbbb, block_we=0, word_we=0
Reading first address again: read_data=aaaabbbb
Expected: AAAABBBB, Got: aaaabbbb PASS

=== Summary ===
Cache controller comprehensive test completed
Clock: State=1->0, Addr=00001000, R=0, W=0, Hit_int=1, Hit=1, Data=aaaabbbb
       cache_read_data=aaaabbbb, block_we=0, word_we=0
testbench/cache_controller_tb.v:206: $finish called at 285 (1s)
#!/bin/bash
iverilog -o test_output.vvp tests/basic_test.v
vvp test_output.vvp
set test_dir "tests"
set test_files [glob -tails "$test_dir/*.v"]

foreach test_file $test_files {
    set test_name [file tail $test_file]
    puts "Running test: $test_name"
    exec iverilog -o "out_$test_name" "$test_file"
    exec vvp "out_$test_name"
}
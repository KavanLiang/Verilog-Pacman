vlib work
vlog -timescale 1ns/1ns run_pacman.v
vsim test

log {/*}
add wave {/*}

force {SW[5:0]} 000000 0
force {SW[9:7]} 000 0
force {CLOCK_50} 0 0, 1 5 -r 10
force {KEY[0]} 0 0, 1 10
force {KEY[1]} 1 0, 0 50, 1 60

run 5000
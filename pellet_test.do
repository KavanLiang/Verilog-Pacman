vlib work
vlog -timescale 1ns/1ns pellet_map.v
vsim pellet_map

log {/*}
add wave {/*}

force {write_en} 0 0, 1 15
force {x} 0 0, 10 15
force {y} 0 0, 1 15
force {clock} 0 0, 1 5 -r 10
force {reset_n} 0 0, 1 10

run 5000
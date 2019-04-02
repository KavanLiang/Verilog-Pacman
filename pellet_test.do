vlib work
vlog -timescale 1ns/1ns wip.v
vsim control_master

log {/*}
add wave {/*}

force {dir_in} 000 0
force {clock} 0 0, 1 5 -r 10
force {reset_n} 0 0, 1 10

run 20000

#vlib work
#vlog -timescale 1ns/1ns random_generator.v
#vsim random_generator
#
#log {/*}
#add wave {/*}
#
#force {clock} 0 0, 1 5 -r 10
#force {reset_n} 0 0, 1 10
#
#run 10000

#vlib work
#vlog -timescale 1ns/1ns control_pellet.v
#vsim control_pellet
#
#log {/*}
#add wave {/*}
#
#force {enable} 1 0, 0 200
#force {reset_n} 0 0, 1 10
#force {clock} 0 0, 1 5 -r 10
#force {go} 0 0, 1 20, 0 30 -r 200
#
#run 10000
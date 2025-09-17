vlib work
vlog DSP48.v DSP48_tb.v 
vsim -voptargs=+acc work.DSP48_tb
add wave *
run -all
#quit -sim
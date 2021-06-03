

vsim work.Processor

add wave -position 1  sim:/processor/clk
add wave -position 2  sim:/processor/reset
add wave -position end  sim:/processor/execute/ff/flags_out
add wave -hex -position end sim:/processor/decode/reg_file/reg_file

mem load -i test/deliv-1.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

force -freeze sim:/Processor/IO_in 16#00000000 0
force -freeze sim:/Processor/IO_out 16#00000000 0
force -freeze sim:/processor/clk 0 0
force -freeze sim:/processor/reset 1 0
run 50ps;

force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
run 50ps;

noforce sim:/Processor/IO_in
noforce sim:/Processor/IO_out
force -freeze sim:/processor/reset 0 0

# Reach middle of execute stage of in R1
run 700ps;
force -freeze sim:/Processor/IO_in 16#00000005 0

# One cycle forward
run 100ps;
force -freeze sim:/Processor/IO_in 16#00000010 0
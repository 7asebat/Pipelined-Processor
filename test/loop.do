<<<<<<< HEAD:assembler/test/tc1.do


vsim work.Processor

add wave -position 1  sim:/processor/clk
add wave -position 2  sim:/processor/reset
add wave -position insertpoint  \
sim:/processor/IO_in
add wave -position insertpoint  \
sim:/processor/IO_out
add wave -position insertpoint  \
sim:/processor/fetch/pc_controller/PC_value
add wave -position insertpoint  \
sim:/processor/intreg_ifid/IR
add wave -position insertpoint  \
sim:/processor/execute/ff/flags_out
add wave -hex -position end sim:/processor/decode/reg_file/reg_file

mem load -i assembler/test/tc1.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

force -freeze sim:/Processor/IO_in 16#00000000 0
force -freeze sim:/Processor/IO_out 16#00000000 0
force -freeze sim:/processor/clk 0 0
force -freeze sim:/processor/reset 1 0
force -freeze sim:/Processor/s_IFID_reset 1 0
force -freeze sim:/Processor/s_IDEX_reset 1 0
force -freeze sim:/Processor/s_EXMEM_reset 1 0
force -freeze sim:/Processor/s_MEMWB_reset 1 0
run 50ps;

force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
run 50ps;

noforce sim:/Processor/IO_in
noforce sim:/Processor/IO_out
noforce sim:/Processor/s_IFID_reset
noforce sim:/Processor/s_IDEX_reset
noforce sim:/Processor/s_EXMEM_reset
noforce sim:/Processor/s_MEMWB_reset
force -freeze sim:/processor/reset 0 0
=======
# vsim work.Processor
# 
# add wave -position 1  sim:/processor/clk
# add wave -position 2  sim:/processor/reset
# add wave -hex -position end sim:/processor/decode/reg_file/reg_file
restart

mem load -i test/loop.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

force -freeze sim:/Processor/IO_in 16#00000000 0
force -freeze sim:/Processor/IO_out 16#00000000 0
force -freeze sim:/processor/clk 0 0
force -freeze sim:/processor/reset 1 0
force -freeze sim:/Processor/s_IFID_reset 1 0
force -freeze sim:/Processor/s_IDEX_reset 1 0
force -freeze sim:/Processor/s_EXMEM_reset 1 0
force -freeze sim:/Processor/s_MEMWB_reset 1 0
run 50ps;

force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
run 50ps;

noforce sim:/Processor/IO_in
noforce sim:/Processor/IO_out
noforce sim:/Processor/s_IFID_reset
noforce sim:/Processor/s_IDEX_reset
noforce sim:/Processor/s_EXMEM_reset
noforce sim:/Processor/s_MEMWB_reset
force -freeze sim:/processor/reset 0 0
>>>>>>> d03d153d28d54954bec57891e038625aeda5719e:test/loop.do

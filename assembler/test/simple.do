
restart

mem load -i assembler/test/simple.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

run 1ps;

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

run 16ns;

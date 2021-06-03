
restart
delete wave *

mem load -i test/simple.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

# add wave -hex -position end  sim:/processor/clk
# add wave -hex -position end  sim:/processor/reset
# add wave -hex -position end  sim:/processor/decode/reg_file/reg_file
# add wave -hex -position end  sim:/processor/intreg_ifid/s_IR
# add wave -hex -position end  sim:/processor/intreg_ifid/s_return_adr
# add wave -hex -position end  sim:/processor/intreg_idex/s_control_signals
# add wave -hex -position end  sim:/processor/intreg_idex/s_return_adr
# add wave -hex -position end  sim:/processor/intreg_idex/s_imm_value
# add wave -hex -position end  sim:/processor/intreg_idex/s_regA_ID
# add wave -hex -position end  sim:/processor/intreg_idex/s_regB_ID
# add wave -hex -position end  sim:/processor/intreg_idex/s_regA_data
# add wave -hex -position end  sim:/processor/intreg_idex/s_regB_data
# add wave -hex -position end  sim:/processor/intreg_exmem/s_control_signals
# add wave -hex -position end  sim:/processor/intreg_exmem/s_flags
# add wave -hex -position end  sim:/processor/intreg_exmem/s_ALU_result
# add wave -hex -position end  sim:/processor/intreg_exmem/s_return_adr
# add wave -hex -position end  sim:/processor/intreg_exmem/s_regB_data
# add wave -hex -position end  sim:/processor/intreg_exmem/s_regB_ID
# add wave -hex -position end  sim:/processor/intreg_exmem/s_IO_load
# add wave -hex -position end  sim:/processor/intreg_memwb/s_control_signals
# add wave -hex -position end  sim:/processor/intreg_memwb/s_ALU_result
# add wave -hex -position end  sim:/processor/intreg_memwb/s_MEM_load
# add wave -hex -position end  sim:/processor/intreg_memwb/s_IO_load
# add wave -hex -position end  sim:/processor/intreg_memwb/s_regB_ID


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

add wave -position end  -dec sim:/register_file/WORD_SIZE
add wave -position end  -dec sim:/register_file/REG_COUNT
add wave -position end  -dec sim:/register_file/REG_ADR_WIDTH
add wave -position end  -hex sim:/register_file/clk
add wave -position end  -hex sim:/register_file/write_en
add wave -position end  -hex sim:/register_file/read_regA_ID
add wave -position end  -hex sim:/register_file/read_regB_ID
add wave -position end  -hex sim:/register_file/write_reg_ID
add wave -position end  -hex sim:/register_file/write_data
add wave -position end  -hex sim:/register_file/regA_data
add wave -position end  -hex sim:/register_file/regB_data
add wave -position end  -hex sim:/register_file/reg_file
force -freeze sim:/register_file/write_en 0 0
force -freeze sim:/register_file/clk 0 0, 1 {100 ps} -r 200
force -freeze sim:/register_file/read_regA_ID 16#0 0
force -freeze sim:/register_file/read_regB_ID 16#0 0
force -freeze sim:/register_file/write_reg_ID 16#7 0
force -freeze sim:/register_file/write_data 16#deadbeef 0
run
run
run
force -freeze sim:/register_file/write_en 1 0
run
run
force -freeze sim:/register_file/read_regB_ID 16#7 0
run
run
run

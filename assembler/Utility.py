def write_memory_to_file(Memory, filePath):
    with open(filePath, 'w+b') as f:
        for i in sorted(Memory):
            word = int(Memory[i], 2).to_bytes(2, byteorder='little')
            f.write(word)


def write_mem_file(fn, Memory):
    with open(f'{fn}.mem', 'w') as f:
        f.write("// memory data file (do not edit the following line - required for mem load use)\n// instance=/processor/RAM/ram\n// format=mti addressradix=h dataradix=s version=1.0 wordsperline=4")
        for k, v in enumerate(Memory.items()):
            if(v[0] % 4 == 0):
                f.write(f'\n{v[0]:x}: ')
            f.write('{val} '.format(val=v[1]))


def write_do_file(fn, memoryImport):
    with open(f'{fn}.do', 'w') as f:
        f.write(fr'''
vsim work.processor

{memoryImport}

add wave -dec -position insertpoint \
\
sim:/processor/Rx_out(7) \
sim:/processor/CTRL_COUNTER_out \
sim:/processor/uPC_out \
\
-dec \
sim:/processor/MDR_out \
sim:/processor/MAR_out \
\
-bin \
{{sim:/processor/Rstatus_out[2:0]}} \
\
-dec \
sim:/processor/Rx_out \

# bin \
# sim:/processor/ALU_flags \
# sim:/processor/ALU_F \
# sim:/processor/ALU_Cin \

# -dec \
# sim:/processor/INT_SRC_out \
# sim:/processor/INT_DST_out \

# -hex \
# sim:/processor/CTRL_SIGNALS \
# sim:/processor/uIR_sig \
# sim:/processor/IR_out \
# sim:/processor/shared_bus \
# sim:/processor/WMFC \
# sim:/processor/MFC \
# sim:/processor/RUN \
# sim:/processor/clk \
# sim:/processor/MIU_read \
# sim:/processor/MIU_write \
# sim:/processor/MIU_mem_write \
# sim:/processor/MIU_mem_read \

# sim:/processor/MDR_REGISTER/A_en \
# sim:/processor/MDR_REGISTER/A_in \
# sim:/processor/MDR_REGISTER/B_en \
# sim:/processor/MDR_REGISTER/B_in \
# sim:/processor/RAM/dataIn \
# sim:/processor/RAM/dataOut \

force -freeze sim:/processor/clk 1 0
force -freeze sim:/processor/uPC_reset 1 0
force -freeze sim:/processor/MIU_reset 1 0
force -freeze sim:/processor/Rz_reset 1 0
force -freeze sim:/processor/Ry_reset 1 0
force -freeze sim:/processor/Rstatus_reset 1 0
force -freeze sim:/processor/MDR_reset 1 0
force -freeze sim:/processor/MAR_reset 1 0
force -freeze sim:/processor/IR_reset 1 0
force -freeze sim:/processor/INT_SRC_reset 1 0
force -freeze sim:/processor/INT_DST_reset 1 0
force -freeze sim:/processor/INTERRUPT_reset 1 0
force -freeze sim:/processor/HALT_reset 1 0
force -freeze sim:/processor/CTRL_COUNTER_reset 1 0
force -freeze sim:/processor/Rx_reset 11111111 0
run

noforce sim:/processor/uPC_reset
noforce sim:/processor/MIU_reset
noforce sim:/processor/Rz_reset
noforce sim:/processor/Ry_reset
noforce sim:/processor/Rx_reset
noforce sim:/processor/Rstatus_reset
noforce sim:/processor/MDR_reset
noforce sim:/processor/MAR_reset
noforce sim:/processor/IR_reset
noforce sim:/processor/INT_SRC_reset
noforce sim:/processor/INT_DST_reset
noforce sim:/processor/INTERRUPT_reset
noforce sim:/processor/HALT_reset
noforce sim:/processor/CTRL_COUNTER_reset
noforce sim:/processor/Rx_reset
force -freeze sim:/processor/clk 1 0, 0 {{50 ps}} -r 100

run 16ns;
''')


def build_lookup_table(filePath):
    table = {}
    with open(filePath, 'r') as f:
        keyValueList = [x for x in f.read().splitlines() if x]
        for kv in keyValueList:
            string, code = kv.split()
            table[string] = code

    return table


def value_to_bit_string(value_string: str, size: int = 16) -> str:
    value = int(value_string)

    # Use the 2's complement
    if value < 0:
        value = (1 << size) + value

    # Keep only `size` bits
    value &= (1 << size) - 1

    return f'{value:0{size}b}'

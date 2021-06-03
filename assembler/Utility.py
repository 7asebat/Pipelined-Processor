def pad_memory(Memory):
    # Automatically point to the first available instruction
    padded_memory = [f'{0:016b}', f'{2:016b}']
    for i in sorted(Memory):
        padded_memory.append(Memory[i])

    return padded_memory


def write_memory_to_file(fn, Memory):
    filepath = f'{fn}.hex'
    with open(filepath, 'w+b') as f:
        for word in Memory:
            bitstr = int(word, 2).to_bytes(2, byteorder='big')
            f.write(bitstr)


def write_mem_file(fn, Memory):
    with open(f'{fn}.mem', 'w') as f:
        f.write(r'''// memory data file (do not edit the following line - required for mem load use)
// instance=/processor/fetch/instruction_memory/ram
// format=mti addressradix=h dataradix=s version=1.0 wordsperline=4''')

        for i, word in enumerate(Memory):
            if (i % 4) == 0:
                f.write(f'\n{i:x}: ')

            f.write(f'{word} ')


def write_do_file(fn):
    with open(f'{fn}.do', 'w') as f:
        f.write(fr'''
restart

mem load -i {fn}.mem -filltype value -filldata 0 /processor/fetch/instruction_memory/ram 

force -freeze sim:/Processor/IO_in 16#00000000 0
force -freeze sim:/Processor/IO_out 16#00000000 0
force -freeze sim:/processor/clk 0 0
force -freeze sim:/processor/reset 1 0
force -freeze sim:/Processor/s_IFID_reset 1 0
force -freeze sim:/Processor/s_IDEX_reset 1 0
force -freeze sim:/Processor/s_EXMEM_reset 1 0
force -freeze sim:/Processor/s_MEMWB_reset 1 0
run 50ps;

force -freeze sim:/processor/clk 1 0, 0 {{50 ps}} -r 100
run 50ps;

noforce sim:/Processor/IO_in
noforce sim:/Processor/IO_out
noforce sim:/Processor/s_IFID_reset
noforce sim:/Processor/s_IDEX_reset
noforce sim:/Processor/s_EXMEM_reset
noforce sim:/Processor/s_MEMWB_reset
force -freeze sim:/processor/reset 0 0
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
    # Values are hexadecimal
    value = int(value_string, base=16)

    # # Use the 2's complement
    # if value < 0:
    #     value = (1 << size) + value

    # Keep only `size` bits
    value &= (1 << size) - 1

    return f'{value:0{size}b}'

import sys
from Utility import write_do_file, write_mem_file, write_memory_to_file
from Process import process_instruction
from Sanitize import is_instruction, sanitize_line, sanitize_label, define_label

# Break if no input files were selected
if len(sys.argv) < 2:
    print('Invalid arguments')
    sys.exit(1)

Memory = {}
labels = {}

with open(sys.argv[1]) as f:
    curr_addr = 0
    for (index, line) in enumerate(f):
        # Ignore comments
        line = line.rstrip().strip().upper()
        if line.find(';') > -1:
            line = line[:line.find(';')]

        # If empty line ignore
        if len(line) <= 1:
            continue

        # Defining labels
        if ':' in line:
            define_label(line, labels, curr_addr)

        # Line sanity
        instruction = sanitize_line(line)
        if not instruction:
            continue
        print(instruction)

        # Constructing bit string
        bit_string = ''

        # Load instruction opcode
        if not is_instruction(instruction[0]):
            print('Error in parsing instruction: syntax error in line', index + 1)
            raise NotImplementedError

        # Load instruction opcode to the bit string
        curr_addr = process_instruction(instruction, bit_string, Memory, curr_addr, index) + 1


# Post-processing to update labels offset
for (key, value) in Memory.items():
    sanitize_label(key, value, labels, Memory)

print('\nLabels:')
for k, v in labels.items():
    print(k, v)

fn = (sys.argv[1]).split('.')[0]
print(Memory)
write_memory_to_file(Memory, 'memory.bin')
write_mem_file(fn, Memory)

if len(sys.argv) == 2:
    write_do_file(fn, f'mem load -i ./{fn}.mem /processor/RAM/ram')

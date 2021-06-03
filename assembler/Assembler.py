import sys
from Utility import write_do_file, write_mem_file, write_memory_to_file, pad_memory
from Process import process_instruction, process_constant
from Sanitize import is_instruction, sanitize_line, org_update
from Config import Comment_String

# Break if no input files were selected
if len(sys.argv) < 2:
    print('Invalid arguments')
    sys.exit(1)

Memory = {}

is_post_org = False
with open(sys.argv[1]) as f:
    curr_addr = 0
    for (index, line) in enumerate(f):
        # # Ignore comments
        # line = line.rstrip().strip().upper()
        # if line.find(Comment_String) > -1:
        #     line = line[:line.find(Comment_String)]

        # # If empty line ignore
        # if len(line) <= 1:
        #     continue

        # Line sanity
        instruction = sanitize_line(line)
        if not instruction:
            continue
        print(instruction)

        # Is an org instruction
        if instruction[0] == '.ORG':
            curr_addr = org_update(instruction, curr_addr, index)
            continue

        if not is_instruction(instruction[0]):
            # Is a number
            curr_addr = process_constant(instruction, Memory, curr_addr, index) 
        else:
            # Write opcode and return the following address
            curr_addr = process_instruction(instruction, Memory, curr_addr, index)

        curr_addr += 1


# Not all addresses are assigned, Memory is a dictionary of assigned memory addresses
Memory = pad_memory(Memory)

fn = (sys.argv[1]).split('.')[0]
write_memory_to_file(fn, Memory)
write_mem_file(fn, Memory)

if len(sys.argv) == 2:
    write_do_file(fn)

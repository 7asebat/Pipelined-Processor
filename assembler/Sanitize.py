import re
from Config import Instruction_Names, Comment_String


def is_instruction(ins: str) -> bool:
    found = False
    found |= ins in Instruction_Names.R_type.Single_Op
    found |= ins in Instruction_Names.R_type.Double_Op
    found |= ins in Instruction_Names.I_type.Value
    found |= ins in Instruction_Names.I_type.Offset
    found |= ins in Instruction_Names.J_type
    found |= ins in Instruction_Names.C_type
    return found


def org_update(instruction, curr_addr: int, index: int) -> int:
    try:
        adr = instruction[1]
        new_addr = int(adr, base=16)
        return new_addr
    except Exception as e:
        raise ValueError(f'Failed to parse .ORG instruction for line {index+1}')


def sanitize_line(line):
    # removing comments from each line
    line = line.rstrip().strip().upper()
    line = re.split(Comment_String, line)[0]
    instruction = re.split(r",|\s", line)
    instruction = list(filter(lambda x: bool(x), instruction))
    return instruction


def parse_I_type_offset(ins):
    # Rb
    operands = ["", ""]
    operands[1] = ins[0]

    # offset
    offset = re.search(r"(-?\d+)(\(R[0-7]\))", ins[1]).group(1)

    # Ra
    operands[0] = re.search(r"(-?\d+)\((R[0-7])\)", ins[1]).group(2)

    return operands, offset


def value_to_bit_string(value_string: str, size: int = 16) -> str:
    # Values are hexadecimal
    value = int(value_string, base=16)

    # # Use the 2's complement
    # if value < 0:
    #     value = (1 << size) + value

    # Keep only `size` bits
    value &= (1 << size) - 1

    return f'{value:0{size}b}'

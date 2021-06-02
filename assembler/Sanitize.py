import re
from Config import Instruction_Names


def is_instruction(ins: str) -> bool:
    found = False
    found |= ins in Instruction_Names.R_type.Single_Op
    found |= ins in Instruction_Names.R_type.Double_Op
    found |= ins in Instruction_Names.I_type.Value
    found |= ins in Instruction_Names.I_type.Offset
    found |= ins in Instruction_Names.J_type
    found |= ins in Instruction_Names.C_type
    return found

# Ignores leading labels


def sanitize_line(line):
    line = re.split(';', line)[0]  # removing comments from each line
    instructionString = re.split(':', line)[-1].strip().upper()  # removing labels
    instruction = re.split(r",|\s", instructionString)
    instruction = list(filter(lambda x: bool(x), instruction))
    return instruction


def sanitize_label(key, value, labels, Memory):
    if re.search(r"\{\w+\}", value):
        label = re.search(r"\{(\w+)\}", value).group(1)
        if re.match(r"^\{", value):
            address = f"{labels[label]:016b}"
            newValue = value.replace('{' + label + '}', address)
        else:
            offset = labels[label] - (key + 1)
            if not -128 <= offset <= 127:
                print('Offset out of range for label {label}')
                sys.exit(1)
            newValue = value.replace('{' + label + '}', '000' + f"{offset & 0xFF:08b}")
        # Updating Memory Value
        Memory[key] = newValue


def define_label(line, labels, curr_addr):
    label = line.split(':')[0].upper()
    labels[label] = curr_addr


def parse_I_type_offset(ins: list[str]) -> list[str]:
    # Rb
    operands = ["", ""]
    operands[1] = ins[0]

    # offset
    offset = re.search(r"(-?\d+)(\(R[0-7]\))", ins[1]).group(1)

    # Ra
    operands[0] = re.search(r"(-?\d+)\((R[0-7])\)", ins[1]).group(2)

    return operands, offset


def value_to_bit_string(value_string: str, size: int = 16) -> str:
    value = int(value_string)

    # Use the 2's complement
    if value < 0:
        value = (1 << size) - value

    # Keep only `size` bits
    value &= (1 << size) - 1

    return f'{value:0{size}b}'

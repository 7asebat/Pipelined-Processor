from Config import Register_Codes, Instruction_Opcode_Funct, Instruction_Names
from Utility import value_to_bit_string
from Sanitize import parse_I_type_offset


# TODO(Abdelrahman) Handle negative shifts?
def write_single_op(operand, bit_string, Memory, curr_addr):
    bit_string += Register_Codes["UD"] + Register_Codes[operand]
    Memory[curr_addr] = bit_string
    return curr_addr


def write_double_op(operands, bit_string, Memory, curr_addr):
    bit_string += Register_Codes[operands[0]] + Register_Codes[operands[1]]
    Memory[curr_addr] = bit_string
    return curr_addr


def write_immediate_value(value, Memory, curr_addr):
    Memory[curr_addr] = value_to_bit_string(value)
    return curr_addr


def write_no_op(bit_string, Memory, curr_addr):
    bit_string += "000000"
    Memory[curr_addr] = bit_string
    return curr_addr


def process_instruction(ins, bit_string, Memory, curr_addr: int, index: int):
    bit_string += Instruction_Opcode_Funct[ins[0]]

    # NOTE(Abdelrahman) bit_string should be 16 bits here
    # no idea why it's 32 bits in the table/schematic/design
    if ins[0] in Instruction_Names.R_type.Single_Op:
        curr_addr = write_single_op(ins[1], bit_string, Memory, curr_addr)

    elif ins[0] in Instruction_Names.R_type.Double_Op:
        curr_addr = write_double_op(ins[1:], bit_string, Memory, curr_addr)

    elif ins[0] in Instruction_Names.I_type.Value:
        curr_addr = write_single_op(ins[1], bit_string, Memory, curr_addr)
        curr_addr += 1
        curr_addr = write_immediate_value(ins[2], Memory, curr_addr)

    elif ins[0] in Instruction_Names.I_type.Offset:
        operands, offset = parse_I_type_offset(ins[1:])
        curr_addr = write_double_op(operands, bit_string, Memory, curr_addr)
        curr_addr += 1
        curr_addr = write_immediate_value(offset, Memory, curr_addr)

    elif ins[0] in Instruction_Names.J_type:
        if ins[0] == "RET":
            curr_addr = write_no_op(bit_string, Memory, curr_addr)
        else:
            curr_addr = write_single_op(ins[1], bit_string, Memory, curr_addr)

    elif ins[0] in Instruction_Names.C_type:
        curr_addr = write_no_op(bit_string, Memory, curr_addr)

    else:
        print('Invalid instruction: syntax error in line', index + 1)
        raise NotImplementedError

    return curr_addr

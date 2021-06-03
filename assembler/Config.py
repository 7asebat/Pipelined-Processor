class Instruction_Names:
    class R_type:
        Single_Op = [
            "CLR",
            "NOT",
            "INC",
            "DEC",
            "NEG",
            "RLC",
            "RRC",
            "PUSH",
            "POP",
            "IN",
            "OUT"
        ]
        Double_Op = [
            "MOV",
            "ADD",
            "SUB",
            "AND",
            "OR"
        ]

    class I_type:
        Value = [
            "SHL",
            "SHR",
            "IADD",
            "LDM",
        ]
        Offset = [
            "LDD",
            "STD",
        ]

    J_type = [
        "JZ",
        "JN",
        "JC",
        "JMP",
        "CALL",
        "RET"
    ]
    C_type = [
        "CLRC",
        "SETC",
        "NOP"
    ]


class ALU_Funct:
    CLR = "0000"
    NOT = "0001"
    INC = "0010"
    DEC = "0011"
    NEG = "0100"
    RLC = "0101"
    RRC = "0110"
    MOV = "0111"
    ADD = "1000"
    SUB = "1001"
    AND = "1010"
    OR = "1011"
    SHL = "1100"
    SHR = "1101"


class Instruction_Prefix:
    class R_type:
        Single_Op = "000000"
        Double_Op = "001000"
        PUSH = "000100"
        POP = "000101"
        IN = "000110"
        OUT = "000111"

    class I_type:
        Main_ALU = "100000"
        LDD = "100101"
        STD = "100110"

    class J_type:
        JZ = "010011"
        JN = "010010"
        JC = "010001"
        JMP = "010000"
        CALL = "010100"
        RET = "010101"

    class C_type:
        CLRC = "111000"
        SETC = "111001"
        NOP = "111010"


# 10 bits
Instruction_Opcode_Funct = {
    "CLR": Instruction_Prefix.R_type.Single_Op + ALU_Funct.CLR,
    "NOT": Instruction_Prefix.R_type.Single_Op + ALU_Funct.NOT,
    "INC": Instruction_Prefix.R_type.Single_Op + ALU_Funct.INC,
    "DEC": Instruction_Prefix.R_type.Single_Op + ALU_Funct.DEC,
    "NEG": Instruction_Prefix.R_type.Single_Op + ALU_Funct.NEG,
    "RLC": Instruction_Prefix.R_type.Single_Op + ALU_Funct.RLC,
    "RRC": Instruction_Prefix.R_type.Single_Op + ALU_Funct.RRC,

    "MOV": Instruction_Prefix.R_type.Double_Op + ALU_Funct.MOV,
    "ADD": Instruction_Prefix.R_type.Double_Op + ALU_Funct.ADD,
    "SUB": Instruction_Prefix.R_type.Double_Op + ALU_Funct.SUB,
    "AND": Instruction_Prefix.R_type.Double_Op + ALU_Funct.AND,
    "OR": Instruction_Prefix.R_type.Double_Op + ALU_Funct.OR,

    "SHL": Instruction_Prefix.I_type.Main_ALU + ALU_Funct.SHL,
    "SHR": Instruction_Prefix.I_type.Main_ALU + ALU_Funct.SHR,
    "IADD": Instruction_Prefix.I_type.Main_ALU + ALU_Funct.ADD,
    "LDM": Instruction_Prefix.I_type.Main_ALU + ALU_Funct.MOV,
    "LDD": Instruction_Prefix.I_type.LDD + ALU_Funct.ADD,
    "STD": Instruction_Prefix.I_type.STD + ALU_Funct.ADD,

    "PUSH": Instruction_Prefix.R_type.PUSH + ALU_Funct.ADD,
    "POP": Instruction_Prefix.R_type.POP + ALU_Funct.ADD,
    "IN": Instruction_Prefix.R_type.IN + ALU_Funct.CLR,
    "OUT": Instruction_Prefix.R_type.OUT + ALU_Funct.CLR,

    "JZ": Instruction_Prefix.J_type.JZ + ALU_Funct.CLR,
    "JN": Instruction_Prefix.J_type.JN + ALU_Funct.CLR,
    "JC": Instruction_Prefix.J_type.JC + ALU_Funct.CLR,
    "JMP": Instruction_Prefix.J_type.JMP + ALU_Funct.CLR,
    "CALL": Instruction_Prefix.J_type.CALL + ALU_Funct.ADD,
    "RET": Instruction_Prefix.J_type.RET + ALU_Funct.ADD,

    "CLRC": Instruction_Prefix.C_type.CLRC + ALU_Funct.CLR,
    "SETC": Instruction_Prefix.C_type.SETC + ALU_Funct.CLR,
    "NOP": Instruction_Prefix.C_type.NOP + ALU_Funct.CLR,
}


Register_Codes = {
    'R0': '000',
    'R1': '001',
    'R2': '010',
    'R3': '011',
    'R4': '100',
    'R5': '101',
    'R6': '110',
    'R7': '111',
    "UD": "000"
}

Comment_String = '#'

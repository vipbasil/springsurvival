extends Node

# Library of instructions

const INSTRUCTIONS = {
    "NOP": {"type": "nop", "args": 0},
    "MOV": {"type": "mov", "args": 0},
    "SCN": {"type": "scn", "args": 0},
    "PCK": {"type": "pck", "args": 0},
    "DRP": {"type": "drp", "args": 0},
    "CHG": {"type": "chg", "args": 0},
    "JMP": {"type": "jmp", "args": 1},
    "JNZ": {"type": "jnz", "args": 1},
    "DEC": {"type": "dec", "args": 0},
    "INC": {"type": "inc", "args": 0},
    "SET": {"type": "set", "args": 1},
    "OUT": {"type": "out", "args": 0},
    "DIE": {"type": "die", "args": 0},
    "ROT": {"type": "rot", "args": 1},
}

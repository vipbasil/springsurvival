extends RefCounted

class_name PunchEncoding

# Prototype 5-channel tape map.
# Each row is one longitudinal tape step with five punch positions across the tape width.
const ROW_TO_INSTRUCTION := {
    "00000": "NOP",
    "10000": "MOV",
    "01000": "ROT 1",
    "00100": "ROT -1",
    "11000": "CHG",
    "10100": "SCN",
    "01100": "PCK",
    "11100": "DRP",
    "00001": "OUT",
    "10001": "INC",
    "01001": "DEC",
    "10101": "CMP 3",
    "00101": "CMP 0",
    "10010": "JNZ 1",
    "01010": "JNZ 2",
    "01101": "JMP 0",
    "11101": "JMP 1",
    "00110": "DIE",
}

const EXAMPLE_ROWS := [
    "10101", # CMP 3
    "00001", # OUT
    "01001", # DEC
    "10010", # JNZ 1
    "00110", # DIE
]

static func instruction_for_bits(bits: String) -> String:
    return ROW_TO_INSTRUCTION.get(bits, "")

static func decode_rows(rows: PackedStringArray) -> Dictionary:
    var decoded_lines: Array = []
    var unknown_rows: Array = []

    for bits in rows:
        var instruction := instruction_for_bits(bits)
        if instruction.is_empty():
            unknown_rows.append(bits)
            decoded_lines.append("UNKNOWN(" + bits + ")")
        else:
            decoded_lines.append(instruction)

    return {
        "decoded_lines": decoded_lines,
        "unknown_rows": unknown_rows,
    }

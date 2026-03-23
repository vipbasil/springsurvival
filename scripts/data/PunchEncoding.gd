extends RefCounted

class_name PunchEncoding

const InstructionLibraryData = preload("res://scripts/data/InstructionLibrary.gd")

# Five-bit punch codes are fixed by index. Display labels are mutable so the
# machine can train alternate mnemonics without changing the physical tape
# result. Canonical execution meaning comes from OPCODE_LABELS and the
# instruction library.
const OPCODE_LABELS := {
	0: "NOP",
	1: "MOV",
	2: "ROT",
	4: "CHG",
	5: "SCN",
	6: "PCK",
	7: "DRP",
	8: "OUT",
	9: "INC",
	10: "DEC",
	11: "SET",
	13: "JNZ",
	15: "JMP",
	17: "DIE",
	18: "ATK",
}

const DEFAULT_LABELS := {
	0: "NOP",
	1: "MOV",
	2: "ROT",
	4: "CHG",
	5: "SCN",
	6: "PCK",
	7: "DRP",
	8: "OUT",
	9: "INC",
	10: "DEC",
	11: "SET",
	13: "JNZ",
	15: "JMP",
	17: "DIE",
	18: "ATK",
}

const EXAMPLE_INDEXES := [11, 3, 8, 10, 13, 1, 17]

static var _labels: Dictionary = {}

static func _ensure_labels():
	if not _labels.is_empty():
		return

	for index in range(32):
		_labels[index] = str(DEFAULT_LABELS.get(index, ""))

static func bits_for_index(index: int) -> String:
	var clamped_index := clampi(index, 0, 31)
	var bits := ""
	for shift in range(4, -1, -1):
		bits += "1" if clamped_index & (1 << shift) else "0"
	return bits

static func index_for_bits(bits: String) -> int:
	if bits.length() != 5:
		return -1

	var value := 0
	for char_index in range(bits.length()):
		var char := bits.substr(char_index, 1)
		if char != "0" and char != "1":
			return -1
		value = value * 2 + int(char)
	return value

static func signed_value_for_bits(bits: String) -> int:
	var value := index_for_bits(bits)
	if value < 0:
		return -1
	if value >= 16:
		return value - 32
	return value

static func get_codes() -> Array[Dictionary]:
	_ensure_labels()

	var codes: Array[Dictionary] = []
	for index in range(32):
		codes.append({
			"index": index,
			"bits": bits_for_index(index),
			"label": str(_labels.get(index, "")),
		})
	return codes

static func get_code(index: int) -> Dictionary:
	_ensure_labels()
	if index < 0 or index > 31:
		return {}
	return {
		"index": index,
		"bits": bits_for_index(index),
		"label": str(_labels.get(index, "")),
		"opcode": str(OPCODE_LABELS.get(index, "")),
	}

static func get_code_for_bits(bits: String) -> Dictionary:
	var index := index_for_bits(bits)
	if index == -1:
		return {}
	return get_code(index)

static func get_opcode_name(index: int) -> String:
	return str(OPCODE_LABELS.get(index, ""))

static func set_label(index: int, label: String):
	_ensure_labels()
	if index < 0 or index > 31:
		return
	_labels[index] = label.strip_edges()

static func get_example_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for index in EXAMPLE_INDEXES:
		var code := get_code(index)
		rows.append({
			"index": int(code.get("index", 0)),
			"bits": str(code.get("bits", "")),
		})
	return rows

static func decode_rows(rows: Array) -> Dictionary:
	var row_labels: Array = []
	var program_lines: Array = []
	var unknown_rows: Array = []
	for _row in rows:
		row_labels.append("")

	var row_index := 0
	while row_index < rows.size():
		var row = rows[row_index]
		var bits := ""
		var code_index := -1
		if row is Dictionary:
			bits = str(row.get("bits", ""))
			code_index = int(row.get("index", index_for_bits(bits)))
		else:
			bits = str(row)
			code_index = index_for_bits(bits)

		var opcode_name := get_opcode_name(code_index)
		if opcode_name.is_empty():
			unknown_rows.append(bits)
			row_labels[row_index] = "DATA " + str(code_index if code_index >= 0 else "?")
			row_index += 1
			continue

		var instruction_info: Dictionary = InstructionLibraryData.INSTRUCTIONS.get(opcode_name, {})
		var arg_count := int(instruction_info.get("args", 0))
		if arg_count > 0:
			if row_index + 1 >= rows.size():
				unknown_rows.append(bits)
				row_labels[row_index] = opcode_name + " ?"
				row_index += 1
				continue

			var arg_row = rows[row_index + 1]
			var arg_bits := ""
			var arg_index := -1
			if arg_row is Dictionary:
				arg_bits = str(arg_row.get("bits", ""))
				arg_index = int(arg_row.get("index", index_for_bits(arg_bits)))
			else:
				arg_bits = str(arg_row)
				arg_index = index_for_bits(arg_bits)

			if arg_index < 0:
				unknown_rows.append(arg_bits)
				row_labels[row_index] = opcode_name + " ?"
				row_labels[row_index + 1] = "ARG ?"
				row_index += 2
				continue

			var arg_value := arg_index
			if opcode_name == "ROT":
				arg_value = signed_value_for_bits(arg_bits)
				if arg_value == -1 and arg_bits != "11111":
					unknown_rows.append(arg_bits)
					row_labels[row_index] = opcode_name + " ?"
					row_labels[row_index + 1] = "ARG ?"
					row_index += 2
					continue

			var combined_line := opcode_name + " " + str(arg_value)
			row_labels[row_index] = combined_line
			row_labels[row_index + 1] = "ARG " + str(arg_value)
			program_lines.append(combined_line)
			row_index += 2
			continue

		row_labels[row_index] = opcode_name
		program_lines.append(opcode_name)
		row_index += 1

	return {
		"row_labels": row_labels,
		"program_lines": program_lines,
		"unknown_rows": unknown_rows,
	}

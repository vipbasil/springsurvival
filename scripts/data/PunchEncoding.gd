extends RefCounted

class_name PunchEncoding

# Five-bit punch codes are fixed by index. Labels are mutable so the machine can
# train alternate mnemonics without changing the physical tape result.
const DEFAULT_LABELS := {
	0: "NOP",
	1: "MOV",
	2: "ROT 1",
	3: "ROT -1",
	4: "CHG",
	5: "SCN",
	6: "PCK",
	7: "DRP",
	8: "OUT",
	9: "INC",
	10: "DEC",
	11: "CMP 3",
	12: "CMP 0",
	13: "JNZ 1",
	14: "JNZ 2",
	15: "JMP 0",
	16: "JMP 1",
	17: "DIE",
	18: "ROT 2",
	19: "ROT -2",
}

const EXAMPLE_INDEXES := [11, 8, 10, 13, 17]

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
	}

static func get_code_for_bits(bits: String) -> Dictionary:
	var index := index_for_bits(bits)
	if index == -1:
		return {}
	return get_code(index)

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
	var decoded_lines: Array = []
	var unknown_rows: Array = []

	for row in rows:
		var bits := ""
		if row is Dictionary:
			bits = str(row.get("bits", ""))
		else:
			bits = str(row)

		var code := get_code_for_bits(bits)
		var label := str(code.get("label", ""))
		if label.is_empty():
			unknown_rows.append(bits)
			decoded_lines.append("UNKNOWN(" + bits + ")")
		else:
			decoded_lines.append(label)

	return {
		"decoded_lines": decoded_lines,
		"unknown_rows": unknown_rows,
	}

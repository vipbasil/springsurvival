extends Control

const PunchEncodingData = preload("res://scripts/data/PunchEncoding.gd")

const FRAME_COLOR := Color(0.09, 0.10, 0.12)
const MACHINE_COLOR := Color(0.13, 0.14, 0.16)
const MACHINE_SHADOW := Color(0.08, 0.08, 0.09)
const PANEL_COLOR := Color(0.15, 0.16, 0.18)
const BORDER_COLOR := Color(0.47, 0.40, 0.24)
const BORDER_DARK := Color(0.27, 0.22, 0.12)
const BRASS_COLOR := Color(0.80, 0.66, 0.27)
const BRASS_DARK := Color(0.52, 0.42, 0.18)
const STEEL_COLOR := Color(0.43, 0.43, 0.42)
const ENAMEL_COLOR := Color(0.17, 0.18, 0.20)
const BAKELITE_COLOR := Color(0.13, 0.12, 0.11)
const BAKELITE_HOVER := Color(0.19, 0.18, 0.16)
const BAKELITE_PRESS := Color(0.09, 0.09, 0.09)
const TAPE_COLOR := Color(0.84, 0.78, 0.60)
const TAPE_SHADE := Color(0.68, 0.61, 0.42)
const HOLE_COLOR := Color(0.10, 0.10, 0.10)
const PREVIEW_COLOR := Color(0.32, 0.50, 0.66, 0.35)
const CARTRIDGE_CAPACITY := 48.0

@onready var title_label: Label = $Header/TitleLabel
@onready var subtitle_label: Label = $Header/SubtitleLabel
@onready var frame: Control = $Frame
@onready var input_section: Control = $InputSection
@onready var keyboard_deck: Control = $InputSection/KeyboardDeck
@onready var keyboard_grid: GridContainer = $InputSection/KeyboardGrid
@onready var mechanical_section: Control = $MechanicalSection
@onready var tape_viewport: Control = $MechanicalSection/TapeViewport
@onready var punch_head: Control = $MechanicalSection/PunchHead
@onready var guide_rails: Control = $MechanicalSection/GuideRails
@onready var left_cartridge: Control = $MechanicalSection/LeftCartridge
@onready var feed_wheel_left: Control = $MechanicalSection/FeedWheelLeft
@onready var feed_wheel_right: Control = $MechanicalSection/FeedWheelRight
@onready var right_cartridge: Control = $MechanicalSection/RightCartridge
@onready var linkage_bar: Control = $MechanicalSection/LinkageBar
@onready var horizontal_beam: Control = $MechanicalSection/LinkageBar/HorizontalBeam
@onready var linkage_decor: Control = $MechanicalSection/LinkageBar/LinkageDecor
@onready var tape_control_section: Control = $TapeControlSection
@onready var rewind_button: Button = $TapeControlSection/RewindButton
@onready var clear_tape_button: Button = $TapeControlSection/ClearTapeButton
@onready var load_to_automaton_button: Button = $TapeControlSection/LoadToAutomatonButton
@onready var decode_preview_button: Button = $TapeControlSection/DecodePreviewButton
@onready var example_tape_button: Button = $TapeControlSection/ExampleTapeButton
@onready var output_section: Control = $OutputSection
@onready var tape_rows_list: ItemList = $OutputSection/TapeRowsList
@onready var decoded_instructions_label: RichTextLabel = $OutputSection/DecodedInstructionsLabel
@onready var status_label: Label = $OutputSection/StatusLabel

var keyboard_buttons: Array[Button] = []
var code_table: Array[Dictionary] = []
var tape_rows: Array[Dictionary] = []
var tape_cursor := 0
var active_code_index := 0
var punch_head_offset := 0.0
var tape_shift := 0.0
var feed_rotation := 0.0
var linkage_offset := 0.0

func _ready():
	custom_minimum_size = Vector2(980, 620)
	# title_label.text = "Punch Machine"
	# subtitle_label.text = "5-channel bench punch for automaton tape"
	_rebuild_code_table()
	_build_keyboard()
	_style_buttons()
	_wire_controls()
	_refresh_keyboard()
	_refresh_output()
	_set_status("Ready")
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw():
	_draw_panel(_rect_in_root(frame), FRAME_COLOR, BORDER_COLOR, 3.0)
	_draw_machine_body()
	_draw_panel(_rect_in_root(tape_control_section), PANEL_COLOR, BORDER_COLOR)
	_draw_panel(_rect_in_root(output_section), PANEL_COLOR, BORDER_COLOR)

func _rebuild_code_table():
	code_table = PunchEncodingData.get_codes()

func _build_keyboard():
	for child in keyboard_grid.get_children():
		child.queue_free()

	keyboard_buttons.clear()
	for code in code_table:
		var button := Button.new()
		var index := int(code.get("index", 0))
		button.custom_minimum_size = Vector2(54, 54)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.clip_text = true
		button.pressed.connect(_on_code_key_pressed.bind(index))
		keyboard_grid.add_child(button)
		keyboard_buttons.append(button)

func _style_buttons():
	var key_normal := _make_stylebox(BAKELITE_COLOR, BRASS_DARK, 2, 18)
	var key_hover := _make_stylebox(BAKELITE_HOVER, BRASS_COLOR, 2, 18)
	var key_pressed := _make_stylebox(BAKELITE_PRESS, BRASS_COLOR, 3, 18)
	var control_normal := _make_stylebox(ENAMEL_COLOR, BORDER_DARK, 2, 8)
	var control_hover := _make_stylebox(Color(0.20, 0.21, 0.23), BRASS_COLOR, 2, 8)
	var control_pressed := _make_stylebox(Color(0.11, 0.12, 0.14), BRASS_COLOR, 3, 8)

	for button in keyboard_buttons:
		button.add_theme_stylebox_override("normal", key_normal.duplicate())
		button.add_theme_stylebox_override("hover", key_hover.duplicate())
		button.add_theme_stylebox_override("pressed", key_pressed.duplicate())
		button.add_theme_stylebox_override("focus", key_hover.duplicate())
		button.add_theme_color_override("font_color", Color(0.93, 0.90, 0.82))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.95, 0.82))
		button.add_theme_font_size_override("font_size", 11)

	for button in [rewind_button, clear_tape_button, load_to_automaton_button, decode_preview_button, example_tape_button]:
		button.add_theme_stylebox_override("normal", control_normal.duplicate())
		button.add_theme_stylebox_override("hover", control_hover.duplicate())
		button.add_theme_stylebox_override("pressed", control_pressed.duplicate())
		button.add_theme_stylebox_override("focus", control_hover.duplicate())
		button.add_theme_color_override("font_color", Color(0.92, 0.90, 0.84))
		button.add_theme_font_size_override("font_size", 12)

func _wire_controls():
	rewind_button.pressed.connect(_on_rewind_pressed)
	clear_tape_button.pressed.connect(_on_clear_tape_pressed)
	load_to_automaton_button.pressed.connect(_on_load_to_automaton_pressed)
	decode_preview_button.pressed.connect(_on_decode_preview_pressed)
	example_tape_button.pressed.connect(_on_example_tape_pressed)
	tape_rows_list.item_selected.connect(_on_row_selected)

func _refresh_keyboard():
	_rebuild_code_table()
	for index in range(mini(keyboard_buttons.size(), code_table.size())):
		var button := keyboard_buttons[index]
		var code := code_table[index]
		var label := str(code.get("label", ""))
		var bits := str(code.get("bits", ""))
		button.text = "%02d\n%s\n%s" % [index, bits, _key_face_label(label)]
		button.tooltip_text = "%02d  %s  %s" % [index, bits, label if not label.is_empty() else "(unassigned)"]
		button.modulate = Color(1.0, 0.94, 0.78) if index == active_code_index else Color.WHITE

func _on_code_key_pressed(index: int):
	if tape_rows.size() >= int(CARTRIDGE_CAPACITY):
		EventBus.log_message.emit("PunchMachine: tape full")
		_set_status("Tape full")
		return

	var code := PunchEncodingData.get_code(index)
	if code.is_empty():
		return

	active_code_index = index
	_refresh_keyboard()
	_animate_linkage()
	_animate_punch()
	_animate_feed(20.0, 0.30)

	var row := {
		"bits": str(code.get("bits", "")),
		"index": index,
	}
	tape_rows.append(row)
	tape_cursor = tape_rows.size()
	_refresh_output()

	var bits := str(code.get("bits", ""))
	var label := str(code.get("label", ""))
	EventBus.tape_row_punched.emit(bits)
	EventBus.log_message.emit("PunchMachine: key %02d punched %s%s" % [index, bits, " " + label if not label.is_empty() else ""])
	EventBus.log_message.emit("PunchMachine: tape advanced")
	_set_status("Punched %02d %s" % [index, bits])

func _on_rewind_pressed():
	tape_cursor = 0
	_animate_feed(-22.0, -0.24)
	_refresh_output()
	EventBus.log_message.emit("PunchMachine: tape rewound")
	_set_status("Tape rewound")

func _on_clear_tape_pressed():
	tape_rows.clear()
	tape_cursor = 0
	_refresh_output()
	EventBus.tape_cleared.emit()
	EventBus.log_message.emit("PunchMachine: tape cleared")
	_set_status("Tape cleared")

func _on_load_to_automaton_pressed():
	if tape_rows.is_empty():
		_set_status("Nothing to load")
		EventBus.log_message.emit("PunchMachine: no tape to load")
		return

	var decode_result := _refresh_output()
	var unknown_rows: Array = decode_result["unknown_rows"]
	if not unknown_rows.is_empty():
		var unknown_text := _join_with_separator(unknown_rows, ", ")
		_set_status("Unknown rows block loading")
		EventBus.log_message.emit("PunchMachine: load failed, unknown rows " + unknown_text)
		return

	var instruction_lines: Array = decode_result["program_lines"]
	var tape_text := _join_with_separator(instruction_lines, "\n")
	var program := TapeDecoder.decode_tape(tape_text)
	if program.is_empty():
		_set_status("Decode produced no runnable program")
		EventBus.log_message.emit("PunchMachine: load failed, no program decoded")
		return

	TapeExecutionSystem.is_executing = false
	GameState.tape_program = program
	GameState.automaton_ptr = 0
	GameState.automaton_status = "idle"
	EventBus.tape_loaded.emit(program)
	EventBus.ptr_changed.emit(GameState.automaton_ptr)
	EventBus.status_changed.emit(GameState.automaton_status)
	EventBus.tape_loaded_to_automaton.emit(program, instruction_lines)
	EventBus.log_message.emit("PunchMachine: tape loaded into automaton")
	_set_status("Tape loaded into automaton")

func _on_decode_preview_pressed():
	var decode_result := _refresh_output()
	EventBus.log_message.emit("PunchMachine: decoded " + str(Array(decode_result["program_lines"]).size()) + " instructions")
	_set_status("Decoded " + str(Array(decode_result["program_lines"]).size()) + " instructions")

func _on_example_tape_pressed():
	tape_rows = PunchEncodingData.get_example_rows()
	if not tape_rows.is_empty():
		active_code_index = int(tape_rows[-1].get("index", 0))
		_refresh_keyboard()
	tape_cursor = tape_rows.size()
	_refresh_output()
	EventBus.log_message.emit("PunchMachine: example tape loaded")
	_set_status("Example tape loaded")

func _on_row_selected(index: int):
	if index < 0 or index >= tape_rows.size():
		return
	tape_cursor = index
	active_code_index = int(tape_rows[index].get("index", 0))
	_refresh_keyboard()
	_refresh_output()
	_set_status("Inspecting row " + str(index))

func _refresh_output() -> Dictionary:
	var decode_result := PunchEncodingData.decode_rows(tape_rows)
	var row_labels: Array = decode_result["row_labels"]
	var program_lines: Array = decode_result["program_lines"]
	var unknown_rows: Array = decode_result["unknown_rows"]

	tape_rows_list.clear()
	for index in range(tape_rows.size()):
		var row: Dictionary = tape_rows[index]
		tape_rows_list.add_item("%02d  %s  %s" % [index, str(row.get("bits", "")), str(row_labels[index])])

	tape_rows_list.deselect_all()
	if not tape_rows.is_empty():
		var selected_index := clampi(tape_cursor if tape_cursor < tape_rows.size() else tape_rows.size() - 1, 0, tape_rows.size() - 1)
		tape_rows_list.select(selected_index)

	decoded_instructions_label.clear()
	if program_lines.is_empty():
		decoded_instructions_label.append_text("Decode preview:\n(no tape rows punched)")
	else:
		var preview_lines := PackedStringArray()
		for index in range(program_lines.size()):
			preview_lines.append("%02d  %s" % [index, str(program_lines[index])])
		decoded_instructions_label.append_text("Decode preview:\n" + "\n".join(preview_lines))
		if not unknown_rows.is_empty():
			decoded_instructions_label.append_text("\n\nUnknown rows: " + _join_with_separator(unknown_rows, ", "))

	EventBus.decode_preview_generated.emit(program_lines, unknown_rows)
	queue_redraw()
	return decode_result

func _set_status(status: String):
	status_label.text = "Status: " + status
	EventBus.machine_status_changed.emit(status)

func _key_face_label(label: String) -> String:
	var trimmed := label.strip_edges()
	if trimmed.is_empty():
		return "--"
	if trimmed.length() <= 6:
		return trimmed
	return trimmed.substr(0, 6)

func _join_with_separator(values: Array, separator: String) -> String:
	var strings := PackedStringArray()
	for value in values:
		strings.append(str(value))
	return separator.join(strings)

func has_punched_tape() -> bool:
	return not tape_rows.is_empty()

func get_tape_rows_copy() -> Array:
	var rows_copy: Array = []
	for row in tape_rows:
		rows_copy.append({
			"bits": str(row.get("bits", "")),
			"index": int(row.get("index", 0)),
		})
	return rows_copy

func _animate_punch():
	var tween := create_tween()
	tween.tween_method(Callable(self, "_set_punch_head_offset"), 0.0, 1.0, 0.08)
	tween.tween_method(Callable(self, "_set_punch_head_offset"), 1.0, 0.0, 0.12)

func _animate_feed(shift_amount: float, wheel_delta: float):
	var rotation_start := feed_rotation
	var tween := create_tween()
	tween.tween_method(Callable(self, "_set_tape_shift"), shift_amount, 0.0, 0.18)
	tween.parallel().tween_method(Callable(self, "_set_feed_rotation"), rotation_start, rotation_start + wheel_delta, 0.18)

func _animate_linkage():
	var tween := create_tween()
	tween.tween_method(Callable(self, "_set_linkage_offset"), 0.0, 8.0, 0.06)
	tween.tween_method(Callable(self, "_set_linkage_offset"), 8.0, 0.0, 0.12)

func _set_punch_head_offset(value: float):
	punch_head_offset = value
	queue_redraw()

func _set_tape_shift(value: float):
	tape_shift = value
	queue_redraw()

func _set_feed_rotation(value: float):
	feed_rotation = value
	queue_redraw()

func _set_linkage_offset(value: float):
	linkage_offset = value
	queue_redraw()

func _draw_machine_body():
	var machine_rect := _rect_in_root(mechanical_section).merge(_rect_in_root(input_section)).grow(10.0)
	_draw_panel(machine_rect, MACHINE_COLOR, BORDER_COLOR, 3.0)
	draw_rect(Rect2(machine_rect.position + Vector2(12, machine_rect.size.y - 14), Vector2(machine_rect.size.x - 24, 8)), MACHINE_SHADOW)

	_draw_tape_path()
	_draw_punch_assembly()
	_draw_linkage()
	_draw_keyboard_deck()

func _draw_tape_path():
	var viewport_rect := _rect_in_root(tape_viewport)
	var guide_rect := _rect_in_root(guide_rails)
	var strip_rect := _tape_strip_rect()
	var reference_x := viewport_rect.position.x + viewport_rect.size.x * 0.58
	var row_width := 16.0
	var content_min_x := strip_rect.position.x + row_width * 0.5
	var content_max_x := strip_rect.end.x - row_width * 0.5
	var tape_band_rect := Rect2(strip_rect.position + Vector2(0.0, 3.0), Vector2(strip_rect.size.x, strip_rect.size.y - 6.0))

	_draw_cartridge(left_cartridge, true)
	_draw_cartridge(right_cartridge, false)
	draw_rect(guide_rect, Color(0.10, 0.10, 0.11), false, 2.0)
	draw_rect(viewport_rect, Color(0.10, 0.10, 0.11))
	draw_rect(viewport_rect, BORDER_DARK, false, 2.0)
	draw_rect(strip_rect, TAPE_SHADE)
	draw_rect(tape_band_rect, TAPE_COLOR)
	_draw_tape_guides(strip_rect, reference_x, row_width)

	for row_index in range(tape_rows.size()):
		var row: Dictionary = tape_rows[row_index]
		var row_bits := str(row.get("bits", "00000"))
		var row_x := reference_x + (row_index - tape_cursor) * row_width + tape_shift
		if row_x < content_min_x or row_x > content_max_x:
			continue
		var row_rect := Rect2(Vector2(row_x - row_width * 0.5, strip_rect.position.y + 2.0), Vector2(row_width - 1.0, strip_rect.size.y - 4.0))
		draw_rect(row_rect, TAPE_COLOR.lightened(0.03))
		draw_rect(row_rect, TAPE_SHADE, false, 1.0)
		_draw_tape_row(row_rect, row_bits, false)

	var selected_code := PunchEncodingData.get_code(active_code_index)
	var current_row_rect := _current_tape_row_rect()
	draw_rect(current_row_rect, PREVIEW_COLOR)
	draw_rect(current_row_rect, BRASS_COLOR, false, 1.0)
	_draw_tape_row(current_row_rect, str(selected_code.get("bits", "00000")), true)

	_draw_roller(feed_wheel_left, 1.0)
	_draw_roller(feed_wheel_right, -1.0)

func _draw_tape_guides(strip_rect: Rect2, reference_x: float, row_width: float):
	var base_center_x := reference_x + tape_shift
	var content_min_x := strip_rect.position.x + row_width * 0.5
	var content_max_x := strip_rect.end.x - row_width * 0.5
	var start_column := int(floor((content_min_x - base_center_x) / row_width)) - 1
	var end_column := int(ceil((content_max_x - base_center_x) / row_width)) + 1

	for column in range(start_column, end_column + 1):
		var row_center_x := base_center_x + column * row_width
		if row_center_x < content_min_x or row_center_x > content_max_x:
			continue
		var row_rect := Rect2(
			Vector2(row_center_x - row_width * 0.5, strip_rect.position.y + 2.0),
			Vector2(row_width - 1.0, strip_rect.size.y - 4.0)
		)
		draw_rect(row_rect, Color(1.0, 0.98, 0.92, 0.05))
		draw_rect(row_rect, Color(0.43, 0.37, 0.25, 0.28), false, 1.0)
		_draw_tape_row(row_rect, "00000", false, true)

func _draw_punch_assembly():
	var head_rect := _rect_in_root(punch_head)
	var current_row_rect := _current_tape_row_rect()
	var tape_rect := _tape_strip_rect()
	var housing_inner_rect := Rect2(
		Vector2(
			current_row_rect.position.x + current_row_rect.size.x * 0.5 - head_rect.size.x * 0.5,
			tape_rect.position.y - 10.0
		),
		Vector2(head_rect.size.x, tape_rect.size.y + 20.0)
	)
	var housing_rect := housing_inner_rect.grow(8.0)
	var depth_inset := punch_head_offset * 4.0
	var mask_rect := housing_inner_rect.grow(-depth_inset)

	draw_rect(housing_rect, Color(0.32, 0.28, 0.22))
	draw_rect(housing_rect, BORDER_COLOR, false, 2.0)
	draw_rect(housing_inner_rect, Color(0.53, 0.48, 0.37))
	draw_rect(housing_inner_rect, BORDER_DARK, false, 1.0)
	draw_rect(mask_rect, Color(0.74, 0.70, 0.56))
	draw_rect(mask_rect, BORDER_DARK, false, 2.0)
	var die_rect := mask_rect.grow(-8.0)
	draw_rect(die_rect, Color(0.62, 0.60, 0.48))
	draw_rect(Rect2(Vector2(die_rect.position.x + 4.0, tape_rect.position.y - 2.0), Vector2(die_rect.size.x - 8.0, tape_rect.size.y + 4.0)), Color(0.55, 0.52, 0.40, 0.45))

	var bits := str(PunchEncodingData.get_code(active_code_index).get("bits", "00000"))
	var pin_x := die_rect.position.x + die_rect.size.x * 0.5
	var channel_centers := _channel_centers_for_row(current_row_rect)
	for pin_index in range(5):
		var active := bits.substr(pin_index, 1) == "1"
		var center_y := channel_centers[pin_index].y
		draw_circle(Vector2(pin_x, center_y), 6.0, Color(0.44, 0.42, 0.34))
		draw_circle(Vector2(pin_x, center_y), 4.2, BRASS_COLOR if active else STEEL_COLOR)
		if active:
			draw_circle(Vector2(pin_x, center_y), 2.4, HOLE_COLOR)

func _draw_linkage():
	var beam_rect := _rect_in_root(horizontal_beam)
	var shifted_beam := beam_rect
	shifted_beam.position.x += linkage_offset
	draw_rect(shifted_beam, BRASS_DARK)
	draw_rect(shifted_beam, BORDER_COLOR, false, 2.0)

	var decor_rect := _rect_in_root(linkage_decor)
	var deck_rect := _rect_in_root(keyboard_deck)
	var deck_top_y := deck_rect.position.y + 18.0
	for rod_index in range(8):
		var t := float(rod_index) / 7.0
		var beam_x := lerpf(shifted_beam.position.x + 24.0, shifted_beam.position.x + shifted_beam.size.x - 24.0, t)
		var deck_x := lerpf(deck_rect.position.x + 116.0, deck_rect.position.x + deck_rect.size.x - 116.0, t) + linkage_offset * 0.35
		draw_line(Vector2(beam_x, shifted_beam.position.y + shifted_beam.size.y), Vector2(deck_x, deck_top_y), STEEL_COLOR, 2.0)

	var accent_y := decor_rect.position.y + decor_rect.size.y * 0.5
	draw_line(
		Vector2(shifted_beam.position.x + 32.0, accent_y),
		Vector2(shifted_beam.position.x + shifted_beam.size.x - 32.0, accent_y),
		BRASS_COLOR,
		2.0
	)

func _draw_keyboard_deck():
	var deck_rect := _rect_in_root(keyboard_deck)
	var plate_points := PackedVector2Array([
		Vector2(deck_rect.position.x + 76.0, deck_rect.position.y + 10.0),
		Vector2(deck_rect.position.x + deck_rect.size.x - 76.0, deck_rect.position.y + 10.0),
		Vector2(deck_rect.position.x + deck_rect.size.x - 26.0, deck_rect.position.y + deck_rect.size.y - 12.0),
		Vector2(deck_rect.position.x + 26.0, deck_rect.position.y + deck_rect.size.y - 12.0),
	])
	draw_colored_polygon(plate_points, Color(0.11, 0.12, 0.14))
	for point_index in range(plate_points.size()):
		var next_index := (point_index + 1) % plate_points.size()
		draw_line(plate_points[point_index], plate_points[next_index], BORDER_COLOR, 2.0)

	var keybed_rect := _rect_in_root(keyboard_grid).grow(10.0)
	draw_rect(keybed_rect, ENAMEL_COLOR)
	draw_rect(keybed_rect, BORDER_DARK, false, 2.0)

func _draw_tape_row(row_rect: Rect2, bits: String, is_preview: bool, placeholders_only: bool = false):
	var channel_centers := _channel_centers_for_row(row_rect)
	for channel_index in range(5):
		var center := channel_centers[channel_index]
		var bit_is_on := bits.substr(channel_index, 1) == "1"
		if placeholders_only:
			draw_circle(center, 1.4, Color(0.34, 0.30, 0.22, 0.35))
		elif bit_is_on:
			draw_circle(center, 4.5, Color(0.92, 0.86, 0.66, 0.60) if is_preview else Color(0.18, 0.17, 0.15))
			draw_circle(center, 2.8, BRASS_COLOR if is_preview else HOLE_COLOR)
		else:
			draw_circle(center, 1.8, TAPE_SHADE.darkened(0.2))

func _current_tape_row_rect() -> Rect2:
	var viewport_rect := _rect_in_root(tape_viewport)
	var strip_rect := _tape_strip_rect()
	var row_width := 16.0
	var reference_x := viewport_rect.position.x + viewport_rect.size.x * 0.58
	return Rect2(
		Vector2(reference_x - row_width * 0.5, strip_rect.position.y + 2.0),
		Vector2(row_width - 1.0, strip_rect.size.y - 4.0)
	)

func _tape_strip_rect() -> Rect2:
	var viewport_rect := _rect_in_root(tape_viewport)
	var left_cartridge_rect := _rect_in_root(left_cartridge)
	var right_cartridge_rect := _rect_in_root(right_cartridge)
	var mouth_width := 3.0
	var left_x := left_cartridge_rect.end.x - mouth_width - 1.0
	var right_x := right_cartridge_rect.position.x + mouth_width + 1.0
	return Rect2(
		Vector2(left_x, viewport_rect.position.y + 12.0),
		Vector2(right_x - left_x, viewport_rect.size.y - 24.0)
	)

func _channel_centers_for_row(row_rect: Rect2) -> Array[Vector2]:
	var centers: Array[Vector2] = []
	var margin := 8.0
	var channel_spacing := (row_rect.size.y - margin * 2.0) / 4.0
	for channel_index in range(5):
		centers.append(Vector2(
			row_rect.position.x + row_rect.size.x * 0.5,
			row_rect.position.y + margin + channel_spacing * channel_index
		))
	return centers

func _draw_roller(node: Control, phase_direction: float):
	var rect := _rect_in_root(node)
	var body_rect := rect.grow(-2.0)
	var left_cap := Rect2(body_rect.position, Vector2(4.0, body_rect.size.y))
	var right_cap := Rect2(Vector2(body_rect.end.x - 4.0, body_rect.position.y), Vector2(4.0, body_rect.size.y))
	var highlight_rect := Rect2(
		Vector2(body_rect.position.x + body_rect.size.x * 0.28, body_rect.position.y + 3.0),
		Vector2(body_rect.size.x * 0.18, body_rect.size.y - 6.0)
	)

	draw_rect(body_rect, Color(0.20, 0.19, 0.17))
	draw_rect(body_rect, BORDER_COLOR, false, 2.0)
	draw_rect(left_cap, BRASS_DARK)
	draw_rect(right_cap, BRASS_DARK)
	draw_rect(highlight_rect, Color(0.75, 0.72, 0.62, 0.18))

	var band_spacing := 18.0
	var band_phase := fposmod(feed_rotation * 18.0 * phase_direction, band_spacing)
	for band_index in range(-1, int(ceil(body_rect.size.y / band_spacing)) + 2):
		var band_y := body_rect.position.y + band_index * band_spacing + band_phase
		var band_rect := Rect2(
			Vector2(body_rect.position.x + 4.0, band_y),
			Vector2(body_rect.size.x - 8.0, 5.0)
		)
		if band_rect.end.y < body_rect.position.y or band_rect.position.y > body_rect.end.y:
			continue
		draw_rect(band_rect, Color(0.11, 0.10, 0.09, 0.24))

func _draw_cartridge(node: Control, programmed: bool):
	var rect := _rect_in_root(node)
	var shell_rect := rect.grow(-1.0)
	var is_left := node == left_cartridge
	var tape_rect := _tape_strip_rect()
	var fill_color := Color(0.16, 0.16, 0.17)
	var body_rect := Rect2(
		Vector2(shell_rect.position.x + 10.0, shell_rect.position.y + 14.0),
		Vector2(shell_rect.size.x - 20.0, shell_rect.size.y - 28.0)
	)
	var shell_inner := body_rect.grow(-3.0)
	var top_rim_rect := Rect2(
		Vector2(body_rect.position.x - 6.0, body_rect.position.y - 8.0),
		Vector2(body_rect.size.x + 12.0, 10.0)
	)
	var bottom_rim_rect := Rect2(
		Vector2(body_rect.position.x - 6.0, body_rect.end.y - 2.0),
		Vector2(body_rect.size.x + 12.0, 10.0)
	)
	var spindle_rect := Rect2(
		Vector2(body_rect.position.x + body_rect.size.x * 0.5 - 8.0, top_rim_rect.position.y - 8.0),
		Vector2(16.0, 8.0)
	)
	var seam_y_top := body_rect.position.y + body_rect.size.y * 0.18
	var seam_y_bottom := body_rect.position.y + body_rect.size.y * 0.82
	var mouth_width := 3.0
	var mouth_rect := Rect2(
		Vector2(
			shell_rect.end.x - mouth_width - 1.0 if is_left else shell_rect.position.x + 1.0,
			tape_rect.position.y + 7.0
		),
		Vector2(mouth_width, tape_rect.size.y - 14.0)
	)
	var side_lip_rect := Rect2(
		Vector2(shell_rect.end.x - 8.0 if is_left else shell_rect.position.x, shell_rect.position.y + 16.0),
		Vector2(8.0, shell_rect.size.y - 32.0)
	)
	var shell_highlight_rect := Rect2(
		Vector2(body_rect.position.x + 3.0, body_rect.position.y + 3.0),
		Vector2(4.0, body_rect.size.y - 6.0)
	)
	var shell_shadow_rect := Rect2(
		Vector2(body_rect.end.x - 7.0, body_rect.position.y + 3.0),
		Vector2(4.0, body_rect.size.y - 6.0)
	)
	var gauge_plate_rect := Rect2(
		Vector2(body_rect.position.x + 7.0 if is_left else body_rect.end.x - 16.0, body_rect.position.y + 18.0),
		Vector2(9.0, 34.0)
	)
	var rim_shadow_top := Rect2(
		Vector2(top_rim_rect.position.x + 2.0, top_rim_rect.end.y - 3.0),
		Vector2(top_rim_rect.size.x - 4.0, 2.0)
	)
	var rim_highlight_top := Rect2(
		Vector2(top_rim_rect.position.x + 3.0, top_rim_rect.position.y + 1.0),
		Vector2(top_rim_rect.size.x - 6.0, 2.0)
	)
	var rim_highlight_bottom := Rect2(
		Vector2(bottom_rim_rect.position.x + 3.0, bottom_rim_rect.position.y + 1.0),
		Vector2(bottom_rim_rect.size.x - 6.0, 2.0)
	)
	var spindle_phase := fposmod(feed_rotation * 14.0, 10.0)
	var spindle_band_rect := Rect2(
		Vector2(spindle_rect.position.x + 2.0 + spindle_phase * 0.35, spindle_rect.position.y + 1.0),
		Vector2(3.0, spindle_rect.size.y - 2.0)
	)
	var mouth_recess_rect := Rect2(
		Vector2(
			mouth_rect.end.x if is_left else mouth_rect.position.x - 4.0,
			mouth_rect.position.y + 2.0
		),
		Vector2(4.0, mouth_rect.size.y - 4.0)
	)

	draw_rect(top_rim_rect, fill_color)
	draw_rect(bottom_rim_rect, fill_color)
	draw_rect(spindle_rect, fill_color)
	draw_rect(body_rect, fill_color)
	draw_rect(shell_inner, Color(0.20, 0.20, 0.21))
	draw_rect(shell_highlight_rect, Color(0.28, 0.28, 0.30, 0.55))
	draw_rect(shell_shadow_rect, Color(0.06, 0.06, 0.07, 0.40))
	draw_rect(rim_highlight_top, Color(0.30, 0.30, 0.32, 0.45))
	draw_rect(rim_shadow_top, Color(0.05, 0.05, 0.06, 0.40))
	draw_rect(rim_highlight_bottom, Color(0.24, 0.24, 0.26, 0.35))
	draw_rect(spindle_band_rect, Color(0.08, 0.08, 0.09, 0.45))
	draw_rect(top_rim_rect, BORDER_COLOR, false, 2.0)
	draw_rect(bottom_rim_rect, BORDER_COLOR, false, 2.0)
	draw_rect(spindle_rect, BORDER_DARK, false, 1.0)
	draw_rect(body_rect, BORDER_COLOR, false, 2.0)
	draw_rect(shell_inner, BORDER_DARK, false, 1.0)
	_draw_cartridge_fill_gauge(gauge_plate_rect, _cartridge_fill_bits(is_left))
	draw_line(Vector2(body_rect.position.x + 4.0, seam_y_top), Vector2(body_rect.end.x - 4.0, seam_y_top), Color(0.32, 0.30, 0.27), 1.0)
	draw_line(Vector2(body_rect.position.x + 4.0, seam_y_bottom), Vector2(body_rect.end.x - 4.0, seam_y_bottom), Color(0.32, 0.30, 0.27), 1.0)

	draw_rect(side_lip_rect, Color(0.11, 0.11, 0.12))
	draw_rect(side_lip_rect, BORDER_DARK, false, 1.0)
	draw_rect(mouth_recess_rect, Color(0.03, 0.03, 0.04, 0.80))
	draw_rect(mouth_rect, Color(0.07, 0.07, 0.08))
	draw_rect(mouth_rect, BORDER_DARK, false, 1.0)
	draw_rect(shell_inner.grow(-1.0), Color(0.0, 0.0, 0.0, 0.08), false, 2.0)

func _cartridge_fill_bits(is_left: bool) -> String:
	var normalized := clampf(float(tape_rows.size()) / CARTRIDGE_CAPACITY, 0.0, 1.0)
	var fill_value := normalized if is_left else 1.0 - normalized
	if fill_value >= 0.75:
		return "111"
	if fill_value >= 0.40:
		return "011"
	if fill_value >= 0.10:
		return "001"
	return "000"

func _draw_cartridge_fill_gauge(plate_rect: Rect2, bits: String):
	draw_rect(plate_rect, Color(0.11, 0.11, 0.12))
	draw_rect(plate_rect, BORDER_DARK, false, 1.0)
	for slot_index in range(3):
		var slot_rect := Rect2(
			Vector2(plate_rect.position.x + 2.0, plate_rect.position.y + 3.0 + slot_index * 10.0),
			Vector2(plate_rect.size.x - 4.0, 7.0)
		)
		var active := bits.substr(slot_index, 1) == "1"
		draw_rect(slot_rect, Color(0.08, 0.08, 0.09))
		draw_rect(slot_rect, BORDER_DARK, false, 1.0)
		if active:
			draw_rect(slot_rect.grow(-1.0), BRASS_COLOR)
		else:
			draw_rect(slot_rect.grow(-1.0), Color(0.18, 0.17, 0.15))

func _draw_panel(rect: Rect2, fill_color: Color, border_color: Color, border_width: float = 2.0):
	draw_rect(rect, fill_color)
	draw_rect(rect, border_color, false, border_width)

func _make_stylebox(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	style.shadow_size = 2
	return style

func _rect_in_root(control: Control) -> Rect2:
	return Rect2(control.global_position - global_position, control.size)

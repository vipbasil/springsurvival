extends Control

const PunchEncodingData = preload("res://scripts/data/PunchEncoding.gd")
const FRAME_COLOR := Color(0.10, 0.11, 0.13)
const PANEL_COLOR := Color(0.15, 0.16, 0.18)
const PANEL_ALT_COLOR := Color(0.18, 0.18, 0.16)
const BORDER_COLOR := Color(0.47, 0.40, 0.24)
const ACCENT_COLOR := Color(0.80, 0.66, 0.27)
const TAPE_COLOR := Color(0.82, 0.75, 0.56)
const TAPE_SHADOW := Color(0.70, 0.63, 0.44)
const HOLE_COLOR := Color(0.08, 0.08, 0.09)
const PREVIEW_COLOR := Color(0.30, 0.50, 0.68, 0.35)

@onready var title_label: Label = $Margin/RootVBox/Header/TitleLabel
@onready var subtitle_label: Label = $Margin/RootVBox/Header/SubtitleLabel
@onready var current_row_preview: Label = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/CurrentRowPreview
@onready var punch_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/PunchButton
@onready var advance_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/RowActions/AdvanceButton
@onready var clear_row_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/RowActions/ClearRowButton
@onready var rewind_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection/ControlsMargin/ControlsGrid/RewindButton
@onready var clear_tape_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection/ControlsMargin/ControlsGrid/ClearTapeButton
@onready var load_to_automaton_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection/ControlsMargin/ControlsGrid/LoadToAutomatonButton
@onready var decode_preview_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection/ControlsMargin/ControlsGrid/DecodePreviewButton
@onready var example_tape_button: Button = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection/ControlsMargin/ControlsGrid/ExampleTapeButton
@onready var tape_rows_list: ItemList = $Margin/RootVBox/MachineBody/OutputSection/OutputMargin/OutputVBox/TapeRowsList
@onready var decoded_instructions_label: RichTextLabel = $Margin/RootVBox/MachineBody/OutputSection/OutputMargin/OutputVBox/DecodedInstructionsLabel
@onready var status_label: Label = $Margin/RootVBox/MachineBody/OutputSection/OutputMargin/OutputVBox/StatusLabel
@onready var frame: Control = $Frame
@onready var input_section: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection
@onready var mechanical_section: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection
@onready var tape_control_section: Control = $Margin/RootVBox/MachineBody/LeftColumn/TapeControlSection
@onready var output_section: Control = $Margin/RootVBox/MachineBody/OutputSection
@onready var tape_viewport: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/TapeViewport
@onready var tape_strip: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/TapeViewport/TapeStrip
@onready var punch_head: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/PunchHead
@onready var feed_wheel_left: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/FeedWheelLeft
@onready var feed_wheel_right: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/FeedWheelRight
@onready var feed_ratchet: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/FeedRatchet
@onready var optional_mask_drum: Control = $Margin/RootVBox/MachineBody/LeftColumn/TopRow/MechanicalSection/OptionalMaskDrum

@onready var channel_buttons: Array[Button] = [
	$Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/ChannelButtons/ChannelButton0,
	$Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/ChannelButtons/ChannelButton1,
	$Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/ChannelButtons/ChannelButton2,
	$Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/ChannelButtons/ChannelButton3,
	$Margin/RootVBox/MachineBody/LeftColumn/TopRow/InputSection/InputMargin/InputVBox/ChannelButtons/ChannelButton4,
]

var current_row_state := [false, false, false, false, false]
var tape_rows := PackedStringArray()
var tape_cursor := 0
var punch_head_offset := 0.0
var tape_shift := 0.0
var feed_rotation := 0.0
var mask_drum_rotation := 0.0

func _ready():
	custom_minimum_size = Vector2(760, 540)
	title_label.text = "Punch Machine"
	subtitle_label.text = "5-channel bench punch for automaton tape"
	_wire_channel_buttons()
	_wire_controls()
	tape_rows_list.allow_reselect = true
	_update_current_row_preview()
	_refresh_output()
	_set_status("Ready")
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw():
	_draw_panel(_rect_in_root(frame), FRAME_COLOR, BORDER_COLOR, 3.0)
	_draw_panel(_rect_in_root(input_section), PANEL_COLOR, BORDER_COLOR)
	_draw_panel(_rect_in_root(mechanical_section), PANEL_ALT_COLOR, BORDER_COLOR)
	_draw_panel(_rect_in_root(tape_control_section), PANEL_COLOR, BORDER_COLOR)
	_draw_panel(_rect_in_root(output_section), PANEL_COLOR, BORDER_COLOR)
	_draw_mechanical_view()
	_draw_mask_drum()

func _wire_channel_buttons():
	for index in range(channel_buttons.size()):
		var button = channel_buttons[index]
		button.toggle_mode = true
		button.toggled.connect(_on_channel_toggled.bind(index))

func _wire_controls():
	punch_button.pressed.connect(_on_punch_pressed)
	advance_button.pressed.connect(_on_advance_pressed)
	clear_row_button.pressed.connect(_on_clear_row_pressed)
	rewind_button.pressed.connect(_on_rewind_pressed)
	clear_tape_button.pressed.connect(_on_clear_tape_pressed)
	load_to_automaton_button.pressed.connect(_on_load_to_automaton_pressed)
	decode_preview_button.pressed.connect(_on_decode_preview_pressed)
	example_tape_button.pressed.connect(_on_example_tape_pressed)
	tape_rows_list.item_selected.connect(_on_row_selected)

func _on_channel_toggled(pressed: bool, index: int):
	current_row_state[index] = pressed
	_update_current_row_preview()

func _on_punch_pressed():
	var row_bits := _current_row_bits()
	tape_rows.append(row_bits)
	tape_cursor = tape_rows.size()
	_animate_punch()
	_animate_feed(-20.0, 0.35)
	_refresh_output()
	EventBus.tape_row_punched.emit(row_bits)
	EventBus.log_message.emit("PunchMachine: row punched " + row_bits)
	EventBus.log_message.emit("PunchMachine: tape advanced")
	_set_status("Punched row " + row_bits)

func _on_advance_pressed():
	if tape_rows.is_empty():
		_set_status("No tape to advance")
		return
	tape_cursor = min(tape_cursor + 1, tape_rows.size())
	_animate_feed(-18.0, 0.22)
	_refresh_output()
	EventBus.log_message.emit("PunchMachine: tape advanced")
	_set_status("Tape advanced to row " + str(tape_cursor))

func _on_clear_row_pressed():
	for index in range(current_row_state.size()):
		current_row_state[index] = false
		channel_buttons[index].button_pressed = false
	_update_current_row_preview()
	EventBus.log_message.emit("PunchMachine: current row cleared")
	_set_status("Current row mask cleared")

func _on_rewind_pressed():
	tape_cursor = 0
	_animate_feed(22.0, -0.30)
	_refresh_output()
	EventBus.log_message.emit("PunchMachine: tape rewound")
	_set_status("Tape rewound")

func _on_clear_tape_pressed():
	tape_rows = PackedStringArray()
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

	var instruction_lines: Array = decode_result["decoded_lines"]
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
	var decoded_lines: Array = decode_result["decoded_lines"]
	EventBus.log_message.emit("PunchMachine: decoded " + str(decoded_lines.size()) + " rows")
	_set_status("Decoded " + str(decoded_lines.size()) + " rows")

func _on_example_tape_pressed():
	tape_rows = PackedStringArray()
	for row_bits in PunchEncodingData.EXAMPLE_ROWS:
		tape_rows.append(row_bits)
	tape_cursor = tape_rows.size()
	_refresh_output()
	EventBus.log_message.emit("PunchMachine: example tape loaded")
	_set_status("Example tape loaded")

func _on_row_selected(index: int):
	tape_cursor = clamp(index, 0, tape_rows.size())
	_refresh_output()
	_set_status("Inspecting row " + str(index))

func _current_row_bits() -> String:
	var bits := ""
	for pressed in current_row_state:
		bits += "1" if pressed else "0"
	return bits

func _formatted_bits(bits: String) -> String:
	var pieces := PackedStringArray()
	for index in range(bits.length()):
		pieces.append(bits.substr(index, 1))
	return "[" + " ".join(pieces) + "]"

func _update_current_row_preview():
	var bits := _current_row_bits()
	current_row_preview.text = "Current row " + _formatted_bits(bits) + "  " + bits
	queue_redraw()

func _refresh_output() -> Dictionary:
	var decode_result: Dictionary = PunchEncodingData.decode_rows(tape_rows)
	var decoded_lines: Array = decode_result["decoded_lines"]
	var unknown_rows: Array = decode_result["unknown_rows"]

	tape_rows_list.clear()
	for index in range(tape_rows.size()):
		var row_bits: String = tape_rows[index]
		var mnemonic: String = str(decoded_lines[index])
		tape_rows_list.add_item("%02d  %s  %s" % [index, row_bits, mnemonic])

	tape_rows_list.deselect_all()
	if tape_cursor < tape_rows_list.get_item_count():
		tape_rows_list.select(tape_cursor)

	decoded_instructions_label.clear()
	if decoded_lines.is_empty():
		decoded_instructions_label.append_text("Decode preview:\n(no tape rows punched)")
	else:
		var preview_lines := PackedStringArray()
		for index in range(decoded_lines.size()):
			preview_lines.append("%02d  %s" % [index, str(decoded_lines[index])])
		decoded_instructions_label.append_text("Decode preview:\n" + "\n".join(preview_lines))
		if not unknown_rows.is_empty():
			decoded_instructions_label.append_text("\n\nUnknown rows: " + _join_with_separator(unknown_rows, ", "))

	EventBus.decode_preview_generated.emit(decoded_lines, unknown_rows)
	queue_redraw()
	return decode_result

func _set_status(status: String):
	status_label.text = "Status: " + status
	EventBus.machine_status_changed.emit(status)

func _join_with_separator(values: Array, separator: String) -> String:
	var strings := PackedStringArray()
	for value in values:
		strings.append(str(value))
	return separator.join(strings)

func _animate_punch():
	var tween = create_tween()
	tween.tween_method(Callable(self, "_set_punch_head_offset"), 0.0, 18.0, 0.08)
	tween.tween_method(Callable(self, "_set_punch_head_offset"), 18.0, 0.0, 0.12)

func _animate_feed(shift_amount: float, wheel_delta: float):
	var rotation_start := feed_rotation
	var mask_start := mask_drum_rotation
	var tween = create_tween()
	tween.tween_method(Callable(self, "_set_tape_shift"), shift_amount, 0.0, 0.18)
	tween.parallel().tween_method(Callable(self, "_set_feed_rotation"), rotation_start, rotation_start + wheel_delta, 0.18)
	tween.parallel().tween_method(Callable(self, "_set_mask_drum_rotation"), mask_start, mask_start + wheel_delta * 0.75, 0.18)

func _set_punch_head_offset(value: float):
	punch_head_offset = value
	queue_redraw()

func _set_tape_shift(value: float):
	tape_shift = value
	queue_redraw()

func _set_feed_rotation(value: float):
	feed_rotation = value
	queue_redraw()

func _set_mask_drum_rotation(value: float):
	mask_drum_rotation = value
	queue_redraw()

func _draw_panel(rect: Rect2, fill_color: Color, border_color: Color, border_width: float = 2.0):
	draw_rect(rect, fill_color)
	draw_rect(rect, border_color, false, border_width)

func _draw_mechanical_view():
	var viewport_rect := _rect_in_root(tape_viewport).grow(-12.0)
	var strip_rect := _rect_in_root(tape_strip).grow(-6.0)
	var head_rect := _rect_in_root(punch_head)
	var reference_y := viewport_rect.position.y + viewport_rect.size.y * 0.56
	var row_height := 22.0
	var strip_left := strip_rect.position.x
	var strip_width := strip_rect.size.x

	_draw_panel(viewport_rect, Color(0.08, 0.09, 0.10), BORDER_COLOR)
	draw_rect(strip_rect, TAPE_SHADOW)
	draw_rect(Rect2(strip_rect.position + Vector2(4, 0), Vector2(strip_rect.size.x - 8, strip_rect.size.y)), TAPE_COLOR)

	var rail_top := Vector2(strip_left - 18.0, viewport_rect.position.y + 10.0)
	var rail_bottom := Vector2(strip_left - 18.0, viewport_rect.position.y + viewport_rect.size.y - 10.0)
	var rail_top_right := Vector2(strip_left + strip_width + 18.0, rail_top.y)
	var rail_bottom_right := Vector2(strip_left + strip_width + 18.0, rail_bottom.y)
	draw_line(rail_top, rail_bottom, BORDER_COLOR, 4.0)
	draw_line(rail_top_right, rail_bottom_right, BORDER_COLOR, 4.0)

	for row_index in range(tape_rows.size()):
		var row_bits: String = tape_rows[row_index]
		var row_y := reference_y + (row_index - tape_cursor) * row_height + tape_shift
		var row_rect := Rect2(Vector2(strip_left + 6.0, row_y - row_height * 0.5), Vector2(strip_width - 12.0, row_height - 2.0))
		if row_rect.position.y + row_rect.size.y < viewport_rect.position.y or row_rect.position.y > viewport_rect.position.y + viewport_rect.size.y:
			continue
		draw_rect(row_rect, TAPE_COLOR.lightened(0.03))
		draw_rect(row_rect, TAPE_SHADOW, false, 1.0)
		_draw_tape_row(row_rect, row_bits, false)

	var current_row_rect := Rect2(Vector2(strip_left + 6.0, reference_y - row_height * 0.5), Vector2(strip_width - 12.0, row_height - 2.0))
	draw_rect(current_row_rect, PREVIEW_COLOR)
	draw_rect(current_row_rect, ACCENT_COLOR, false, 1.0)
	_draw_tape_row(current_row_rect, _current_row_bits(), true)

	var actual_head_rect := head_rect
	actual_head_rect.position.y += punch_head_offset
	draw_rect(actual_head_rect, Color(0.48, 0.43, 0.34))
	draw_rect(actual_head_rect.grow(-10.0), Color(0.28, 0.27, 0.26))
	draw_line(
		Vector2(actual_head_rect.position.x + actual_head_rect.size.x * 0.5, actual_head_rect.position.y + actual_head_rect.size.y),
		Vector2(actual_head_rect.position.x + actual_head_rect.size.x * 0.5, reference_y - row_height * 0.6),
		Color(0.60, 0.56, 0.46),
		5.0
	)

	_draw_wheel(feed_wheel_left, feed_rotation)
	_draw_wheel(feed_wheel_right, -feed_rotation)
	_draw_ratchet()

func _draw_tape_row(row_rect: Rect2, bits: String, is_preview: bool):
	var margin := 14.0
	var channel_spacing := (row_rect.size.x - margin * 2.0) / 4.0
	var center_y := row_rect.position.y + row_rect.size.y * 0.5
	for channel_index in range(5):
		var center_x := row_rect.position.x + margin + channel_spacing * channel_index
		var bit_is_on := bits.substr(channel_index, 1) == "1"
		if bit_is_on:
			draw_circle(Vector2(center_x, center_y), 6.5, Color(0.94, 0.86, 0.64, 0.65) if is_preview else Color(0.20, 0.18, 0.15))
			draw_circle(Vector2(center_x, center_y), 4.0, HOLE_COLOR if not is_preview else ACCENT_COLOR)
		else:
			draw_circle(Vector2(center_x, center_y), 2.0, Color(0.44, 0.40, 0.33))

func _draw_wheel(node: Control, rotation_offset: float):
	var rect: Rect2 = _rect_in_root(node)
	var center: Vector2 = rect.position + rect.size * 0.5
	var radius: float = minf(rect.size.x, rect.size.y) * 0.45
	draw_circle(center, radius, Color(0.18, 0.17, 0.15))
	draw_circle(center, radius, BORDER_COLOR, false, 2.0)
	draw_circle(center, radius * 0.35, Color(0.34, 0.30, 0.22))
	for spoke_index in range(6):
		var angle: float = rotation_offset + spoke_index * PI / 3.0
		var spoke: Vector2 = Vector2(cos(angle), sin(angle)) * radius * 0.82
		draw_line(center, center + spoke, ACCENT_COLOR, 2.0)

func _draw_ratchet():
	var rect := _rect_in_root(feed_ratchet)
	_draw_panel(rect, Color(0.16, 0.15, 0.13), BORDER_COLOR)
	var tooth_width := rect.size.x / 6.0
	for tooth_index in range(6):
		var x := rect.position.x + tooth_index * tooth_width
		draw_line(Vector2(x, rect.position.y + rect.size.y), Vector2(x + tooth_width * 0.5, rect.position.y), ACCENT_COLOR, 1.5)

func _draw_mask_drum():
	var rect: Rect2 = _rect_in_root(optional_mask_drum)
	_draw_panel(rect, Color(0.12, 0.12, 0.11), BORDER_COLOR)
	var center: Vector2 = rect.position + rect.size * 0.5
	var radius: float = minf(rect.size.x, rect.size.y) * 0.34
	draw_circle(center, radius, Color(0.20, 0.18, 0.14))
	draw_circle(center, radius, BORDER_COLOR, false, 2.0)

	for channel_index in range(5):
		var angle: float = mask_drum_rotation + PI * 0.78 + channel_index * 0.52
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * radius * 0.72
		var marker_color := ACCENT_COLOR if current_row_state[channel_index] else Color(0.38, 0.34, 0.25)
		draw_circle(center + offset, 5.0, marker_color)

func _rect_in_root(control: Control) -> Rect2:
	return Rect2(control.global_position - global_position, control.size)

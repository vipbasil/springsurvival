extends Control

const PROGRAMMING_SCENE_PATH := "res://scenes/main/ProgrammingMain.tscn"
const MACHINE_CAPACITY := 48.0
const OUTSIDE_STEP_INTERVAL := 0.55

const WALL_DARK := Color(0.08, 0.09, 0.11)
const WALL_MID := Color(0.11, 0.12, 0.15)
const WALL_BAND := Color(0.14, 0.15, 0.18)
const FLOOR := Color(0.20, 0.18, 0.16)
const FLOOR_SEAM := Color(0.28, 0.24, 0.20)
const PANEL_FILL := Color(0.13, 0.14, 0.16)
const PANEL_INNER := Color(0.16, 0.17, 0.19)
const PANEL_BORDER := Color(0.47, 0.40, 0.24)
const STEEL := Color(0.20, 0.21, 0.24)
const STEEL_LIGHT := Color(0.30, 0.31, 0.35)
const STEEL_DARK := Color(0.10, 0.10, 0.11)
const ACCENT := Color(0.80, 0.66, 0.27)
const ACCENT_DIM := Color(0.53, 0.43, 0.18)
const TAPE := Color(0.84, 0.78, 0.60)
const TAPE_SHADE := Color(0.68, 0.61, 0.42)
const TAPE_HOLE := Color(0.20, 0.18, 0.13)
const TEXT := Color(0.92, 0.89, 0.82)
const GRID := Color(0.32, 0.34, 0.38, 0.85)
const TRAIL := Color(0.78, 0.62, 0.24, 0.85)
const SHADOW := Color(0.0, 0.0, 0.0, 0.24)
const DISK_OFF := Color(0.15, 0.16, 0.18)
const DISK_ON := Color(0.82, 0.67, 0.28)
const DISK_ROUTE := Color(0.39, 0.34, 0.25)
const BLANK_CARTRIDGE_DISPLAY_COUNT := 4
const DRAG_THRESHOLD := 6.0
const BOT_ROUTE_COLORS := [
	Color(0.82, 0.67, 0.28),
	Color(0.60, 0.76, 0.63),
]
const BOT_PREDICT_COLORS := [
	Color(0.82, 0.67, 0.28, 0.28),
	Color(0.60, 0.76, 0.63, 0.28),
]

@onready var machine_region: Button = $MachineRegion
@onready var shelf_region: Control = $ShelfRegion
@onready var cabinet_region: Control = $CabinetRegion
@onready var map_region: Control = $MapRegion
@onready var background: ColorRect = $Background
@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var shelf_info_label: Label = $ShelfRegion/InfoLabel
@onready var cabinet_info_label: Label = $CabinetRegion/InfoLabel
@onready var map_info_label: Label = $MapRegion/InfoLabel

var _machine_hovered := false
var _outside_step_cooldown := 0.0
var _selected_bot_index := 0
var _selected_power_slot_index := -1
var _drag_candidate := {}
var _active_drag := {}
var _drag_start_root := Vector2.ZERO
var _drag_mouse_root := Vector2.ZERO
var _current_cursor_shape := Control.CURSOR_ARROW

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	background.visible = false
	title_label.visible = false
	subtitle_label.visible = false
	machine_region.pressed.connect(_open_programming_scene)
	machine_region.mouse_entered.connect(_on_machine_hovered.bind(true))
	machine_region.mouse_exited.connect(_on_machine_hovered.bind(false))
	machine_region.text = ""
	machine_region.flat = true
	machine_region.focus_mode = Control.FOCUS_NONE
	machine_region.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		machine_region.add_theme_stylebox_override(style_name, empty_style)
	shelf_region.gui_input.connect(_on_shelf_gui_input)
	cabinet_region.gui_input.connect(_on_cabinet_gui_input)
	map_region.gui_input.connect(_on_map_gui_input)

	for title_path in ["MachineRegion/RegionTitle", "ShelfRegion/RegionTitle", "CabinetRegion/RegionTitle", "MapRegion/RegionTitle"]:
		var title_label: Label = get_node(title_path)
		title_label.visible = false

	for info_label in [shelf_info_label, cabinet_info_label, map_info_label]:
		info_label.visible = false
		info_label.add_theme_color_override("font_color", TEXT)
		info_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.5))
		info_label.add_theme_constant_override("shadow_offset_x", 1)
		info_label.add_theme_constant_override("shadow_offset_y", 1)

	EventBus.automaton_moved.connect(_refresh_labels)
	EventBus.status_changed.connect(_refresh_labels)
	EventBus.ptr_changed.connect(_refresh_labels)
	EventBus.acc_changed.connect(_refresh_labels)
	EventBus.energy_changed.connect(_refresh_labels)
	EventBus.log_message.connect(_on_log_message)
	EventBus.cartridges_changed.connect(_refresh_labels)
	EventBus.cartridge_selected.connect(_on_cartridge_selected)
	EventBus.bot_loadouts_changed.connect(_refresh_labels)
	EventBus.outside_world_changed.connect(_refresh_labels)
	_refresh_labels()
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_set_cursor_shape(Control.CURSOR_ARROW)

func _process(delta: float):
	_outside_step_cooldown -= delta
	if _outside_step_cooldown > 0.0:
		return
	_outside_step_cooldown = OUTSIDE_STEP_INTERVAL
	GameState.tick_active_bots()

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		_drag_mouse_root = motion.position
		if not _drag_candidate.is_empty() and _active_drag.is_empty() and _drag_start_root.distance_to(_drag_mouse_root) > DRAG_THRESHOLD:
			_active_drag = _drag_candidate.duplicate(true)
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()
		elif not _active_drag.is_empty():
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()
		else:
			_update_cursor_state(_drag_mouse_root)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var mouse_button: InputEventMouseButton = event
		_drag_mouse_root = mouse_button.position
		if not _active_drag.is_empty():
			_complete_drag(_drag_mouse_root)
			_active_drag.clear()
			_drag_candidate.clear()
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()
		elif not _drag_candidate.is_empty():
			_complete_click_candidate(_drag_candidate)
			_drag_candidate.clear()
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()

func _draw():
	_draw_room_shell()
	_draw_machine_bay(_rect_in_root(machine_region))
	_draw_shelf_bay(_rect_in_root(shelf_region))
	_draw_cabinet_bay(_rect_in_root(cabinet_region))
	_draw_map_bay(_rect_in_root(map_region))
	_draw_drag_overlay()

func _open_programming_scene():
	var blocker := _get_programming_bench_blocker()
	if not blocker.is_empty():
		EventBus.log_message.emit(blocker)
		return
	get_tree().change_scene_to_file(PROGRAMMING_SCENE_PATH)

func _refresh_labels(_value = null):
	var loaded_rows: int = GameState.tape_program.size()
	var normalized_fill := clampf(float(loaded_rows) / MACHINE_CAPACITY, 0.0, 1.0)
	shelf_info_label.text = "Programmed: %d rows\nBlank stock: %d rows\nFill: %d%%" % [
		loaded_rows,
		max(0, int(MACHINE_CAPACITY) - loaded_rows),
		int(round(normalized_fill * 100.0))
	]
	cabinet_info_label.text = "Cabinet A: active\nStatus: %s\nFacing: %s\nEnergy: %d" % [
		GameState.automaton_status,
		GameState.automaton_facing,
		GameState.automaton_energy
	]
	map_info_label.text = "Route table\nPTR %d / ACC %d\nPos (%d,%d)" % [
		GameState.automaton_ptr,
		GameState.automaton_acc,
		int(GameState.automaton_position.x),
		int(GameState.automaton_position.y)
	]
	queue_redraw()

func _on_log_message(message: String):
	queue_redraw()

func _get_programming_bench_blocker() -> String:
	if not GameState.has_blank_cartridge_available():
		return "No blank cartridge available"
	if not GameState.has_free_programmed_slot():
		return "No free programmed cartridge slot available"
	return ""

func _on_cartridge_selected(_cartridge_id: String):
	queue_redraw()

func _on_machine_hovered(is_hovered: bool):
	_machine_hovered = is_hovered
	queue_redraw()

func _on_shelf_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		var root_point := shelf_region.global_position - global_position + motion.position
		_update_cursor_state(root_point)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_event: InputEventMouseButton = event
		var root_point := shelf_region.global_position - global_position + mouse_event.position
		var slot_data := _get_shelf_slot_data(_rect_in_root(shelf_region).grow(-28.0))
		for slot in slot_data["programmed_slots"]:
			if Rect2(slot["rect"]).has_point(root_point):
				var cartridge: Dictionary = slot["cartridge"]
				var cartridge_id := str(cartridge.get("id", ""))
				if not cartridge_id.is_empty():
					_drag_start_root = root_point
					_drag_candidate = {
						"kind": "cartridge",
						"source": "shelf",
						"cartridge_id": cartridge_id,
					}
					_selected_power_slot_index = -1
					GameState.select_programmed_cartridge(cartridge_id)
					return
		if Rect2(slot_data["recycle_hotspot"]).has_point(root_point):
			var selected_cartridge := GameState.get_selected_cartridge()
			if selected_cartridge.is_empty():
				EventBus.log_message.emit("Select a shelf cartridge to recycle it into a blank cartridge")
			elif GameState.recycle_programmed_cartridge(str(selected_cartridge.get("id", ""))):
				EventBus.log_message.emit("Cartridge recycled into blank stock")
			else:
				EventBus.log_message.emit("No empty blank slot available for recycling")
			queue_redraw()
			return

func _on_cabinet_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		var root_point := cabinet_region.global_position - global_position + motion.position
		_update_cursor_state(root_point)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_event: InputEventMouseButton = event
		var root_point := cabinet_region.global_position - global_position + mouse_event.position
		var slots := _get_cabinet_slot_data(_rect_in_root(cabinet_region).grow(-28.0))
		for slot in slots:
			var bot_index: int = int(slot["index"])
			var available_in_workshop := bool(slot["available_in_workshop"])
			var body_hotspot: Rect2 = slot["body_hotspot"]
			var tape_badge_rect: Rect2 = slot["tape_badge_rect"]
			var play_hotspot: Rect2 = slot["play_hotspot"]
			if play_hotspot.has_point(root_point):
				_selected_bot_index = bot_index
				if GameState.can_recover_bot(bot_index):
					if not GameState.recover_bot(bot_index):
						EventBus.log_message.emit("Recovery failed")
					return
				var blocker: String = GameState.get_bot_launch_blocker(bot_index)
				if blocker.is_empty() and GameState.launch_bot(bot_index):
					EventBus.log_message.emit("%s launched" % _bot_display_name(bot_index))
				else:
					EventBus.log_message.emit("%s" % blocker)
				return
			if tape_badge_rect.has_point(root_point):
				_selected_bot_index = bot_index
				if not available_in_workshop:
					EventBus.log_message.emit("%s is outside" % _bot_display_name(bot_index))
					return
				var loaded_cartridge: Dictionary = slot["loaded_cartridge"]
				if not loaded_cartridge.is_empty():
					_drag_start_root = root_point
					_drag_candidate = {
						"kind": "cartridge",
						"source": "bot",
						"bot_index": bot_index,
						"cartridge_id": str(loaded_cartridge.get("id", "")),
					}
				return
			if not body_hotspot.has_point(root_point):
				continue
			_selected_bot_index = bot_index
			EventBus.log_message.emit("%s selected" % _bot_display_name(bot_index))
			queue_redraw()
			return

func _on_map_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		var root_point := map_region.global_position - global_position + motion.position
		_update_cursor_state(root_point)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_event: InputEventMouseButton = event
		var root_point := map_region.global_position - global_position + mouse_event.position
		var stack_data := _get_power_stack_data(_rect_in_root(map_region))
		var top_card_rect: Rect2 = stack_data["top_card_rect"]
		var stack_zone: Rect2 = stack_data["stack_zone"]
		var top_slot_index := int(stack_data["top_slot_index"])
		if top_slot_index != -1 and top_card_rect.has_point(root_point):
			_drag_start_root = root_point
			_drag_candidate = {
				"kind": "power",
				"source": "shelf",
				"slot_index": top_slot_index,
			}
			_selected_power_slot_index = top_slot_index
			return
		if stack_zone.has_point(root_point):
			var empty_slot_index := _get_first_empty_power_slot_index()
			if empty_slot_index != -1:
				_drag_start_root = root_point
				_drag_candidate = {
					"kind": "empty_power_slot",
					"source": "power_stack",
					"slot_index": empty_slot_index,
				}
				_selected_power_slot_index = empty_slot_index

func _complete_click_candidate(candidate: Dictionary):
	match str(candidate.get("kind", "")):
		"power":
			if str(candidate.get("source", "")) != "shelf":
				return
			var slot_index := int(candidate.get("slot_index", -1))
			var power_unit := GameState.get_power_unit_in_slot(slot_index)
			if power_unit.is_empty():
				return
			_selected_power_slot_index = slot_index
		"empty_power_slot":
			var slot_index := int(candidate.get("slot_index", -1))
			if GameState.create_power_unit_in_slot(slot_index):
				EventBus.log_message.emit("Power unit created: %d/%d" % [GameState.BOT_POWER_CAPACITY, GameState.BOT_POWER_CAPACITY])

func _complete_drag(drop_root: Vector2):
	match str(_active_drag.get("kind", "")):
		"cartridge":
			_complete_cartridge_drag(drop_root)
		"power":
			_complete_power_drag(drop_root)

func _update_cursor_state(root_point: Vector2):
	_set_cursor_shape(_cursor_shape_for_point(root_point))

func _set_cursor_shape(shape: int):
	if _current_cursor_shape == shape:
		return
	_current_cursor_shape = shape
	mouse_default_cursor_shape = shape
	shelf_region.mouse_default_cursor_shape = shape
	cabinet_region.mouse_default_cursor_shape = shape
	machine_region.mouse_default_cursor_shape = shape
	map_region.mouse_default_cursor_shape = shape
	Input.set_default_cursor_shape(shape)

func _cursor_shape_for_point(root_point: Vector2) -> int:
	if not _active_drag.is_empty():
		return Control.CURSOR_CAN_DROP if _is_valid_drop_target(root_point) else Control.CURSOR_DRAG

	var shelf_body := _rect_in_root(shelf_region).grow(-28.0)
	var shelf_slots := _get_shelf_slot_data(shelf_body)
	for slot in shelf_slots["programmed_slots"]:
		if Rect2(slot["rect"]).has_point(root_point) and not Dictionary(slot["cartridge"]).is_empty():
			return Control.CURSOR_POINTING_HAND
	var power_stack_data := _get_power_stack_data(_rect_in_root(map_region))
	if int(power_stack_data["top_slot_index"]) != -1 and Rect2(power_stack_data["top_card_rect"]).has_point(root_point):
		return Control.CURSOR_POINTING_HAND
	if Rect2(power_stack_data["stack_zone"]).has_point(root_point) and _get_first_empty_power_slot_index() != -1:
		return Control.CURSOR_POINTING_HAND

	var cabinet_slots := _get_cabinet_slot_data(_rect_in_root(cabinet_region).grow(-28.0))
	for slot in cabinet_slots:
		if Rect2(slot["tape_badge_rect"]).has_point(root_point) and not Dictionary(slot["loaded_cartridge"]).is_empty():
			return Control.CURSOR_POINTING_HAND
		if Rect2(slot["body_hotspot"]).has_point(root_point):
			return Control.CURSOR_POINTING_HAND

	return Control.CURSOR_ARROW

func _is_valid_drop_target(root_point: Vector2) -> bool:
	match str(_active_drag.get("kind", "")):
		"cartridge":
			return _get_drop_cabinet_index(root_point) != -1 or _is_point_in_shelf_region(root_point) or _is_point_in_recycle_zone(root_point)
		"power":
			return _get_drop_cabinet_index(root_point) != -1
	return false

func _complete_cartridge_drag(drop_root: Vector2):
	var cartridge_id := str(_active_drag.get("cartridge_id", ""))
	if cartridge_id.is_empty():
		return
	var target_bot := _get_drop_cabinet_index(drop_root)
	if target_bot != -1:
		_selected_bot_index = target_bot
		if GameState.load_cartridge_into_bot(target_bot, cartridge_id):
			EventBus.log_message.emit("%s loaded" % _bot_display_name(target_bot))
			return
	if _is_point_in_shelf_region(drop_root) and str(_active_drag.get("source", "")) == "bot":
		var source_bot := int(_active_drag.get("bot_index", -1))
		if GameState.unload_bot_cartridge(source_bot):
			EventBus.log_message.emit("%s unloaded" % _bot_display_name(source_bot))
			return
	if _is_point_in_recycle_zone(drop_root) and str(_active_drag.get("source", "")) == "shelf":
		if GameState.recycle_programmed_cartridge(cartridge_id):
			EventBus.log_message.emit("Cartridge recycled into blank stock")

func _complete_power_drag(drop_root: Vector2):
	var target_bot := _get_drop_cabinet_index(drop_root)
	var source := str(_active_drag.get("source", ""))
	if target_bot != -1:
		_selected_bot_index = target_bot
		if source == "shelf":
			var slot_index := int(_active_drag.get("slot_index", -1))
			if GameState.install_power_unit_from_slot(target_bot, slot_index) >= 0:
				_selected_power_slot_index = -1
				EventBus.log_message.emit("%s power added" % _bot_display_name(target_bot))
				return

func _get_drop_cabinet_index(root_point: Vector2) -> int:
	var slots := _get_cabinet_slot_data(_rect_in_root(cabinet_region).grow(-28.0))
	for slot in slots:
		if Rect2(slot["rect"]).has_point(root_point) and bool(slot["available_in_workshop"]):
			return int(slot["index"])
	return -1

func _is_point_in_shelf_region(root_point: Vector2) -> bool:
	return _rect_in_root(shelf_region).has_point(root_point)

func _is_point_in_recycle_zone(root_point: Vector2) -> bool:
	var shelf_body := _rect_in_root(shelf_region).grow(-28.0)
	var frame := shelf_body.grow(-10.0)
	var body := frame.grow(-18.0)
	var recycle_rect := Rect2(Vector2(body.position.x + 154.0, body.position.y + 202.0), Vector2(54.0, 22.0))
	return recycle_rect.has_point(root_point)

func _draw_room_shell():
	var wall_rect := Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.72))
	var floor_rect := Rect2(Vector2(0.0, wall_rect.end.y), Vector2(size.x, size.y - wall_rect.end.y))
	draw_rect(wall_rect, WALL_DARK)
	draw_rect(Rect2(Vector2(0.0, 96.0), Vector2(size.x, wall_rect.size.y - 96.0)), WALL_MID)
	draw_rect(Rect2(Vector2(0.0, wall_rect.end.y - 36.0), Vector2(size.x, 36.0)), WALL_BAND)
	draw_rect(floor_rect, FLOOR)
	for seam_index in range(12):
		var seam_x := floor_rect.position.x + seam_index * (floor_rect.size.x / 11.0)
		draw_line(
			Vector2(seam_x, floor_rect.position.y + 8.0),
			Vector2(seam_x - 18.0, floor_rect.end.y),
			FLOOR_SEAM,
			2.0
		)

func _draw_machine_bay(rect: Rect2):
	var frame := _draw_region_frame(rect, "Programming Bench")
	var body := frame.grow(-18.0)
	var bench_rect := Rect2(Vector2(body.position.x + 18.0, body.end.y - 54.0), Vector2(body.size.x - 36.0, 26.0))
	var machine_rect := Rect2(Vector2(body.position.x + 30.0, body.position.y + 56.0), Vector2(body.size.x - 60.0, 126.0))
	var deck_points := PackedVector2Array([
		Vector2(body.position.x + 52.0, body.position.y + 176.0),
		Vector2(body.end.x - 52.0, body.position.y + 176.0),
		Vector2(body.end.x - 18.0, body.position.y + 228.0),
		Vector2(body.position.x + 18.0, body.position.y + 228.0),
	])
	var tape_rect := Rect2(Vector2(machine_rect.position.x + 64.0, machine_rect.position.y + 42.0), Vector2(machine_rect.size.x - 128.0, 28.0))
	var cartridge_width := 18.0
	var left_cartridge := Rect2(Vector2(tape_rect.position.x - cartridge_width - 18.0, tape_rect.position.y - 9.0), Vector2(cartridge_width, 46.0))
	var right_cartridge := Rect2(Vector2(tape_rect.end.x + 18.0, tape_rect.position.y - 9.0), Vector2(cartridge_width, 46.0))
	var left_roller := Rect2(Vector2(tape_rect.position.x - 10.0, tape_rect.position.y - 5.0), Vector2(8.0, tape_rect.size.y + 10.0))
	var right_roller := Rect2(Vector2(tape_rect.end.x + 2.0, tape_rect.position.y - 5.0), Vector2(8.0, tape_rect.size.y + 10.0))
	var punch_rect := Rect2(Vector2(tape_rect.position.x + tape_rect.size.x * 0.5 - 14.0, tape_rect.position.y - 18.0), Vector2(28.0, 62.0))
	var linkage_rect := Rect2(Vector2(machine_rect.position.x + 34.0, tape_rect.position.y - 18.0), Vector2(machine_rect.size.x - 68.0, 4.0))

	draw_rect(Rect2(bench_rect.position + Vector2(0.0, 8.0), bench_rect.size), SHADOW)
	draw_rect(bench_rect, STEEL_DARK)
	draw_rect(bench_rect.grow(-2.0), Color(0.14, 0.15, 0.17))
	draw_rect(bench_rect, PANEL_BORDER, false, 2.0)
	draw_rect(Rect2(Vector2(bench_rect.position.x + 18.0, bench_rect.position.y + 8.0), Vector2(bench_rect.size.x - 36.0, 3.0)), ACCENT_DIM)

	draw_rect(machine_rect, Color(0.11, 0.12, 0.14))
	draw_rect(machine_rect, PANEL_BORDER, false, 2.0)
	draw_rect(linkage_rect, ACCENT_DIM)
	draw_rect(Rect2(Vector2(linkage_rect.position.x + 20.0, linkage_rect.position.y - 12.0), Vector2(linkage_rect.size.x - 40.0, 8.0)), STEEL)
	draw_rect(Rect2(Vector2(machine_rect.position.x + 20.0, tape_rect.end.y + 20.0), Vector2(machine_rect.size.x - 40.0, 4.0)), ACCENT_DIM)

	_draw_canister_side(left_cartridge, true)
	_draw_canister_side(right_cartridge, false)
	draw_rect(left_roller, STEEL_DARK)
	draw_rect(left_roller.grow(-1.0), STEEL)
	draw_rect(right_roller, STEEL_DARK)
	draw_rect(right_roller.grow(-1.0), STEEL)
	_draw_preview_tape(tape_rect, mini(GameState.tape_program.size(), 14), max(0, mini(GameState.automaton_ptr, 13)))

	draw_rect(punch_rect, Color(0.54, 0.49, 0.37))
	draw_rect(punch_rect.grow(-4.0), Color(0.67, 0.62, 0.47))
	draw_rect(punch_rect, PANEL_BORDER, false, 2.0)
	for bit in range(5):
		draw_circle(Vector2(punch_rect.position.x + punch_rect.size.x * 0.5, tape_rect.position.y + 4.0 + bit * 5.0), 2.2, STEEL_LIGHT)

	draw_colored_polygon(deck_points, Color(0.12, 0.13, 0.15))
	for point_index in range(deck_points.size()):
		var next_index := (point_index + 1) % deck_points.size()
		draw_line(deck_points[point_index], deck_points[next_index], PANEL_BORDER, 2.0)

	var key_start := Vector2(body.position.x + 102.0, body.position.y + 185.0)
	for row in range(4):
		for column in range(8):
			var row_origin := key_start + Vector2(-float(row) * 2.0, float(row) * 9.0)
			var key_center := row_origin + Vector2(column * 18.0, 0.0)
			draw_circle(key_center, 3.3, STEEL_DARK)
			draw_circle(key_center, 2.5, Color(0.17, 0.18, 0.20))
			draw_arc(key_center, 2.5, 3.5, 6.0, 12, PANEL_BORDER, 0.8)

	var plaque_rect := Rect2(Vector2(body.end.x - 152.0, body.end.y - 48.0), Vector2(128.0, 26.0))
	var bench_blocker := _get_programming_bench_blocker()
	var bench_ready := bench_blocker.is_empty()
	draw_rect(plaque_rect, ACCENT if bench_ready else Color(0.42, 0.22, 0.14))
	draw_rect(plaque_rect.grow(-2.0), Color(0.20, 0.18, 0.12))
	draw_circle(plaque_rect.position + Vector2(18.0, plaque_rect.size.y * 0.5), 4.0, TEXT if bench_ready else Color(0.78, 0.52, 0.32))
	if not bench_ready:
		_draw_disabled_hatch(plaque_rect.grow(-2.0))
		var blocker_icon := Rect2(Vector2(plaque_rect.end.x - 18.0, plaque_rect.position.y + 5.0), Vector2(10.0, 16.0))
		if not GameState.has_blank_cartridge_available():
			draw_rect(blocker_icon, TAPE)
			draw_rect(blocker_icon, PANEL_BORDER, false, 1.0)
			draw_line(blocker_icon.position + Vector2(2.0, 2.0), blocker_icon.end - Vector2(2.0, 2.0), Color(0.52, 0.18, 0.14), 1.2)
		else:
			draw_rect(Rect2(blocker_icon.position + Vector2(1.0, 2.0), Vector2(8.0, 3.0)), STEEL_LIGHT)
			draw_rect(Rect2(blocker_icon.position + Vector2(1.0, 7.0), Vector2(8.0, 3.0)), STEEL_LIGHT)
			draw_rect(Rect2(blocker_icon.position + Vector2(1.0, 12.0), Vector2(8.0, 3.0)), STEEL_LIGHT)
			draw_line(blocker_icon.position + Vector2(0.0, 0.0), blocker_icon.end, Color(0.52, 0.18, 0.14), 1.2)

func _draw_shelf_bay(rect: Rect2):
	var frame := _draw_region_frame(rect, "Cartridge Stores")
	var body := frame.grow(-18.0)
	var slot_data := _get_shelf_slot_data(body)
	var table_rect := Rect2(Vector2(body.position.x + 20.0, body.position.y + 46.0), Vector2(body.size.x - 40.0, 150.0))
	draw_rect(table_rect, Color(0.11, 0.10, 0.09))
	draw_rect(table_rect.grow(-3.0), Color(0.15, 0.13, 0.11))
	draw_rect(table_rect, PANEL_BORDER, false, 2.0)
	for slot in slot_data["programmed_slots"]:
		if slot["cartridge"].is_empty():
			_draw_empty_shelf_slot(Rect2(slot["rect"]))
		else:
			_draw_canister_standing(Rect2(slot["rect"]), true, str(slot["cartridge"].get("label", "")), bool(slot["selected"]))
	for slot in slot_data["blank_slots"]:
		if bool(slot["filled"]):
			_draw_canister_standing(Rect2(slot["rect"]), false, "", false)
		else:
			_draw_empty_shelf_slot(Rect2(slot["rect"]))
	var recycle_rect := Rect2(Vector2(body.position.x + 154.0, body.position.y + 202.0), Vector2(54.0, 22.0))
	var selected_cartridge: Dictionary = GameState.get_selected_cartridge()
	var recycle_enabled := not selected_cartridge.is_empty()
	_draw_recycle_icon(recycle_rect, recycle_enabled)
	if recycle_enabled:
		draw_rect(recycle_rect.grow(2.0), Color(0.80, 0.66, 0.27, 0.10), false, 1.0)

func _draw_cabinet_bay(rect: Rect2):
	var frame := _draw_region_frame(rect, "Drone Cards")
	var body := frame.grow(-18.0)
	var cabinet_slots := _get_cabinet_slot_data(body)
	for slot in cabinet_slots:
		var card_index: int = int(slot["index"])
		var card_rect: Rect2 = slot["rect"]
		var body_hotspot: Rect2 = slot["body_hotspot"]
		var loaded_cartridge: Dictionary = slot["loaded_cartridge"]
		var power_charge: int = int(slot["power_charge"])
		var power_card_count: int = int(slot["power_card_count"])
		var max_power_charge: int = int(slot["max_power_charge"])
		var outside_status := str(slot["outside_status"])
		var available_in_workshop := bool(slot["available_in_workshop"])
		var play_hotspot: Rect2 = slot["play_hotspot"]
		var tape_badge_rect: Rect2 = slot["tape_badge_rect"]
		var is_selected := card_index == _selected_bot_index
		var recovery_enabled := GameState.can_recover_bot(card_index)
		var launch_enabled := available_in_workshop and not recovery_enabled and not loaded_cartridge.is_empty() and power_charge > 0
		var drag_ready := not _active_drag.is_empty() and bool(slot["available_in_workshop"]) and Rect2(body_hotspot).has_point(_drag_mouse_root)
		var back_rect := Rect2(card_rect.position + Vector2(4.0, -4.0), card_rect.size)
		var face_rect := card_rect.grow(-4.0)
		var art_rect := Rect2(Vector2(face_rect.position.x + 14.0, face_rect.position.y + 22.0), Vector2(face_rect.size.x - 28.0, 84.0))
		draw_rect(back_rect, SHADOW)
		draw_rect(card_rect, STEEL_DARK)
		draw_rect(face_rect, Color(0.14, 0.15, 0.18))
		draw_rect(card_rect, ACCENT if is_selected else PANEL_BORDER, false, 2.0)
		if drag_ready:
			draw_rect(card_rect.grow(4.0), Color(0.80, 0.66, 0.27, 0.14))
		draw_rect(art_rect, Color(0.11, 0.12, 0.14))
		draw_rect(art_rect, STEEL_LIGHT, false, 1.0)
		if available_in_workshop:
			if card_index == 0:
				_draw_drone_silhouette(art_rect.grow(-8.0))
			else:
				_draw_butterfly_drone(art_rect.grow(-8.0))
			_draw_drone_tape_badge(tape_badge_rect, loaded_cartridge, is_selected)
			_draw_drone_power_badge(Rect2(Vector2(face_rect.end.x - 54.0, face_rect.end.y - 28.0), Vector2(42.0, 18.0)), power_charge, power_card_count > 0)
		else:
			_draw_empty_cabinet_window(art_rect, outside_status)
		var status_light := Rect2(Vector2(card_rect.end.x - 16.0, card_rect.position.y + 10.0), Vector2(6.0, 6.0))
		draw_circle(status_light.get_center(), 3.0, Color(0.46, 0.77, 0.46) if available_in_workshop else Color(0.76, 0.44, 0.24))
		_draw_bot_control_button(play_hotspot, "recover" if recovery_enabled else "launch", true, recovery_enabled or launch_enabled)

func _draw_map_bay(rect: Rect2):
	var frame := _draw_region_frame(rect, "Outside Route Table")
	var body := frame.grow(-10.0)
	var housing_size := minf(body.size.x - 18.0, body.size.y - 46.0)
	var housing_rect := Rect2(
		Vector2(body.position.x + (body.size.x - housing_size) * 0.5, body.position.y + 42.0),
		Vector2(housing_size, housing_size)
	)
	var display_rect := housing_rect.grow(-22.0)
	var grid_rect := display_rect.grow(-10.0)
	draw_rect(housing_rect, STEEL_DARK)
	draw_rect(housing_rect.grow(-4.0), Color(0.14, 0.15, 0.17))
	draw_rect(housing_rect, PANEL_BORDER, false, 2.0)
	draw_rect(display_rect, Color(0.09, 0.10, 0.12))
	draw_rect(display_rect, PANEL_BORDER, false, 2.0)
	var left_mount := Rect2(Vector2(housing_rect.position.x - 18.0, housing_rect.position.y + housing_rect.size.y * 0.35), Vector2(18.0, 28.0))
	var right_mount := Rect2(Vector2(housing_rect.end.x, housing_rect.position.y + housing_rect.size.y * 0.35), Vector2(18.0, 28.0))
	draw_rect(left_mount, STEEL_DARK)
	draw_rect(right_mount, STEEL_DARK)
	draw_rect(left_mount, PANEL_BORDER, false, 1.0)
	draw_rect(right_mount, PANEL_BORDER, false, 1.0)

	var grid_size: Vector2 = GameState.grid_size
	var cells_x: int = int(grid_size.x)
	var cells_y: int = int(grid_size.y)
	var cell_size := minf(grid_rect.size.x / float(cells_x), grid_rect.size.y / float(cells_y))
	var display_size := Vector2(cell_size * cells_x, cell_size * cells_y)
	var origin := grid_rect.position + (grid_rect.size - display_size) * 0.5
	for y in range(cells_y):
		for x in range(cells_x):
			var center := origin + Vector2((float(x) + 0.5) * cell_size, (float(y) + 0.5) * cell_size)
			var radius := cell_size * 0.28
			draw_circle(center, radius + 1.2, STEEL_DARK)
			draw_circle(center, radius, DISK_OFF)
			draw_line(center + Vector2(-radius * 0.85, 0.0), center + Vector2(radius * 0.85, 0.0), Color(0.0, 0.0, 0.0, 0.18), 1.0)

	_draw_shelter_marker(origin, cell_size)
	_draw_discovery_markers(origin, cell_size)
	_draw_outside_bot_routes(origin, cell_size)
	for fastener in [
		housing_rect.position + Vector2(12.0, 12.0),
		housing_rect.position + Vector2(housing_rect.size.x - 12.0, 12.0),
		housing_rect.position + Vector2(12.0, housing_rect.size.y - 12.0),
		housing_rect.position + Vector2(housing_rect.size.x - 12.0, housing_rect.size.y - 12.0)
	]:
		draw_circle(fastener, 2.0, ACCENT)
	_draw_power_deck(_get_power_stack_data(rect))

func _draw_drag_overlay():
	if _active_drag.is_empty():
		return
	var drag_kind := str(_active_drag.get("kind", ""))
	var shelf_rect := _rect_in_root(shelf_region)
	var cabinet_slots := _get_cabinet_slot_data(_rect_in_root(cabinet_region).grow(-28.0))
	if drag_kind == "cartridge":
		if _is_point_in_shelf_region(_drag_mouse_root) and str(_active_drag.get("source", "")) == "bot":
			draw_rect(shelf_rect.grow(-8.0), Color(0.80, 0.66, 0.27, 0.10))
		if _is_point_in_recycle_zone(_drag_mouse_root) and str(_active_drag.get("source", "")) == "shelf":
			var recycle_body := _rect_in_root(shelf_region).grow(-56.0)
			var recycle_rect := Rect2(Vector2(recycle_body.position.x + 182.0, recycle_body.position.y + 230.0), Vector2(54.0, 22.0))
			draw_rect(recycle_rect.grow(3.0), Color(0.66, 0.28, 0.18, 0.20))
		for slot in cabinet_slots:
			if Rect2(slot["rect"]).has_point(_drag_mouse_root) and bool(slot["available_in_workshop"]):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "power":
		for slot in cabinet_slots:
			if Rect2(slot["rect"]).has_point(_drag_mouse_root) and bool(slot["available_in_workshop"]):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))

	var preview_rect := Rect2(_drag_mouse_root + Vector2(12.0, 12.0), Vector2(24.0, 30.0))
	if drag_kind == "cartridge":
		_draw_card_stack(preview_rect, TAPE, true, "", false)
	elif drag_kind == "power":
		_draw_power_card(Rect2(preview_rect.position, Vector2(44.0, 62.0)), GameState.BOT_POWER_CAPACITY, GameState.BOT_POWER_CAPACITY, false)

func _draw_region_frame(rect: Rect2, title: String) -> Rect2:
	draw_rect(Rect2(rect.position + Vector2(8.0, 10.0), rect.size), SHADOW)
	draw_rect(rect, PANEL_FILL)
	draw_rect(rect.grow(-8.0), PANEL_INNER)
	draw_rect(rect, PANEL_BORDER, false, 3.0)
	draw_rect(Rect2(Vector2(rect.position.x + 16.0, rect.position.y + 42.0), Vector2(rect.size.x - 32.0, 3.0)), ACCENT_DIM)
	for corner in [
		rect.position + Vector2(12.0, 12.0),
		rect.position + Vector2(rect.size.x - 12.0, 12.0),
		rect.position + Vector2(12.0, rect.size.y - 12.0),
		rect.position + Vector2(rect.size.x - 12.0, rect.size.y - 12.0)
	]:
		draw_circle(corner, 2.0, ACCENT)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, TEXT)
	return rect.grow(-10.0)

func _draw_preview_tape(rect: Rect2, visible_rows: int, active_row: int):
	draw_rect(rect, TAPE_SHADE)
	draw_rect(rect.grow(-2.0), TAPE)
	var rows: int = maxi(visible_rows, 10)
	var row_width: float = (rect.size.x - 16.0) / float(rows)
	for row in range(rows):
		var row_rect := Rect2(Vector2(rect.position.x + 8.0 + row * row_width, rect.position.y + 3.0), Vector2(row_width - 2.0, rect.size.y - 6.0))
		draw_rect(row_rect, Color(1.0, 1.0, 1.0, 0.04))
		draw_rect(row_rect, Color(0.42, 0.36, 0.24, 0.22), false, 1.0)
		for bit in range(5):
			var hole_center := Vector2(row_rect.position.x + row_rect.size.x * 0.5, row_rect.position.y + 5.0 + bit * ((row_rect.size.y - 10.0) / 4.0))
			draw_circle(hole_center, 1.7, TAPE_HOLE if row <= active_row else Color(0.35, 0.30, 0.20, 0.25))
	if visible_rows > 0:
		var highlight_x: float = rect.position.x + 8.0 + float(mini(active_row, rows - 1)) * row_width
		var highlight_rect := Rect2(Vector2(highlight_x, rect.position.y + 1.0), Vector2(row_width - 2.0, rect.size.y - 2.0))
		draw_rect(highlight_rect, Color(0.85, 0.68, 0.28, 0.18))
		draw_rect(highlight_rect, ACCENT, false, 1.0)

func _draw_canister_side(rect: Rect2, programmed: bool):
	var top_rim := Rect2(Vector2(rect.position.x - 2.0, rect.position.y), Vector2(rect.size.x + 4.0, 6.0))
	var body := Rect2(Vector2(rect.position.x, rect.position.y + 5.0), Vector2(rect.size.x, rect.size.y - 10.0))
	var bottom_rim := Rect2(Vector2(rect.position.x - 2.0, rect.end.y - 6.0), Vector2(rect.size.x + 4.0, 6.0))
	var label_strip := Rect2(Vector2(body.position.x + 2.0, body.position.y + 4.0), Vector2(body.size.x - 4.0, body.size.y - 8.0))
	var stock_marker := Rect2(
		Vector2(label_strip.position.x + (2.0 if programmed else label_strip.size.x - 6.0), label_strip.position.y),
		Vector2(4.0, label_strip.size.y)
	)
	draw_rect(top_rim, STEEL_DARK)
	draw_rect(body, STEEL)
	draw_rect(bottom_rim, STEEL_DARK)
	draw_rect(body.grow(-2.0), Color(0.21, 0.22, 0.25))
	draw_rect(label_strip, TAPE if programmed else Color(0.21, 0.22, 0.25))
	draw_rect(stock_marker, ACCENT)
	draw_rect(Rect2(Vector2(body.position.x + body.size.x * 0.5 - 1.0, body.position.y - 3.0), Vector2(2.0, 3.0)), STEEL_LIGHT)
	draw_rect(body, PANEL_BORDER, false, 1.0)
	draw_rect(label_strip, PANEL_BORDER, false, 1.0)

func _draw_canister_standing(rect: Rect2, programmed: bool, label: String = "", selected: bool = false):
	_draw_card_stack(rect, TAPE if programmed else Color(0.22, 0.23, 0.25), programmed, label, selected)

func _draw_empty_shelf_slot(rect: Rect2):
	var back_rect := Rect2(rect.position + Vector2(2.0, -2.0), rect.size)
	var front_rect := Rect2(rect.position, rect.size)
	draw_rect(back_rect, Color(0.10, 0.10, 0.11))
	draw_rect(front_rect, Color(0.13, 0.13, 0.14))
	draw_rect(back_rect, PANEL_BORDER, false, 1.0)
	draw_rect(front_rect, PANEL_BORDER, false, 1.0)
	draw_line(front_rect.position + Vector2(4.0, 4.0), front_rect.end - Vector2(4.0, 4.0), STEEL_LIGHT, 1.0)
	draw_line(Vector2(front_rect.position.x + 4.0, front_rect.end.y - 4.0), Vector2(front_rect.end.x - 4.0, front_rect.position.y + 4.0), STEEL_LIGHT, 1.0)

func _draw_card_stack(rect: Rect2, face_color: Color, programmed: bool, label: String, selected: bool):
	var back_rect := Rect2(rect.position + Vector2(2.0, -2.0), rect.size)
	var front_rect := Rect2(rect.position, rect.size)
	var face_rect := front_rect.grow(-2.0)
	var rail_rect := Rect2(face_rect.position + Vector2(1.0, 1.0), Vector2(3.0, face_rect.size.y - 2.0))
	var suit_rect := Rect2(face_rect.position + Vector2(6.0, 4.0), Vector2(18.0, 10.0))
	draw_rect(back_rect, STEEL_DARK)
	draw_rect(front_rect, STEEL)
	draw_rect(face_rect, face_color)
	draw_rect(rail_rect, ACCENT if programmed else STEEL_LIGHT)
	draw_rect(back_rect, PANEL_BORDER, false, 1.0)
	draw_rect(front_rect, ACCENT if selected else PANEL_BORDER, false, 1.0)
	_draw_tape_suit(suit_rect, programmed)
	if programmed and not label.is_empty():
		var short_label := _trim_cartridge_label(label, 8).to_upper()
		draw_string(ThemeDB.fallback_font, face_rect.position + Vector2(6.0, face_rect.end.y - 7.0), short_label, HORIZONTAL_ALIGNMENT_LEFT, face_rect.size.x - 10.0, 8, STEEL_DARK)

func _draw_tape_suit(rect: Rect2, programmed: bool):
	var strip_rect := Rect2(rect.position + Vector2(0.0, 2.0), Vector2(rect.size.x, rect.size.y - 4.0))
	draw_rect(strip_rect, TAPE_SHADE if programmed else Color(0.70, 0.70, 0.72))
	draw_rect(strip_rect, Color(0.56, 0.48, 0.28), false, 1.0)
	for hole_index in range(5):
		var hole_center := Vector2(strip_rect.position.x + 4.0 + float(hole_index) * 3.0, strip_rect.position.y + strip_rect.size.y * 0.5)
		draw_circle(hole_center, 0.9, TAPE_HOLE if programmed else STEEL_LIGHT)

func _get_shelf_slot_data(body: Rect2) -> Dictionary:
	var rack_rect := Rect2(Vector2(body.position.x + 20.0, body.position.y + 46.0), Vector2(body.size.x - 40.0, 150.0))
	var programmed_slots: Array = []
	var blank_slots: Array = []
	var power_slots: Array = []
	for slot_index in range(GameState.PROGRAMMED_CARTRIDGE_CAPACITY):
		var row := slot_index / 4
		var column := slot_index % 4
		var slot_rect := Rect2(
			Vector2(rack_rect.position.x + 16.0 + column * 74.0, rack_rect.position.y + 10.0 + row * 46.0),
			Vector2(56.0, 34.0)
		)
		var cartridge: Dictionary = GameState.get_programmed_cartridge_in_slot(slot_index)
		programmed_slots.append({
			"rect": slot_rect,
			"cartridge": cartridge,
			"selected": str(cartridge.get("id", "")) == GameState.selected_cartridge_id,
		})
	for blank_index in range(BLANK_CARTRIDGE_DISPLAY_COUNT):
		blank_slots.append({
			"rect": Rect2(
				Vector2(rack_rect.position.x + 24.0 + blank_index * 74.0, rack_rect.position.y + 106.0),
				Vector2(48.0, 30.0)
			),
			"filled": GameState.is_blank_slot_filled(blank_index),
		})
	var recycle_rect := Rect2(Vector2(body.position.x + 154.0, body.position.y + 202.0), Vector2(54.0, 22.0))
	for slot_index in range(GameState.POWER_UNIT_SLOT_COUNT):
		power_slots.append({
			"index": slot_index,
			"rect": Rect2(),
			"power_unit": GameState.get_power_unit_in_slot(slot_index),
		})
	return {
		"programmed_slots": programmed_slots,
		"blank_slots": blank_slots,
		"power_slots": power_slots,
		"recycle_hotspot": recycle_rect,
	}

func _get_cabinet_slot_data(body: Rect2) -> Array:
	var slots: Array = []
	for cabinet_index in range(2):
		var cabinet_rect := Rect2(Vector2(body.position.x + 28.0 + cabinet_index * 164.0, body.position.y + 42.0), Vector2(128.0, 156.0))
		var tape_badge_rect := Rect2(
			Vector2(cabinet_rect.position.x + 14.0, cabinet_rect.end.y - 48.0),
			Vector2(48.0, 16.0)
		)
		var available_in_workshop := GameState.is_bot_available_in_workshop(cabinet_index)
		var control_y := cabinet_rect.end.y + 10.0
		slots.append({
			"index": cabinet_index,
			"rect": cabinet_rect,
			"body_hotspot": cabinet_rect,
			"tape_badge_rect": tape_badge_rect,
			"loaded_cartridge": GameState.get_bot_loaded_cartridge(cabinet_index),
			"power_charge": int(GameState.bot_loadouts[cabinet_index].get("power_charge", 0)),
			"power_card_count": int(GameState.bot_loadouts[cabinet_index].get("power_card_count", 0)),
			"max_power_charge": int(GameState.bot_loadouts[cabinet_index].get("max_power_charge", GameState.BOT_POWER_CAPACITY)),
			"outside_status": str(GameState.bot_loadouts[cabinet_index].get("outside_status", "cabinet")),
			"available_in_workshop": available_in_workshop,
			"play_hotspot": Rect2(Vector2(cabinet_rect.position.x + 24.0, control_y), Vector2(cabinet_rect.size.x - 48.0, 20.0)),
		})
	return slots

func _draw_empty_cabinet_window(window_rect: Rect2, outside_status: String):
	draw_rect(window_rect.grow(-10.0), Color(0.10, 0.11, 0.12))

func _draw_drone_tape_badge(rect: Rect2, loaded_cartridge: Dictionary, is_selected: bool):
	draw_rect(rect, STEEL_DARK)
	draw_rect(rect.grow(-1.0), Color(0.18, 0.19, 0.22))
	draw_rect(rect, ACCENT if is_selected else PANEL_BORDER, false, 1.0)
	if loaded_cartridge.is_empty():
		return
	var tape_rect := rect.grow(-2.0)
	draw_rect(tape_rect, TAPE)
	draw_rect(Rect2(tape_rect.position + Vector2(2.0, 1.0), Vector2(4.0, tape_rect.size.y - 2.0)), ACCENT)
	var short_label := _trim_cartridge_label(str(loaded_cartridge.get("label", "")), 5).to_upper()
	draw_string(ThemeDB.fallback_font, tape_rect.position + Vector2(9.0, 11.0), short_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, STEEL_DARK)

func _draw_drone_power_badge(rect: Rect2, power_charge: int, has_power: bool):
	if not has_power and power_charge <= 0:
		return
	var font := ThemeDB.fallback_font
	var font_size := 9
	var value_text := str(maxi(power_charge, 0))
	var value_size := font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var suit_rect := Rect2(rect.position + Vector2(1.0, 5.0), Vector2(12.0, 8.0))
	_draw_power_suit(suit_rect, power_charge > 0, 1.1)
	draw_string(
		font,
		Vector2(rect.end.x - 2.0 - value_size.x, rect.position.y + 12.5),
		value_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		TAPE
	)

func _draw_bot_control_button(rect: Rect2, icon_kind: String, visible: bool, enabled: bool):
	draw_rect(rect, STEEL_DARK if visible else Color(0.09, 0.09, 0.10))
	draw_rect(rect.grow(-1.0), Color(0.18, 0.19, 0.22) if visible else Color(0.12, 0.12, 0.13))
	draw_rect(rect, ACCENT if enabled else PANEL_BORDER, false, 1.0)
	var icon_color := ACCENT if enabled else STEEL_LIGHT
	var center := rect.get_center()
	match icon_kind:
		"launch":
			var triangle := PackedVector2Array([
				center + Vector2(-5.0, -6.0),
				center + Vector2(-5.0, 6.0),
				center + Vector2(6.0, 0.0),
			])
			draw_colored_polygon(triangle, icon_color)
		"recover":
			draw_arc(center, 6.0, PI * 0.20, PI * 1.55, 16, icon_color, 1.4)
			var arrow := PackedVector2Array([
				center + Vector2(-2.0, -7.0),
				center + Vector2(3.0, -7.0),
				center + Vector2(0.5, -3.0),
			])
			draw_colored_polygon(arrow, icon_color)
			draw_line(center + Vector2(1.0, 2.0), center + Vector2(5.0, 5.0), icon_color, 1.3)
		"power_out":
			var unit_rect := Rect2(center + Vector2(-7.0, -5.0), Vector2(9.0, 10.0))
			draw_rect(unit_rect, TAPE if enabled else Color(0.12, 0.12, 0.13))
			draw_rect(unit_rect, PANEL_BORDER, false, 1.0)
			draw_rect(Rect2(unit_rect.position + Vector2(1.0, 1.0), Vector2(2.0, unit_rect.size.y - 2.0)), ACCENT_DIM)
			draw_line(center + Vector2(4.0, 0.0), center + Vector2(11.0, 0.0), icon_color, 1.4)
			var arrow_out := PackedVector2Array([
				center + Vector2(11.0, 0.0),
				center + Vector2(7.0, -3.0),
				center + Vector2(7.0, 3.0),
			])
			draw_colored_polygon(arrow_out, icon_color)
	if visible and not enabled:
		_draw_disabled_hatch(rect.grow(-1.0))

func _draw_power_deck(stack_data: Dictionary):
	var stack_zone: Rect2 = stack_data["stack_zone"]
	var visible_cards: Array = stack_data["visible_cards"]
	draw_rect(stack_zone, STEEL_DARK)
	draw_rect(stack_zone.grow(-2.0), Color(0.14, 0.15, 0.18))
	draw_rect(stack_zone, PANEL_BORDER, false, 2.0)
	for card_info in visible_cards:
		var card_rect: Rect2 = card_info["rect"]
		var slot_index: int = int(card_info["slot_index"])
		var power_unit: Dictionary = card_info["power_unit"]
		var charge := int(power_unit.get("charge", 0))
		var max_charge := maxi(int(power_unit.get("max_charge", 1)), 1)
		_draw_power_card(card_rect, charge, max_charge, slot_index == _selected_power_slot_index)

func _get_power_stack_data(rect: Rect2) -> Dictionary:
	var frame := rect.grow(-10.0)
	var body := frame.grow(-10.0)
	var housing_size := minf(body.size.x - 18.0, body.size.y - 46.0)
	var housing_rect := Rect2(
		Vector2(body.position.x + (body.size.x - housing_size) * 0.5, body.position.y + 42.0),
		Vector2(housing_size, housing_size)
	)
	var stack_zone := Rect2(Vector2(housing_rect.end.x + 32.0, housing_rect.position.y + 22.0), Vector2(72.0, 116.0))
	var occupied_cards: Array = []
	for slot_index in range(GameState.POWER_UNIT_SLOT_COUNT):
		var power_unit := GameState.get_power_unit_in_slot(slot_index)
		if power_unit.is_empty():
			continue
		occupied_cards.append({
			"slot_index": slot_index,
			"power_unit": power_unit,
		})
	var visible_cards: Array = []
	var top_card_rect := Rect2(Vector2(stack_zone.position.x + 12.0, stack_zone.position.y + 14.0), Vector2(44.0, 62.0))
	for card_index in range(occupied_cards.size()):
		var offset := occupied_cards.size() - 1 - card_index
		var card_rect := Rect2(
			Vector2(stack_zone.position.x + 12.0 + float(offset) * 2.0, stack_zone.position.y + 14.0 + float(offset) * 4.0),
			Vector2(44.0, 62.0)
		)
		if card_index == occupied_cards.size() - 1:
			top_card_rect = card_rect
		visible_cards.append({
			"rect": card_rect,
			"slot_index": int(occupied_cards[card_index]["slot_index"]),
			"power_unit": Dictionary(occupied_cards[card_index]["power_unit"]),
		})
	return {
		"stack_zone": stack_zone,
		"visible_cards": visible_cards,
		"top_slot_index": int(occupied_cards[-1]["slot_index"]) if not occupied_cards.is_empty() else -1,
		"top_card_rect": top_card_rect,
	}

func _draw_power_card(rect: Rect2, charge: int, max_charge: int, selected: bool):
	var back_rect := Rect2(rect.position + Vector2(2.0, -2.0), rect.size)
	var front_rect := Rect2(rect.position, rect.size)
	var face_rect := front_rect.grow(-2.0)
	var fill_ratio := clampf(float(charge) / float(maxi(max_charge, 1)), 0.0, 1.0)
	var font := ThemeDB.fallback_font
	var font_size := 13
	var number_text := str(maxi(charge, 0))
	var number_size := font.get_string_size(number_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var suit_rect := Rect2(Vector2(face_rect.position.x + 8.0, face_rect.position.y + 16.0), Vector2(face_rect.size.x - 16.0, 12.0))
	var meter_rect := Rect2(Vector2(face_rect.position.x + 6.0, face_rect.end.y - 6.0), Vector2(face_rect.size.x - 12.0, 3.0))
	var fill_rect := Rect2(meter_rect.position, Vector2(meter_rect.size.x * fill_ratio, meter_rect.size.y))
	draw_rect(back_rect, Color(0.34, 0.29, 0.18, 0.42))
	draw_rect(front_rect, TAPE_SHADE)
	draw_rect(face_rect, TAPE)
	_draw_power_suit(suit_rect, charge > 0)
	draw_string(font, Vector2(face_rect.end.x - 5.0 - number_size.x, face_rect.position.y + 45.0), number_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, STEEL_DARK)
	draw_rect(meter_rect, Color(0.68, 0.60, 0.40))
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, ACCENT)
	draw_rect(back_rect, Color(0.45, 0.38, 0.22), false, 1.0)
	draw_rect(front_rect, ACCENT if selected else Color(0.56, 0.48, 0.28), false, 1.0)
	if charge <= 0:
		_draw_disabled_hatch(face_rect)

func _draw_power_suit(rect: Rect2, charged: bool, line_width: float = 1.5):
	var color := ACCENT if charged else STEEL_LIGHT
	var left := rect.position.x + 1.0
	var right := rect.end.x - 1.0
	var cy := rect.get_center().y
	var amp := rect.size.y * 0.32
	var pts := PackedVector2Array()
	for step in range(9):
		var t := float(step) / 8.0
		var x := lerpf(left + 2.0, right - 2.0, t)
		var y := cy
		if step > 0 and step < 8:
			y += amp if step % 2 == 0 else -amp
		pts.append(Vector2(x, y))
	draw_line(Vector2(left, cy), pts[0], color, line_width)
	for i in range(pts.size() - 1):
		draw_line(pts[i], pts[i + 1], color, line_width)
	draw_line(pts[-1], Vector2(right, cy), color, line_width)

func _get_first_empty_power_slot_index() -> int:
	for slot_index in range(GameState.POWER_UNIT_SLOT_COUNT):
		if GameState.get_power_unit_in_slot(slot_index).is_empty():
			return slot_index
	return -1

func _draw_recycle_icon(rect: Rect2, enabled: bool):
	var center := rect.position + Vector2(10.0, rect.size.y * 0.5)
	var color := ACCENT if enabled else STEEL_LIGHT
	draw_arc(center, 4.0, PI * 0.20, PI * 1.45, 12, color, 1.2)
	draw_arc(center, 4.0, PI * 1.20, PI * 2.45, 12, color, 1.2)
	var head_a := PackedVector2Array([
		center + Vector2(3.5, -1.0),
		center + Vector2(7.0, -1.0),
		center + Vector2(5.5, 2.0),
	])
	var head_b := PackedVector2Array([
		center + Vector2(-3.5, 1.0),
		center + Vector2(-7.0, 1.0),
		center + Vector2(-5.5, -2.0),
	])
	draw_colored_polygon(head_a, color)
	draw_colored_polygon(head_b, color)

func _draw_stock_meter(rect: Rect2, ratio: float, fill_color: Color):
	draw_rect(rect, STEEL_DARK)
	draw_rect(rect, PANEL_BORDER, false, 1.0)
	var inner := rect.grow(-1.0)
	draw_rect(inner, Color(0.12, 0.12, 0.13))
	var fill_width := inner.size.x * clampf(ratio, 0.0, 1.0)
	if fill_width > 0.0:
		draw_rect(Rect2(inner.position, Vector2(fill_width, inner.size.y)), fill_color)

func _draw_disabled_hatch(rect: Rect2):
	var x := rect.position.x - rect.size.y
	while x < rect.end.x:
		draw_line(Vector2(x, rect.position.y), Vector2(x + rect.size.y, rect.end.y), Color(0.0, 0.0, 0.0, 0.18), 1.0)
		x += 6.0

func _draw_bot_play_button(play_hotspot: Rect2, enabled: bool):
	draw_rect(play_hotspot, ACCENT_DIM if enabled else STEEL_DARK)
	draw_rect(play_hotspot.grow(-1.5), Color(0.20, 0.18, 0.12) if enabled else Color(0.16, 0.17, 0.19))
	draw_rect(play_hotspot, PANEL_BORDER, false, 1.0)
	var triangle := PackedVector2Array([
		play_hotspot.get_center() + Vector2(-4.0, -5.0),
		play_hotspot.get_center() + Vector2(-4.0, 5.0),
		play_hotspot.get_center() + Vector2(5.0, 0.0),
	])
	draw_colored_polygon(triangle, ACCENT if enabled else STEEL_LIGHT)
	draw_line(
		Vector2(play_hotspot.position.x + 8.0, play_hotspot.end.y - 4.0),
		Vector2(play_hotspot.end.x - 8.0, play_hotspot.end.y - 4.0),
		PANEL_BORDER,
		1.0
	)

func _draw_shelter_marker(origin: Vector2, cell_size: float):
	var shelter_center: Vector2 = origin + (GameState.get_shelter_position() + Vector2.ONE * 0.5) * cell_size
	var shelter_rect := Rect2(shelter_center - Vector2(5.0, 4.0), Vector2(10.0, 8.0))
	draw_rect(shelter_rect, STEEL_DARK)
	draw_rect(shelter_rect.grow(-1.0), TAPE)
	draw_line(shelter_center + Vector2(0.0, -7.0), shelter_center + Vector2(0.0, 7.0), PANEL_BORDER, 1.0)

func _draw_discovery_markers(origin: Vector2, cell_size: float):
	for object_entry in GameState.get_discovered_outside_objects():
		var position := Vector2(object_entry.get("position", Vector2.ZERO))
		var center := origin + (position + Vector2.ONE * 0.5) * cell_size
		var object_type := str(object_entry.get("type", ""))
		match object_type:
			"resource":
				draw_circle(center, 3.0, Color(0.42, 0.70, 0.44))
				draw_line(center + Vector2(-4.0, 0.0), center + Vector2(4.0, 0.0), STEEL_DARK, 1.0)
				draw_line(center + Vector2(0.0, -4.0), center + Vector2(0.0, 4.0), STEEL_DARK, 1.0)
			"hazard":
				draw_line(center + Vector2(-4.0, -4.0), center + Vector2(4.0, 4.0), Color(0.72, 0.28, 0.18), 1.2)
				draw_line(center + Vector2(-4.0, 4.0), center + Vector2(4.0, -4.0), Color(0.72, 0.28, 0.18), 1.2)
			"landmark":
				draw_rect(Rect2(center - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), TAPE_SHADE)
				draw_rect(Rect2(center - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), PANEL_BORDER, false, 1.0)
			"surveillance":
				var triangle := PackedVector2Array([
					center + Vector2(0.0, -4.5),
					center + Vector2(4.0, 3.5),
					center + Vector2(-4.0, 3.5),
				])
				draw_colored_polygon(triangle, Color(0.72, 0.62, 0.24))
				draw_line(triangle[0], triangle[1], STEEL_DARK, 1.0)
				draw_line(triangle[1], triangle[2], STEEL_DARK, 1.0)
				draw_line(triangle[2], triangle[0], STEEL_DARK, 1.0)

func _draw_outside_bot_routes(origin: Vector2, cell_size: float):
	for bot_index in range(GameState.bot_loadouts.size()):
		var bot_state: Dictionary = GameState.bot_loadouts[bot_index]
		var outside_status := str(bot_state.get("outside_status", "cabinet"))
		var route_color: Color = BOT_ROUTE_COLORS[bot_index % BOT_ROUTE_COLORS.size()]
		var predict_color: Color = BOT_PREDICT_COLORS[bot_index % BOT_PREDICT_COLORS.size()]
		var trail: Array = bot_state.get("outside_trail", [])
		var predicted: Array = bot_state.get("predicted_trail", [])
		if outside_status != "cabinet":
			_draw_path_segments(origin, cell_size, trail, route_color, 2.2, 3.0)
		if outside_status == "cabinet" and not predicted.is_empty():
			var prelaunch_path: Array = [GameState.get_shelter_position()]
			prelaunch_path.append_array(predicted)
			_draw_path_segments(origin, cell_size, prelaunch_path, predict_color, 1.2, 2.2)
			continue
		if not trail.is_empty():
			var future_path: Array = [trail[-1]]
			future_path.append_array(predicted)
			_draw_path_segments(origin, cell_size, future_path, predict_color, 1.2, 2.2)
		if outside_status == "cabinet":
			continue
		var bot_position := Vector2(bot_state.get("outside_position", GameState.get_shelter_position()))
		var bot_center := origin + (bot_position + Vector2.ONE * 0.5) * cell_size
		draw_circle(bot_center, cell_size * 0.24, STEEL_DARK)
		draw_circle(bot_center, cell_size * 0.19, route_color if outside_status == "active" else TAPE_SHADE)
		draw_line(bot_center, bot_center + _facing_vector(str(bot_state.get("outside_facing", "north"))) * (cell_size * 0.28), TEXT, 1.6)

func _draw_path_segments(origin: Vector2, cell_size: float, path: Array, color: Color, width: float, disk_radius: float):
	if path.is_empty():
		return
	for point_index in range(path.size()):
		var position := Vector2(path[point_index])
		var center := origin + (position + Vector2.ONE * 0.5) * cell_size
		draw_circle(center, disk_radius, color)
		if point_index == 0:
			continue
		var previous_position := Vector2(path[point_index - 1])
		var previous_center := origin + (previous_position + Vector2.ONE * 0.5) * cell_size
		draw_line(previous_center, center, color, width)

func _bot_display_name(bot_index: int) -> String:
	match bot_index:
		0:
			return "Spider drone"
		1:
			return "Butterfly drone"
		_:
			return "Bot %d" % [bot_index + 1]

func _trim_cartridge_label(label: String, max_length: int) -> String:
	var trimmed := label.strip_edges()
	if trimmed.length() <= max_length:
		return trimmed
	return trimmed.substr(0, max_length)

func _draw_drone_silhouette(rect: Rect2):
	var chassis_rect := Rect2(
		Vector2(rect.position.x + rect.size.x * 0.5 - 19.0, rect.position.y + 36.0),
		Vector2(38.0, 18.0)
	)
	var chassis_top := Rect2(Vector2(chassis_rect.position.x + 4.0, chassis_rect.position.y + 2.0), Vector2(chassis_rect.size.x - 8.0, 4.0))
	var optic_pod := Rect2(Vector2(chassis_rect.position.x + 6.0, chassis_rect.position.y + 2.0), Vector2(11.0, 11.0))
	var service_hatch := Rect2(Vector2(chassis_rect.end.x - 12.0, chassis_rect.position.y + 4.0), Vector2(8.0, 8.0))
	var spring_gauge := Rect2(Vector2(chassis_rect.position.x + 20.0, chassis_rect.position.y + 4.0), Vector2(9.0, 4.0))
	var belly_plate := Rect2(Vector2(chassis_rect.position.x + 10.0, chassis_rect.end.y - 2.0), Vector2(chassis_rect.size.x - 20.0, 3.0))
	draw_rect(chassis_rect, STEEL_DARK)
	draw_rect(chassis_rect.grow(-2.0), Color(0.17, 0.18, 0.20))
	draw_rect(chassis_top, STEEL_LIGHT)
	draw_rect(optic_pod, STEEL)
	draw_rect(service_hatch, Color(0.15, 0.15, 0.17))
	draw_rect(spring_gauge, Color(0.10, 0.10, 0.11))
	draw_rect(Rect2(spring_gauge.position + Vector2(1.0, 1.0), Vector2(5.0, spring_gauge.size.y - 2.0)), ACCENT_DIM)
	draw_rect(belly_plate, ACCENT_DIM)
	draw_rect(chassis_rect, PANEL_BORDER, false, 2.0)
	draw_rect(optic_pod, PANEL_BORDER, false, 1.0)
	draw_rect(service_hatch, PANEL_BORDER, false, 1.0)

	var sensor_center := optic_pod.position + optic_pod.size * 0.5
	draw_circle(sensor_center, 4.0, STEEL_DARK)
	draw_circle(sensor_center, 2.7, STEEL)
	draw_circle(sensor_center, 1.3, TEXT)
	draw_circle(sensor_center + Vector2(-0.6, -0.6), 0.7, ACCENT)

	for bolt in [
		chassis_rect.position + Vector2(6.0, chassis_rect.size.y - 5.0),
		chassis_rect.position + Vector2(chassis_rect.size.x - 6.0, chassis_rect.size.y - 5.0)
	]:
		draw_circle(bolt, 1.3, STEEL_LIGHT)

	var key_center := Vector2(chassis_rect.position.x + chassis_rect.size.x * 0.5 + 6.0, chassis_rect.position.y - 2.0)
	draw_line(key_center + Vector2(-2.2, 0.0), key_center + Vector2(-2.2, -7.0), STEEL_DARK, 2.0)
	draw_line(key_center + Vector2(2.2, 0.0), key_center + Vector2(2.2, -7.0), STEEL_DARK, 2.0)
	draw_arc(key_center + Vector2(-2.2, -8.5), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	draw_arc(key_center + Vector2(2.2, -8.5), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)

	var left_anchors := [Vector2(0.0, 3.0), Vector2(0.0, 7.0), Vector2(0.0, 11.0), Vector2(0.0, 15.0)]
	var right_anchors := [Vector2(chassis_rect.size.x, 3.0), Vector2(chassis_rect.size.x, 7.0), Vector2(chassis_rect.size.x, 11.0), Vector2(chassis_rect.size.x, 15.0)]
	var left_knees := [Vector2(-8.0, -1.0), Vector2(-12.0, 2.0), Vector2(-13.0, 7.0), Vector2(-10.0, 12.0)]
	var right_knees := [Vector2(8.0, -1.0), Vector2(12.0, 2.0), Vector2(13.0, 7.0), Vector2(10.0, 12.0)]
	for leg_index in range(4):
		var left_anchor: Vector2 = chassis_rect.position + left_anchors[leg_index]
		var right_anchor: Vector2 = chassis_rect.position + right_anchors[leg_index]
		_draw_spider_leg(left_anchor, left_knees[leg_index], true)
		_draw_spider_leg(right_anchor, right_knees[leg_index], false)

func _draw_spider_leg(anchor: Vector2, knee_offset: Vector2, is_left: bool):
	var knee := anchor + knee_offset
	var shin := knee + Vector2(-10.0 if is_left else 10.0, 8.0)
	var foot := shin + Vector2(-5.0 if is_left else 5.0, 12.0)
	_draw_leg_segment(anchor, knee, shin, foot)

func _draw_butterfly_drone(rect: Rect2):
	var body_center := rect.position + Vector2(rect.size.x * 0.5, 42.0)
	var head_center := body_center + Vector2(0.0, -18.0)
	var thorax_rect := Rect2(Vector2(body_center.x - 6.0, body_center.y - 10.0), Vector2(12.0, 18.0))
	var spring_rect := Rect2(Vector2(body_center.x - 3.5, body_center.y - 2.0), Vector2(7.0, 34.0))
	var key_axle_rect := Rect2(Vector2(body_center.x - 2.0, body_center.y - 4.0), Vector2(4.0, 14.0))
	var key_bar_y := body_center.y + 3.0
	var lower_tail := PackedVector2Array([
		body_center + Vector2(-5.0, 28.0),
		body_center + Vector2(0.0, 36.0),
		body_center + Vector2(5.0, 28.0),
		body_center + Vector2(0.0, 20.0),
	])
	draw_circle(head_center, 4.0, STEEL_DARK)
	draw_rect(thorax_rect, STEEL_DARK)
	draw_rect(thorax_rect.grow(-1.0), ACCENT_DIM)
	draw_rect(spring_rect, STEEL_DARK)
	draw_rect(spring_rect.grow(-1.0), TAPE)
	draw_rect(key_axle_rect, STEEL_DARK)
	draw_line(Vector2(body_center.x - 8.0, key_bar_y), Vector2(body_center.x + 8.0, key_bar_y), STEEL_DARK, 2.0)
	draw_arc(Vector2(body_center.x - 8.0, key_bar_y - 3.0), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	draw_arc(Vector2(body_center.x + 8.0, key_bar_y - 3.0), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	draw_circle(Vector2(body_center.x, key_bar_y), 2.0, STEEL_LIGHT)
	draw_line(spring_rect.position + Vector2(0.0, 4.0), spring_rect.position + Vector2(spring_rect.size.x, 4.0), PANEL_BORDER, 1.0)
	draw_line(spring_rect.position + Vector2(0.0, 10.0), spring_rect.position + Vector2(spring_rect.size.x, 10.0), PANEL_BORDER, 1.0)
	draw_line(spring_rect.position + Vector2(0.0, 16.0), spring_rect.position + Vector2(spring_rect.size.x, 16.0), PANEL_BORDER, 1.0)
	draw_colored_polygon(lower_tail, STEEL_DARK)

	var upper_left := PackedVector2Array([
		body_center + Vector2(-5.0, -10.0),
		body_center + Vector2(-24.0, -26.0),
		body_center + Vector2(-39.0, -20.0),
		body_center + Vector2(-33.0, -3.0),
		body_center + Vector2(-12.0, -1.0),
		body_center + Vector2(-6.0, -4.0),
	])
	var upper_right := PackedVector2Array([
		body_center + Vector2(5.0, -10.0),
		body_center + Vector2(24.0, -26.0),
		body_center + Vector2(39.0, -20.0),
		body_center + Vector2(33.0, -3.0),
		body_center + Vector2(12.0, -1.0),
		body_center + Vector2(6.0, -4.0),
	])
	var lower_left := PackedVector2Array([
		body_center + Vector2(-4.0, 6.0),
		body_center + Vector2(-16.0, 13.0),
		body_center + Vector2(-26.0, 24.0),
		body_center + Vector2(-24.0, 37.0),
		body_center + Vector2(-13.0, 44.0),
		body_center + Vector2(-5.0, 34.0),
		body_center + Vector2(-2.0, 18.0),
	])
	var lower_right := PackedVector2Array([
		body_center + Vector2(4.0, 6.0),
		body_center + Vector2(16.0, 13.0),
		body_center + Vector2(26.0, 24.0),
		body_center + Vector2(24.0, 37.0),
		body_center + Vector2(13.0, 44.0),
		body_center + Vector2(5.0, 34.0),
		body_center + Vector2(2.0, 18.0),
	])

	_draw_butterfly_wing(upper_left, 4)
	_draw_butterfly_wing(upper_right, 4)
	_draw_butterfly_wing(lower_left, 5)
	_draw_butterfly_wing(lower_right, 5)

	draw_line(head_center + Vector2(-1.0, -2.0), head_center + Vector2(-7.0, -10.0), ACCENT_DIM, 1.4)
	draw_line(head_center + Vector2(1.0, -2.0), head_center + Vector2(7.0, -10.0), ACCENT_DIM, 1.4)
	draw_arc(head_center + Vector2(-7.0, -12.0), 2.5, 0.0, TAU, 10, STEEL_DARK, 1.1)
	draw_arc(head_center + Vector2(7.0, -12.0), 2.5, 0.0, TAU, 10, STEEL_DARK, 1.1)

func _draw_butterfly_wing(points: PackedVector2Array, rib_count: int):
	draw_colored_polygon(points, TAPE)
	for point_index in range(points.size()):
		var next_index: int = (point_index + 1) % points.size()
		draw_line(points[point_index], points[next_index], STEEL_DARK, 2.4)
	var root := points[points.size() - 1]
	var tip := points[0]
	draw_line(root, tip, Color(0.58, 0.52, 0.37), 1.1)
	for rib_index in range(1, mini(rib_count + 1, points.size() - 1)):
		draw_line(root, points[rib_index], Color(0.58, 0.52, 0.37), 1.0)

func _draw_leg_segment(anchor: Vector2, joint_a: Vector2, joint_b: Vector2, foot: Vector2):
	draw_line(anchor, joint_a, STEEL_DARK, 4.0)
	draw_line(joint_a, joint_b, STEEL_DARK, 4.0)
	draw_line(joint_b, foot, STEEL_DARK, 4.0)
	draw_line(anchor, joint_a, ACCENT_DIM, 1.8)
	draw_line(joint_a, joint_b, ACCENT_DIM, 1.8)
	draw_line(joint_b, foot, ACCENT_DIM, 1.8)
	for point in [anchor, joint_a, joint_b]:
		draw_circle(point, 2.2, STEEL_DARK)
		draw_circle(point, 1.1, STEEL_LIGHT)

func _facing_vector(facing: String) -> Vector2:
	match facing:
		"north":
			return Vector2(0.0, -1.0)
		"south":
			return Vector2(0.0, 1.0)
		"east":
			return Vector2(1.0, 0.0)
		"west":
			return Vector2(-1.0, 0.0)
		"north_east":
			return Vector2(1.0, -1.0).normalized()
		"south_east":
			return Vector2(1.0, 1.0).normalized()
		"south_west":
			return Vector2(-1.0, 1.0).normalized()
		"north_west":
			return Vector2(-1.0, -1.0).normalized()
		_:
			return Vector2.ZERO

func _rect_in_root(control: Control) -> Rect2:
	return Rect2(control.global_position - global_position, control.size)

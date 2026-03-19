extends Control

const PROGRAMMING_SCENE_PATH := "res://scenes/main/ProgrammingMain.tscn"
const MACHINE_CAPACITY := 48.0
const OUTSIDE_STEP_INTERVAL := 0.55
const CHARGE_PRODUCTION_INTERVAL := 7.2
const ROUTE_SCAN_INTERVAL := 6.0
const ENEMY_FIGHT_INTERVAL := 2.2

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
const MACHINE_CARD := Color(0.44, 0.17, 0.15)
const MACHINE_CARD_LIGHT := Color(0.55, 0.23, 0.20)
const MACHINE_CARD_SHADE := Color(0.26, 0.11, 0.10)
const CARD_SIZE := Vector2(128.0, 156.0)
const BLANK_CARTRIDGE_DISPLAY_COUNT := 4
const DRAG_THRESHOLD := 6.0
const DROP_OVERLAP_RATIO := 0.18
const OPERATOR_ID_PHOTO := preload("res://assets/cards/operator_id_photo.svg")
const BOT_ROUTE_COLORS := [
	Color(0.82, 0.67, 0.28),
	Color(0.60, 0.76, 0.63),
]
const BOT_PREDICT_COLORS := [
	Color(0.82, 0.67, 0.28, 0.28),
	Color(0.60, 0.76, 0.63, 0.28),
]
const WORKSHOP_OPERATOR := {
	"name": "OP. LERA",
	"focus": "MECH / ARCHIVE",
}

@onready var map_region: Control = $MapRegion
@onready var background: ColorRect = $Background

var _outside_step_cooldown := 0.0
var _charge_production_cooldown := CHARGE_PRODUCTION_INTERVAL
var _route_scan_cooldown := ROUTE_SCAN_INTERVAL
var _enemy_fight_cooldowns := {}
var _selected_bot_index := 0
var _selected_power_slot_index := -1
var _drag_candidate := {}
var _active_drag := {}
var _drag_start_root := Vector2.ZERO
var _drag_mouse_root := Vector2.ZERO
var _drag_pickup_offset := Vector2.ZERO
var _current_cursor_shape := Control.CURSOR_ARROW
var _table_machine_position := Vector2.ZERO
var _table_route_position := Vector2.ZERO
var _table_charge_position := Vector2.ZERO
var _table_operator_position := Vector2.ZERO
var _table_trash_position := Vector2.ZERO
var _table_drone_positions := {}
var _table_cartridge_positions := {}
var _table_power_positions := {}
var _table_blank_positions := {}
var _table_location_positions := {}
var _table_enemy_positions := {}

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	background.visible = false
	map_region.position = Vector2.ZERO
	map_region.size = size
	map_region.gui_input.connect(_on_map_gui_input)

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
	EventBus.operator_state_changed.connect(_refresh_labels)
	_refresh_labels()
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		if is_instance_valid(map_region):
			map_region.position = Vector2.ZERO
			map_region.size = size
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_set_cursor_shape(Control.CURSOR_ARROW)

func _process(delta: float):
	if not GameState.is_run_active():
		return
	_tick_charge_machine(delta)
	_tick_route_scan(delta)
	_tick_enemy_fights(delta)
	_outside_step_cooldown -= delta
	if _outside_step_cooldown > 0.0:
		return
	_outside_step_cooldown = OUTSIDE_STEP_INTERVAL
	GameState.tick_active_bots()

func _tick_charge_machine(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	var empty_slot_index := _get_first_empty_power_slot_index()
	if empty_slot_index == -1 or not _is_charge_machine_operating():
		_charge_production_cooldown = CHARGE_PRODUCTION_INTERVAL
		return
	var charge_rect := Rect2(_table_charge_position, CARD_SIZE)
	_charge_production_cooldown -= delta
	queue_redraw()
	if _charge_production_cooldown > 0.0:
		return
	_charge_production_cooldown = CHARGE_PRODUCTION_INTERVAL
	if not GameState.consume_operator_charge_work():
		queue_redraw()
		return
	if GameState.create_power_unit_in_slot(empty_slot_index):
		_place_generated_power_card(empty_slot_index, charge_rect)
		_selected_power_slot_index = empty_slot_index
		EventBus.log_message.emit("Power card wound")
		queue_redraw()

func _tick_route_scan(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	if not GameState.can_operator_scan_route() or not _is_route_scan_operating():
		_route_scan_cooldown = ROUTE_SCAN_INTERVAL
		return
	var route_rect := Rect2(_table_route_position, CARD_SIZE)
	_route_scan_cooldown -= delta
	queue_redraw()
	if _route_scan_cooldown > 0.0:
		return
	_route_scan_cooldown = ROUTE_SCAN_INTERVAL
	var result: Dictionary = GameState.resolve_operator_scan()
	if result.is_empty():
		return
	var card: Dictionary = result.get("card", {})
	match str(result.get("kind", "")):
		"location":
			var location_id := str(card.get("id", ""))
			if not location_id.is_empty():
				_place_generated_location_card(location_id, route_rect)
				EventBus.log_message.emit("Location detected")
		"enemy":
			var enemy_id := str(card.get("id", ""))
			if not enemy_id.is_empty():
				_place_generated_enemy_card(enemy_id, route_rect)
				EventBus.log_message.emit("Hostile contact inferred")
	queue_redraw()

func _tick_enemy_fights(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	for fight_info in _get_enemy_fight_states(rect):
		var enemy_id := str(fight_info.get("enemy_id", ""))
		if enemy_id.is_empty():
			continue
		var cooldown := float(_enemy_fight_cooldowns.get(enemy_id, ENEMY_FIGHT_INTERVAL))
		cooldown -= delta
		_enemy_fight_cooldowns[enemy_id] = cooldown
		queue_redraw()
		if cooldown > 0.0:
			continue
		_enemy_fight_cooldowns[enemy_id] = ENEMY_FIGHT_INTERVAL
		var result: Dictionary = GameState.resolve_enemy_fight(enemy_id, bool(fight_info.get("use_operator", false)), Array(fight_info.get("bot_indices", [])))
		if result.is_empty():
			continue
		if bool(result.get("defeated", false)):
			_table_enemy_positions.erase(enemy_id)
			_enemy_fight_cooldowns.erase(enemy_id)
			EventBus.log_message.emit("%s defeated" % str(result.get("enemy_type", "Hostile")).replace("_", " "))
		else:
			EventBus.log_message.emit("%s fought back" % str(result.get("enemy_type", "Hostile")).replace("_", " "))

func _is_charge_machine_operating() -> bool:
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	var charge_rect := Rect2(_table_charge_position, CARD_SIZE)
	return _has_meaningful_overlap(charge_rect, operator_rect, 0.30)

func _is_route_scan_operating() -> bool:
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	var route_rect := Rect2(_table_route_position, CARD_SIZE)
	return _has_meaningful_overlap(route_rect, operator_rect, 0.30)

func _input(event: InputEvent):
	if not GameState.is_run_active():
		return
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
			_drag_pickup_offset = Vector2.ZERO
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()
		elif not _drag_candidate.is_empty():
			_complete_click_candidate(_drag_candidate)
			_drag_candidate.clear()
			_drag_pickup_offset = Vector2.ZERO
			_update_cursor_state(_drag_mouse_root)
			queue_redraw()

func _draw():
	_draw_room_shell()
	_draw_map_bay(Rect2(Vector2(24.0, 24.0), Vector2(size.x - 48.0, size.y - 48.0)))
	_draw_drag_overlay()
	if not GameState.is_run_active():
		_draw_run_end_overlay()

func _open_programming_scene():
	var blocker := _get_programming_bench_blocker()
	if not blocker.is_empty():
		EventBus.log_message.emit(blocker)
		return
	get_tree().change_scene_to_file(PROGRAMMING_SCENE_PATH)

func _refresh_labels(_value = null):
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

func _get_table_workspace_rect(rect: Rect2) -> Rect2:
	return rect.grow(-18.0)

func _clamp_table_position(position: Vector2, size: Vector2, workspace: Rect2) -> Vector2:
	return Vector2(
		clampf(position.x, workspace.position.x, workspace.end.x - size.x),
		clampf(position.y, workspace.position.y, workspace.end.y - size.y)
	)

func _ensure_table_layout(rect: Rect2):
	var workspace := _get_table_workspace_rect(rect)
	_table_machine_position = _clamp_table_position(
		GameState.get_workshop_card_position("machine_bench", workspace.position + Vector2(32.0, 24.0)) if _table_machine_position == Vector2.ZERO else _table_machine_position,
		CARD_SIZE,
		workspace
	)
	_table_route_position = _clamp_table_position(
		GameState.get_workshop_card_position("machine_route", workspace.position + Vector2(200.0, 24.0)) if _table_route_position == Vector2.ZERO else _table_route_position,
		CARD_SIZE,
		workspace
	)
	_table_charge_position = _clamp_table_position(
		GameState.get_workshop_card_position("machine_charge", workspace.position + Vector2(368.0, 24.0)) if _table_charge_position == Vector2.ZERO else _table_charge_position,
		CARD_SIZE,
		workspace
	)
	_table_operator_position = _clamp_table_position(
		GameState.get_workshop_card_position("operator_card", workspace.position + Vector2(workspace.size.x * 0.5 - CARD_SIZE.x * 0.5, 28.0)) if _table_operator_position == Vector2.ZERO else _table_operator_position,
		CARD_SIZE,
		workspace
	)
	_table_trash_position = _clamp_table_position(
		GameState.get_workshop_card_position("trash_card", Vector2(workspace.end.x - CARD_SIZE.x - 20.0, workspace.end.y - CARD_SIZE.y - 20.0)) if _table_trash_position == Vector2.ZERO else _table_trash_position,
		CARD_SIZE,
		workspace
	)

	for bot_index in range(2):
		if not _table_drone_positions.has(bot_index):
			_table_drone_positions[bot_index] = _clamp_table_position(
				GameState.get_workshop_card_position("drone_%d" % bot_index, workspace.position + Vector2(workspace.size.x - 320.0 + float(bot_index) * 146.0, 34.0)),
				CARD_SIZE,
				workspace
			)

	var valid_cartridge_ids := {}
	var visible_index := 0
	for slot_index in range(GameState.PROGRAMMED_CARTRIDGE_CAPACITY):
		var cartridge: Dictionary = GameState.get_programmed_cartridge_in_slot(slot_index)
		if cartridge.is_empty():
			continue
		var cartridge_id := str(cartridge.get("id", ""))
		valid_cartridge_ids[cartridge_id] = true
		if not _table_cartridge_positions.has(cartridge_id):
			_table_cartridge_positions[cartridge_id] = _clamp_table_position(
				GameState.get_workshop_card_position("cartridge_%s" % cartridge_id, workspace.position + Vector2(36.0 + float(visible_index) * 34.0, workspace.end.y - 190.0 + absf(float(visible_index) - 1.5) * 8.0)),
				CARD_SIZE,
				workspace
			)
		visible_index += 1
	for cartridge_id in _table_cartridge_positions.keys():
		if not valid_cartridge_ids.has(cartridge_id):
			_table_cartridge_positions.erase(cartridge_id)

	for blank_index in range(BLANK_CARTRIDGE_DISPLAY_COUNT):
		if not _table_blank_positions.has(blank_index):
			_table_blank_positions[blank_index] = _clamp_table_position(
				GameState.get_workshop_card_position("blank_%d" % blank_index, workspace.position + Vector2(workspace.end.x - 340.0 + float(blank_index) * 28.0, workspace.end.y - 190.0 + absf(float(blank_index) - 1.5) * 6.0)),
				CARD_SIZE,
				workspace
			)

	var valid_power_slots := {}
	var power_visible_index := 0
	for slot_index in range(GameState.power_unit_slots.size()):
		var power_unit: Dictionary = GameState.get_power_unit_in_slot(slot_index)
		if power_unit.is_empty():
			continue
		valid_power_slots[slot_index] = true
		if not _table_power_positions.has(slot_index):
			_table_power_positions[slot_index] = _clamp_table_position(
				GameState.get_workshop_card_position("power_%d" % slot_index, workspace.position + Vector2(workspace.end.x - 170.0 + float(power_visible_index) * 6.0, workspace.position.y + 26.0 + absf(float(power_visible_index) - 1.0) * 6.0)),
				CARD_SIZE,
				workspace
			)
		power_visible_index += 1
	for slot_index in _table_power_positions.keys():
		if not valid_power_slots.has(slot_index):
			_table_power_positions.erase(slot_index)

	var valid_location_ids := {}
	var location_visible_index := 0
	for location_card in GameState.get_location_cards():
		var location_id := str(location_card.get("id", ""))
		if location_id.is_empty():
			continue
		valid_location_ids[location_id] = true
		if not _table_location_positions.has(location_id):
			_table_location_positions[location_id] = _clamp_table_position(
				GameState.get_workshop_card_position("location_%s" % location_id, workspace.position + Vector2(520.0 + float(location_visible_index) * 18.0, workspace.end.y - 220.0 + absf(float(location_visible_index) - 1.5) * 6.0)),
				CARD_SIZE,
				workspace
			)
		location_visible_index += 1
	for location_id in _table_location_positions.keys():
		if not valid_location_ids.has(location_id):
			_table_location_positions.erase(location_id)

	var valid_enemy_ids := {}
	var enemy_visible_index := 0
	for enemy_card in GameState.get_enemy_cards():
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		valid_enemy_ids[enemy_id] = true
		if not _table_enemy_positions.has(enemy_id):
			_table_enemy_positions[enemy_id] = _clamp_table_position(
				GameState.get_workshop_card_position("enemy_%s" % enemy_id, workspace.position + Vector2(workspace.end.x - 240.0 + float(enemy_visible_index) * 14.0, workspace.end.y - 220.0 + absf(float(enemy_visible_index) - 1.0) * 6.0)),
				CARD_SIZE,
				workspace
			)
		enemy_visible_index += 1
	for enemy_id in _table_enemy_positions.keys():
		if not valid_enemy_ids.has(enemy_id):
			_table_enemy_positions.erase(enemy_id)

func _on_map_gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		var root_point := map_region.global_position - global_position + motion.position
		_update_cursor_state(root_point)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_event: InputEventMouseButton = event
		var root_point := map_region.global_position - global_position + mouse_event.position
		_ensure_table_layout(_rect_in_root(map_region))
		var tape_data := _get_tape_hand_data(_rect_in_root(map_region))
		var drone_data := _get_table_drone_data(_rect_in_root(map_region))
		var badge_hit := _get_top_tape_badge_at_point(drone_data, root_point)
		if not badge_hit.is_empty():
			var bot_index := int(badge_hit["index"])
			var loaded_cartridge: Dictionary = badge_hit["loaded_cartridge"]
			if not loaded_cartridge.is_empty():
				_selected_bot_index = bot_index
				_drag_start_root = root_point
				_drag_pickup_offset = Vector2(18.0, 24.0)
				_drag_candidate = {
					"kind": "cartridge",
					"source": "bot",
					"bot_index": bot_index,
					"cartridge_id": str(loaded_cartridge.get("id", "")),
				}
			return
		var top_card := _get_top_table_card_at_point(_rect_in_root(map_region), root_point)
		if not top_card.is_empty():
			match str(top_card.get("kind", "")):
				"bench_card":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {"kind": "bench_card"}
					return
				"route_card":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {"kind": "route_card"}
					return
				"charge_card":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {"kind": "charge_card"}
					return
				"cartridge":
					var cartridge_id := str(top_card.get("cartridge_id", ""))
					if not cartridge_id.is_empty():
						_drag_start_root = root_point
						_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
						_drag_candidate = {
							"kind": "cartridge",
							"source": "table",
							"cartridge_id": cartridge_id,
						}
						_selected_power_slot_index = -1
						GameState.select_programmed_cartridge(cartridge_id)
					return
				"blank":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {
						"kind": "blank",
						"blank_index": int(top_card.get("blank_index", -1)),
					}
					return
				"power":
					var slot_index := int(top_card.get("slot_index", -1))
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {
						"kind": "power",
						"source": "table",
						"slot_index": slot_index,
					}
					_selected_power_slot_index = slot_index
					return
				"location":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {
						"kind": "location",
						"location_id": str(top_card.get("location_id", "")),
						"card_data": Dictionary(top_card.get("card_data", {})),
					}
					return
				"enemy":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {
						"kind": "enemy",
						"enemy_id": str(top_card.get("enemy_id", "")),
						"card_data": Dictionary(top_card.get("card_data", {})),
					}
					return
				"bot":
					_selected_bot_index = int(top_card.get("bot_index", 0))
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {
						"kind": "bot",
						"bot_index": _selected_bot_index,
					}
					return
				"operator":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {"kind": "operator"}
					return
				"trash_card":
					_drag_start_root = root_point
					_drag_pickup_offset = root_point - Rect2(top_card["rect"]).position
					_drag_candidate = {"kind": "trash_card"}
					return

func _complete_click_candidate(candidate: Dictionary):
	match str(candidate.get("kind", "")):
		"bot":
			_selected_bot_index = int(candidate.get("bot_index", 0))
		"bench_card":
			_open_programming_scene()

func _complete_drag(drop_root: Vector2):
	match str(_active_drag.get("kind", "")):
		"cartridge":
			_complete_cartridge_drag(drop_root)
		"power":
			_complete_power_drag(drop_root)
		"bot":
			_complete_bot_drag(drop_root)
		"blank":
			_complete_blank_drag(drop_root)
		"location":
			_complete_table_card_drag("location", drop_root, CARD_SIZE)
		"enemy":
			_complete_table_card_drag("enemy", drop_root, CARD_SIZE)
		"operator":
			_complete_table_card_drag("operator", drop_root, CARD_SIZE)
		"bench_card":
			_complete_machine_card_drag("bench", drop_root, CARD_SIZE)
		"route_card":
			_complete_machine_card_drag("route", drop_root, CARD_SIZE)
		"charge_card":
			_complete_machine_card_drag("charge", drop_root, CARD_SIZE)
		"trash_card":
			_complete_machine_card_drag("trash", drop_root, CARD_SIZE)

func _update_cursor_state(root_point: Vector2):
	_set_cursor_shape(_cursor_shape_for_point(root_point))

func _set_cursor_shape(shape: int):
	if _current_cursor_shape == shape:
		return
	_current_cursor_shape = shape
	mouse_default_cursor_shape = shape
	map_region.mouse_default_cursor_shape = shape
	Input.set_default_cursor_shape(shape)

func _cursor_shape_for_point(root_point: Vector2) -> int:
	if not _active_drag.is_empty():
		return Control.CURSOR_CAN_DROP if _is_valid_drop_target(root_point) else Control.CURSOR_DRAG

	_ensure_table_layout(_rect_in_root(map_region))
	var drone_slots := _get_table_drone_data(_rect_in_root(map_region))
	if not _get_top_tape_badge_at_point(drone_slots, root_point).is_empty():
		return Control.CURSOR_POINTING_HAND
	var top_card := _get_top_table_card_at_point(_rect_in_root(map_region), root_point)
	if not top_card.is_empty():
		return Control.CURSOR_POINTING_HAND

	return Control.CURSOR_ARROW

func _is_valid_drop_target(root_point: Vector2) -> bool:
	var drop_rect := _get_drop_rect(root_point)
	match str(_active_drag.get("kind", "")):
		"cartridge":
			return _get_drop_drone_index_for_rect(drop_rect) != -1 or _is_rect_in_tape_hand(drop_rect) or _is_rect_in_recycle_zone(drop_rect)
		"power":
			return _get_drop_drone_index_for_rect(drop_rect) != -1 or _is_rect_in_charge_machine(drop_rect) or _is_rect_in_table_workspace(drop_rect) or _is_rect_in_recycle_zone(drop_rect)
		"location":
			return _is_rect_in_table_workspace(drop_rect) or _is_rect_in_recycle_zone(drop_rect)
		"bot", "blank", "operator", "enemy":
			return _is_rect_in_table_workspace(drop_rect) or _is_rect_in_route_machine(drop_rect)
		"bench_card", "route_card", "charge_card", "trash_card":
			return _is_rect_in_table_workspace(drop_rect)
	return false

func _complete_cartridge_drag(drop_root: Vector2):
	var cartridge_id := str(_active_drag.get("cartridge_id", ""))
	if cartridge_id.is_empty():
		return
	var drop_rect := _get_drop_rect(drop_root)
	var target_bot := _get_drop_drone_index_for_rect(drop_rect)
	if target_bot != -1:
		_selected_bot_index = target_bot
		if GameState.load_cartridge_into_bot(target_bot, cartridge_id):
			EventBus.log_message.emit("%s loaded" % _bot_display_name(target_bot))
			return
	if _is_rect_in_tape_hand(drop_rect) and str(_active_drag.get("source", "")) == "bot":
		var source_bot := int(_active_drag.get("bot_index", -1))
		if GameState.unload_bot_cartridge(source_bot):
			_place_table_card(_table_cartridge_positions, cartridge_id, drop_root, CARD_SIZE)
			EventBus.log_message.emit("%s unloaded" % _bot_display_name(source_bot))
			return
	if _is_rect_in_recycle_zone(drop_rect):
		if str(_active_drag.get("source", "")) == "bot":
			var source_bot := int(_active_drag.get("bot_index", -1))
			if GameState.unload_bot_cartridge(source_bot) and GameState.recycle_programmed_cartridge(cartridge_id):
				EventBus.log_message.emit("Tape card recycled into blank stock")
				return
		elif str(_active_drag.get("source", "")) == "table":
			if GameState.recycle_programmed_cartridge(cartridge_id):
				EventBus.log_message.emit("Tape card recycled into blank stock")
				return
	if _is_rect_in_table_workspace(drop_rect):
		_place_table_card(_table_cartridge_positions, cartridge_id, drop_root, CARD_SIZE)
		return

func _complete_power_drag(drop_root: Vector2):
	var drop_rect := _get_drop_rect(drop_root)
	var target_bot := _get_drop_drone_index_for_rect(drop_rect)
	var source := str(_active_drag.get("source", ""))
	var slot_index := int(_active_drag.get("slot_index", -1))
	if target_bot != -1:
		_selected_bot_index = target_bot
		if source == "table" or source == "shelf":
			if GameState.install_power_unit_from_slot(target_bot, slot_index) >= 0:
				_table_power_positions.erase(slot_index)
				_selected_power_slot_index = -1
				EventBus.log_message.emit("%s power added" % _bot_display_name(target_bot))
				return
	if _is_rect_in_charge_machine(drop_rect):
		if GameState.recharge_power_unit_in_slot(slot_index):
			EventBus.log_message.emit("Power card recharged")
			return
	if _is_rect_in_recycle_zone(drop_rect):
		if GameState.discard_power_unit_in_slot(slot_index):
			_table_power_positions.erase(slot_index)
			_selected_power_slot_index = -1
			EventBus.log_message.emit("Power card discarded")
			return
	if _is_rect_in_table_workspace(drop_rect):
		_place_table_card(_table_power_positions, slot_index, drop_root, CARD_SIZE)

func _complete_bot_drag(drop_root: Vector2):
	var bot_index := int(_active_drag.get("bot_index", -1))
	var drop_rect := _get_drop_rect(drop_root)
	if _is_rect_in_route_machine(drop_rect):
		_selected_bot_index = bot_index
		if GameState.can_recover_bot(bot_index):
			if not GameState.recover_bot(bot_index):
				EventBus.log_message.emit("Recovery failed")
			return
		var blocker: String = GameState.get_bot_launch_blocker(bot_index)
		if blocker.is_empty():
			if GameState.launch_bot(bot_index):
				EventBus.log_message.emit("%s launched" % _bot_display_name(bot_index))
		else:
			EventBus.log_message.emit("%s" % blocker)
		return
	if not _is_rect_in_table_workspace(drop_rect):
		return
	_place_table_card(_table_drone_positions, bot_index, drop_root, CARD_SIZE)

func _complete_blank_drag(drop_root: Vector2):
	if not _is_rect_in_table_workspace(_get_drop_rect(drop_root)):
		return
	var blank_index := int(_active_drag.get("blank_index", -1))
	_place_table_card(_table_blank_positions, blank_index, drop_root, CARD_SIZE)

func _complete_table_card_drag(kind: String, drop_root: Vector2, card_size: Vector2):
	var drop_rect := _get_drop_rect(drop_root)
	if kind == "location" and _is_rect_in_recycle_zone(drop_rect):
		var location_id := str(_active_drag.get("location_id", ""))
		if location_id.is_empty():
			return
		if GameState.forget_location_card(location_id):
			_table_location_positions.erase(location_id)
			EventBus.log_message.emit("Location card forgotten")
		return
	if not _is_rect_in_table_workspace(_get_drop_rect(drop_root)):
		return
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var clamped := _clamp_table_position(drop_root - _drag_pickup_offset, card_size, workspace)
	if kind == "operator":
		_table_operator_position = clamped
		GameState.set_workshop_card_position("operator_card", clamped)
	elif kind == "location":
		var location_id := str(_active_drag.get("location_id", ""))
		if location_id.is_empty():
			return
		_table_location_positions[location_id] = clamped
		GameState.set_workshop_card_position("location_%s" % location_id, clamped)
	elif kind == "enemy":
		var enemy_id := str(_active_drag.get("enemy_id", ""))
		if enemy_id.is_empty():
			return
		_table_enemy_positions[enemy_id] = clamped
		GameState.set_workshop_card_position("enemy_%s" % enemy_id, clamped)
	elif kind == "trash":
		_table_trash_position = clamped
		GameState.set_workshop_card_position("trash_card", clamped)

func _get_drop_drone_index_for_rect(drop_rect: Rect2) -> int:
	var slots := _get_table_drone_data(_rect_in_root(map_region))
	var best_index := -1
	var best_area := 0.0
	var min_overlap := CARD_SIZE.x * CARD_SIZE.y * DROP_OVERLAP_RATIO
	for slot in slots:
		if not bool(slot["available_in_workshop"]):
			continue
		var overlap := Rect2(slot["rect"]).intersection(drop_rect)
		var overlap_area := overlap.size.x * overlap.size.y
		if overlap_area >= min_overlap and overlap_area > best_area:
			best_area = overlap_area
			best_index = int(slot["index"])
	return best_index

func _is_point_in_tape_hand(root_point: Vector2) -> bool:
	return Rect2(_get_tape_hand_data(_rect_in_root(map_region))["hand_zone"]).has_point(root_point)

func _is_point_in_table_workspace(root_point: Vector2) -> bool:
	return _get_table_workspace_rect(_rect_in_root(map_region)).has_point(root_point)

func _is_point_in_route_machine(root_point: Vector2) -> bool:
	return Rect2(_get_machine_card_data(_rect_in_root(map_region))["route_rect"]).has_point(root_point)

func _is_point_in_charge_machine(root_point: Vector2) -> bool:
	return Rect2(_get_machine_card_data(_rect_in_root(map_region))["charge_rect"]).has_point(root_point)

func _is_point_in_recycle_zone(root_point: Vector2) -> bool:
	var recycle_rect := Rect2(_get_tape_hand_data(_rect_in_root(map_region))["recycle_hotspot"])
	return recycle_rect.has_point(root_point)

func _get_drop_rect(drop_root: Vector2) -> Rect2:
	return Rect2(drop_root - _drag_pickup_offset, CARD_SIZE)

func _is_rect_in_tape_hand(drop_rect: Rect2) -> bool:
	return Rect2(_get_tape_hand_data(_rect_in_root(map_region))["hand_zone"]).intersects(drop_rect)

func _is_rect_in_table_workspace(drop_rect: Rect2) -> bool:
	return _get_table_workspace_rect(_rect_in_root(map_region)).intersects(drop_rect)

func _is_rect_in_route_machine(drop_rect: Rect2) -> bool:
	return _has_meaningful_overlap(Rect2(_get_machine_card_data(_rect_in_root(map_region))["route_rect"]), drop_rect)

func _is_rect_in_charge_machine(drop_rect: Rect2) -> bool:
	return _has_meaningful_overlap(Rect2(_get_machine_card_data(_rect_in_root(map_region))["charge_rect"]), drop_rect)

func _is_rect_in_recycle_zone(drop_rect: Rect2) -> bool:
	return _has_meaningful_overlap(Rect2(_get_tape_hand_data(_rect_in_root(map_region))["recycle_hotspot"]), drop_rect)

func _has_meaningful_overlap(target_rect: Rect2, drop_rect: Rect2, min_ratio: float = DROP_OVERLAP_RATIO) -> bool:
	var overlap := target_rect.intersection(drop_rect)
	return overlap.size.x * overlap.size.y >= CARD_SIZE.x * CARD_SIZE.y * min_ratio

func _place_table_card(store: Dictionary, key, drop_root: Vector2, card_size: Vector2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var clamped := _clamp_table_position(drop_root - _drag_pickup_offset, card_size, workspace)
	store[key] = clamped
	if store == _table_cartridge_positions:
		GameState.set_workshop_card_position("cartridge_%s" % str(key), clamped)
	elif store == _table_power_positions:
		GameState.set_workshop_card_position("power_%d" % int(key), clamped)
	elif store == _table_blank_positions:
		GameState.set_workshop_card_position("blank_%d" % int(key), clamped)
	elif store == _table_drone_positions:
		GameState.set_workshop_card_position("drone_%d" % int(key), clamped)
	elif store == _table_location_positions:
		GameState.set_workshop_card_position("location_%s" % str(key), clamped)
	elif store == _table_enemy_positions:
		GameState.set_workshop_card_position("enemy_%s" % str(key), clamped)

func _place_generated_location_card(location_id: String, route_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		route_rect.position + Vector2(route_rect.size.x + 12.0, 12.0),
		CARD_SIZE,
		workspace
	)
	_table_location_positions[location_id] = generated_position
	GameState.set_workshop_card_position("location_%s" % location_id, generated_position)

func _place_generated_enemy_card(enemy_id: String, route_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		route_rect.position + Vector2(route_rect.size.x + 12.0, route_rect.size.y - 28.0),
		CARD_SIZE,
		workspace
	)
	_table_enemy_positions[enemy_id] = generated_position
	GameState.set_workshop_card_position("enemy_%s" % enemy_id, generated_position)

func _place_generated_power_card(slot_index: int, charge_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		charge_rect.position + Vector2(12.0, charge_rect.size.y + 10.0),
		CARD_SIZE,
		workspace
	)
	_table_power_positions[slot_index] = generated_position
	GameState.set_workshop_card_position("power_%d" % slot_index, generated_position)

func _complete_machine_card_drag(kind: String, drop_root: Vector2, card_size: Vector2):
	if not _is_point_in_table_workspace(drop_root):
		return
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var clamped := _clamp_table_position(drop_root - _drag_pickup_offset, card_size, workspace)
	if kind == "bench":
		_table_machine_position = clamped
		GameState.set_workshop_card_position("machine_bench", clamped)
	elif kind == "route":
		_table_route_position = clamped
		GameState.set_workshop_card_position("machine_route", clamped)
	elif kind == "charge":
		_table_charge_position = clamped
		GameState.set_workshop_card_position("machine_charge", clamped)
	elif kind == "trash":
		_table_trash_position = clamped
		GameState.set_workshop_card_position("trash_card", clamped)

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
	var frame := _draw_region_frame(rect, "")
	var body := frame.grow(-18.0)
	_draw_route_table_machine(body)

func _draw_cabinet_bay(rect: Rect2):
	_draw_region_frame(rect, "")

func _draw_map_bay(rect: Rect2):
	var workspace := _get_table_workspace_rect(rect)
	_ensure_table_layout(rect)
	draw_rect(rect, Color(0.10, 0.09, 0.08))
	draw_rect(workspace, Color(0.17, 0.14, 0.11))
	draw_rect(workspace.grow(-4.0), Color(0.20, 0.17, 0.13))
	draw_rect(workspace, PANEL_BORDER, false, 2.0)
	for card_info in _get_table_visual_cards(rect):
		match str(card_info.get("kind", "")):
			"bench_card":
				_draw_machine_card(Rect2(card_info["rect"]), "bench")
			"route_card":
				_draw_machine_card(Rect2(card_info["rect"]), "route")
			"charge_card":
				_draw_machine_card(Rect2(card_info["rect"]), "charge")
			"operator":
				_draw_operator_card(Rect2(card_info["rect"]))
			"cartridge":
				_draw_tape_card(Rect2(card_info["rect"]), true, str(card_info.get("label", "")), bool(card_info.get("selected", false)))
			"blank":
				_draw_tape_card(Rect2(card_info["rect"]), false, "", false)
			"location":
				_draw_location_card(Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"enemy":
				_draw_enemy_card(Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"bot":
				_draw_table_drone_card(Dictionary(card_info["slot"]))
			"power":
				_draw_power_card(Rect2(card_info["rect"]), int(card_info.get("charge", 0)), int(card_info.get("max_charge", 1)), bool(card_info.get("selected", false)))
			"trash_card":
				_draw_trash_card(Rect2(card_info["rect"]), _active_drag.is_empty() == false and _is_point_in_recycle_zone(_drag_mouse_root))
	for process_info in _get_active_process_overlays(rect):
		_draw_process_bar(Rect2(process_info["rect"]), float(process_info["progress"]))

func _draw_drag_overlay():
	if _active_drag.is_empty():
		return
	var drag_kind := str(_active_drag.get("kind", ""))
	var tape_data := _get_tape_hand_data(_rect_in_root(map_region))
	var tape_rect: Rect2 = tape_data["hand_zone"]
	var drone_slots := _get_table_drone_data(_rect_in_root(map_region))
	if drag_kind == "cartridge":
		var drag_rect := _get_drop_rect(_drag_mouse_root)
		if _is_rect_in_tape_hand(drag_rect) and str(_active_drag.get("source", "")) == "bot":
			draw_rect(tape_rect.grow(4.0), Color(0.80, 0.66, 0.27, 0.10))
		if _is_rect_in_recycle_zone(drag_rect):
			draw_rect(Rect2(tape_data["recycle_hotspot"]).grow(3.0), Color(0.66, 0.28, 0.18, 0.20))
		for slot in drone_slots:
			if Rect2(slot["rect"]).intersects(drag_rect) and bool(slot["available_in_workshop"]):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "power":
		var drag_rect := _get_drop_rect(_drag_mouse_root)
		for slot in drone_slots:
			if Rect2(slot["rect"]).intersects(drag_rect) and bool(slot["available_in_workshop"]):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		if _is_rect_in_charge_machine(drag_rect):
			draw_rect(Rect2(_get_machine_card_data(_rect_in_root(map_region))["charge_rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		if _is_rect_in_recycle_zone(drag_rect):
			draw_rect(Rect2(tape_data["recycle_hotspot"]).grow(3.0), Color(0.66, 0.28, 0.18, 0.20))
	elif drag_kind == "bot":
		if _is_rect_in_route_machine(_get_drop_rect(_drag_mouse_root)):
			draw_rect(Rect2(_get_machine_card_data(_rect_in_root(map_region))["route_rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))

	var preview_rect := Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE)
	if drag_kind == "cartridge":
		_draw_tape_card(preview_rect, true, "", false)
	elif drag_kind == "power":
		_draw_power_card(preview_rect, GameState.BOT_POWER_CAPACITY, GameState.BOT_POWER_CAPACITY, false)
	elif drag_kind == "bot":
		var drag_drone_slots: Array = _get_table_drone_data(_rect_in_root(map_region))
		var slot: Dictionary = drag_drone_slots[int(_active_drag.get("bot_index", 0))]
		var moved_slot: Dictionary = slot.duplicate(true)
		moved_slot["rect"] = Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE)
		moved_slot["body_hotspot"] = moved_slot["rect"]
		moved_slot["tape_badge_rect"] = Rect2(Vector2(moved_slot["rect"].position.x + 14.0, moved_slot["rect"].end.y - 48.0), Vector2(48.0, 16.0))
		_draw_table_drone_card(moved_slot)
	elif drag_kind == "blank":
		_draw_tape_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), false, "", false)
	elif drag_kind == "location":
		_draw_location_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "enemy":
		_draw_enemy_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "operator":
		_draw_operator_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE))
	elif drag_kind == "trash_card":
		_draw_trash_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), false)
	elif drag_kind == "bench_card":
		_draw_machine_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "bench")
	elif drag_kind == "route_card":
		_draw_machine_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "route")
	elif drag_kind == "charge_card":
		_draw_machine_card(Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "charge")

func _get_active_process_overlays(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var overlays: Array = []
	if _is_charge_machine_operating() and _get_first_empty_power_slot_index() != -1:
		overlays.append({
			"rect": Rect2(_table_charge_position, CARD_SIZE),
			"progress": clampf(1.0 - (_charge_production_cooldown / CHARGE_PRODUCTION_INTERVAL), 0.0, 1.0),
		})
	if _is_route_scan_operating() and GameState.can_operator_scan_route():
		overlays.append({
			"rect": Rect2(_table_route_position, CARD_SIZE),
			"progress": clampf(1.0 - (_route_scan_cooldown / ROUTE_SCAN_INTERVAL), 0.0, 1.0),
		})
	for fight_info in _get_enemy_fight_states(rect):
		var enemy_id := str(fight_info.get("enemy_id", ""))
		if enemy_id.is_empty():
			continue
		var cooldown := float(_enemy_fight_cooldowns.get(enemy_id, ENEMY_FIGHT_INTERVAL))
		overlays.append({
			"rect": Rect2(fight_info.get("rect", Rect2())),
			"progress": clampf(1.0 - (cooldown / ENEMY_FIGHT_INTERVAL), 0.0, 1.0),
		})
	return overlays

func _draw_process_bar(card_rect: Rect2, progress: float):
	var bar_rect := Rect2(
		Vector2(card_rect.position.x + 10.0, card_rect.position.y - 12.0),
		Vector2(card_rect.size.x - 20.0, 8.0)
	)
	var fill_rect := Rect2(bar_rect.position + Vector2(1.0, 1.0), Vector2((bar_rect.size.x - 2.0) * clampf(progress, 0.0, 1.0), bar_rect.size.y - 2.0))
	draw_rect(bar_rect, Color(0.06, 0.06, 0.07))
	draw_rect(bar_rect.grow(-1.0), Color(0.16, 0.16, 0.17))
	draw_rect(bar_rect, PANEL_BORDER, false, 1.0)
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, Color(0.94, 0.94, 0.88))

func _draw_run_end_overlay():
	var overlay_rect := Rect2(Vector2.ZERO, size)
	draw_rect(overlay_rect, Color(0.0, 0.0, 0.0, 0.28))
	var plaque_rect := Rect2(Vector2(size.x * 0.5 - 120.0, 36.0), Vector2(240.0, 30.0))
	draw_rect(plaque_rect, Color(0.28, 0.10, 0.10))
	draw_rect(plaque_rect.grow(-2.0), Color(0.18, 0.08, 0.08))
	draw_rect(plaque_rect, PANEL_BORDER, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(plaque_rect.position.x, plaque_rect.position.y + 20.0), "RUN ENDED", HORIZONTAL_ALIGNMENT_CENTER, plaque_rect.size.x, 14, TEXT)

func _get_machine_card_data(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	return {
		"bench_rect": Rect2(_table_machine_position, CARD_SIZE),
		"route_rect": Rect2(_table_route_position, CARD_SIZE),
		"charge_rect": Rect2(_table_charge_position, CARD_SIZE),
	}

func _draw_card_shell(rect: Rect2, card_class: String, selected: bool, hovered: bool) -> Dictionary:
	var back_rect := Rect2(rect.position + Vector2(3.0, -3.0), rect.size)
	var face_rect := rect.grow(-3.0)
	var art_rect := Rect2(
		Vector2(face_rect.position.x + 12.0, face_rect.position.y + 18.0),
		Vector2(face_rect.size.x - 24.0, 86.0)
	)
	var info_rect := Rect2(
		Vector2(face_rect.position.x + 12.0, face_rect.end.y - 40.0),
		Vector2(face_rect.size.x - 24.0, 24.0)
	)
	var colors := _get_card_class_colors(card_class)
	draw_rect(back_rect, SHADOW)
	draw_rect(rect, colors["edge"])
	draw_rect(face_rect, colors["face"])
	draw_rect(Rect2(face_rect.position, Vector2(face_rect.size.x, 12.0)), colors["band"])
	draw_rect(back_rect, colors["shadow_border"], false, 1.0)
	draw_rect(rect, ACCENT if selected else PANEL_BORDER, false, 1.0)
	if hovered:
		draw_rect(rect.grow(4.0), Color(0.80, 0.66, 0.27, 0.14))
	return {
		"back_rect": back_rect,
		"face_rect": face_rect,
		"art_rect": art_rect,
		"info_rect": info_rect,
	}

func _draw_card_template(
	rect: Rect2,
	card_class: String,
	selected: bool,
	hovered: bool,
	face_fill: Variant = null,
	art_fill: Variant = null,
	art_border: Variant = null,
	info_rule_color: Variant = null
) -> Dictionary:
	var shell := _draw_card_shell(rect, card_class, selected, hovered)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	if face_fill != null:
		draw_rect(face_rect, face_fill)
	if art_fill != null:
		draw_rect(art_rect, art_fill)
	if art_border != null:
		draw_rect(art_rect, art_border, false, 1.0)
	if info_rule_color != null:
		draw_line(
			Vector2(info_rect.position.x, info_rect.end.y - 2.0),
			Vector2(info_rect.end.x, info_rect.end.y - 2.0),
			info_rule_color,
			2.0
		)
	return shell

func _get_card_class_colors(card_class: String) -> Dictionary:
	match card_class:
		"machine":
			return {
				"edge": MACHINE_CARD_SHADE,
				"face": MACHINE_CARD,
				"band": MACHINE_CARD_LIGHT,
				"shadow_border": Color(0.45, 0.25, 0.22),
			}
		"agent":
			return {
				"edge": STEEL_DARK,
				"face": Color(0.14, 0.15, 0.18),
				"band": Color(0.19, 0.20, 0.24),
				"shadow_border": Color(0.22, 0.23, 0.26),
			}
		"medium":
			return {
				"edge": STEEL,
				"face": TAPE,
				"band": Color(0.89, 0.84, 0.69),
				"shadow_border": Color(0.42, 0.36, 0.24),
			}
		"charge":
			return {
				"edge": TAPE_SHADE,
				"face": TAPE,
				"band": Color(0.90, 0.83, 0.63),
				"shadow_border": Color(0.45, 0.38, 0.22),
			}
		"place":
			return {
				"edge": Color(0.27, 0.31, 0.38),
				"face": Color(0.68, 0.72, 0.78),
				"band": Color(0.80, 0.84, 0.88),
				"shadow_border": Color(0.32, 0.36, 0.42),
			}
		"threat":
			return {
				"edge": Color(0.27, 0.10, 0.10),
				"face": Color(0.46, 0.16, 0.15),
				"band": Color(0.58, 0.22, 0.20),
				"shadow_border": Color(0.32, 0.12, 0.11),
			}
		_:
			return {
				"edge": STEEL_DARK,
				"face": PANEL_INNER,
				"band": STEEL,
				"shadow_border": PANEL_BORDER,
			}

func _draw_machine_card(rect: Rect2, kind: String):
	var shell := _draw_card_template(rect, "machine", false, false, null, Color(0.15, 0.13, 0.12), PANEL_BORDER, ACCENT_DIM)
	var art_rect: Rect2 = shell["art_rect"]
	match kind:
		"bench":
			_draw_programming_bench_art(art_rect.grow(-6.0))
		"route":
			_draw_route_table_card_art(art_rect.grow(-3.0))
		"charge":
			_draw_charge_machine_art(art_rect.grow(-6.0))
		"trash":
			_draw_trash_machine_art(art_rect.grow(-6.0))

func _draw_programming_bench_art(rect: Rect2):
	var body_rect := Rect2(
		Vector2(rect.position.x + 8.0, rect.position.y + 12.0),
		Vector2(rect.size.x - 16.0, 30.0)
	)
	var tape_rect := Rect2(
		Vector2(body_rect.position.x + 12.0, body_rect.position.y + 9.0),
		Vector2(body_rect.size.x - 24.0, 12.0)
	)
	var left_roller := Rect2(Vector2(tape_rect.position.x - 10.0, tape_rect.position.y - 4.0), Vector2(6.0, tape_rect.size.y + 8.0))
	var right_roller := Rect2(Vector2(tape_rect.end.x + 4.0, tape_rect.position.y - 4.0), Vector2(6.0, tape_rect.size.y + 8.0))
	var punch_rect := Rect2(Vector2(tape_rect.get_center().x - 7.0, tape_rect.position.y - 10.0), Vector2(14.0, 28.0))
	var deck_rect := Rect2(
		Vector2(body_rect.position.x + 8.0, body_rect.end.y + 10.0),
		Vector2(body_rect.size.x - 16.0, 10.0)
	)
	draw_rect(body_rect, Color(0.14, 0.15, 0.18))
	draw_rect(body_rect, PANEL_BORDER, false, 1.0)
	draw_rect(Rect2(Vector2(body_rect.position.x + 12.0, body_rect.position.y + 8.0), Vector2(body_rect.size.x - 24.0, 3.0)), ACCENT_DIM)
	draw_rect(left_roller, STEEL_DARK)
	draw_rect(left_roller.grow(-1.0), STEEL)
	draw_rect(right_roller, STEEL_DARK)
	draw_rect(right_roller.grow(-1.0), STEEL)
	_draw_preview_tape(tape_rect, 6, 1)
	draw_rect(punch_rect, Color(0.61, 0.54, 0.40))
	draw_rect(punch_rect.grow(-2.0), Color(0.71, 0.65, 0.49))
	draw_rect(punch_rect, PANEL_BORDER, false, 1.0)
	draw_rect(deck_rect, Color(0.12, 0.13, 0.15))
	draw_rect(deck_rect, PANEL_BORDER, false, 1.0)
	var key_origin := deck_rect.position + Vector2(16.0, 3.0)
	for column in range(4):
		var key_center := key_origin + Vector2(column * 13.0, 2.0)
		draw_circle(key_center, 1.6, STEEL_DARK)
		draw_circle(key_center, 1.0, Color(0.17, 0.18, 0.20))

func _draw_route_table_card_art(rect: Rect2):
	var outer_size := minf(rect.size.x - 2.0, rect.size.y - 2.0)
	var display_rect := Rect2(rect.position + (rect.size - Vector2(outer_size, outer_size)) * 0.5, Vector2(outer_size, outer_size))
	draw_rect(display_rect, Color(0.10, 0.11, 0.13))
	draw_rect(display_rect, PANEL_BORDER, false, 1.0)
	var grid_size: Vector2 = GameState.grid_size
	var cells_x: int = int(grid_size.x)
	var cells_y: int = int(grid_size.y)
	var cell_size := minf((display_rect.size.x - 12.0) / float(cells_x), (display_rect.size.y - 12.0) / float(cells_y))
	var grid_display_size := Vector2(cell_size * cells_x, cell_size * cells_y)
	var origin := display_rect.position + (display_rect.size - grid_display_size) * 0.5
	for y in range(cells_y):
		for x in range(cells_x):
			var center := origin + Vector2((float(x) + 0.5) * cell_size, (float(y) + 0.5) * cell_size)
			draw_circle(center, cell_size * 0.18, DISK_OFF)
	_draw_shelter_marker(origin, cell_size)
	_draw_discovery_markers(origin, cell_size)
	_draw_outside_bot_routes(origin, cell_size)

func _draw_trash_machine_art(rect: Rect2):
	var inner_rect := rect.grow(-4.0)
	var bin_color := Color(0.28, 0.29, 0.31)
	var body_rect := Rect2(
		Vector2(inner_rect.position.x + 16.0, inner_rect.position.y + 16.0),
		Vector2(inner_rect.size.x - 32.0, 36.0)
	)
	var lid_rect := Rect2(
		Vector2(body_rect.position.x - 5.0, body_rect.position.y - 8.0),
		Vector2(body_rect.size.x + 10.0, 8.0)
	)
	var slot_rect := Rect2(
		Vector2(body_rect.position.x + 12.0, body_rect.position.y - 2.0),
		Vector2(body_rect.size.x - 24.0, 2.0)
	)
	var paper_rect := Rect2(
		Vector2(inner_rect.position.x + inner_rect.size.x * 0.5 - 10.0, inner_rect.position.y + 8.0),
		Vector2(20.0, 14.0)
	)
	draw_rect(lid_rect, bin_color)
	draw_rect(lid_rect.grow(-1.0), Color(0.20, 0.21, 0.23))
	draw_rect(lid_rect, STEEL_LIGHT, false, 1.0)
	draw_rect(body_rect, bin_color)
	draw_rect(body_rect.grow(-2.0), Color(0.18, 0.19, 0.20))
	draw_rect(body_rect, STEEL_LIGHT, false, 1.0)
	draw_rect(slot_rect, Color(0.09, 0.10, 0.12))
	draw_rect(paper_rect, TAPE)
	draw_rect(paper_rect, Color(0.60, 0.52, 0.31), false, 1.0)
	draw_line(paper_rect.position + Vector2(4.0, 4.0), paper_rect.end - Vector2(4.0, 4.0), Color(0.46, 0.16, 0.13), 1.2)
	draw_line(
		Vector2(body_rect.position.x + 12.0, body_rect.position.y + 4.0),
		Vector2(body_rect.position.x + 8.0, body_rect.end.y - 6.0),
		STEEL_LIGHT,
		1.0
	)
	draw_line(
		Vector2(body_rect.end.x - 12.0, body_rect.position.y + 4.0),
		Vector2(body_rect.end.x - 8.0, body_rect.end.y - 6.0),
		STEEL_LIGHT,
		1.0
	)

func _draw_charge_machine_art(rect: Rect2):
	var inner_rect := rect.grow(-4.0)
	var drum_rect := Rect2(
		Vector2(inner_rect.position.x + 12.0, inner_rect.position.y + 16.0),
		Vector2(inner_rect.size.x - 24.0, 28.0)
	)
	var tray_rect := Rect2(
		Vector2(inner_rect.position.x + 16.0, inner_rect.end.y - 28.0),
		Vector2(inner_rect.size.x - 32.0, 14.0)
	)
	var crank_center := Vector2(drum_rect.end.x - 12.0, drum_rect.get_center().y)
	draw_rect(drum_rect, Color(0.24, 0.25, 0.28))
	draw_rect(drum_rect.grow(-2.0), Color(0.17, 0.18, 0.20))
	draw_rect(drum_rect, STEEL_LIGHT, false, 1.0)
	_draw_power_suit(Rect2(drum_rect.position + Vector2(10.0, 8.0), Vector2(drum_rect.size.x - 32.0, 10.0)), true, 1.3)
	draw_line(crank_center + Vector2(-8.0, 0.0), crank_center + Vector2(3.0, 0.0), TAPE, 1.5)
	draw_line(crank_center + Vector2(3.0, 0.0), crank_center + Vector2(8.0, -6.0), TAPE, 1.5)
	draw_circle(crank_center + Vector2(8.0, -6.0), 2.0, TAPE)
	draw_rect(tray_rect, TAPE)
	draw_rect(tray_rect, TAPE_SHADE, false, 1.0)
	draw_rect(Rect2(tray_rect.position + Vector2(10.0, 3.0), Vector2(tray_rect.size.x - 20.0, 8.0)), Color(0.88, 0.82, 0.66))

func _get_table_visual_cards(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var cards: Array = []
	var machine_cards := _get_machine_card_data(rect)
	if not _is_dragging_table_card("bench_card", 0):
		cards.append({
			"kind": "bench_card",
			"rect": Rect2(machine_cards["bench_rect"]),
			"z": Rect2(machine_cards["bench_rect"]).end.y,
		})
	if not _is_dragging_table_card("route_card", 0):
		cards.append({
			"kind": "route_card",
			"rect": Rect2(machine_cards["route_rect"]),
			"z": Rect2(machine_cards["route_rect"]).end.y,
		})
	if not _is_dragging_table_card("charge_card", 0):
		cards.append({
			"kind": "charge_card",
			"rect": Rect2(machine_cards["charge_rect"]),
			"z": Rect2(machine_cards["charge_rect"]).end.y,
		})
	if not _is_dragging_table_card("operator", 0):
		cards.append({
			"kind": "operator",
			"rect": Rect2(_table_operator_position, CARD_SIZE),
			"z": _table_operator_position.y + CARD_SIZE.y,
		})
	if not _is_dragging_table_card("trash_card", 0):
		cards.append({
			"kind": "trash_card",
			"rect": Rect2(_table_trash_position, CARD_SIZE),
			"z": _table_trash_position.y + CARD_SIZE.y,
		})
	for location_card in GameState.get_location_cards():
		var location_id := str(location_card.get("id", ""))
		if location_id.is_empty() or _is_dragging_table_card("location", location_id):
			continue
		var location_pos := Vector2(_table_location_positions.get(location_id, rect.position))
		cards.append({
			"kind": "location",
			"rect": Rect2(location_pos, CARD_SIZE),
			"location_id": location_id,
			"card_data": location_card,
			"z": location_pos.y + CARD_SIZE.y,
		})
	for enemy_card in GameState.get_enemy_cards():
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty() or _is_dragging_table_card("enemy", enemy_id):
			continue
		var enemy_pos := Vector2(_table_enemy_positions.get(enemy_id, rect.position))
		cards.append({
			"kind": "enemy",
			"rect": Rect2(enemy_pos, CARD_SIZE),
			"enemy_id": enemy_id,
			"card_data": enemy_card,
			"z": enemy_pos.y + CARD_SIZE.y,
		})
	var tape_data := _get_tape_hand_data(rect)
	for slot in tape_data["programmed_slots"]:
		var cartridge: Dictionary = slot["cartridge"]
		var cartridge_id := str(cartridge.get("id", ""))
		if _is_dragging_table_card("cartridge", cartridge_id):
			continue
		cards.append({
			"kind": "cartridge",
			"rect": Rect2(slot["rect"]),
			"cartridge_id": cartridge_id,
			"label": str(cartridge.get("label", "")),
			"selected": bool(slot["selected"]),
			"z": Rect2(slot["rect"]).end.y,
		})
	for slot in tape_data["blank_slots"]:
		if not bool(slot["filled"]):
			continue
		var blank_index := int(slot["index"])
		if _is_dragging_table_card("blank", blank_index):
			continue
		cards.append({
			"kind": "blank",
			"rect": Rect2(slot["rect"]),
			"blank_index": blank_index,
			"z": Rect2(slot["rect"]).end.y,
		})
	for slot in _get_table_drone_data(rect):
		var bot_index := int(slot["index"])
		if _is_dragging_table_card("bot", bot_index):
			continue
		cards.append({
			"kind": "bot",
			"rect": Rect2(slot["rect"]),
			"bot_index": bot_index,
			"slot": slot,
			"z": Rect2(slot["rect"]).end.y,
		})
	for card_info in _get_power_stack_data(rect)["visible_cards"]:
		var slot_index := int(card_info["slot_index"])
		if _is_dragging_table_card("power", slot_index):
			continue
		var power_unit: Dictionary = card_info["power_unit"]
		cards.append({
			"kind": "power",
			"rect": Rect2(card_info["rect"]),
			"slot_index": slot_index,
			"charge": int(power_unit.get("charge", 0)),
			"max_charge": int(power_unit.get("max_charge", 1)),
			"selected": slot_index == _selected_power_slot_index,
			"z": Rect2(card_info["rect"]).end.y,
		})
	cards.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["z"]) < float(b["z"]))
	return cards

func _get_top_tape_badge_at_point(drone_slots: Array, root_point: Vector2) -> Dictionary:
	var sorted_slots := drone_slots.duplicate()
	sorted_slots.sort_custom(func(a: Dictionary, b: Dictionary): return Rect2(a["rect"]).end.y > Rect2(b["rect"]).end.y)
	for slot in sorted_slots:
		if Rect2(slot["tape_badge_rect"]).has_point(root_point) and not Dictionary(slot["loaded_cartridge"]).is_empty():
			return slot
	return {}

func _get_top_table_card_at_point(rect: Rect2, root_point: Vector2) -> Dictionary:
	var cards := _get_table_visual_cards(rect)
	for card_index in range(cards.size() - 1, -1, -1):
		var card_info: Dictionary = cards[card_index]
		if Rect2(card_info["rect"]).has_point(root_point):
			return card_info
	return {}

func _is_dragging_table_card(kind: String, identifier) -> bool:
	if _active_drag.is_empty():
		return false
	if str(_active_drag.get("kind", "")) != kind:
		return false
	match kind:
		"cartridge":
			return str(_active_drag.get("source", "")) == "table" and str(_active_drag.get("cartridge_id", "")) == str(identifier)
		"power":
			return int(_active_drag.get("slot_index", -1)) == int(identifier)
		"blank":
			return int(_active_drag.get("blank_index", -1)) == int(identifier)
		"bot":
			return int(_active_drag.get("bot_index", -1)) == int(identifier)
		"location":
			return str(_active_drag.get("location_id", "")) == str(identifier)
		"enemy":
			return str(_active_drag.get("enemy_id", "")) == str(identifier)
		"operator":
			return true
		"bench_card":
			return true
		"route_card":
			return true
		"trash_card":
			return true
		"charge_card":
			return true
	return false

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
	if not title.is_empty():
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(18.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, TEXT)
	return rect.grow(-10.0)

func _draw_table_drone_card(slot: Dictionary):
	var card_index: int = int(slot["index"])
	var card_rect: Rect2 = slot["rect"]
	var body_hotspot: Rect2 = slot["body_hotspot"]
	var loaded_cartridge: Dictionary = slot["loaded_cartridge"]
	var power_charge: int = int(slot["power_charge"])
	var power_card_count: int = int(slot["power_card_count"])
	var outside_status := str(slot["outside_status"])
	var available_in_workshop := bool(slot["available_in_workshop"])
	var tape_badge_rect: Rect2 = slot["tape_badge_rect"]
	var is_selected := card_index == _selected_bot_index
	var drag_ready := not _active_drag.is_empty() and bool(slot["available_in_workshop"]) and Rect2(body_hotspot).has_point(_drag_mouse_root)
	var shell := _draw_card_template(card_rect, "agent", is_selected, drag_ready, null, Color(0.11, 0.12, 0.14), STEEL_LIGHT, null)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	if available_in_workshop:
		if card_index == 0:
			_draw_drone_silhouette(art_rect.grow(-8.0))
		else:
			_draw_butterfly_drone(art_rect.grow(-8.0))
		_draw_drone_tape_badge(tape_badge_rect, loaded_cartridge, is_selected)
		_draw_drone_power_badge(Rect2(Vector2(face_rect.end.x - 46.0, face_rect.end.y - 28.0), Vector2(34.0, 16.0)), power_charge, power_card_count > 0)
	else:
		_draw_empty_drone_card_face(art_rect, outside_status)
	var status_light := Rect2(Vector2(card_rect.end.x - 16.0, card_rect.position.y + 10.0), Vector2(6.0, 6.0))
	draw_circle(status_light.get_center(), 3.0, Color(0.46, 0.77, 0.46) if available_in_workshop else Color(0.76, 0.44, 0.24))

func _draw_route_table_machine(body: Rect2):
	var housing_rect := _get_route_table_machine_rect(body)
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

func _get_route_table_machine_rect(body: Rect2) -> Rect2:
	var housing_size := minf(body.size.x - 56.0, body.size.y - 38.0)
	return Rect2(
		Vector2(body.position.x + (body.size.x - housing_size) * 0.5, body.position.y + 24.0),
		Vector2(housing_size, housing_size)
	)

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
	_draw_tape_card(rect, programmed, label, selected)

func _draw_empty_shelf_slot(rect: Rect2):
	var back_rect := Rect2(rect.position + Vector2(2.0, -2.0), rect.size)
	var front_rect := Rect2(rect.position, rect.size)
	draw_rect(back_rect, Color(0.10, 0.10, 0.11))
	draw_rect(front_rect, Color(0.13, 0.13, 0.14))
	draw_rect(back_rect, PANEL_BORDER, false, 1.0)
	draw_rect(front_rect, PANEL_BORDER, false, 1.0)
	draw_line(front_rect.position + Vector2(4.0, 4.0), front_rect.end - Vector2(4.0, 4.0), STEEL_LIGHT, 1.0)
	draw_line(Vector2(front_rect.position.x + 4.0, front_rect.end.y - 4.0), Vector2(front_rect.end.x - 4.0, front_rect.position.y + 4.0), STEEL_LIGHT, 1.0)

func _draw_tape_card(rect: Rect2, programmed: bool, label: String, selected: bool):
	var shell := _draw_card_template(rect, "medium", selected, false, TAPE if programmed else Color(0.22, 0.23, 0.25), Color(1.0, 1.0, 1.0, 0.06), null, null)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var side_strip := Rect2(face_rect.position + Vector2(5.0, 8.0), Vector2(4.0, face_rect.size.y - 16.0))
	var suit_rect := Rect2(art_rect.position + Vector2(6.0, 2.0), Vector2(art_rect.size.x - 12.0, 12.0))
	var label_rect := Rect2(Vector2(info_rect.position.x, info_rect.position.y + 5.0), Vector2(info_rect.size.x, 12.0))
	draw_rect(side_strip, ACCENT if programmed else STEEL_LIGHT)
	_draw_tape_suit(suit_rect, programmed)
	if programmed and not label.is_empty():
		var short_label := _trim_cartridge_label(label, 10).to_upper()
		draw_string(ThemeDB.fallback_font, Vector2(label_rect.position.x, label_rect.position.y + 9.0), short_label, HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, 8, STEEL_DARK)
	elif not programmed:
		draw_line(
			Vector2(info_rect.position.x + 4.0, info_rect.position.y + 10.0),
			Vector2(info_rect.end.x - 4.0, info_rect.position.y + 10.0),
			Color(0.55, 0.57, 0.60),
			1.0
		)

func _draw_tape_suit(rect: Rect2, programmed: bool):
	var strip_rect := Rect2(rect.position + Vector2(0.0, 2.0), Vector2(rect.size.x, rect.size.y - 4.0))
	draw_rect(strip_rect, TAPE_SHADE if programmed else Color(0.70, 0.70, 0.72))
	draw_rect(strip_rect, Color(0.56, 0.48, 0.28), false, 1.0)
	for hole_index in range(5):
		var hole_center := Vector2(strip_rect.position.x + 5.0 + float(hole_index) * ((strip_rect.size.x - 10.0) / 4.0), strip_rect.position.y + strip_rect.size.y * 0.5)
		draw_circle(hole_center, 0.9, TAPE_HOLE if programmed else STEEL_LIGHT)

func _get_tape_hand_data(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	var hand_zone: Rect2 = _get_table_workspace_rect(rect)
	var programmed_slots: Array = []
	var blank_slots: Array = []
	for slot_index in range(GameState.PROGRAMMED_CARTRIDGE_CAPACITY):
		var cartridge: Dictionary = GameState.get_programmed_cartridge_in_slot(slot_index)
		if cartridge.is_empty():
			continue
		var cartridge_id := str(cartridge.get("id", ""))
		programmed_slots.append({
			"rect": Rect2(Vector2(_table_cartridge_positions.get(cartridge_id, hand_zone.position)), CARD_SIZE),
			"cartridge": cartridge,
			"selected": cartridge_id == GameState.selected_cartridge_id,
		})
	for blank_index in range(BLANK_CARTRIDGE_DISPLAY_COUNT):
		blank_slots.append({
			"index": blank_index,
			"rect": Rect2(Vector2(_table_blank_positions.get(blank_index, hand_zone.position)), CARD_SIZE),
			"filled": GameState.is_blank_slot_filled(blank_index),
		})
	var recycle_rect := Rect2(_table_trash_position, CARD_SIZE)
	return {
		"hand_zone": hand_zone,
		"programmed_slots": programmed_slots,
		"blank_slots": blank_slots,
		"recycle_hotspot": recycle_rect,
	}

func _get_table_drone_data(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var workspace := _get_table_workspace_rect(rect)
	var slots: Array = []
	for drone_index in range(2):
		var drone_rect := Rect2(Vector2(_table_drone_positions.get(drone_index, workspace.position)), CARD_SIZE)
		var tape_badge_rect := Rect2(
			Vector2(drone_rect.position.x + 14.0, drone_rect.end.y - 48.0),
			Vector2(48.0, 16.0)
		)
		var available_in_workshop: bool = GameState.is_bot_available_in_workshop(drone_index)
		var control_y := drone_rect.end.y + 10.0
		slots.append({
			"index": drone_index,
			"rect": drone_rect,
			"body_hotspot": drone_rect,
			"tape_badge_rect": tape_badge_rect,
			"loaded_cartridge": GameState.get_bot_loaded_cartridge(drone_index),
			"power_charge": int(GameState.bot_loadouts[drone_index].get("power_charge", 0)),
			"power_card_count": int(GameState.bot_loadouts[drone_index].get("power_card_count", 0)),
			"max_power_charge": int(GameState.bot_loadouts[drone_index].get("max_power_charge", GameState.BOT_POWER_CAPACITY)),
			"outside_status": str(GameState.bot_loadouts[drone_index].get("outside_status", "cabinet")),
			"available_in_workshop": available_in_workshop,
			"play_hotspot": Rect2(Vector2(drone_rect.position.x + 24.0, control_y), Vector2(drone_rect.size.x - 48.0, 20.0)),
		})
	return slots

func _draw_empty_drone_card_face(window_rect: Rect2, outside_status: String):
	draw_rect(window_rect.grow(-10.0), Color(0.10, 0.11, 0.12))

func _draw_drone_tape_badge(rect: Rect2, loaded_cartridge: Dictionary, is_selected: bool):
	if loaded_cartridge.is_empty():
		return
	var tag_rect := rect
	var back_poly := PackedVector2Array([
		tag_rect.position + Vector2(3.0, -2.0),
		tag_rect.position + Vector2(tag_rect.size.x - 3.0, -2.0),
		tag_rect.end + Vector2(0.0, -2.0),
		tag_rect.position + Vector2(7.0, tag_rect.size.y - 2.0),
		tag_rect.position + Vector2(0.0, tag_rect.size.y * 0.5),
	])
	var front_poly := PackedVector2Array([
		tag_rect.position + Vector2(0.0, 0.0),
		tag_rect.position + Vector2(tag_rect.size.x - 4.0, 0.0),
		tag_rect.end + Vector2(-4.0, 0.0),
		tag_rect.position + Vector2(8.0, tag_rect.size.y),
		tag_rect.position + Vector2(0.0, tag_rect.size.y * 0.5),
	])
	draw_colored_polygon(back_poly, Color(0.22, 0.18, 0.12, 0.65))
	draw_colored_polygon(front_poly, TAPE)
	_draw_poly_outline(front_poly, ACCENT if is_selected else PANEL_BORDER, 1.0)
	draw_rect(Rect2(tag_rect.position + Vector2(4.0, 2.0), Vector2(3.0, tag_rect.size.y - 4.0)), ACCENT)
	var short_label := _trim_cartridge_label(str(loaded_cartridge.get("label", "")), 6).to_upper()
	draw_string(ThemeDB.fallback_font, tag_rect.position + Vector2(12.0, 11.0), short_label, HORIZONTAL_ALIGNMENT_LEFT, tag_rect.size.x - 14.0, 8, STEEL_DARK)

func _draw_drone_power_badge(rect: Rect2, power_charge: int, has_power: bool):
	if not has_power and power_charge <= 0:
		return
	var font := ThemeDB.fallback_font
	var font_size := 9
	var value_text := str(maxi(power_charge, 0))
	var value_size := font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var suit_rect := Rect2(rect.position + Vector2(0.0, 4.0), Vector2(14.0, 8.0))
	_draw_power_suit(suit_rect, power_charge > 0, 1.0)
	draw_string(
		font,
		Vector2(rect.end.x - value_size.x, rect.position.y + 12.0),
		value_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		TAPE
	)

func _draw_operator_card(rect: Rect2):
	var shell := _draw_card_template(rect, "agent", false, false, null, Color(0.13, 0.14, 0.16), STEEL_LIGHT, null)
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var dossier_rect := art_rect.grow(-8.0)
	draw_rect(dossier_rect, TAPE)
	draw_rect(dossier_rect, Color(0.58, 0.50, 0.30), false, 1.0)
	draw_texture_rect(OPERATOR_ID_PHOTO, dossier_rect, false)
	var clip_rect := Rect2(Vector2(dossier_rect.end.x - 18.0, dossier_rect.position.y + 8.0), Vector2(8.0, 18.0))
	draw_rect(clip_rect, ACCENT_DIM)
	draw_rect(clip_rect.grow(-1.0), ACCENT)
	var operator_state: Dictionary = GameState.get_operator_state()
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 7.0), str(WORKSHOP_OPERATOR["name"]), HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, TEXT)
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 16.0), "EN %d  HP %d" % [int(operator_state.get("energy", 0)), int(operator_state.get("hp", 0))], HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, TAPE)
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 24.0), str(WORKSHOP_OPERATOR["focus"]), HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 6, TAPE_SHADE)

func _draw_location_card(rect: Rect2, card_data: Dictionary):
	var shell := _draw_card_template(rect, "place", false, false, null, Color(0.20, 0.22, 0.25), Color(0.84, 0.84, 0.78, 0.30), Color(0.42, 0.38, 0.24))
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var location_type := str(card_data.get("type", "site"))
	var pos: Dictionary = card_data.get("position", {"x": 0, "y": 0})
	var coords := Vector2(int(pos.get("x", 0)), int(pos.get("y", 0)))
	_draw_location_glyph(art_rect.grow(-8.0), location_type)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 8.0), location_type.replace("_", " ").to_upper(), HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, STEEL_DARK)
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 18.0), "(%d,%d)" % [int(coords.x), int(coords.y)], HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, Color(0.24, 0.26, 0.30))

func _draw_enemy_card(rect: Rect2, card_data: Dictionary):
	var shell := _draw_card_template(rect, "threat", false, false, null, Color(0.16, 0.10, 0.10), Color(0.75, 0.61, 0.40, 0.24), Color(0.48, 0.20, 0.18))
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var enemy_type := str(card_data.get("type", "hostile_creature"))
	var threat_level := int(card_data.get("threat_level", 1))
	var enemy_hp := int(card_data.get("hp", 1))
	_draw_enemy_glyph(art_rect.grow(-8.0), enemy_type)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 8.0), enemy_type.replace("_", " ").to_upper(), HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, TAPE)
	draw_string(font, Vector2(info_rect.position.x, info_rect.position.y + 18.0), "ATK %d  HP %d" % [threat_level, enemy_hp], HORIZONTAL_ALIGNMENT_CENTER, info_rect.size.x, 8, Color(0.93, 0.78, 0.54))

func _draw_location_glyph(rect: Rect2, location_type: String):
	match location_type:
		"tower", "surveillance_zone":
			var tower_rect := Rect2(rect.position + Vector2(rect.size.x * 0.5 - 10.0, 8.0), Vector2(20.0, rect.size.y - 20.0))
			draw_rect(tower_rect, STEEL_DARK)
			draw_rect(tower_rect.grow(-2.0), STEEL)
			draw_rect(tower_rect, PANEL_BORDER, false, 1.0)
			draw_line(tower_rect.get_center() + Vector2(-16.0, 0.0), tower_rect.get_center() + Vector2(16.0, 0.0), ACCENT_DIM, 1.0)
		"cache":
			var box_rect := Rect2(rect.position + Vector2(18.0, 18.0), rect.size - Vector2(36.0, 32.0))
			draw_rect(box_rect, TAPE_SHADE)
			draw_rect(box_rect.grow(-2.0), TAPE)
			draw_rect(box_rect, PANEL_BORDER, false, 1.0)
			draw_line(box_rect.position + Vector2(0.0, box_rect.size.y * 0.5), box_rect.end - Vector2(0.0, box_rect.size.y * 0.5), PANEL_BORDER, 1.0)
		"crater":
			draw_arc(rect.get_center(), 24.0, 0.2, TAU - 0.2, 24, STEEL_DARK, 4.0)
			draw_arc(rect.get_center() + Vector2(0.0, 2.0), 16.0, 0.2, TAU - 0.2, 20, Color(0.30, 0.24, 0.18), 2.0)
		_:
			draw_rect(Rect2(rect.position + Vector2(16.0, 16.0), rect.size - Vector2(32.0, 32.0)), TAPE_SHADE)
			draw_rect(Rect2(rect.position + Vector2(16.0, 16.0), rect.size - Vector2(32.0, 32.0)), PANEL_BORDER, false, 1.0)

func _draw_enemy_glyph(rect: Rect2, enemy_type: String):
	match enemy_type:
		"swarm":
			for point in [Vector2(24, 18), Vector2(42, 28), Vector2(32, 42), Vector2(54, 46)]:
				draw_circle(rect.position + point, 4.0, TAPE)
		"raider":
			var triangle := PackedVector2Array([
				rect.position + Vector2(rect.size.x * 0.5, 16.0),
				rect.position + Vector2(24.0, rect.size.y - 18.0),
				rect.position + Vector2(rect.size.x - 24.0, rect.size.y - 18.0),
			])
			draw_colored_polygon(triangle, TAPE)
			_draw_poly_outline(triangle, STEEL_DARK, 1.0)
		_:
			var body := rect.get_center()
			draw_circle(body + Vector2(0.0, -6.0), 8.0, TAPE)
			draw_line(body + Vector2(-10.0, 6.0), body + Vector2(10.0, 6.0), TAPE, 2.0)
			draw_line(body + Vector2(-8.0, 16.0), body + Vector2(-2.0, 6.0), TAPE, 2.0)
			draw_line(body + Vector2(8.0, 16.0), body + Vector2(2.0, 6.0), TAPE, 2.0)

func _get_enemy_fight_states(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var states: Array = []
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	var drones := _get_table_drone_data(rect)
	for enemy_card in GameState.get_enemy_cards():
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		var enemy_rect := Rect2(Vector2(_table_enemy_positions.get(enemy_id, rect.position)), CARD_SIZE)
		var use_operator := _has_meaningful_overlap(enemy_rect, operator_rect, 0.30)
		var bot_indices: Array = []
		for drone_slot in drones:
			if not bool(drone_slot.get("available_in_workshop", false)):
				continue
			if int(drone_slot.get("power_charge", 0)) <= 0:
				continue
			if _has_meaningful_overlap(enemy_rect, Rect2(drone_slot.get("rect", Rect2())), 0.30):
				bot_indices.append(int(drone_slot.get("index", -1)))
		if not use_operator and bot_indices.is_empty():
			_enemy_fight_cooldowns.erase(enemy_id)
			continue
		if not _enemy_fight_cooldowns.has(enemy_id):
			_enemy_fight_cooldowns[enemy_id] = ENEMY_FIGHT_INTERVAL
		states.append({
			"enemy_id": enemy_id,
			"rect": enemy_rect,
			"use_operator": use_operator,
			"bot_indices": bot_indices,
		})
	return states

func _draw_poly_outline(points: PackedVector2Array, color: Color, width: float):
	if points.size() < 2:
		return
	for point_index in range(points.size()):
		var next_index := (point_index + 1) % points.size()
		draw_line(points[point_index], points[next_index], color, width)

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
	var visible_cards: Array = stack_data["visible_cards"]
	for card_info in visible_cards:
		var card_rect: Rect2 = card_info["rect"]
		var slot_index: int = int(card_info["slot_index"])
		var power_unit: Dictionary = card_info["power_unit"]
		var charge := int(power_unit.get("charge", 0))
		var max_charge := maxi(int(power_unit.get("max_charge", 1)), 1)
		_draw_power_card(card_rect, charge, max_charge, slot_index == _selected_power_slot_index)

func _get_power_stack_data(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	var workspace := _get_table_workspace_rect(rect)
	var occupied_cards: Array = []
	for slot_index in range(GameState.power_unit_slots.size()):
		var power_unit: Dictionary = GameState.get_power_unit_in_slot(slot_index)
		if power_unit.is_empty():
			continue
		occupied_cards.append({
			"slot_index": slot_index,
			"power_unit": power_unit,
		})
	var visible_cards: Array = []
	for card_info in occupied_cards:
		var slot_index := int(card_info["slot_index"])
		var card_rect := Rect2(Vector2(_table_power_positions.get(slot_index, workspace.position)), CARD_SIZE)
		visible_cards.append({
			"rect": card_rect,
			"slot_index": slot_index,
			"power_unit": Dictionary(card_info["power_unit"]),
		})
	return {
		"stack_zone": Rect2(workspace.end - CARD_SIZE - Vector2(20.0, 20.0), CARD_SIZE),
		"visible_cards": visible_cards,
		"top_slot_index": -1,
		"top_card_rect": Rect2(),
	}

func _draw_power_card(rect: Rect2, charge: int, max_charge: int, selected: bool):
	var shell := _draw_card_template(rect, "charge", selected, false, TAPE, Color(1.0, 1.0, 1.0, 0.05), null, Color(0.68, 0.60, 0.40))
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var fill_ratio := clampf(float(charge) / float(maxi(max_charge, 1)), 0.0, 1.0)
	var font := ThemeDB.fallback_font
	var font_size := 13
	var number_text := str(maxi(charge, 0))
	var number_size := font.get_string_size(number_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var suit_rect := Rect2(art_rect.position + Vector2(8.0, 20.0), Vector2(art_rect.size.x - 16.0, 14.0))
	var meter_rect := Rect2(Vector2(info_rect.position.x, info_rect.end.y - 2.0), Vector2(info_rect.size.x, 3.0))
	var fill_rect := Rect2(meter_rect.position, Vector2(meter_rect.size.x * fill_ratio, meter_rect.size.y))
	_draw_power_suit(suit_rect, charge > 0)
	draw_string(font, Vector2(info_rect.end.x - number_size.x, info_rect.position.y + 13.0), number_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, STEEL_DARK)
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, ACCENT)
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
	for slot_index in range(GameState.power_unit_slots.size()):
		if GameState.get_power_unit_in_slot(slot_index).is_empty():
			return slot_index
	return GameState.power_unit_slots.size()

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

func _draw_trash_card(rect: Rect2, active: bool):
	_draw_machine_card(rect, "trash")
	if active:
		var shell := _draw_card_shell(rect, "machine", false, false)
		var info_rect: Rect2 = shell["info_rect"]
		var active_rect := Rect2(
			Vector2(info_rect.position.x + 10.0, info_rect.end.y - 5.0),
			Vector2(info_rect.size.x - 20.0, 3.0)
		)
		draw_rect(active_rect, Color(0.55, 0.22, 0.18))

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

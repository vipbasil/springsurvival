extends Control

const WorkshopArtData := preload("res://scripts/ui/WorkshopArt.gd")
const PROGRAMMING_SCENE_PATH := "res://scenes/main/ProgrammingMain.tscn"
const MACHINE_CAPACITY := 48.0
const OUTSIDE_STEP_INTERVAL := 0.55
const CHARGE_PRODUCTION_INTERVAL := 7.2
const ROUTE_SCAN_INTERVAL := 6.0
const ENEMY_FIGHT_INTERVAL := 2.2
const ATTACK_FEEDBACK_DURATION := 0.22
const DAMAGE_FEEDBACK_DURATION := 0.30
const FLOATING_NUMBER_DURATION := 0.60

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
const FONT_SIZE_REGION := 24
const FONT_SIZE_BANNER := 14
const FONT_SIZE_VALUE := 12
const FONT_SIZE_CARD_TITLE := 8
const FONT_SIZE_CARD_META := 6
const FONT_SIZE_CARD_VALUE := 9
const FONT_SIZE_FLOATING_BASE := 14
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
var _combat_card_fx := {}
var _floating_numbers := []
var _location_bunker_texture: Texture2D
var _location_cache_texture: Texture2D
var _location_pond_texture: Texture2D
var _location_crater_texture: Texture2D
var _location_tower_texture: Texture2D
var _location_surveillance_texture: Texture2D
var _location_facility_texture: Texture2D
var _location_field_texture: Texture2D
var _location_dump_texture: Texture2D
var _location_nest_texture: Texture2D
var _location_ruin_texture: Texture2D

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
	_location_bunker_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_bunker.svg")
	_location_cache_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_cache.svg")
	_location_pond_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_pond.svg")
	_location_crater_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_crater.svg")
	_location_tower_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_tower.svg")
	_location_surveillance_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_surveillance_zone.svg")
	_location_facility_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_facility.svg")
	_location_field_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_field.svg")
	_location_dump_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_dump.svg")
	_location_nest_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_nest.svg")
	_location_ruin_texture = WorkshopArtData.load_svg_texture("res://assets/cards/location_ruin.svg")
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
	_tick_combat_feedback(delta)
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
		_emit_enemy_fight_feedback(enemy_id, fight_info, result)
		if bool(result.get("defeated", false)):
			_table_enemy_positions.erase(enemy_id)
			_enemy_fight_cooldowns.erase(enemy_id)
			EventBus.log_message.emit("%s defeated" % str(result.get("enemy_name", "Hostile")))
		else:
			EventBus.log_message.emit("%s fought back" % str(result.get("enemy_name", "Hostile")))

func _tick_combat_feedback(delta: float):
	var active := false
	for fx_key in _combat_card_fx.keys():
		var entry: Dictionary = _combat_card_fx[fx_key]
		entry["attack_timer"] = maxf(float(entry.get("attack_timer", 0.0)) - delta, 0.0)
		entry["damage_timer"] = maxf(float(entry.get("damage_timer", 0.0)) - delta, 0.0)
		if float(entry.get("attack_timer", 0.0)) <= 0.0 and float(entry.get("damage_timer", 0.0)) <= 0.0:
			_combat_card_fx.erase(fx_key)
		else:
			_combat_card_fx[fx_key] = entry
			active = true
	for index in range(_floating_numbers.size() - 1, -1, -1):
		var entry: Dictionary = _floating_numbers[index]
		entry["timer"] = maxf(float(entry.get("timer", FLOATING_NUMBER_DURATION)) - delta, 0.0)
		if float(entry.get("timer", 0.0)) <= 0.0:
			_floating_numbers.remove_at(index)
		else:
			_floating_numbers[index] = entry
			active = true
	if active:
		queue_redraw()

func _emit_enemy_fight_feedback(enemy_id: String, fight_info: Dictionary, result: Dictionary):
	var enemy_center := _get_table_card_center("enemy", enemy_id)
	if bool(fight_info.get("use_operator", false)):
		var operator_center := _get_table_card_center("operator", 0)
		_trigger_attack_feedback("operator", 0, enemy_center - operator_center, int(result.get("operator_attack", 0)))
		_trigger_damage_feedback("operator", 0, int(result.get("operator_damage", 0)))
	for bot_attack in Array(result.get("bot_attacks", [])):
		var attack_entry: Dictionary = bot_attack
		var bot_index := int(attack_entry.get("bot_index", -1))
		if bot_index == -1:
			continue
		var bot_center := _get_table_card_center("bot", bot_index)
		_trigger_attack_feedback("bot", bot_index, enemy_center - bot_center, int(attack_entry.get("attack", 0)))
	for bot_damage in Array(result.get("bot_damage", [])):
		var damage_entry: Dictionary = bot_damage
		_trigger_damage_feedback("bot", int(damage_entry.get("bot_index", -1)), int(damage_entry.get("damage", 0)))
	_trigger_damage_feedback("enemy", enemy_id, int(result.get("total_attack", 0)))

func _trigger_attack_feedback(kind: String, identifier, direction: Vector2, amount: int):
	if amount <= 0:
		return
	var fx_key := _get_card_fx_key(kind, identifier)
	var entry: Dictionary = _combat_card_fx.get(fx_key, {})
	entry["attack_timer"] = ATTACK_FEEDBACK_DURATION
	entry["attack_duration"] = ATTACK_FEEDBACK_DURATION
	entry["attack_dir"] = direction.normalized() if direction.length() > 0.0 else Vector2.RIGHT
	entry["seed"] = float(fx_key.hash() % 97)
	_combat_card_fx[fx_key] = entry
	_floating_numbers.append({
		"position": _get_table_card_center(kind, identifier) + Vector2(0.0, -24.0),
		"value": str(amount),
		"color": Color(0.90, 0.78, 0.36),
		"timer": FLOATING_NUMBER_DURATION,
		"duration": FLOATING_NUMBER_DURATION,
	})

func _trigger_damage_feedback(kind: String, identifier, amount: int):
	if amount <= 0:
		return
	if (kind == "bot" or kind == "operator") and int(identifier) == -1:
		return
	var fx_key := _get_card_fx_key(kind, identifier)
	var entry: Dictionary = _combat_card_fx.get(fx_key, {})
	entry["damage_timer"] = DAMAGE_FEEDBACK_DURATION
	entry["damage_duration"] = DAMAGE_FEEDBACK_DURATION
	entry["seed"] = float((fx_key.hash() % 131) + 17)
	_combat_card_fx[fx_key] = entry
	_floating_numbers.append({
		"position": _get_table_card_center(kind, identifier) + Vector2(0.0, -8.0),
		"value": str(amount),
		"color": Color(0.93, 0.42, 0.34),
		"timer": FLOATING_NUMBER_DURATION,
		"duration": FLOATING_NUMBER_DURATION,
	})

func _get_card_fx_key(kind: String, identifier) -> String:
	return "%s:%s" % [kind, str(identifier)]

func _get_card_feedback_offset(kind: String, identifier) -> Vector2:
	var entry: Dictionary = _combat_card_fx.get(_get_card_fx_key(kind, identifier), {})
	if entry.is_empty():
		return Vector2.ZERO
	var offset := Vector2.ZERO
	var attack_timer := float(entry.get("attack_timer", 0.0))
	var attack_duration := maxf(float(entry.get("attack_duration", ATTACK_FEEDBACK_DURATION)), 0.001)
	if attack_timer > 0.0:
		var attack_progress := 1.0 - attack_timer / attack_duration
		offset += Vector2(entry.get("attack_dir", Vector2.RIGHT)) * (sin(attack_progress * PI) * 9.0)
	var damage_timer := float(entry.get("damage_timer", 0.0))
	var damage_duration := maxf(float(entry.get("damage_duration", DAMAGE_FEEDBACK_DURATION)), 0.001)
	if damage_timer > 0.0:
		var damage_progress := 1.0 - damage_timer / damage_duration
		var amplitude := (1.0 - damage_progress) * 5.0
		var seed := float(entry.get("seed", 1.0))
		offset += Vector2(
			sin(damage_progress * 28.0 + seed),
			cos(damage_progress * 23.0 + seed * 0.7)
		) * amplitude
	return offset

func _get_table_card_center(kind: String, identifier) -> Vector2:
	match kind:
		"operator":
			return Rect2(_table_operator_position, CARD_SIZE).get_center()
		"bot":
			return Rect2(Vector2(_table_drone_positions.get(int(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		"enemy":
			return Rect2(Vector2(_table_enemy_positions.get(str(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		_:
			return Vector2.ZERO

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
	WorkshopArtData.draw_room_shell(self, size, WALL_DARK, WALL_MID, WALL_BAND, FLOOR, FLOOR_SEAM)
	_draw_map_bay(Rect2(Vector2(24.0, 24.0), Vector2(size.x - 48.0, size.y - 48.0)))
	_draw_drag_overlay()
	_draw_floating_numbers()
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
				WorkshopArtData.draw_machine_card(self, Rect2(card_info["rect"]), "bench")
			"route_card":
				WorkshopArtData.draw_machine_card(self, Rect2(card_info["rect"]), "route", Callable(self, "_draw_route_card_overlay"))
			"charge_card":
				WorkshopArtData.draw_machine_card(self, Rect2(card_info["rect"]), "charge")
			"operator":
				WorkshopArtData.draw_operator_card(self, Rect2(card_info["rect"]), GameState.get_operator_state(), str(WORKSHOP_OPERATOR["name"]), str(WORKSHOP_OPERATOR["focus"]), OPERATOR_ID_PHOTO)
			"cartridge":
				WorkshopArtData.draw_tape_card(self, Rect2(card_info["rect"]), true, str(card_info.get("label", "")), bool(card_info.get("selected", false)))
			"blank":
				WorkshopArtData.draw_tape_card(self, Rect2(card_info["rect"]), false, "", false)
			"location":
				WorkshopArtData.draw_location_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]), _location_bunker_texture, _location_cache_texture, _location_pond_texture, _location_crater_texture, _location_tower_texture, _location_surveillance_texture, _location_facility_texture, _location_field_texture, _location_dump_texture, _location_nest_texture, _location_ruin_texture)
			"enemy":
				WorkshopArtData.draw_enemy_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"bot":
				_draw_table_drone_card(Dictionary(card_info["slot"]))
			"power":
				WorkshopArtData.draw_power_card(self, Rect2(card_info["rect"]), int(card_info.get("charge", 0)), int(card_info.get("max_charge", 1)), bool(card_info.get("selected", false)))
			"trash_card":
				WorkshopArtData.draw_trash_card(self, Rect2(card_info["rect"]), _active_drag.is_empty() == false and _is_point_in_recycle_zone(_drag_mouse_root))
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
		var preview_label := ""
		var cartridge_id := str(_active_drag.get("cartridge_id", ""))
		if not cartridge_id.is_empty():
			var cartridge := GameState.get_programmed_cartridge_by_id(cartridge_id)
			preview_label = str(cartridge.get("label", ""))
		WorkshopArtData.draw_tape_card(self, preview_rect, true, preview_label, false)
	elif drag_kind == "power":
		WorkshopArtData.draw_power_card(self, preview_rect, GameState.BOT_POWER_CAPACITY, GameState.BOT_POWER_CAPACITY, false)
	elif drag_kind == "bot":
		var drag_drone_slots: Array = _get_table_drone_data(_rect_in_root(map_region))
		var slot: Dictionary = drag_drone_slots[int(_active_drag.get("bot_index", 0))]
		var moved_slot: Dictionary = slot.duplicate(true)
		moved_slot["rect"] = Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE)
		moved_slot["body_hotspot"] = moved_slot["rect"]
		moved_slot["tape_badge_rect"] = Rect2(Vector2(moved_slot["rect"].position.x + 14.0, moved_slot["rect"].end.y - 48.0), Vector2(48.0, 16.0))
		_draw_table_drone_card(moved_slot)
	elif drag_kind == "blank":
		WorkshopArtData.draw_tape_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), false, "", false)
	elif drag_kind == "location":
		WorkshopArtData.draw_location_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})), _location_bunker_texture, _location_cache_texture, _location_pond_texture, _location_crater_texture, _location_tower_texture, _location_surveillance_texture, _location_facility_texture, _location_field_texture, _location_dump_texture, _location_nest_texture, _location_ruin_texture)
	elif drag_kind == "enemy":
		WorkshopArtData.draw_enemy_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "operator":
		WorkshopArtData.draw_operator_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), GameState.get_operator_state(), str(WORKSHOP_OPERATOR["name"]), str(WORKSHOP_OPERATOR["focus"]), OPERATOR_ID_PHOTO)
	elif drag_kind == "trash_card":
		WorkshopArtData.draw_trash_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), false)
	elif drag_kind == "bench_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "bench")
	elif drag_kind == "route_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "route", Callable(self, "_draw_route_card_overlay"))
	elif drag_kind == "charge_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "charge")

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

func _draw_route_card_overlay(display_rect: Rect2):
	var grid_size: Vector2 = GameState.grid_size
	var cells_x: int = int(grid_size.x)
	var cells_y: int = int(grid_size.y)
	var cell_size := minf((display_rect.size.x - 12.0) / float(cells_x), (display_rect.size.y - 12.0) / float(cells_y))
	var grid_display_size := Vector2(cell_size * cells_x, cell_size * cells_y)
	var origin := display_rect.position + (display_rect.size - grid_display_size) * 0.5
	for y in range(cells_y):
		for x in range(cells_x):
			var center := origin + Vector2((float(x) + 0.5) * cell_size, (float(y) + 0.5) * cell_size)
			draw_circle(center, cell_size * 0.18, Color(0.64, 0.58, 0.40, 0.20))
			draw_circle(center, cell_size * 0.10, TAPE_HOLE)
	_draw_shelter_marker(origin, cell_size)
	_draw_discovery_markers(origin, cell_size)
	_draw_outside_bot_routes(origin, cell_size)

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

func _draw_floating_numbers():
	for entry in _floating_numbers:
		var timer := float(entry.get("timer", FLOATING_NUMBER_DURATION))
		var duration := maxf(float(entry.get("duration", FLOATING_NUMBER_DURATION)), 0.001)
		var progress := 1.0 - timer / duration
		var position := Vector2(entry.get("position", Vector2.ZERO)) + Vector2(0.0, -20.0 * progress)
		var color := Color(entry.get("color", TEXT))
		color.a = clampf(1.0 - progress * 0.8, 0.0, 1.0)
		var outline := Color(0.08, 0.07, 0.06, color.a)
		var font_size := maxi(int(round(lerpf(FONT_SIZE_FLOATING_BASE + 2.0, float(FONT_SIZE_FLOATING_BASE), progress))), FONT_SIZE_FLOATING_BASE)
		_draw_outlined_text(position + Vector2(0.0, 1.0), str(entry.get("value", "")), HORIZONTAL_ALIGNMENT_CENTER, 32.0, font_size, color, outline)

func _draw_run_end_overlay():
	var overlay_rect := Rect2(Vector2.ZERO, size)
	draw_rect(overlay_rect, Color(0.0, 0.0, 0.0, 0.28))
	var plaque_rect := Rect2(Vector2(size.x * 0.5 - 120.0, 36.0), Vector2(240.0, 30.0))
	draw_rect(plaque_rect, Color(0.28, 0.10, 0.10))
	draw_rect(plaque_rect.grow(-2.0), Color(0.18, 0.08, 0.08))
	draw_rect(plaque_rect, PANEL_BORDER, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(plaque_rect.position.x, plaque_rect.position.y + 20.0), "RUN ENDED", HORIZONTAL_ALIGNMENT_CENTER, plaque_rect.size.x, FONT_SIZE_BANNER, TEXT)

func _draw_outlined_text(position: Vector2, text: String, alignment: HorizontalAlignment, width: float, font_size: int, fill: Color, outline: Color):
	var font := ThemeDB.fallback_font
	for offset in [
		Vector2(-1.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, -1.0),
		Vector2(0.0, 1.0),
		Vector2(-1.0, -1.0),
		Vector2(1.0, -1.0),
		Vector2(-1.0, 1.0),
		Vector2(1.0, 1.0),
	]:
		draw_string(font, position + offset, text, alignment, width, font_size, outline)
	draw_string(font, position, text, alignment, width, font_size, fill)

func _get_machine_card_data(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	return {
		"bench_rect": Rect2(_table_machine_position, CARD_SIZE),
		"route_rect": Rect2(_table_route_position, CARD_SIZE),
		"charge_rect": Rect2(_table_charge_position, CARD_SIZE),
	}

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
		var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
		operator_rect.position += _get_card_feedback_offset("operator", 0)
		cards.append({
			"kind": "operator",
			"rect": operator_rect,
			"z": operator_rect.end.y,
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
		enemy_pos += _get_card_feedback_offset("enemy", enemy_id)
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
		var moved_slot: Dictionary = slot.duplicate(true)
		var fx_offset := _get_card_feedback_offset("bot", bot_index)
		moved_slot["rect"] = Rect2(Rect2(slot["rect"]).position + fx_offset, Rect2(slot["rect"]).size)
		moved_slot["body_hotspot"] = Rect2(Rect2(slot["body_hotspot"]).position + fx_offset, Rect2(slot["body_hotspot"]).size)
		moved_slot["tape_badge_rect"] = Rect2(Rect2(slot["tape_badge_rect"]).position + fx_offset, Rect2(slot["tape_badge_rect"]).size)
		cards.append({
			"kind": "bot",
			"rect": Rect2(moved_slot["rect"]),
			"bot_index": bot_index,
			"slot": moved_slot,
			"z": Rect2(moved_slot["rect"]).end.y,
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

func _draw_table_drone_card(slot: Dictionary):
	var card_index: int = int(slot["index"])
	var card_rect: Rect2 = slot["rect"]
	var body_hotspot: Rect2 = slot["body_hotspot"]
	var is_selected := card_index == _selected_bot_index
	var drag_ready := not _active_drag.is_empty() and bool(slot["available_in_workshop"]) and Rect2(body_hotspot).has_point(_drag_mouse_root)
	WorkshopArtData.draw_table_drone_card(self, card_rect, slot, is_selected, drag_ready)

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

func _get_first_empty_power_slot_index() -> int:
	for slot_index in range(GameState.power_unit_slots.size()):
		if GameState.get_power_unit_in_slot(slot_index).is_empty():
			return slot_index
	return GameState.power_unit_slots.size()

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
			"resource", "cache", "field", "pond", "facility", "dump", "bunker":
				draw_circle(center, 3.4, TAPE_SHADE)
				draw_circle(center, 1.6, TAPE_HOLE)
				draw_line(center + Vector2(-4.0, 0.0), center + Vector2(4.0, 0.0), ACCENT_DIM, 1.0)
				draw_line(center + Vector2(0.0, -4.0), center + Vector2(0.0, 4.0), ACCENT_DIM, 1.0)
			"hazard", "crater", "anomaly_zone":
				draw_circle(center, 3.2, TAPE_SHADE)
				draw_line(center + Vector2(-3.6, -3.6), center + Vector2(3.6, 3.6), STEEL_DARK, 1.2)
				draw_line(center + Vector2(-3.6, 3.6), center + Vector2(3.6, -3.6), STEEL_DARK, 1.2)
			"landmark", "tower", "bridge", "road_node":
				draw_rect(Rect2(center - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), TAPE_SHADE)
				draw_rect(Rect2(center - Vector2(1.2, 1.2), Vector2(2.4, 2.4)), TAPE_HOLE)
				draw_rect(Rect2(center - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), PANEL_BORDER, false, 1.0)
			"surveillance", "surveillance_zone", "nest":
				var triangle := PackedVector2Array([
					center + Vector2(0.0, -4.5),
					center + Vector2(4.0, 3.5),
					center + Vector2(-4.0, 3.5),
				])
				draw_colored_polygon(triangle, TAPE_SHADE)
				draw_line(triangle[0], triangle[1], STEEL_DARK, 1.0)
				draw_line(triangle[1], triangle[2], STEEL_DARK, 1.0)
				draw_line(triangle[2], triangle[0], STEEL_DARK, 1.0)
				draw_circle(center + Vector2(0.0, 0.8), 1.1, TAPE_HOLE)
			_:
				draw_circle(center, 2.8, TAPE_SHADE)
				draw_circle(center, 1.1, TAPE_HOLE)

func _draw_outside_bot_routes(origin: Vector2, cell_size: float):
	for bot_index in range(GameState.bot_loadouts.size()):
		var bot_state: Dictionary = GameState.bot_loadouts[bot_index]
		var outside_status := str(bot_state.get("outside_status", "cabinet"))
		var route_color: Color = BOT_ROUTE_COLORS[bot_index % BOT_ROUTE_COLORS.size()]
		var predict_color: Color = BOT_PREDICT_COLORS[bot_index % BOT_PREDICT_COLORS.size()]
		var trail: Array = bot_state.get("outside_trail", [])
		var predicted: Array = bot_state.get("predicted_trail", [])
		if outside_status != "cabinet" and outside_status != "returned":
			_draw_path_segments(origin, cell_size, trail, route_color, 2.2, 3.0)
		if outside_status == "cabinet" and not predicted.is_empty():
			var prelaunch_path: Array = [GameState.get_shelter_position()]
			prelaunch_path.append_array(predicted)
			_draw_path_segments(origin, cell_size, prelaunch_path, predict_color, 1.2, 2.2)
			continue
		if outside_status == "returned":
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

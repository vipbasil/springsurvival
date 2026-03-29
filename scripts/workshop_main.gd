extends Control

const WorkshopArtData := preload("res://scripts/ui/WorkshopArt.gd")
const WorkshopCardRuntimeData := preload("res://scripts/ui/WorkshopCardRuntime.gd")
const WorkshopTableControllerData := preload("res://scripts/ui/WorkshopTableController.gd")
const PROGRAMMING_SCENE_PATH := "res://scenes/main/ProgrammingMain.tscn"
const MACHINE_CAPACITY := 48.0
const OUTSIDE_STEP_INTERVAL := 0.55
const CHARGE_PRODUCTION_INTERVAL := 7.2
const ROUTE_SCAN_INTERVAL := 6.0
const JOURNAL_RESEARCH_INTERVAL := 9.5
const BLUEPRINT_CRAFT_INTERVAL := 6.5
const ENEMY_FIGHT_INTERVAL := 2.2
const BOT_RECOVERY_BASE_INTERVAL := 4.2
const BOT_RECOVERY_PER_TILE_INTERVAL := 0.75
const BOT_RECOVERY_ENCOUNTER_INTERVAL := 3.4
const ENEMY_CAGE_CAPTURE_BASE_INTERVAL := 2.2
const DOG_TAMING_BASE_INTERVAL := 5.0
const ATTACK_FEEDBACK_DURATION := 0.22
const DAMAGE_FEEDBACK_DURATION := 0.30
const RESEARCH_FEEDBACK_DURATION := 0.72
const MERGE_FEEDBACK_DURATION := 0.40
const FLOATING_NUMBER_DURATION := 0.60
const DISCOVERY_BANNER_DURATION := 1.8
const BOT_LOG_PAGE_SIZE := 12
const STORAGE_PAGE_SIZE := 10
const TARGET_MARKER_FEEDBACK_DURATION := 1.6

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
const OPERATOR_LERA_PHOTO := preload("res://assets/cards/operator_lera.svg")
const OPERATOR_MIRA_PHOTO := preload("res://assets/cards/operator_mira.svg")
const OPERATOR_DREN_PHOTO := preload("res://assets/cards/operator_dren.svg")
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
var _journal_research_cooldown := JOURNAL_RESEARCH_INTERVAL
var _blueprint_craft_cooldown := BLUEPRINT_CRAFT_INTERVAL
var _enemy_fight_cooldowns := {}
var _bot_recovery_process := {}
var _enemy_cage_capture_process := {}
var _dog_taming_process := {}
var _selected_bot_index := 0
var _drag_candidate := {}
var _active_drag := {}
var _drag_start_root := Vector2.ZERO
var _drag_mouse_root := Vector2.ZERO
var _drag_pickup_offset := Vector2.ZERO
var _current_cursor_shape := Control.CURSOR_ARROW
var _table_machine_position := Vector2.ZERO
var _table_route_position := Vector2.ZERO
var _table_charge_position := Vector2.ZERO
var _table_journal_position := Vector2.ZERO
var _table_operator_position := Vector2.ZERO
var _table_trash_position := Vector2.ZERO
var _table_drone_positions := {}
var _table_cartridge_positions := {}
var _table_blank_positions := {}
var _table_location_positions := {}
var _table_enemy_positions := {}
var _table_dog_positions := {}
var _table_material_positions := {}
var _table_blueprint_positions := {}
var _table_mechanism_positions := {}
var _table_structure_positions := {}
var _table_equipment_positions := {}
var _combat_card_fx := {}
var _location_marker_fx := {}
var _floating_numbers := []
var _floating_announcements := []
var _operator_selection_open := false
var _operator_selection_click_rects := []
var _journal_open := false
var _journal_page_index := 0
var _journal_recipe_click_rects := []
var _journal_index_click_rects := []
var _journal_related_click_rects := []
var _journal_recipe_prev_rect := Rect2()
var _journal_recipe_next_rect := Rect2()
var _journal_prev_rect := Rect2()
var _journal_next_rect := Rect2()
var _journal_close_rect := Rect2()
var _journal_recipe_page_index := 0
var _journal_viewed_subject_key := ""
var _bot_log_open := false
var _bot_log_bot_index := 0
var _bot_log_page_index := 0
var _bot_log_prev_rect := Rect2()
var _bot_log_next_rect := Rect2()
var _bot_log_close_rect := Rect2()
var _storage_open := false
var _storage_container_id := ""
var _storage_page_index := 0
var _storage_item_click_rects := []
var _storage_prev_rect := Rect2()
var _storage_next_rect := Rect2()
var _storage_close_rect := Rect2()
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

func _get_state_table_position_store(kind: String) -> Dictionary:
	match kind:
		"location":
			return _table_location_positions
		"enemy":
			return _table_enemy_positions
		"dog":
			return _table_dog_positions
		"material":
			return _table_material_positions
		"blueprint":
			return _table_blueprint_positions
		"mechanism":
			return _table_mechanism_positions
		"structure", "crafted":
			return _table_structure_positions
		"equipment":
			return _table_equipment_positions
		_:
			return {}

func _get_default_state_table_card_position(kind: String, visible_index: int, workspace: Rect2) -> Vector2:
	match kind:
		"location":
			return workspace.position + Vector2(520.0 + float(visible_index) * 18.0, workspace.end.y - 220.0 + absf(float(visible_index) - 1.5) * 6.0)
		"enemy":
			return workspace.position + Vector2(workspace.end.x - 240.0 + float(visible_index) * 14.0, workspace.end.y - 220.0 + absf(float(visible_index) - 1.0) * 6.0)
		"dog":
			return workspace.position + Vector2(workspace.size.x * 0.5 - 180.0 + float(visible_index) * 18.0, workspace.end.y - 214.0 + absf(float(visible_index) - 1.5) * 6.0)
		"material":
			return workspace.position + Vector2(360.0 + float(visible_index) * 16.0, workspace.end.y - 220.0 + absf(float(visible_index) - 1.5) * 6.0)
		"blueprint":
			return workspace.position + Vector2(508.0 + float(visible_index) * 18.0, workspace.end.y - 232.0 + absf(float(visible_index) - 1.5) * 6.0)
		"mechanism":
			return workspace.position + Vector2(600.0 + float(visible_index) * 18.0, workspace.end.y - 210.0 + absf(float(visible_index) - 1.5) * 6.0)
		"structure", "crafted":
			return workspace.position + Vector2(600.0 + float(visible_index) * 18.0, workspace.end.y - 210.0 + absf(float(visible_index) - 1.5) * 6.0)
		"equipment":
			return workspace.position + Vector2(720.0 + float(visible_index) * 16.0, workspace.end.y - 212.0 + absf(float(visible_index) - 1.5) * 6.0)
		_:
			return workspace.position

func _sync_state_table_card_positions(kind: String, workspace: Rect2) -> void:
	var store := _get_state_table_position_store(kind)
	var valid_ids := {}
	var visible_index := 0
	for card_data in GameState.get_state_table_cards(kind):
		var card_id := str(card_data.get("id", ""))
		if card_id.is_empty():
			continue
		valid_ids[card_id] = true
		if not store.has(card_id):
			var fallback := _get_default_state_table_card_position(kind, visible_index, workspace)
			var layout_key := GameState.get_state_table_card_layout_key(kind, card_id)
			store[card_id] = _clamp_table_position(
				GameState.get_workshop_card_position(layout_key, fallback),
				CARD_SIZE,
				workspace
			)
		visible_index += 1
	for card_id in store.keys():
		if not valid_ids.has(card_id):
			store.erase(card_id)

func _append_state_table_visual_cards(cards: Array, kind: String, rect: Rect2) -> void:
	var store := _get_state_table_position_store(kind)
	for card_data in GameState.get_state_table_cards(kind):
		var card_id := str(card_data.get("id", ""))
		if card_id.is_empty() or _is_dragging_table_card(kind, card_id):
			continue
		var card_pos := Vector2(store.get(card_id, rect.position))
		card_pos += _get_card_feedback_offset(kind, card_id)
		var visual_card := {
			"kind": kind,
			"rect": Rect2(card_pos, CARD_SIZE),
			"card_data": card_data,
			"z": card_pos.y + CARD_SIZE.y,
		}
		visual_card["%s_id" % kind] = card_id
		cards.append(visual_card)

func _set_state_table_card_position(kind: String, card_id: String, position: Vector2) -> void:
	if card_id.is_empty():
		return
	var store := _get_state_table_position_store(kind)
	store[card_id] = position
	var layout_key := GameState.get_state_table_card_layout_key(kind, card_id)
	if not layout_key.is_empty():
		GameState.set_workshop_card_position(layout_key, position)

func _forget_state_table_card(kind: String, card_id: String) -> bool:
	if card_id.is_empty():
		return false
	if not GameState.forget_state_table_card(kind, card_id):
		return false
	_get_state_table_position_store(kind).erase(card_id)
	var layout_key := GameState.get_state_table_card_layout_key(kind, card_id)
	if not layout_key.is_empty():
		GameState.clear_workshop_card_position(layout_key)
	return true

func _set_non_state_table_card_position(kind: String, identifier, position: Vector2) -> void:
	match kind:
		"cartridge":
			_table_cartridge_positions[identifier] = position
			GameState.set_workshop_card_position("cartridge_%s" % str(identifier), position)
		"blank":
			_table_blank_positions[identifier] = position
			GameState.set_workshop_card_position("blank_%d" % int(identifier), position)
		"bot":
			_table_drone_positions[identifier] = position
			GameState.set_workshop_card_position("drone_%d" % int(identifier), position)

func _sync_programmed_cartridge_positions(workspace: Rect2) -> void:
	var valid_cartridge_ids := {}
	var visible_index := 0
	for cartridge_variant in GameState.get_shelf_programmed_cartridges():
		var cartridge: Dictionary = cartridge_variant
		var cartridge_id := str(cartridge.get("id", ""))
		valid_cartridge_ids[cartridge_id] = true
		if not _table_cartridge_positions.has(cartridge_id):
			var fallback := workspace.position + Vector2(36.0 + float(visible_index) * 34.0, workspace.end.y - 190.0 + absf(float(visible_index) - 1.5) * 8.0)
			_table_cartridge_positions[cartridge_id] = _clamp_table_position(
				GameState.get_workshop_card_position("cartridge_%s" % cartridge_id, fallback),
				CARD_SIZE,
				workspace
			)
		visible_index += 1
	for cartridge_id in _table_cartridge_positions.keys():
		if not valid_cartridge_ids.has(cartridge_id):
			_table_cartridge_positions.erase(cartridge_id)

func _sync_blank_card_positions(workspace: Rect2) -> void:
	var valid_blank_indices := {}
	for blank_index in range(GameState.get_blank_cartridge_count()):
		valid_blank_indices[blank_index] = true
		if not _table_blank_positions.has(blank_index):
			_table_blank_positions[blank_index] = _clamp_table_position(
				GameState.get_workshop_card_position("blank_%d" % blank_index, workspace.position + Vector2(workspace.end.x - 340.0 + float(blank_index) * 28.0, workspace.end.y - 190.0 + absf(float(blank_index) - 1.5) * 6.0)),
				CARD_SIZE,
				workspace
			)
	for blank_index in _table_blank_positions.keys():
		if not valid_blank_indices.has(blank_index):
			_table_blank_positions.erase(blank_index)

func _sync_drone_card_positions(workspace: Rect2) -> void:
	var valid_bot_indices := {}
	for bot_index in range(GameState.bot_loadouts.size()):
		valid_bot_indices[bot_index] = true
		if not _table_drone_positions.has(bot_index):
			_table_drone_positions[bot_index] = _clamp_table_position(
				GameState.get_workshop_card_position("drone_%d" % bot_index, workspace.position + Vector2(workspace.size.x - 320.0 + float(bot_index) * 146.0, 34.0)),
				CARD_SIZE,
				workspace
			)
	for stored_bot_index in _table_drone_positions.keys():
		if not valid_bot_indices.has(stored_bot_index):
			_table_drone_positions.erase(stored_bot_index)

func _append_programmed_cartridge_visual_cards(cards: Array, tape_data: Dictionary) -> void:
	for slot in tape_data["programmed_slots"]:
		var cartridge: Dictionary = slot["cartridge"]
		var cartridge_id := str(cartridge.get("id", ""))
		if _is_dragging_table_card("cartridge", cartridge_id):
			continue
		var cartridge_rect := Rect2(slot["rect"])
		cartridge_rect.position += _get_card_feedback_offset("cartridge", cartridge_id)
		cards.append({
			"kind": "cartridge",
			"rect": cartridge_rect,
			"cartridge_id": cartridge_id,
			"label": str(cartridge.get("label", "")),
			"selected": bool(slot["selected"]),
			"z": cartridge_rect.end.y,
		})

func _append_blank_visual_cards(cards: Array, tape_data: Dictionary) -> void:
	for slot in tape_data["blank_slots"]:
		if not bool(slot["filled"]):
			continue
		var blank_index := int(slot["index"])
		if _is_dragging_table_card("blank", blank_index):
			continue
		var blank_rect := Rect2(slot["rect"])
		blank_rect.position += _get_card_feedback_offset("blank", blank_index)
		cards.append({
			"kind": "blank",
			"rect": blank_rect,
			"blank_index": blank_index,
			"z": blank_rect.end.y,
		})

func _append_drone_visual_cards(cards: Array, rect: Rect2) -> void:
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

func _begin_drag_candidate(root_point: Vector2, rect: Rect2, kind: String, extra: Dictionary = {}) -> void:
	var drag_state := WorkshopCardRuntimeData.begin_drag_candidate(root_point, rect, kind, extra)
	_drag_start_root = Vector2(drag_state.get("drag_start_root", root_point))
	_drag_pickup_offset = Vector2(drag_state.get("drag_pickup_offset", root_point - rect.position))
	_drag_candidate = Dictionary(drag_state.get("payload", {}))

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
	_operator_selection_open = GameState.needs_operator_selection() or not GameState.is_run_active()
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
	if _operator_selection_open:
		return
	_tick_combat_feedback(delta)
	if not GameState.is_run_active():
		return
	_tick_charge_machine(delta)
	_tick_route_scan(delta)
	_tick_journal_research(delta)
	_tick_blueprint_crafting(delta)
	_tick_tank_process(delta)
	_tick_bot_recovery(delta)
	_tick_enemy_cage_capture(delta)
	_tick_dog_taming(delta)
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
	var target_bot := _get_charge_machine_target_bot_index(rect)
	if target_bot == -1 or not _is_charge_machine_operating() or not GameState.has_charged_power_unit_available():
		_charge_production_cooldown = CHARGE_PRODUCTION_INTERVAL
		return
	var charge_rect := Rect2(_table_charge_position, CARD_SIZE)
	_charge_production_cooldown -= delta
	queue_redraw()
	if _charge_production_cooldown > 0.0:
		return
	_charge_production_cooldown = CHARGE_PRODUCTION_INTERVAL
	var charge_result := GameState.charge_bot_with_power_units(target_bot, GameState.CHARGE_MACHINE_TRANSFER_UNITS)
	if bool(charge_result.get("ok", false)):
		_trigger_research_card_feedback("bot", target_bot)
		EventBus.log_message.emit("%s +%d power" % [_bot_display_name(target_bot), int(charge_result.get("charged", 0))])
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

func _tick_journal_research(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	var subject := _get_journal_research_subject(rect)
	if subject.is_empty():
		_journal_research_cooldown = JOURNAL_RESEARCH_INTERVAL
		return
	_journal_research_cooldown -= delta
	queue_redraw()
	if _journal_research_cooldown > 0.0:
		return
	_journal_research_cooldown = JOURNAL_RESEARCH_INTERVAL
	var result: Dictionary = GameState.resolve_journal_research(subject)
	if result.is_empty():
		return
	var recipe: Dictionary = result.get("recipe", {})
	var entry: Dictionary = result.get("entry", {})
	var failure_penalty: Dictionary = result.get("failure_penalty", {})
	if bool(result.get("success", false)) and not recipe.is_empty():
		var blueprint := GameState.create_blueprint_card(recipe)
		var blueprint_id := str(blueprint.get("id", ""))
		if not blueprint_id.is_empty():
			_place_generated_blueprint_card(blueprint_id, Rect2(_table_journal_position, CARD_SIZE))
		_trigger_research_success_feedback(subject, recipe)
		EventBus.log_message.emit("Research noted: %s" % str(recipe.get("result", "Formula")))
	else:
		_trigger_research_failure_feedback(subject, failure_penalty)
		var fail_message := "Research failed: %s" % str(entry.get("title", "ENTRY"))
		if bool(failure_penalty.get("collapsed", false)):
			fail_message = "Research failed: %s. Operator collapsed." % str(entry.get("title", "ENTRY"))
		EventBus.log_message.emit(fail_message)
	queue_redraw()

func _tick_blueprint_crafting(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	var craft_state := _get_active_blueprint_craft_state(rect)
	if craft_state.is_empty():
		_blueprint_craft_cooldown = BLUEPRINT_CRAFT_INTERVAL
		return
	_blueprint_craft_cooldown -= delta
	queue_redraw()
	if _blueprint_craft_cooldown > 0.0:
		return
	_blueprint_craft_cooldown = BLUEPRINT_CRAFT_INTERVAL
	var crafted_card := GameState.resolve_blueprint_craft(str(craft_state.get("blueprint_id", "")), Array(craft_state.get("material_consumptions", [])))
	if crafted_card.is_empty():
		return
	var crafted_kind := str(crafted_card.get("kind", "structure"))
	if crafted_kind == "blank":
		EventBus.log_message.emit("Fresh tape crafted")
		queue_redraw()
		return
	var crafted_id := str(crafted_card.get("id", ""))
	if crafted_kind == "material" and not crafted_id.is_empty():
		_place_generated_material_card(crafted_id, Rect2(craft_state.get("machine_rect", Rect2())))
		EventBus.log_message.emit("%s crafted" % str(crafted_card.get("display_name", crafted_card.get("result", "Resource"))))
		queue_redraw()
		return
	if crafted_kind == "equipment" and not crafted_id.is_empty():
		_place_generated_equipment_card(crafted_id, Rect2(craft_state.get("machine_rect", Rect2())))
		EventBus.log_message.emit("%s crafted" % str(crafted_card.get("display_name", crafted_card.get("result", "Equipment"))))
		queue_redraw()
		return
	if crafted_kind == "mechanism" and not crafted_id.is_empty():
		_place_generated_mechanism_card(crafted_id, Rect2(craft_state.get("machine_rect", Rect2())))
		EventBus.log_message.emit("%s crafted" % str(crafted_card.get("display_name", crafted_card.get("result", "Mechanism"))))
		queue_redraw()
		return
	if not crafted_id.is_empty():
		_place_generated_structure_card(crafted_id, Rect2(craft_state.get("machine_rect", Rect2())))
		EventBus.log_message.emit("%s crafted" % str(crafted_card.get("display_name", crafted_card.get("result", "Item"))))
	queue_redraw()

func _tick_tank_process(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	for start_variant in GameState.start_available_tank_processes():
		if typeof(start_variant) != TYPE_DICTIONARY:
			continue
		var start_result: Dictionary = start_variant
		var started_tank_id := str(start_result.get("tank_id", ""))
		if not started_tank_id.is_empty():
			_trigger_research_card_feedback("mechanism", started_tank_id)
		EventBus.log_message.emit("Tank cycle started: %s" % str(start_result.get("display_name", "Bioprocess")))
		queue_redraw()
	var completions := GameState.tick_tank_processes()
	for completion_variant in completions:
		if typeof(completion_variant) != TYPE_DICTIONARY:
			continue
		var completion: Dictionary = completion_variant
		var tank_id := str(completion.get("tank_id", ""))
		var created_material: Dictionary = Dictionary(completion.get("material", {}))
		var material_id := str(created_material.get("id", ""))
		if material_id.is_empty():
			continue
		var tank_rect := Rect2(_table_mechanism_positions.get(tank_id, Vector2.ZERO), CARD_SIZE)
		_place_generated_material_card(material_id, tank_rect)
		if not tank_id.is_empty():
			_trigger_research_card_feedback("mechanism", tank_id)
		EventBus.log_message.emit("Tank output ready: %s" % str(created_material.get("display_name", created_material.get("type", "Resource"))))
		queue_redraw()

func _tick_enemy_cage_capture(delta: float):
	if _enemy_cage_capture_process.is_empty():
		return
	var cage_id := str(_enemy_cage_capture_process.get("cage_id", ""))
	var enemy_id := str(_enemy_cage_capture_process.get("enemy_id", ""))
	if cage_id.is_empty() or enemy_id.is_empty():
		_enemy_cage_capture_process.clear()
		return
	if not GameState.is_enemy_cage_crafted_card(cage_id) or GameState.is_enemy_cage_occupied(cage_id):
		_enemy_cage_capture_process.clear()
		return
	if _get_enemy_card_by_id(enemy_id).is_empty():
		_enemy_cage_capture_process.clear()
		return
	var remaining_cooldown := maxf(float(_enemy_cage_capture_process.get("cooldown", 0.0)) - delta, 0.0)
	_enemy_cage_capture_process["cooldown"] = remaining_cooldown
	queue_redraw()
	if remaining_cooldown > 0.0:
		return
	var result := GameState.resolve_enemy_cage_capture(cage_id, enemy_id)
	var capture_rect := Rect2(_enemy_cage_capture_process.get("rect", Rect2()))
	var enemy_name := str(_enemy_cage_capture_process.get("enemy_name", "Enemy"))
	_enemy_cage_capture_process.clear()
	if result.is_empty() or not bool(result.get("ok", false)):
		EventBus.log_message.emit(str(result.get("message", "Capture failed")))
		return
	if bool(result.get("success", false)):
		_table_enemy_positions.erase(enemy_id)
		var enemy_layout_key := GameState.get_state_table_card_layout_key("enemy", enemy_id)
		if not enemy_layout_key.is_empty():
			GameState.clear_workshop_card_position(enemy_layout_key)
		_trigger_research_card_feedback("structure", cage_id)
		_trigger_research_card_feedback("enemy", enemy_id)
		_floating_announcements.append({
			"position": capture_rect.get_center() + Vector2(0.0, -28.0),
			"text": "CAPTURED",
			"subtext": enemy_name,
			"timer": DISCOVERY_BANNER_DURATION,
			"duration": DISCOVERY_BANNER_DURATION,
		})
	else:
		_table_structure_positions.erase(cage_id)
		var cage_layout_key := GameState.get_state_table_card_layout_key("structure", cage_id)
		if not cage_layout_key.is_empty():
			GameState.clear_workshop_card_position(cage_layout_key)
		_trigger_research_failure_card_feedback("enemy", enemy_id)
		_floating_announcements.append({
			"position": capture_rect.get_center() + Vector2(0.0, -28.0),
			"text": "CAPTURE FAILED",
			"subtext": "CAGE LOST",
			"timer": DISCOVERY_BANNER_DURATION,
			"duration": DISCOVERY_BANNER_DURATION,
		})
	EventBus.log_message.emit(str(result.get("message", "Capture resolved")))

func _tick_dog_taming(delta: float):
	if _dog_taming_process.is_empty():
		return
	var cage_id := str(_dog_taming_process.get("cage_id", ""))
	var material_id := str(_dog_taming_process.get("material_id", ""))
	if cage_id.is_empty() or material_id.is_empty():
		_dog_taming_process.clear()
		return
	if not GameState.is_wolf_taming_cage(cage_id):
		_dog_taming_process.clear()
		return
	var material_card := _get_material_card_by_id(material_id)
	if material_card.is_empty() or str(material_card.get("type", "")) != "bone":
		_dog_taming_process.clear()
		return
	var remaining_cooldown := maxf(float(_dog_taming_process.get("cooldown", 0.0)) - delta, 0.0)
	_dog_taming_process["cooldown"] = remaining_cooldown
	queue_redraw()
	if remaining_cooldown > 0.0:
		return
	var taming_rect := Rect2(_dog_taming_process.get("rect", Rect2()))
	var result := GameState.resolve_wolf_taming(cage_id, material_id)
	_dog_taming_process.clear()
	if result.is_empty() or not bool(result.get("ok", false)):
		EventBus.log_message.emit(str(result.get("message", "Taming failed")))
		return
	if bool(result.get("removed_material", false)):
		_table_material_positions.erase(material_id)
		var material_layout_key := GameState.get_state_table_card_layout_key("material", material_id)
		if not material_layout_key.is_empty():
			GameState.clear_workshop_card_position(material_layout_key)
	if bool(result.get("success", false)):
		var dog_card := Dictionary(result.get("dog_card", {}))
		var dog_id := str(dog_card.get("id", ""))
		if not dog_id.is_empty():
			_place_generated_dog_card(dog_id, taming_rect)
		_trigger_research_card_feedback("structure", cage_id)
		_floating_announcements.append({
			"position": taming_rect.get_center() + Vector2(0.0, -28.0),
			"text": "TAMED",
			"subtext": "DOG",
			"timer": DISCOVERY_BANNER_DURATION,
			"duration": DISCOVERY_BANNER_DURATION,
		})
	else:
		_trigger_research_failure_card_feedback("structure", cage_id)
		_floating_announcements.append({
			"position": taming_rect.get_center() + Vector2(0.0, -28.0),
			"text": "TAMING FAILED",
			"subtext": "WOLF RESISTS",
			"timer": DISCOVERY_BANNER_DURATION,
			"duration": DISCOVERY_BANNER_DURATION,
		})
	EventBus.log_message.emit(str(result.get("message", "Taming resolved")))

func _tick_bot_recovery(delta: float):
	if not is_instance_valid(map_region):
		return
	var rect := _rect_in_root(map_region)
	_ensure_table_layout(rect)
	var candidate := _get_active_bot_recovery_candidate(rect)
	if candidate.is_empty():
		_bot_recovery_process.clear()
		return
	var bot_index := int(candidate.get("bot_index", -1))
	if bot_index == -1:
		_bot_recovery_process.clear()
		return
	if int(_bot_recovery_process.get("bot_index", -999)) != bot_index:
		var duration := float(candidate.get("duration", BOT_RECOVERY_BASE_INTERVAL))
		_bot_recovery_process = {
			"bot_index": bot_index,
			"rect": Rect2(candidate.get("rect", Rect2())),
			"duration": duration,
			"cooldown": duration,
			"energy_cost": int(candidate.get("energy_cost", 1)),
			"distance": int(candidate.get("distance", 0)),
			"encounter_interval": BOT_RECOVERY_ENCOUNTER_INTERVAL,
			"encounter_cooldown": minf(BOT_RECOVERY_ENCOUNTER_INTERVAL, maxf(duration * 0.5, 1.6)),
			"encounter_rolls": 0,
			"retrieval_from_active": bool(candidate.get("retrieval_from_active", false)),
		}
		EventBus.log_message.emit("%s started: %s" % ["Retrieval" if bool(_bot_recovery_process.get("retrieval_from_active", false)) else "Recovery", _bot_display_name(bot_index)])
		queue_redraw()
	var remaining_cooldown := maxf(float(_bot_recovery_process.get("cooldown", 0.0)) - delta, 0.0)
	var remaining_encounter := maxf(float(_bot_recovery_process.get("encounter_cooldown", BOT_RECOVERY_ENCOUNTER_INTERVAL)) - delta, 0.0)
	_bot_recovery_process["cooldown"] = remaining_cooldown
	_bot_recovery_process["encounter_cooldown"] = remaining_encounter
	queue_redraw()
	if remaining_cooldown > 0.0 and remaining_encounter <= 0.0:
		_bot_recovery_process["encounter_cooldown"] = float(_bot_recovery_process.get("encounter_interval", BOT_RECOVERY_ENCOUNTER_INTERVAL))
		var encounter_rolls := int(_bot_recovery_process.get("encounter_rolls", 0))
		_bot_recovery_process["encounter_rolls"] = encounter_rolls + 1
		var encounter_chance := clampf(0.18 + float(int(_bot_recovery_process.get("distance", 0))) * 0.04 + float(encounter_rolls) * 0.08, 0.0, 0.68)
		if randf() <= encounter_chance:
			var enemy_card := GameState.spawn_random_enemy_card("bot_recovery")
			var enemy_id := str(enemy_card.get("id", ""))
			if not enemy_id.is_empty():
				_place_generated_enemy_card(enemy_id, Rect2(candidate.get("rect", Rect2())))
				_trigger_research_failure_card_feedback("operator", 0)
				_trigger_research_failure_card_feedback("bot", bot_index)
				_floating_announcements.append({
					"position": Rect2(candidate.get("rect", Rect2())).get_center() + Vector2(0.0, -30.0),
					"text": "HOSTILE CONTACT",
					"subtext": str(enemy_card.get("display_name", "Hostile")),
					"timer": DISCOVERY_BANNER_DURATION,
					"duration": DISCOVERY_BANNER_DURATION,
				})
				EventBus.log_message.emit("Recovery encounter: %s" % str(enemy_card.get("display_name", "Hostile")))
	if remaining_cooldown > 0.0:
		return
	var result := GameState.resolve_bot_recovery(bot_index)
	_bot_recovery_process.clear()
	if result.is_empty() or not bool(result.get("ok", false)):
		EventBus.log_message.emit(str(result.get("message", "Recovery failed")))
		return
	_trigger_research_card_feedback("operator", 0)
	_trigger_research_card_feedback("bot", bot_index)
	var operator_center := Rect2(_table_operator_position, CARD_SIZE).get_center()
	var energy_loss := int(result.get("energy_loss", 0))
	var hp_loss := int(result.get("hp_loss", 0))
	if energy_loss > 0:
		_spawn_floating_feedback(operator_center + Vector2(-16.0, -18.0), "-%d EN" % energy_loss, Color(0.89, 0.71, 0.29), 68.0)
	if hp_loss > 0:
		_spawn_floating_feedback(operator_center + Vector2(14.0, -6.0), "-%d HP" % hp_loss, Color(0.93, 0.42, 0.34), 68.0)
	var recovery_text := "DRONE RECOVERED"
	if bool(result.get("retrieval_from_active", false)):
		recovery_text = "DRONE RETRIEVED"
	if bool(result.get("collapsed", false)):
		recovery_text = "%s - COLLAPSE" % recovery_text
	_floating_announcements.append({
		"position": Rect2(candidate.get("rect", Rect2())).get_center() + Vector2(0.0, -28.0),
		"text": recovery_text,
		"subtext": str(result.get("bot_name", "Drone")),
		"timer": DISCOVERY_BANNER_DURATION,
		"duration": DISCOVERY_BANNER_DURATION,
	})
	EventBus.log_message.emit(str(result.get("summary", "%s recovered" % _bot_display_name(bot_index))))
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
		var result: Dictionary = GameState.resolve_enemy_fight(
			enemy_id,
			bool(fight_info.get("use_operator", false)),
			Array(fight_info.get("bot_indices", [])),
			Array(fight_info.get("dog_ids", []))
		)
		if result.is_empty():
			continue
		_emit_enemy_fight_feedback(enemy_id, fight_info, result)
		if bool(result.get("defeated", false)):
			var drop_card: Dictionary = result.get("drop_card", {})
			var drop_kind := str(drop_card.get("kind", ""))
			var drop_id := str(drop_card.get("id", ""))
			_table_enemy_positions.erase(enemy_id)
			_enemy_fight_cooldowns.erase(enemy_id)
			EventBus.log_message.emit("%s defeated" % str(result.get("enemy_name", "Hostile")))
			if not drop_id.is_empty():
				_place_generated_material_card(drop_id, Rect2(fight_info.get("rect", Rect2())))
				EventBus.log_message.emit("%s dropped" % str(drop_card.get("display_name", "Material")))
		else:
			EventBus.log_message.emit("%s fought back" % str(result.get("enemy_name", "Hostile")))
		for dog_drop_variant in Array(result.get("dog_drops", [])):
			var dog_drop: Dictionary = dog_drop_variant
			var fallen_dog_id := str(dog_drop.get("dog_id", ""))
			var dog_drop_card: Dictionary = Dictionary(dog_drop.get("drop_card", {}))
			var dog_drop_kind := str(dog_drop_card.get("kind", ""))
			var dog_drop_id := str(dog_drop_card.get("id", ""))
			var dog_rect := Rect2(Vector2(_table_dog_positions.get(fallen_dog_id, rect.position)), CARD_SIZE)
			if not dog_drop_id.is_empty():
				_place_generated_material_card(dog_drop_id, dog_rect)
				EventBus.log_message.emit("%s dropped" % str(dog_drop_card.get("display_name", "Material")))
			_table_dog_positions.erase(fallen_dog_id)
			var dog_layout_key := GameState.get_state_table_card_layout_key("dog", fallen_dog_id)
			if not dog_layout_key.is_empty():
				GameState.clear_workshop_card_position(dog_layout_key)
			EventBus.log_message.emit("%s died" % str(dog_drop.get("display_name", "DOG")))

func _tick_combat_feedback(delta: float):
	var active := false
	for fx_key in _combat_card_fx.keys():
		var tick_result := WorkshopCardRuntimeData.tick_feedback_entry(Dictionary(_combat_card_fx[fx_key]), delta)
		var entry: Dictionary = tick_result.get("entry", {})
		if not bool(tick_result.get("active", false)):
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
	for announcement_index in range(_floating_announcements.size() - 1, -1, -1):
		var announcement: Dictionary = _floating_announcements[announcement_index]
		announcement["timer"] = maxf(float(announcement.get("timer", DISCOVERY_BANNER_DURATION)) - delta, 0.0)
		if float(announcement.get("timer", 0.0)) <= 0.0:
			_floating_announcements.remove_at(announcement_index)
		else:
			_floating_announcements[announcement_index] = announcement
			active = true
	for location_id in _location_marker_fx.keys():
		var marker_entry: Dictionary = Dictionary(_location_marker_fx[location_id])
		marker_entry["timer"] = maxf(float(marker_entry.get("timer", TARGET_MARKER_FEEDBACK_DURATION)) - delta, 0.0)
		if float(marker_entry.get("timer", 0.0)) <= 0.0:
			_location_marker_fx.erase(location_id)
		else:
			_location_marker_fx[location_id] = marker_entry
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
	for dog_attack in Array(result.get("dog_attacks", [])):
		var dog_attack_entry: Dictionary = dog_attack
		var dog_id := str(dog_attack_entry.get("dog_id", ""))
		if dog_id.is_empty():
			continue
		var dog_center := _get_table_card_center("dog", dog_id)
		_trigger_attack_feedback("dog", dog_id, enemy_center - dog_center, int(dog_attack_entry.get("attack", 0)))
	for dog_damage in Array(result.get("dog_damage", [])):
		var dog_damage_entry: Dictionary = dog_damage
		_trigger_damage_feedback("dog", str(dog_damage_entry.get("dog_id", "")), int(dog_damage_entry.get("damage", 0)))
	_trigger_damage_feedback("enemy", enemy_id, int(result.get("total_attack", 0)))

func _trigger_attack_feedback(kind: String, identifier, direction: Vector2, amount: int):
	if amount <= 0:
		return
	var fx_key := _get_card_fx_key(kind, identifier)
	_combat_card_fx[fx_key] = WorkshopCardRuntimeData.set_feedback_phase(Dictionary(_combat_card_fx.get(fx_key, {})), "attack", ATTACK_FEEDBACK_DURATION, {
		"attack_dir": direction.normalized() if direction.length() > 0.0 else Vector2.RIGHT,
		"seed": float(fx_key.hash() % 97),
	})
	_floating_numbers.append({
		"position": _get_table_card_center(kind, identifier) + Vector2(0.0, -24.0),
		"value": str(amount),
		"color": Color(0.90, 0.78, 0.36),
		"timer": FLOATING_NUMBER_DURATION,
		"duration": FLOATING_NUMBER_DURATION,
		"width": 32.0,
	})

func _trigger_damage_feedback(kind: String, identifier, amount: int):
	if amount <= 0:
		return
	if (kind == "bot" or kind == "operator") and int(identifier) == -1:
		return
	var fx_key := _get_card_fx_key(kind, identifier)
	_combat_card_fx[fx_key] = WorkshopCardRuntimeData.set_feedback_phase(Dictionary(_combat_card_fx.get(fx_key, {})), "damage", DAMAGE_FEEDBACK_DURATION, {
		"seed": float((fx_key.hash() % 131) + 17),
	})
	_floating_numbers.append({
		"position": _get_table_card_center(kind, identifier) + Vector2(0.0, -8.0),
		"value": str(amount),
		"color": Color(0.93, 0.42, 0.34),
		"timer": FLOATING_NUMBER_DURATION,
		"duration": FLOATING_NUMBER_DURATION,
		"width": 32.0,
	})

func _trigger_research_card_feedback(kind: String, identifier) -> void:
	var fx_key := _get_card_fx_key(kind, identifier)
	_combat_card_fx[fx_key] = WorkshopCardRuntimeData.set_feedback_phase(Dictionary(_combat_card_fx.get(fx_key, {})), "research", RESEARCH_FEEDBACK_DURATION)

func _trigger_merge_feedback(kind: String, identifier, added_quantity: int) -> void:
	if added_quantity <= 0:
		return
	var fx_key := _get_card_fx_key(kind, identifier)
	_combat_card_fx[fx_key] = WorkshopCardRuntimeData.set_feedback_phase(Dictionary(_combat_card_fx.get(fx_key, {})), "merge", MERGE_FEEDBACK_DURATION, {
		"seed": float((fx_key.hash() % 149) + 11),
	})
	_spawn_floating_feedback(
		_get_table_card_center(kind, identifier) + Vector2(0.0, -18.0),
		"+%d" % added_quantity,
		Color(0.86, 0.78, 0.42),
		40.0,
		0.70
	)

func _emit_equipment_total_feedback(kind: String, identifier, before_totals: Dictionary, after_totals: Dictionary) -> void:
	var attack_delta := int(after_totals.get("attack", 0)) - int(before_totals.get("attack", 0))
	var armor_delta := int(after_totals.get("armor", 0)) - int(before_totals.get("armor", 0))
	if attack_delta == 0 and armor_delta == 0:
		return
	if attack_delta > 0 or armor_delta > 0:
		_trigger_research_card_feedback(kind, identifier)
	if attack_delta < 0 or armor_delta < 0:
		_trigger_research_failure_card_feedback(kind, identifier)
	var base_position := _get_table_card_center(kind, identifier) + Vector2(0.0, -18.0)
	if attack_delta != 0:
		_spawn_floating_feedback(
			base_position + Vector2(-18.0, -4.0),
			"%s ATK" % _format_signed_delta(attack_delta),
			Color(0.86, 0.78, 0.42) if attack_delta > 0 else Color(0.93, 0.42, 0.34),
			60.0,
			0.72
		)
	if armor_delta != 0:
		_spawn_floating_feedback(
			base_position + Vector2(20.0, 8.0),
			"%s ARM" % _format_signed_delta(armor_delta),
			Color(0.86, 0.78, 0.42) if armor_delta > 0 else Color(0.93, 0.42, 0.34),
			64.0,
			0.72
		)

func _format_signed_delta(value: int) -> String:
	return "+%d" % value if value >= 0 else str(value)

func _trigger_research_success_feedback(subject: Dictionary, recipe: Dictionary) -> void:
	_trigger_research_card_feedback("journal_card", 0)
	_trigger_research_card_feedback("operator", 0)
	var source_kind := str(subject.get("source_kind", ""))
	if not source_kind.is_empty():
		_trigger_research_card_feedback(source_kind, subject.get("source_identifier", 0))
	_floating_announcements.append({
		"position": Rect2(_table_journal_position, CARD_SIZE).get_center() + Vector2(0.0, -28.0),
		"text": "NEW DISCOVERY",
		"subtext": str(recipe.get("result", "")),
		"timer": DISCOVERY_BANNER_DURATION,
		"duration": DISCOVERY_BANNER_DURATION,
	})

func _trigger_research_failure_feedback(subject: Dictionary, penalty: Dictionary) -> void:
	_trigger_research_failure_card_feedback("journal_card", 0)
	_trigger_research_failure_card_feedback("operator", 0)
	var source_kind := str(subject.get("source_kind", ""))
	if not source_kind.is_empty():
		_trigger_research_failure_card_feedback(source_kind, subject.get("source_identifier", 0))
	var operator_center := Rect2(_table_operator_position, CARD_SIZE).get_center()
	var energy_loss := int(penalty.get("energy_loss", 0))
	var hp_loss := int(penalty.get("hp_loss", 0))
	if energy_loss > 0:
		_spawn_floating_feedback(operator_center + Vector2(-16.0, -18.0), "-%d EN" % energy_loss, Color(0.89, 0.71, 0.29), 68.0)
	if hp_loss > 0:
		_spawn_floating_feedback(operator_center + Vector2(14.0, -6.0), "-%d HP" % hp_loss, Color(0.93, 0.42, 0.34), 68.0)
	var fail_text := "RESEARCH FAILED"
	if bool(penalty.get("collapsed", false)):
		fail_text = "RESEARCH FAILED - COLLAPSE"
	_floating_announcements.append({
		"position": Rect2(_table_journal_position, CARD_SIZE).get_center() + Vector2(0.0, -28.0),
		"text": fail_text,
		"subtext": "",
		"timer": DISCOVERY_BANNER_DURATION,
		"duration": DISCOVERY_BANNER_DURATION,
	})

func _trigger_research_failure_card_feedback(kind: String, identifier) -> void:
	var fx_key := _get_card_fx_key(kind, identifier)
	_combat_card_fx[fx_key] = WorkshopCardRuntimeData.set_feedback_phase(Dictionary(_combat_card_fx.get(fx_key, {})), "failure", DAMAGE_FEEDBACK_DURATION * 1.9, {
		"seed": float((fx_key.hash() % 179) + 29),
	})

func _spawn_floating_feedback(position: Vector2, value: String, color: Color, width: float = 32.0, duration: float = FLOATING_NUMBER_DURATION) -> void:
	_floating_numbers.append({
		"position": position,
		"value": value,
		"color": color,
		"timer": duration,
		"duration": duration,
		"width": width,
	})

func _trigger_location_target_feedback(location_id: String) -> void:
	if location_id.is_empty():
		return
	_location_marker_fx[location_id] = {
		"timer": TARGET_MARKER_FEEDBACK_DURATION,
		"duration": TARGET_MARKER_FEEDBACK_DURATION,
		"seed": float(location_id.hash() % 97),
	}

func _draw_location_target_card_pulse(card_rect: Rect2, location_id: String) -> void:
	var feedback_entry: Dictionary = Dictionary(_location_marker_fx.get(location_id, {}))
	if feedback_entry.is_empty():
		return
	var duration := maxf(float(feedback_entry.get("duration", TARGET_MARKER_FEEDBACK_DURATION)), 0.001)
	var progress := 1.0 - float(feedback_entry.get("timer", TARGET_MARKER_FEEDBACK_DURATION)) / duration
	var pulse_scale := 2.0 + sin(progress * TAU * 3.0) * 2.0
	var pulse_alpha := clampf(0.28 - progress * 0.12, 0.08, 0.28)
	var outer_rect := card_rect.grow(pulse_scale + 4.0)
	var inner_rect := card_rect.grow(pulse_scale)
	draw_rect(outer_rect, Color(0.93, 0.80, 0.34, pulse_alpha * 0.45), false, 2.0)
	draw_rect(inner_rect, Color(0.97, 0.88, 0.52, pulse_alpha), false, 1.6)

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
	var research_timer := float(entry.get("research_timer", 0.0))
	var research_duration := maxf(float(entry.get("research_duration", RESEARCH_FEEDBACK_DURATION)), 0.001)
	if research_timer > 0.0:
		var research_progress := 1.0 - research_timer / research_duration
		offset += Vector2(
			sin(research_progress * TAU * 4.0) * 3.0,
			cos(research_progress * TAU * 2.0) * 1.4
		)
	var merge_timer := float(entry.get("merge_timer", 0.0))
	var merge_duration := maxf(float(entry.get("merge_duration", MERGE_FEEDBACK_DURATION)), 0.001)
	if merge_timer > 0.0:
		var merge_progress := 1.0 - merge_timer / merge_duration
		offset += Vector2(
			sin(merge_progress * TAU * 3.0) * 4.0,
			cos(merge_progress * TAU * 2.0) * 0.9
		)
	var failure_timer := float(entry.get("failure_timer", 0.0))
	var failure_duration := maxf(float(entry.get("failure_duration", DAMAGE_FEEDBACK_DURATION * 1.9)), 0.001)
	if failure_timer > 0.0:
		var failure_progress := 1.0 - failure_timer / failure_duration
		var amplitude := (1.0 - failure_progress) * 8.5
		var fail_seed := float(entry.get("seed", 3.0))
		offset += Vector2(
			sin(failure_progress * 41.0 + fail_seed),
			cos(failure_progress * 37.0 + fail_seed * 1.2)
		) * amplitude
	return offset

func _get_table_card_center(kind: String, identifier) -> Vector2:
	match kind:
		"operator":
			return Rect2(_table_operator_position, CARD_SIZE).get_center()
		"bot":
			return Rect2(Vector2(_table_drone_positions.get(int(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		"dog":
			return Rect2(Vector2(_table_dog_positions.get(str(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		"enemy":
			return Rect2(Vector2(_table_enemy_positions.get(str(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		"material":
			return Rect2(Vector2(_table_material_positions.get(str(identifier), Vector2.ZERO)), CARD_SIZE).get_center()
		_:
			return Vector2.ZERO

func _is_charge_machine_operating() -> bool:
	return true

func _get_charge_machine_target_bot_index(rect: Rect2) -> int:
	_ensure_table_layout(rect)
	var charge_rect := Rect2(_table_charge_position, CARD_SIZE)
	for slot_variant in _get_table_drone_data(rect):
		var slot: Dictionary = slot_variant
		if not bool(slot.get("available_in_workshop", false)):
			continue
		if not _has_meaningful_overlap(charge_rect, Rect2(slot.get("rect", Rect2())), 0.30):
			continue
		var bot_index := int(slot.get("index", -1))
		if bot_index == -1:
			continue
		var power_charge := int(slot.get("power_charge", 0))
		var max_power_charge := int(slot.get("max_power_charge", GameState.BOT_POWER_CAPACITY))
		if power_charge >= max_power_charge:
			continue
		return bot_index
	return -1

func _is_route_scan_operating() -> bool:
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	var route_rect := Rect2(_table_route_position, CARD_SIZE)
	return _has_meaningful_overlap(route_rect, operator_rect, 0.30)

func _is_journal_research_operating() -> bool:
	if not _get_journal_research_subject(_rect_in_root(map_region)).is_empty():
		var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
		var journal_rect := Rect2(_table_journal_position, CARD_SIZE)
		return _has_meaningful_overlap(journal_rect, operator_rect, 0.30)
	return false

func _get_active_bot_recovery_candidate(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	for slot in _get_table_drone_data(rect):
		var bot_index := int(slot.get("index", -1))
		if bot_index == -1:
			continue
		if bool(slot.get("available_in_workshop", false)):
			continue
		if not GameState.can_operator_retrieve_bot(bot_index):
			continue
		var drone_rect := Rect2(slot.get("rect", Rect2()))
		if not _has_meaningful_overlap(drone_rect, operator_rect, 0.30):
			continue
		var distance := GameState.get_bot_recovery_distance(bot_index)
		return {
			"bot_index": bot_index,
			"rect": drone_rect,
			"distance": distance,
			"energy_cost": GameState.get_bot_recovery_energy_cost(bot_index),
			"duration": _get_bot_recovery_duration(distance),
			"retrieval_from_active": str(slot.get("outside_status", "cabinet")) == "active",
		}
	return {}

func _get_bot_recovery_duration(distance: int) -> float:
	return BOT_RECOVERY_BASE_INTERVAL + float(maxi(distance, 1)) * BOT_RECOVERY_PER_TILE_INTERVAL

func _get_journal_research_subject(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	var journal_rect := Rect2(_table_journal_position, CARD_SIZE)
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	if not _has_meaningful_overlap(journal_rect, operator_rect, 0.30):
		return {}
	var cards := _get_table_visual_cards(rect)
	for card_index in range(cards.size() - 1, -1, -1):
		var card_info: Dictionary = cards[card_index]
		var kind := str(card_info.get("kind", ""))
		if kind in ["journal_card", "operator", "trash_card", "blueprint"]:
			continue
		if not _has_meaningful_overlap(journal_rect, Rect2(card_info.get("rect", Rect2())), 0.30):
			continue
		return _build_research_subject_from_card(card_info)
	return {}

func _build_research_subject_from_card(card_info: Dictionary) -> Dictionary:
	var kind := str(card_info.get("kind", ""))
	match kind:
		"location":
			var location_card: Dictionary = card_info.get("card_data", {})
			return {"kind": "location", "type": str(location_card.get("type", "")), "source_kind": "location", "source_identifier": str(location_card.get("id", ""))}
		"enemy":
			return {}
		"material":
			var material_card: Dictionary = card_info.get("card_data", {})
			return {
				"kind": "material",
				"type": str(material_card.get("type", "")),
				"card_id": str(material_card.get("id", "")),
				"source_kind": "material",
				"source_identifier": str(material_card.get("id", "")),
				"requires_quantity": true,
			}
		"equipment":
			var equipment_card: Dictionary = card_info.get("card_data", {})
			return {
				"kind": "equipment",
				"type": str(equipment_card.get("type", "")),
				"card_id": str(equipment_card.get("id", "")),
				"source_kind": "equipment",
				"source_identifier": str(equipment_card.get("id", "")),
			}
		"structure":
			var crafted_card: Dictionary = card_info.get("card_data", {})
			var crafted_id := str(crafted_card.get("id", ""))
			if crafted_id.is_empty() or not GameState.is_enemy_cage_occupied(crafted_id):
				return {}
			var captive_enemy := GameState.get_caged_enemy(crafted_id)
			if captive_enemy.is_empty():
				return {}
			return {
				"kind": "enemy",
				"type": str(captive_enemy.get("type", "")),
				"source_kind": "structure",
				"source_identifier": crafted_id,
			}
		"mechanism":
			var mechanism_card: Dictionary = card_info.get("card_data", {})
			return {
				"kind": "mechanism",
				"type": str(mechanism_card.get("type", "")),
				"source_kind": "mechanism",
				"source_identifier": str(mechanism_card.get("id", "")),
			}
		"bot":
			var slot: Dictionary = card_info.get("slot", {})
			return {"kind": "drone", "type": str(slot.get("drone_type", "spider")), "source_kind": "bot", "source_identifier": int(card_info.get("bot_index", -1))}
		"cartridge":
			return {"kind": "tape", "type": "programmed", "source_kind": "cartridge", "source_identifier": str(card_info.get("cartridge_id", ""))}
		"blank":
			return {"kind": "tape", "type": "blank", "source_kind": "blank", "source_identifier": int(card_info.get("blank_index", -1))}
		"bench_card":
			return {"kind": "machine", "type": "bench", "source_kind": "bench_card", "source_identifier": 0}
		"route_card":
			return {"kind": "machine", "type": "route", "source_kind": "route_card", "source_identifier": 0}
		"charge_card":
			return {"kind": "machine", "type": "charge", "source_kind": "charge_card", "source_identifier": 0}
		"trash_card":
			return {"kind": "machine", "type": "trash", "source_kind": "trash_card", "source_identifier": 0}
		_:
			return {}

func _get_active_blueprint_craft_state(rect: Rect2) -> Dictionary:
	_ensure_table_layout(rect)
	var machine_specs := [
		{"token": "BENCH", "rect": Rect2(_table_machine_position, CARD_SIZE)},
		{"token": "ROUTE TABLE", "rect": Rect2(_table_route_position, CARD_SIZE)},
		{"token": "CHARGE MACHINE", "rect": Rect2(_table_charge_position, CARD_SIZE)},
		{"token": "JOURNAL", "rect": Rect2(_table_journal_position, CARD_SIZE)},
		{"token": "TRASH", "rect": Rect2(_table_trash_position, CARD_SIZE)},
	]
	var visual_cards := _get_table_visual_cards(rect)
	for machine_spec_variant in machine_specs:
		var machine_spec: Dictionary = machine_spec_variant
		var machine_rect := Rect2(machine_spec.get("rect", Rect2()))
		var overlapping_cards: Array = []
		var operator_present := false
		for card_info in visual_cards:
			var kind := str(card_info.get("kind", ""))
			if kind in ["bench_card", "route_card", "charge_card", "journal_card", "trash_card"]:
				continue
			if not _has_meaningful_overlap(machine_rect, Rect2(card_info.get("rect", Rect2())), 0.30):
				continue
			if kind == "operator":
				operator_present = true
			overlapping_cards.append(card_info)
		for card_info in overlapping_cards:
			if str(card_info.get("kind", "")) != "blueprint":
				continue
			var craft_state := _build_blueprint_craft_state(Dictionary(card_info.get("card_data", {})), overlapping_cards, operator_present, str(machine_spec.get("token", "")), machine_rect)
			if not craft_state.is_empty():
				return craft_state
	for blueprint_info in visual_cards:
		if str(blueprint_info.get("kind", "")) != "blueprint":
			continue
		var blueprint_rect := Rect2(blueprint_info.get("rect", Rect2()))
		var overlapping_cards: Array = []
		var operator_present := false
		for card_info in visual_cards:
			if not _has_meaningful_overlap(blueprint_rect, Rect2(card_info.get("rect", Rect2())), 0.30):
				continue
			if str(card_info.get("kind", "")) == "operator":
				operator_present = true
			overlapping_cards.append(card_info)
		var blueprint_craft_state := _build_blueprint_craft_state(Dictionary(blueprint_info.get("card_data", {})), overlapping_cards, operator_present, "", blueprint_rect)
		if not blueprint_craft_state.is_empty():
			return blueprint_craft_state
	return {}

func _get_active_tank_process_state(rect: Rect2) -> Dictionary:
	return {}

func _build_tank_process_candidate(visual_cards: Array, tank_rect: Rect2, crafted_card: Dictionary, process_id: String, spec: Dictionary) -> Dictionary:
	return {}

func _build_blueprint_craft_state(blueprint_card: Dictionary, overlapping_cards: Array, operator_present: bool, machine_token: String, machine_rect: Rect2) -> Dictionary:
	var formula_parts: Array = _get_blueprint_formula_parts(blueprint_card)
	if formula_parts.is_empty():
		return {}
	if str(blueprint_card.get("result", "")).to_upper() == "FRESH TAPE" and not GameState.has_empty_blank_cartridge_slot():
		return {}
	var requires_operator := false
	var required_machine := ""
	var material_requirements := {}
	var required_subject_tokens: Array = []
	for part_variant in formula_parts:
		var part := str(part_variant).strip_edges().to_upper()
		if part == "BLUEPRINT":
			continue
		if part == "OPERATOR":
			requires_operator = true
			continue
		if part in ["BENCH", "ROUTE TABLE", "CHARGE MACHINE", "JOURNAL", "TRASH"]:
			required_machine = part
			continue
		var parsed_requirement := _parse_material_requirement(part)
		if not parsed_requirement.is_empty():
			material_requirements[str(parsed_requirement.get("type", ""))] = int(parsed_requirement.get("quantity", 1))
			continue
		required_subject_tokens.append(part)
	if not required_machine.is_empty() and required_machine != machine_token:
		return {}
	if requires_operator and not operator_present:
		return {}
	for token_variant in required_subject_tokens:
		var token := str(token_variant)
		var token_found := false
		for card_info in overlapping_cards:
			if _card_satisfies_blueprint_token(Dictionary(card_info), token):
				token_found = true
				break
		if not token_found:
			return {}
	var material_cards_by_type := {}
	for card_info in overlapping_cards:
		if str(card_info.get("kind", "")) != "material":
			continue
		var card_data: Dictionary = card_info.get("card_data", {})
		var material_type := str(card_data.get("type", ""))
		if not material_cards_by_type.has(material_type):
			material_cards_by_type[material_type] = []
		var bucket: Array = material_cards_by_type[material_type]
		bucket.append(card_data.duplicate(true))
		material_cards_by_type[material_type] = bucket
	var material_consumptions: Array = []
	for material_type in material_requirements.keys():
		var needed := int(material_requirements[material_type])
		var available_cards: Array = material_cards_by_type.get(material_type, [])
		var collected := 0
		for available_variant in available_cards:
			var available_card: Dictionary = available_variant
			if collected >= needed:
				break
			var card_quantity := maxi(int(available_card.get("quantity", 0)), 0)
			if card_quantity <= 0:
				continue
			var used_quantity := mini(needed - collected, card_quantity)
			material_consumptions.append({
				"card_id": str(available_card.get("id", "")),
				"quantity": used_quantity,
			})
			collected += used_quantity
		if collected < needed:
			return {}
	return {
		"machine_rect": machine_rect,
		"machine_token": machine_token,
		"blueprint_id": str(blueprint_card.get("id", "")),
		"material_consumptions": material_consumptions,
	}

func _get_blueprint_formula_parts(blueprint_card: Dictionary) -> Array:
	var formula_parts: Array = Array(blueprint_card.get("formula_parts", [])).duplicate(true)
	if not formula_parts.is_empty():
		return formula_parts
	var formula := str(blueprint_card.get("formula", ""))
	if formula.is_empty():
		return []
	var rhs := formula
	if formula.contains("="):
		var pieces := formula.split("=", false, 1)
		if pieces.size() == 2:
			rhs = str(pieces[1])
	var parsed_parts: Array = []
	for part in rhs.split("+", false):
		var normalized := str(part).strip_edges()
		if not normalized.is_empty():
			parsed_parts.append(normalized)
	return parsed_parts

func _card_satisfies_blueprint_token(card_info: Dictionary, token: String) -> bool:
	var kind := str(card_info.get("kind", ""))
	match kind:
		"location":
			var location_card: Dictionary = card_info.get("card_data", {})
			return _tokenize_subject_name(str(location_card.get("type", ""))) == token
		"enemy":
			var enemy_card: Dictionary = card_info.get("card_data", {})
			return _tokenize_subject_name(str(enemy_card.get("type", ""))) == token
		"bot":
			var slot: Dictionary = card_info.get("slot", {})
			return _tokenize_subject_name("%s drone" % str(slot.get("drone_type", "spider"))) == token
		"cartridge":
			return token == "PROGRAMMED TAPE"
		"blank":
			return token == "BLANK TAPE"
		_:
			return false

func _tokenize_subject_name(raw_name: String) -> String:
	return raw_name.replace("_", " ").strip_edges().to_upper()

func _parse_material_requirement(part: String) -> Dictionary:
	var normalized := part.strip_edges().to_upper()
	var quantity := 1
	var material_name := normalized
	if normalized.contains(" X"):
		var pieces := normalized.split(" X")
		if pieces.size() == 2:
			material_name = str(pieces[0]).strip_edges()
			quantity = maxi(str(pieces[1]).to_int(), 1)
	var material_map := {
		"METAL": "metal",
		"SPRING": "spring",
		"BIOMASS": "biomass",
		"FIBER": "fiber",
		"HIDE": "hide",
		"BONE": "bone",
		"PAPER": "paper",
		"DRY RATIONS": "dry_rations",
		"MEDICINE": "medicine",
		"GROWTH MEDIUM": "growth_medium",
		"MUSHROOMS": "mushrooms",
		"ALGAE": "algae",
		"BACTERIA": "bacteria",
		"MEALWORMS": "mealworms",
		"BONE MEAL": "bone_meal",
		"POWER UNIT": "power_unit",
	}
	if not material_map.has(material_name):
		return {}
	return {
		"type": str(material_map[material_name]),
		"quantity": quantity,
	}

func _input(event: InputEvent):
	if _operator_selection_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var operator_click: InputEventMouseButton = event
			_handle_operator_selection_click(operator_click.position)
			queue_redraw()
		return
	if _journal_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var modal_click: InputEventMouseButton = event
			_handle_journal_modal_click(modal_click.position)
			queue_redraw()
		return
	if _bot_log_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var log_click: InputEventMouseButton = event
			_handle_bot_log_modal_click(log_click.position)
			queue_redraw()
		return
	if _storage_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var storage_click: InputEventMouseButton = event
			_handle_storage_modal_click(storage_click.position)
			queue_redraw()
		return
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
	_draw_floating_announcements()
	if _operator_selection_open:
		_draw_operator_selection_overlay()
		return
	if _journal_open:
		_draw_journal_overlay()
	if _bot_log_open:
		_draw_bot_log_overlay()
	if _storage_open:
		_draw_storage_overlay()
	if not GameState.is_run_active():
		_draw_run_end_overlay()

func _open_programming_scene():
	var blocker := _get_programming_bench_blocker()
	if not blocker.is_empty():
		EventBus.log_message.emit(blocker)
		return
	get_tree().change_scene_to_file(PROGRAMMING_SCENE_PATH)

func _refresh_labels(_value = null):
	if not GameState.is_run_active():
		_operator_selection_open = true
	queue_redraw()

func _on_log_message(message: String):
	queue_redraw()

func _get_programming_bench_blocker() -> String:
	if not GameState.has_blank_cartridge_available():
		return "No blank cartridge available"
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
	_table_journal_position = _clamp_table_position(
		GameState.get_workshop_card_position("machine_journal", workspace.position + Vector2(536.0, 24.0)) if _table_journal_position == Vector2.ZERO else _table_journal_position,
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

	_sync_drone_card_positions(workspace)
	_sync_programmed_cartridge_positions(workspace)
	_sync_blank_card_positions(workspace)

	for kind in WorkshopCardRuntimeData.STATE_TABLE_CARD_KINDS:
		_sync_state_table_card_positions(kind, workspace)

func _on_map_gui_input(event: InputEvent):
	if _operator_selection_open:
		return
	if _journal_open:
		return
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
		var dog_data := _get_table_dog_data(_rect_in_root(map_region))
		if _has_occupied_equipment_slot_at_point(root_point, drone_data, dog_data):
			if mouse_event.double_click:
				_try_extract_equipment_at_point(root_point, drone_data, dog_data)
			_drag_candidate.clear()
			return
		var badge_hit := WorkshopTableControllerData.get_top_tape_badge_at_point(drone_data, root_point)
		if not badge_hit.is_empty():
			var badge_drag_state := WorkshopTableControllerData.build_badge_drag_state(root_point, badge_hit)
			if not badge_drag_state.is_empty():
				_selected_bot_index = int(badge_hit["index"])
				_drag_start_root = Vector2(badge_drag_state.get("drag_start_root", root_point))
				_drag_pickup_offset = Vector2(badge_drag_state.get("drag_pickup_offset", Vector2(18.0, 24.0)))
				_drag_candidate = badge_drag_state
			return
		var top_card := WorkshopTableControllerData.get_top_table_card_at_point(_get_table_visual_cards(_rect_in_root(map_region)), root_point)
		if not top_card.is_empty():
			var top_kind := str(top_card.get("kind", ""))
			var top_card_data: Dictionary = Dictionary(top_card.get("card_data", {}))
			var top_identifier = null
			match top_kind:
				"enemy":
					top_identifier = str(top_card.get("enemy_id", ""))
				"mechanism":
					top_identifier = str(top_card.get("mechanism_id", ""))
				"structure":
					top_identifier = str(top_card.get("structure_id", ""))
				"material":
					top_identifier = str(top_card.get("material_id", ""))
			var allow_tank_abort := mouse_event.double_click and top_kind == "mechanism" and str(top_card_data.get("type", "")) == "tank"
			if _is_card_locked_by_active_process(top_kind, top_identifier) and not allow_tank_abort:
				_drag_candidate.clear()
				return
			if mouse_event.double_click and top_kind in ["structure", "mechanism"]:
				var crafted_id := str(top_card.get("%s_id" % top_kind, ""))
				if top_kind == "mechanism":
					var tank_unload_result: Dictionary = GameState.abort_tank_process_and_unload_all(crafted_id)
					if bool(tank_unload_result.get("ok", false)):
						var tank_rect := Rect2(top_card.get("rect", Rect2()))
						var unloaded_cards := Array(tank_unload_result.get("cards", []))
						for unloaded_index in range(unloaded_cards.size()):
							if typeof(unloaded_cards[unloaded_index]) != TYPE_DICTIONARY:
								continue
							var withdrawn_card: Dictionary = Dictionary(unloaded_cards[unloaded_index]).duplicate(true)
							var eject_rect := Rect2(tank_rect)
							eject_rect.position += Vector2(14.0 * float(unloaded_index), 10.0 * float(unloaded_index))
							_place_withdrawn_storage_card(withdrawn_card, eject_rect)
						EventBus.log_message.emit(str(tank_unload_result.get("message", "Tank unloaded")))
						return
				if not crafted_id.is_empty() and GameState.is_tool_chest_crafted_card(crafted_id):
					var withdrawn := GameState.withdraw_latest_crafted_storage_item(crafted_id)
					if not withdrawn.is_empty():
						_place_withdrawn_storage_card(withdrawn, Rect2(top_card.get("rect", Rect2())))
						EventBus.log_message.emit("%s withdrawn" % str(withdrawn.get("display_name", withdrawn.get("result", "Stored item"))))
					return
				if not crafted_id.is_empty() and GameState.is_enemy_cage_occupied(crafted_id):
					var release_result: Dictionary = GameState.release_enemy_from_cage(crafted_id)
					if bool(release_result.get("ok", false)):
						var enemy: Dictionary = Dictionary(release_result.get("enemy", {}))
						var enemy_id := str(enemy.get("id", ""))
						if not enemy_id.is_empty():
							_place_generated_enemy_card(enemy_id, Rect2(top_card.get("rect", Rect2())))
					EventBus.log_message.emit(str(release_result.get("message", "Enemy released")))
					return
			var top_drag_state := WorkshopTableControllerData.build_top_card_drag_state(root_point, top_card)
			if not top_drag_state.is_empty():
				match top_kind:
					"cartridge":
						GameState.select_programmed_cartridge(str(top_card.get("cartridge_id", "")))
					"bot":
						_selected_bot_index = int(top_card.get("bot_index", 0))
				_drag_start_root = Vector2(top_drag_state.get("drag_start_root", root_point))
				_drag_pickup_offset = Vector2(top_drag_state.get("drag_pickup_offset", root_point - Rect2(top_card["rect"]).position))
				_drag_candidate = top_drag_state
				return

func _complete_click_candidate(candidate: Dictionary):
	match str(candidate.get("kind", "")):
		"bot":
			_selected_bot_index = int(candidate.get("bot_index", 0))
			_bot_log_bot_index = _selected_bot_index
			_bot_log_page_index = _get_latest_bot_log_page_index(_bot_log_bot_index)
			_bot_log_open = true
		"bench_card":
			_open_programming_scene()
		"journal_card":
			_bot_log_open = false
			_storage_open = false
			_journal_open = true
			_journal_page_index = clampi(_journal_page_index, 0, maxi(_get_journal_display_entries().size() - 1, 0))
			_journal_recipe_page_index = 0
			_journal_viewed_subject_key = _get_current_journal_subject_key()
		"structure":
			var crafted_id := str(candidate.get("structure_id", ""))
			if crafted_id.is_empty() or not GameState.is_archive_shelf_crafted_card(crafted_id):
				return
			_journal_open = false
			_bot_log_open = false
			_storage_open = true
			_storage_container_id = crafted_id
			_storage_page_index = 0

func _complete_drag(drop_root: Vector2):
	match str(_active_drag.get("kind", "")):
		"cartridge":
			_complete_cartridge_drag(drop_root)
		"bot":
			_complete_bot_drag(drop_root)
		"blank":
			_complete_blank_drag(drop_root)
		"location":
			_complete_table_card_drag("location", drop_root, CARD_SIZE)
		"enemy":
			_complete_table_card_drag("enemy", drop_root, CARD_SIZE)
		"material":
			_complete_table_card_drag("material", drop_root, CARD_SIZE)
		"blueprint":
			_complete_table_card_drag("blueprint", drop_root, CARD_SIZE)
		"mechanism":
			_complete_table_card_drag("mechanism", drop_root, CARD_SIZE)
		"structure":
			_complete_table_card_drag("structure", drop_root, CARD_SIZE)
		"dog":
			_complete_table_card_drag("dog", drop_root, CARD_SIZE)
		"equipment":
			_complete_table_card_drag("equipment", drop_root, CARD_SIZE)
		"operator":
			_complete_table_card_drag("operator", drop_root, CARD_SIZE)
		"bench_card":
			_complete_machine_card_drag("bench", drop_root, CARD_SIZE)
		"route_card":
			_complete_machine_card_drag("route", drop_root, CARD_SIZE)
		"charge_card":
			_complete_machine_card_drag("charge", drop_root, CARD_SIZE)
		"journal_card":
			_complete_machine_card_drag("journal", drop_root, CARD_SIZE)
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
	var dog_slots := _get_table_dog_data(_rect_in_root(map_region))
	if _has_occupied_equipment_slot_at_point(root_point, drone_slots, dog_slots):
		return Control.CURSOR_POINTING_HAND
	if not _get_top_tape_badge_at_point(drone_slots, root_point).is_empty():
		return Control.CURSOR_POINTING_HAND
	var top_card := _get_top_table_card_at_point(_rect_in_root(map_region), root_point)
	if not top_card.is_empty():
		return Control.CURSOR_POINTING_HAND

	return Control.CURSOR_ARROW

func _get_operator_card_name() -> String:
	var operator_state := GameState.get_operator_state()
	var display_name := str(operator_state.get("display_name", "")).strip_edges()
	if display_name.is_empty():
		return str(WORKSHOP_OPERATOR["name"])
	return display_name

func _get_operator_card_focus() -> String:
	var operator_state := GameState.get_operator_state()
	var focus := str(operator_state.get("focus", "")).strip_edges()
	if focus.is_empty():
		return str(WORKSHOP_OPERATOR["focus"])
	return focus

func _get_operator_profile_photo(profile_id: String) -> Texture2D:
	match profile_id.strip_edges().to_lower():
		"lera":
			return OPERATOR_LERA_PHOTO
		"mira":
			return OPERATOR_MIRA_PHOTO
		"dren":
			return OPERATOR_DREN_PHOTO
	return OPERATOR_ID_PHOTO

func _get_current_operator_photo() -> Texture2D:
	var operator_state := GameState.get_operator_state()
	return _get_operator_profile_photo(str(operator_state.get("profile_id", "")))

func _build_operator_profile_preview_state(profile: Dictionary) -> Dictionary:
	var state := {
		"energy": GameState.OPERATOR_MAX_ENERGY,
		"max_energy": GameState.OPERATOR_MAX_ENERGY,
		"hp": GameState.OPERATOR_MAX_HP,
		"max_hp": GameState.OPERATOR_MAX_HP,
		"status": "active",
		"equipment_slots": [
			{"slot_index": 0, "item_type": "", "display_name": ""},
			{"slot_index": 1, "item_type": "", "display_name": ""},
			{"slot_index": 2, "item_type": "", "display_name": ""},
		],
	}
	var equipment_type := str(profile.get("starting_equipment", "")).strip_edges()
	if not equipment_type.is_empty():
		var display_name := equipment_type.replace("_", " ").capitalize()
		state["equipment_slots"][0] = {
			"slot_index": 0,
			"item_type": equipment_type,
			"display_name": display_name,
		}
	var totals := {"attack": 0, "armor": 0, "stealth": 0, "utility": 0}
	match equipment_type:
		"knife":
			totals["attack"] = 1
		"bow":
			totals["attack"] = 3
			totals["armor"] = -1
		"plate_mail":
			totals["armor"] = 3
			totals["stealth"] = -1
		"hide_cloak":
			totals["stealth"] = 3
		"tool_kit":
			totals["utility"] = 3
	state["equipment_totals"] = totals
	return state

func _draw_operator_selection_overlay() -> void:
	_operator_selection_click_rects.clear()
	var screen_rect := Rect2(Vector2.ZERO, size)
	draw_rect(screen_rect, Color(0.03, 0.03, 0.04, 0.68))
	var panel_size := Vector2(minf(size.x - 120.0, 1320.0), minf(size.y - 100.0, 760.0))
	var panel_rect := Rect2((size - panel_size) * 0.5, panel_size)
	draw_rect(panel_rect, Color(0.92, 0.87, 0.76))
	draw_rect(panel_rect.grow(-4.0), Color(0.95, 0.91, 0.82))
	draw_rect(panel_rect, PANEL_BORDER, false, 3.0)
	var redeployment := not GameState.is_run_active()
	var title := "ARK REDEPLOYMENT" if redeployment else "ARK DEPLOYMENT"
	var intro_text := "Choose one operator for surface deployment. The selected operator will materialize into a warm starter shelter with the first field package already prepared."
	if redeployment:
		intro_text = "The previous shelter run has ended. Choose the next operator to drop from the Ark and begin again with the starter shelter package."
	_draw_outlined_text(panel_rect.position + Vector2(24.0, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, panel_rect.size.x - 48.0, FONT_SIZE_REGION, STEEL_DARK, Color(0.98, 0.94, 0.86))
	var intro_lines := _wrap_journal_text(intro_text, panel_rect.size.x - 48.0, FONT_SIZE_CARD_VALUE + 2, 3)
	for line_index in range(intro_lines.size()):
		draw_string(ThemeDB.fallback_font, panel_rect.position + Vector2(24.0, 64.0 + float(line_index) * 20.0), intro_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, panel_rect.size.x - 48.0, FONT_SIZE_CARD_VALUE + 2, STEEL_DARK)
	var profiles := GameState.get_start_operator_profiles()
	var card_rect_size := CARD_SIZE * 1.28
	var column_gap := 26.0
	var total_width := float(profiles.size()) * card_rect_size.x + float(maxi(profiles.size() - 1, 0)) * column_gap
	var cards_origin := Vector2(panel_rect.position.x + (panel_rect.size.x - total_width) * 0.5, panel_rect.position.y + 138.0)
	for profile_index in range(profiles.size()):
		var profile: Dictionary = Dictionary(profiles[profile_index])
		var card_rect := Rect2(cards_origin + Vector2(float(profile_index) * (card_rect_size.x + column_gap), 0.0), card_rect_size)
		var preview_state := _build_operator_profile_preview_state(profile)
		WorkshopArtData.draw_operator_card(self, card_rect, preview_state, str(profile.get("name", "OPERATOR")), str(profile.get("focus", "")), _get_operator_profile_photo(str(profile.get("id", ""))))
		var summary_rect := Rect2(Vector2(card_rect.position.x, card_rect.end.y + 12.0), Vector2(card_rect.size.x, 74.0))
		var summary_lines := _wrap_journal_text(str(profile.get("summary", "")), summary_rect.size.x, FONT_SIZE_CARD_VALUE + 1, 4)
		for line_index in range(summary_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(summary_rect.position.x, summary_rect.position.y + 14.0 + float(line_index) * 16.0), summary_lines[line_index], HORIZONTAL_ALIGNMENT_CENTER, summary_rect.size.x, FONT_SIZE_CARD_VALUE + 1, STEEL_DARK)
		var starter_lines := _wrap_journal_text(_build_operator_profile_starter_text(profile), summary_rect.size.x, FONT_SIZE_CARD_META + 3, 4)
		for line_index in range(starter_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(summary_rect.position.x, summary_rect.position.y + 86.0 + float(line_index) * 13.0), starter_lines[line_index], HORIZONTAL_ALIGNMENT_CENTER, summary_rect.size.x, FONT_SIZE_CARD_META + 3, TAPE_SHADE)
		var click_rect := Rect2(card_rect.position, Vector2(card_rect.size.x, 224.0))
		_operator_selection_click_rects.append({"rect": click_rect, "profile_id": str(profile.get("id", ""))})

func _build_operator_profile_starter_text(profile: Dictionary) -> String:
	var extras: Array[String] = []
	var equipment_name := str(profile.get("starting_equipment", "")).strip_edges()
	if not equipment_name.is_empty():
		extras.append("starts with %s" % equipment_name.replace("_", " ").to_upper())
	for extra_variant in Array(profile.get("extra_materials", [])):
		if typeof(extra_variant) != TYPE_DICTIONARY:
			continue
		var extra_material: Dictionary = extra_variant
		var quantity := maxi(int(extra_material.get("quantity", 0)), 0)
		var item_type := str(extra_material.get("type", "")).strip_edges()
		if quantity <= 0 or item_type.is_empty():
			continue
		extras.append("+%d %s" % [quantity, item_type.replace("_", " ").to_upper()])
	return ". ".join(extras)

func _handle_operator_selection_click(root_point: Vector2) -> void:
	for click_info_variant in _operator_selection_click_rects:
		if typeof(click_info_variant) != TYPE_DICTIONARY:
			continue
		var click_info: Dictionary = click_info_variant
		if not Rect2(click_info.get("rect", Rect2())).has_point(root_point):
			continue
		if GameState.start_new_run_with_operator(str(click_info.get("profile_id", ""))):
			_operator_selection_open = false
			_drag_candidate.clear()
			_active_drag.clear()
			_bot_log_open = false
			_storage_open = false
			_journal_open = false
		return

func _is_valid_drop_target(root_point: Vector2) -> bool:
	var drop_rect := _get_drop_rect(root_point)
	return WorkshopTableControllerData.is_valid_drop_target(_active_drag, drop_rect, {
		"has_drop_drone": _get_drop_drone_index_for_rect(drop_rect) != -1,
		"in_tape_hand": _is_rect_in_tape_hand(drop_rect),
		"in_recycle_zone": _is_rect_in_recycle_zone(drop_rect),
		"in_table_workspace": _is_rect_in_table_workspace(drop_rect),
		"in_route_machine": _is_rect_in_route_machine(drop_rect),
		"in_charge_machine": _is_rect_in_charge_machine(drop_rect),
		"overlaps_operator": _has_meaningful_overlap(Rect2(_table_operator_position, CARD_SIZE), drop_rect, 0.30),
	})

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

func _complete_bot_drag(drop_root: Vector2):
	var bot_index := int(_active_drag.get("bot_index", -1))
	var drop_rect := _get_drop_rect(drop_root)
	var target_location := _get_drop_location_target_for_rect(drop_rect)
	if not target_location.is_empty():
		_selected_bot_index = bot_index
		var location_id := str(target_location.get("location_id", ""))
		var location_card: Dictionary = target_location.get("card_data", {})
		var location_title := str(location_card.get("type", "site")).replace("_", " ").to_upper()
		var blocker := GameState.get_bot_launch_blocker(bot_index)
		if blocker.is_empty():
			if GameState.launch_bot_to_location(bot_index, location_id):
				_trigger_location_target_feedback(location_id)
				EventBus.log_message.emit("%s dispatched to %s" % [_bot_display_name(bot_index), location_title])
		else:
			EventBus.log_message.emit("%s" % blocker)
		return
	if _is_rect_in_route_machine(drop_rect):
		_selected_bot_index = bot_index
		if GameState.can_recover_bot(bot_index):
			EventBus.log_message.emit("Place operator on the empty drone card to attempt recovery")
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
	if kind in WorkshopCardRuntimeData.STATE_TABLE_CARD_RECYCLE_MESSAGES and _is_rect_in_recycle_zone(drop_rect):
		var recycled_card_id := str(_active_drag.get("%s_id" % kind, ""))
		if recycled_card_id.is_empty():
			return
		if _forget_state_table_card(kind, recycled_card_id):
			EventBus.log_message.emit(str(WorkshopCardRuntimeData.STATE_TABLE_CARD_RECYCLE_MESSAGES[kind]))
		return
	if kind == "equipment":
		var equipment_id := str(_active_drag.get("equipment_id", ""))
		if equipment_id.is_empty():
			return
		if _has_meaningful_overlap(Rect2(_table_operator_position, CARD_SIZE), drop_rect, 0.30):
			var operator_totals_before := GameState.get_operator_equipment_totals()
			var operator_equip_result: Dictionary = GameState.equip_equipment_on_operator(equipment_id)
			if bool(operator_equip_result.get("ok", false)):
				_table_equipment_positions.erase(equipment_id)
				var equipped_layout_key := GameState.get_state_table_card_layout_key("equipment", equipment_id)
				if not equipped_layout_key.is_empty():
					GameState.clear_workshop_card_position(equipped_layout_key)
				_emit_equipment_total_feedback("operator", 0, operator_totals_before, GameState.get_operator_equipment_totals())
			EventBus.log_message.emit(str(operator_equip_result.get("message", "Equipment handled")))
			return
		for drone_slot in _get_table_drone_data(_rect_in_root(map_region)):
			if not bool(drone_slot.get("available_in_workshop", false)):
				continue
			if not _has_meaningful_overlap(Rect2(drone_slot.get("rect", Rect2())), drop_rect, 0.30):
				continue
			var bot_index := int(drone_slot.get("index", -1))
			var bot_totals_before := GameState.get_bot_equipment_totals(bot_index)
			var bot_equip_result: Dictionary = GameState.equip_equipment_on_bot(equipment_id, int(drone_slot.get("index", -1)))
			if bool(bot_equip_result.get("ok", false)):
				_table_equipment_positions.erase(equipment_id)
				var equipped_bot_layout_key := GameState.get_state_table_card_layout_key("equipment", equipment_id)
				if not equipped_bot_layout_key.is_empty():
					GameState.clear_workshop_card_position(equipped_bot_layout_key)
				_emit_equipment_total_feedback("bot", bot_index, bot_totals_before, GameState.get_bot_equipment_totals(bot_index))
			EventBus.log_message.emit(str(bot_equip_result.get("message", "Equipment handled")))
			return
		for dog_slot_variant in _get_table_dog_data(_rect_in_root(map_region)):
			var dog_slot: Dictionary = dog_slot_variant
			if not _has_meaningful_overlap(Rect2(dog_slot.get("rect", Rect2())), drop_rect, 0.30):
				continue
			var dog_id := str(dog_slot.get("dog_id", ""))
			var dog_totals_before := GameState.get_dog_combat_totals(dog_id)
			var dog_equip_result: Dictionary = GameState.equip_equipment_on_dog(equipment_id, dog_id)
			if bool(dog_equip_result.get("ok", false)):
				_table_equipment_positions.erase(equipment_id)
				var equipped_dog_layout_key := GameState.get_state_table_card_layout_key("equipment", equipment_id)
				if not equipped_dog_layout_key.is_empty():
					GameState.clear_workshop_card_position(equipped_dog_layout_key)
				_emit_equipment_total_feedback("dog", dog_id, dog_totals_before, GameState.get_dog_combat_totals(dog_id))
			EventBus.log_message.emit(str(dog_equip_result.get("message", "Equipment handled")))
			return
	if kind == "enemy":
		var enemy_id := str(_active_drag.get("enemy_id", ""))
		var cage_target := _get_enemy_cage_target(drop_rect, enemy_id)
		if not cage_target.is_empty() and not enemy_id.is_empty():
			if not _enemy_cage_capture_process.is_empty():
				EventBus.log_message.emit("Capture already in progress")
				return
			var cage_id := str(cage_target.get("structure_id", ""))
			var cage_rect := Rect2(cage_target.get("rect", Rect2()))
			_set_state_table_card_position("enemy", enemy_id, cage_rect.position)
			var enemy_card: Dictionary = Dictionary(_active_drag.get("card_data", {})).duplicate(true)
			_start_enemy_cage_capture_process(cage_id, enemy_id, cage_rect, enemy_card)
			return
	if kind == "structure":
		var crafted_id := str(_active_drag.get("structure_id", ""))
		if not crafted_id.is_empty() and GameState.is_enemy_cage_crafted_card(crafted_id) and not GameState.is_enemy_cage_occupied(crafted_id):
			var enemy_target := _get_capture_enemy_target(drop_rect, crafted_id)
			if not enemy_target.is_empty():
				if not _enemy_cage_capture_process.is_empty():
					EventBus.log_message.emit("Capture already in progress")
					return
				var enemy_id := str(enemy_target.get("enemy_id", ""))
				var enemy_rect := Rect2(enemy_target.get("rect", Rect2()))
				_set_state_table_card_position("structure", crafted_id, enemy_rect.position)
				var enemy_card: Dictionary = Dictionary(enemy_target.get("card_data", {})).duplicate(true)
				_start_enemy_cage_capture_process(crafted_id, enemy_id, enemy_rect, enemy_card)
				return
	if kind == "material":
		var material_id := str(_active_drag.get("material_id", ""))
		var material_card: Dictionary = Dictionary(_active_drag.get("card_data", {})).duplicate(true)
		for drone_slot in _get_table_drone_data(_rect_in_root(map_region)):
			if not bool(drone_slot.get("available_in_workshop", false)):
				continue
			if not _has_meaningful_overlap(Rect2(drone_slot.get("rect", Rect2())), drop_rect, 0.30):
				continue
			var bot_index := int(drone_slot.get("index", -1))
			if bot_index == -1:
				continue
			var bot_material_result: Dictionary = GameState.use_material_card_on_bot(material_id, bot_index)
			if bool(bot_material_result.get("ok", false)) and bool(bot_material_result.get("removed", false)):
				_table_material_positions.erase(material_id)
				var bot_material_key := GameState.get_state_table_card_layout_key("material", material_id)
				if not bot_material_key.is_empty():
					GameState.clear_workshop_card_position(bot_material_key)
			if bool(bot_material_result.get("ok", false)):
				_trigger_research_card_feedback("bot", bot_index)
				EventBus.log_message.emit("%s +%d power" % [_bot_display_name(bot_index), int(bot_material_result.get("charged", 0))])
				return
			if str(material_card.get("type", "")) == "power_unit":
				EventBus.log_message.emit(str(bot_material_result.get("message", "Drone charge failed")))
				return
		var tank_target := _get_tank_target(drop_rect)
		if not tank_target.is_empty() and not material_id.is_empty():
			var loaded_tank_id := str(tank_target.get("mechanism_id", ""))
			var tank_load_result := GameState.insert_card_into_tank(loaded_tank_id, "material", material_id)
			if bool(tank_load_result.get("ok", false)):
				_table_material_positions.erase(material_id)
				var tank_material_key := GameState.get_state_table_card_layout_key("material", material_id)
				if not tank_material_key.is_empty():
					GameState.clear_workshop_card_position(tank_material_key)
				EventBus.log_message.emit(str(tank_load_result.get("message", "Tank loaded")))
				return
		if str(material_card.get("type", "")) == "bone":
			var taming_target := _get_wolf_taming_cage_target(drop_rect)
			if not taming_target.is_empty():
				if not _dog_taming_process.is_empty():
					EventBus.log_message.emit("Taming already in progress")
					return
				var taming_cage_id := str(taming_target.get("structure_id", ""))
				var taming_cage_rect := Rect2(taming_target.get("rect", Rect2()))
				_set_state_table_card_position("material", material_id, taming_cage_rect.position)
				_start_dog_taming_process(taming_cage_id, material_id, taming_cage_rect)
				return
	if kind == "blueprint":
		var blueprint_id := str(_active_drag.get("blueprint_id", ""))
		var blueprint_tank_target := _get_tank_target(drop_rect)
		if not blueprint_tank_target.is_empty() and not blueprint_id.is_empty():
			var blueprint_tank_id := str(blueprint_tank_target.get("mechanism_id", ""))
			var blueprint_tank_result := GameState.insert_card_into_tank(blueprint_tank_id, "blueprint", blueprint_id)
			if bool(blueprint_tank_result.get("ok", false)):
				_table_blueprint_positions.erase(blueprint_id)
				var blueprint_tank_key := GameState.get_state_table_card_layout_key("blueprint", blueprint_id)
				if not blueprint_tank_key.is_empty():
					GameState.clear_workshop_card_position(blueprint_tank_key)
				EventBus.log_message.emit(str(blueprint_tank_result.get("message", "Tank loaded")))
				return
	if kind == "structure" and _has_meaningful_overlap(Rect2(_table_operator_position, CARD_SIZE), drop_rect, 0.30):
		var edible_crafted_id := str(_active_drag.get("structure_id", ""))
		if edible_crafted_id.is_empty():
			return
		var use_result: Dictionary = GameState.use_crafted_card_on_operator(edible_crafted_id)
		if bool(use_result.get("ok", false)):
			_table_structure_positions.erase(edible_crafted_id)
		EventBus.log_message.emit(str(use_result.get("message", "Operator supply used")))
		return
	if kind == "structure":
		var dog_supply_crafted_id := str(_active_drag.get("structure_id", ""))
		for dog_slot_variant in _get_table_dog_data(_rect_in_root(map_region)):
			var dog_slot: Dictionary = dog_slot_variant
			if not _has_meaningful_overlap(Rect2(dog_slot.get("rect", Rect2())), drop_rect, 0.30):
				continue
			var dog_id := str(dog_slot.get("dog_id", ""))
			if dog_supply_crafted_id.is_empty() or dog_id.is_empty():
				continue
			var dog_crafted_result: Dictionary = GameState.use_crafted_card_on_dog(dog_supply_crafted_id, dog_id)
			if bool(dog_crafted_result.get("ok", false)):
				_table_structure_positions.erase(dog_supply_crafted_id)
				var dog_crafted_key := GameState.get_state_table_card_layout_key("structure", dog_supply_crafted_id)
				if not dog_crafted_key.is_empty():
					GameState.clear_workshop_card_position(dog_crafted_key)
				EventBus.log_message.emit(str(dog_crafted_result.get("message", "Dog supply used")))
				return
	if kind == "material" and _has_meaningful_overlap(Rect2(_table_operator_position, CARD_SIZE), drop_rect, 0.30):
		var consumable_material_id := str(_active_drag.get("material_id", ""))
		if consumable_material_id.is_empty():
			return
		var material_use_result: Dictionary = GameState.use_material_card_on_operator(consumable_material_id)
		if bool(material_use_result.get("ok", false)) and bool(material_use_result.get("removed", false)):
			_table_material_positions.erase(consumable_material_id)
		if bool(material_use_result.get("ok", false)):
			EventBus.log_message.emit(str(material_use_result.get("message", "Operator supply used")))
			return
	if kind == "material":
		var dog_material_id := str(_active_drag.get("material_id", ""))
		for dog_slot_variant in _get_table_dog_data(_rect_in_root(map_region)):
			var dog_slot: Dictionary = dog_slot_variant
			if not _has_meaningful_overlap(Rect2(dog_slot.get("rect", Rect2())), drop_rect, 0.30):
				continue
			var dog_id := str(dog_slot.get("dog_id", ""))
			if dog_id.is_empty():
				continue
			var dog_use_result: Dictionary = GameState.use_material_card_on_dog(dog_material_id, dog_id)
			if bool(dog_use_result.get("ok", false)) and bool(dog_use_result.get("removed", false)):
				_table_material_positions.erase(dog_material_id)
				var dog_material_key := GameState.get_state_table_card_layout_key("material", dog_material_id)
				if not dog_material_key.is_empty():
					GameState.clear_workshop_card_position(dog_material_key)
			if bool(dog_use_result.get("ok", false)):
				EventBus.log_message.emit(str(dog_use_result.get("message", "Dog supply used")))
				return
	if kind in ["location", "dog", "material", "blueprint", "mechanism", "structure", "equipment"]:
		var storage_target := _get_storage_target(kind, drop_rect)
		if not storage_target.is_empty():
			var storage_id := str(storage_target.get("structure_id", ""))
			var source_card_id := str(_active_drag.get("%s_id" % kind, ""))
			if not storage_id.is_empty() and not source_card_id.is_empty():
				var storage_result := GameState.store_card_in_crafted_storage(storage_id, kind, source_card_id)
				if bool(storage_result.get("ok", false)):
					if kind == "location":
						_table_location_positions.erase(source_card_id)
						var stored_location_key := GameState.get_state_table_card_layout_key("location", source_card_id)
						if not stored_location_key.is_empty():
							GameState.clear_workshop_card_position(stored_location_key)
					elif kind == "dog":
						_table_dog_positions.erase(source_card_id)
						var stored_dog_key := GameState.get_state_table_card_layout_key("dog", source_card_id)
						if not stored_dog_key.is_empty():
							GameState.clear_workshop_card_position(stored_dog_key)
					elif kind == "material":
						_table_material_positions.erase(source_card_id)
						var stored_material_key := GameState.get_state_table_card_layout_key("material", source_card_id)
						if not stored_material_key.is_empty():
							GameState.clear_workshop_card_position(stored_material_key)
					elif kind == "mechanism":
						_table_mechanism_positions.erase(source_card_id)
						var stored_mechanism_key := GameState.get_state_table_card_layout_key("mechanism", source_card_id)
						if not stored_mechanism_key.is_empty():
							GameState.clear_workshop_card_position(stored_mechanism_key)
					elif kind == "structure":
						_table_structure_positions.erase(source_card_id)
						var stored_crafted_key := GameState.get_state_table_card_layout_key("structure", source_card_id)
						if not stored_crafted_key.is_empty():
							GameState.clear_workshop_card_position(stored_crafted_key)
					elif kind == "blueprint":
						_table_blueprint_positions.erase(source_card_id)
						var stored_blueprint_key := GameState.get_state_table_card_layout_key("blueprint", source_card_id)
						if not stored_blueprint_key.is_empty():
							GameState.clear_workshop_card_position(stored_blueprint_key)
					elif kind == "equipment":
						_table_equipment_positions.erase(source_card_id)
						var stored_equipment_key := GameState.get_state_table_card_layout_key("equipment", source_card_id)
						if not stored_equipment_key.is_empty():
							GameState.clear_workshop_card_position(stored_equipment_key)
					EventBus.log_message.emit(str(storage_result.get("message", "Stored")))
					return
	if not _is_rect_in_table_workspace(_get_drop_rect(drop_root)):
		return
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var clamped := _clamp_table_position(drop_root - _drag_pickup_offset, card_size, workspace)
	if kind == "operator":
		_table_operator_position = clamped
		GameState.set_workshop_card_position("operator_card", clamped)
	elif kind in ["location", "enemy", "material", "blueprint", "mechanism", "structure", "dog", "equipment"]:
		var state_card_id := str(_active_drag.get("%s_id" % kind, ""))
		if state_card_id.is_empty():
			return
		if kind == "material":
			var material_card: Dictionary = Dictionary(_active_drag.get("card_data", {})).duplicate(true)
			var live_material_card := _get_material_card_by_id(state_card_id)
			if material_card.is_empty() and not live_material_card.is_empty():
				material_card = live_material_card.duplicate(true)
			var source_material_type := str(material_card.get("type", ""))
			if source_material_type.is_empty():
				source_material_type = str(live_material_card.get("type", ""))
			var added_quantity := maxi(int(material_card.get("quantity", 0)), 0)
			if added_quantity <= 0:
				added_quantity = maxi(int(live_material_card.get("quantity", 0)), 0)
			var merge_target := _get_material_merge_target(state_card_id, source_material_type, Rect2(clamped, card_size))
			if not merge_target.is_empty():
				var target_material_id := str(merge_target.get("material_id", ""))
				var merged := GameState.merge_material_cards(state_card_id, target_material_id)
				if not merged.is_empty():
					_table_material_positions.erase(state_card_id)
					var merged_layout_key := GameState.get_state_table_card_layout_key("material", state_card_id)
					if not merged_layout_key.is_empty():
						GameState.clear_workshop_card_position(merged_layout_key)
					_trigger_merge_feedback("material", target_material_id, added_quantity)
					EventBus.log_message.emit("%s merged to %dx" % [
						str(merged.get("type", "resource")).capitalize(),
						int(merged.get("quantity", 0)),
					])
					return
		_set_state_table_card_position(kind, state_card_id, clamped)
	elif kind == "trash":
		_table_trash_position = clamped
		GameState.set_workshop_card_position("trash_card", clamped)

func _get_capture_enemy_target(drop_rect: Rect2, source_cage_id: String) -> Dictionary:
	if source_cage_id.is_empty():
		return {}
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "enemy":
			continue
		var enemy_id := str(card_info.get("enemy_id", ""))
		if enemy_id.is_empty() or _is_card_locked_by_active_process("enemy", enemy_id):
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

func _get_enemy_cage_target(drop_rect: Rect2, source_enemy_id: String) -> Dictionary:
	if source_enemy_id.is_empty():
		return {}
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "structure":
			continue
		var crafted_id := str(card_info.get("structure_id", ""))
		if crafted_id.is_empty() or not GameState.is_enemy_cage_crafted_card(crafted_id):
			continue
		if GameState.is_enemy_cage_occupied(crafted_id) or _is_card_locked_by_active_process("structure", crafted_id):
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

func _get_storage_target(source_kind: String, drop_rect: Rect2) -> Dictionary:
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "structure":
			continue
		var crafted_id := str(card_info.get("structure_id", ""))
		var source_id := str(_active_drag.get("%s_id" % source_kind, ""))
		if crafted_id.is_empty() or crafted_id == source_id:
			continue
		if not GameState.is_storage_crafted_card(crafted_id):
			continue
		if GameState.is_tool_chest_crafted_card(crafted_id) and source_kind not in ["material", "structure", "blueprint", "equipment"]:
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

func _get_tank_target(drop_rect: Rect2) -> Dictionary:
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "mechanism":
			continue
		var mechanism_id := str(card_info.get("mechanism_id", ""))
		var mechanism_card: Dictionary = Dictionary(card_info.get("card_data", {}))
		if mechanism_id.is_empty() or str(mechanism_card.get("type", "")) != "tank":
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

func _get_material_merge_target(source_material_id: String, source_type: String, drop_rect: Rect2) -> Dictionary:
	if source_material_id.is_empty() or source_type.is_empty():
		return {}
	var table_rect := _rect_in_root(map_region)
	var drop_center := drop_rect.get_center()
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "material":
			continue
		var target_material_id := str(card_info.get("material_id", ""))
		if target_material_id.is_empty() or target_material_id == source_material_id:
			continue
		var target_card: Dictionary = Dictionary(card_info.get("card_data", {}))
		if str(target_card.get("type", "")) != source_type:
			continue
		var target_rect := Rect2(card_info.get("rect", Rect2()))
		if target_rect == Rect2():
			continue
		if target_rect.has_point(drop_center) or _has_meaningful_overlap(target_rect, drop_rect, 0.12) or target_rect.grow(10.0).intersects(drop_rect):
			return card_info
	return {}

func _get_drop_location_target_for_rect(drop_rect: Rect2) -> Dictionary:
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "location":
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

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

func _get_wolf_taming_cage_target(drop_rect: Rect2) -> Dictionary:
	var table_rect := _rect_in_root(map_region)
	for card_info in _get_table_visual_cards(table_rect):
		if str(card_info.get("kind", "")) != "structure":
			continue
		var crafted_id := str(card_info.get("structure_id", ""))
		if crafted_id.is_empty() or not GameState.is_wolf_taming_cage(crafted_id):
			continue
		if _is_card_locked_by_active_process("structure", crafted_id):
			continue
		if _has_meaningful_overlap(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30):
			return card_info
	return {}

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
		_set_non_state_table_card_position("cartridge", key, clamped)
	elif store == _table_blank_positions:
		_set_non_state_table_card_position("blank", key, clamped)
	elif store == _table_drone_positions:
		_set_non_state_table_card_position("bot", key, clamped)
	elif store == _table_location_positions:
		_set_state_table_card_position("location", str(key), clamped)
	elif store == _table_enemy_positions:
		_set_state_table_card_position("enemy", str(key), clamped)
	elif store == _table_material_positions:
		_set_state_table_card_position("material", str(key), clamped)
	elif store == _table_blueprint_positions:
		_set_state_table_card_position("blueprint", str(key), clamped)
	elif store == _table_mechanism_positions:
		_set_state_table_card_position("mechanism", str(key), clamped)
	elif store == _table_structure_positions:
		_set_state_table_card_position("structure", str(key), clamped)

func _place_generated_location_card(location_id: String, route_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		route_rect.position + Vector2(route_rect.size.x + 12.0, 12.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("location", location_id, generated_position)

func _place_generated_enemy_card(enemy_id: String, route_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		route_rect.position + Vector2(route_rect.size.x + 12.0, route_rect.size.y - 28.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("enemy", enemy_id, generated_position)

func _place_generated_material_card(material_id: String, source_rect: Rect2):
	if material_id.is_empty():
		return
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 12.0),
		CARD_SIZE,
		workspace
	)
	var generated_rect := Rect2(generated_position, CARD_SIZE)
	var live_material_card := _get_material_card_by_id(material_id)
	var material_type := str(live_material_card.get("type", ""))
	var generated_quantity := maxi(int(live_material_card.get("quantity", 0)), 0)
	var merge_target := _get_material_merge_target(material_id, material_type, generated_rect)
	if not merge_target.is_empty():
		var target_material_id := str(merge_target.get("material_id", ""))
		var merged := GameState.merge_material_cards(material_id, target_material_id)
		if not merged.is_empty():
			_table_material_positions.erase(material_id)
			var merged_layout_key := GameState.get_state_table_card_layout_key("material", material_id)
			if not merged_layout_key.is_empty():
				GameState.clear_workshop_card_position(merged_layout_key)
			_trigger_merge_feedback("material", target_material_id, generated_quantity)
			return
	_set_state_table_card_position("material", material_id, generated_position)

func _place_generated_blueprint_card(blueprint_id: String, source_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 32.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("blueprint", blueprint_id, generated_position)

func _place_generated_structure_card(crafted_id: String, source_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 18.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("structure", crafted_id, generated_position)

func _place_generated_mechanism_card(mechanism_id: String, source_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 18.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("mechanism", mechanism_id, generated_position)

func _place_generated_equipment_card(equipment_id: String, source_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 18.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("equipment", equipment_id, generated_position)

func _place_generated_dog_card(dog_id: String, source_rect: Rect2):
	var workspace := _get_table_workspace_rect(_rect_in_root(map_region))
	var generated_position := _clamp_table_position(
		source_rect.position + Vector2(source_rect.size.x + 12.0, 18.0),
		CARD_SIZE,
		workspace
	)
	_set_state_table_card_position("dog", dog_id, generated_position)

func _place_withdrawn_storage_card(withdrawn: Dictionary, source_rect: Rect2) -> void:
	var withdrawn_kind := str(withdrawn.get("kind", ""))
	var withdrawn_id := str(withdrawn.get("id", ""))
	match withdrawn_kind:
		"location":
			if not withdrawn_id.is_empty():
				_place_generated_location_card(withdrawn_id, source_rect)
		"material":
			if not withdrawn_id.is_empty():
				_place_generated_material_card(withdrawn_id, source_rect)
		"dog":
			if not withdrawn_id.is_empty():
				_place_generated_dog_card(withdrawn_id, source_rect)
		"mechanism":
			if not withdrawn_id.is_empty():
				_place_generated_mechanism_card(withdrawn_id, source_rect)
		"structure":
			if not withdrawn_id.is_empty():
				_place_generated_structure_card(withdrawn_id, source_rect)
		"blueprint":
			if not withdrawn_id.is_empty():
				_place_generated_blueprint_card(withdrawn_id, source_rect)
		"equipment":
			if not withdrawn_id.is_empty():
				_place_generated_equipment_card(withdrawn_id, source_rect)

func _get_equipment_slot_rects_for_card(card_rect: Rect2) -> Array:
	var face_rect := card_rect.grow(-3.0)
	var art_rect := Rect2(Vector2(face_rect.position.x + 12.0, face_rect.position.y + 18.0), Vector2(face_rect.size.x - 24.0, 86.0))
	var row_rect := Rect2(Vector2(art_rect.position.x + 18.0, art_rect.end.y - 30.0), Vector2(art_rect.size.x - 36.0, 24.0))
	var slot_count: int = 3
	var gap: float = 4.0
	var cell_side: float = floor(minf(row_rect.size.y, (row_rect.size.x - gap * float(slot_count - 1)) / float(slot_count)))
	if cell_side < 8.0:
		return []
	var row_width: float = cell_side * float(slot_count) + gap * float(slot_count - 1)
	var start: Vector2 = Vector2(row_rect.position.x + (row_rect.size.x - row_width) * 0.5, row_rect.position.y + (row_rect.size.y - cell_side) * 0.5)
	var slot_rects: Array = []
	for slot_index in range(slot_count):
		slot_rects.append(Rect2(start + Vector2(float(slot_index) * (cell_side + gap), 0.0), Vector2.ONE * cell_side))
	return slot_rects

func _get_occupied_equipment_slot_hit(root_point: Vector2, slots: Array, slot_rects: Array) -> Dictionary:
	for slot_index in range(mini(slots.size(), slot_rects.size())):
		var slot_rect: Rect2 = slot_rects[slot_index]
		if not slot_rect.has_point(root_point):
			continue
		if typeof(slots[slot_index]) != TYPE_DICTIONARY:
			continue
		var slot_data: Dictionary = slots[slot_index]
		if str(slot_data.get("item_type", "")).is_empty():
			return {}
		return {
			"slot_index": slot_index,
			"slot_rect": slot_rect,
			"slot_data": slot_data,
		}
	return {}

func _get_operator_equipment_slot_hit(root_point: Vector2) -> Dictionary:
	return _get_occupied_equipment_slot_hit(
		root_point,
		Array(GameState.operator_state.get("equipment_slots", [])),
		_get_equipment_slot_rects_for_card(Rect2(_table_operator_position, CARD_SIZE))
	)

func _get_drone_equipment_slot_hit(root_point: Vector2, drone_data: Array) -> Dictionary:
	for drone_slot_variant in drone_data:
		var drone_slot: Dictionary = drone_slot_variant
		if not bool(drone_slot.get("available_in_workshop", false)):
			continue
		var hit := _get_occupied_equipment_slot_hit(
			root_point,
			Array(drone_slot.get("equipment_slots", [])),
			Array(drone_slot.get("equipment_slot_rects", []))
		)
		if hit.is_empty():
			continue
		hit["bot_index"] = int(drone_slot.get("index", -1))
		hit["card_rect"] = Rect2(drone_slot.get("rect", Rect2()))
		return hit
	return {}

func _get_dog_equipment_slot_hit(root_point: Vector2, dog_data: Array) -> Dictionary:
	for dog_slot_variant in dog_data:
		var dog_slot: Dictionary = dog_slot_variant
		var hit := _get_occupied_equipment_slot_hit(
			root_point,
			Array(dog_slot.get("equipment_slots", [])),
			Array(dog_slot.get("equipment_slot_rects", []))
		)
		if hit.is_empty():
			continue
		hit["dog_id"] = str(dog_slot.get("dog_id", ""))
		hit["card_rect"] = Rect2(dog_slot.get("rect", Rect2()))
		return hit
	return {}

func _has_occupied_equipment_slot_at_point(root_point: Vector2, drone_data: Array, dog_data: Array = []) -> bool:
	if not _get_operator_equipment_slot_hit(root_point).is_empty():
		return true
	if not _get_drone_equipment_slot_hit(root_point, drone_data).is_empty():
		return true
	return not _get_dog_equipment_slot_hit(root_point, dog_data).is_empty()

func _try_extract_equipment_at_point(root_point: Vector2, drone_data: Array, dog_data: Array = []) -> bool:
	var operator_hit := _get_operator_equipment_slot_hit(root_point)
	if not operator_hit.is_empty():
		var operator_totals_before := GameState.get_operator_equipment_totals()
		var operator_result: Dictionary = GameState.unequip_equipment_on_operator(int(operator_hit.get("slot_index", -1)))
		if bool(operator_result.get("ok", false)):
			var operator_card := Dictionary(operator_result.get("equipment_card", {}))
			var operator_equipment_id := str(operator_card.get("id", ""))
			if not operator_equipment_id.is_empty():
				_place_generated_equipment_card(operator_equipment_id, Rect2(_table_operator_position, CARD_SIZE))
			_emit_equipment_total_feedback("operator", 0, operator_totals_before, GameState.get_operator_equipment_totals())
		EventBus.log_message.emit(str(operator_result.get("message", "Equipment handled")))
		return true
	var drone_hit := _get_drone_equipment_slot_hit(root_point, drone_data)
	if not drone_hit.is_empty():
		var bot_index := int(drone_hit.get("bot_index", -1))
		var bot_totals_before := GameState.get_bot_equipment_totals(bot_index)
		var drone_result: Dictionary = GameState.unequip_equipment_on_bot(bot_index, int(drone_hit.get("slot_index", -1)))
		if bool(drone_result.get("ok", false)):
			var drone_card := Dictionary(drone_result.get("equipment_card", {}))
			var drone_equipment_id := str(drone_card.get("id", ""))
			if not drone_equipment_id.is_empty():
				_place_generated_equipment_card(drone_equipment_id, Rect2(drone_hit.get("card_rect", Rect2())))
			_emit_equipment_total_feedback("bot", bot_index, bot_totals_before, GameState.get_bot_equipment_totals(bot_index))
		EventBus.log_message.emit(str(drone_result.get("message", "Equipment handled")))
		if bool(drone_result.get("ok", false)):
			return true
	var dog_hit := _get_dog_equipment_slot_hit(root_point, dog_data)
	if dog_hit.is_empty():
		return false
	var dog_id := str(dog_hit.get("dog_id", ""))
	var dog_totals_before := GameState.get_dog_combat_totals(dog_id)
	var dog_result: Dictionary = GameState.unequip_equipment_on_dog(dog_id, int(dog_hit.get("slot_index", -1)))
	if bool(dog_result.get("ok", false)):
		var dog_card := Dictionary(dog_result.get("equipment_card", {}))
		var dog_equipment_id := str(dog_card.get("id", ""))
		if not dog_equipment_id.is_empty():
			_place_generated_equipment_card(dog_equipment_id, Rect2(dog_hit.get("card_rect", Rect2())))
		_emit_equipment_total_feedback("dog", dog_id, dog_totals_before, GameState.get_dog_combat_totals(dog_id))
	EventBus.log_message.emit(str(dog_result.get("message", "Equipment handled")))
	return true

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
	elif kind == "journal":
		_table_journal_position = clamped
		GameState.set_workshop_card_position("machine_journal", clamped)
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
			"journal_card":
				WorkshopArtData.draw_machine_card(self, Rect2(card_info["rect"]), "journal")
			"operator":
				var operator_card_state := GameState.get_operator_state()
				operator_card_state["equipment_totals"] = GameState.get_operator_equipment_totals()
				WorkshopArtData.draw_operator_card(self, Rect2(card_info["rect"]), operator_card_state, _get_operator_card_name(), _get_operator_card_focus(), _get_current_operator_photo())
			"cartridge":
				WorkshopArtData.draw_tape_card(self, Rect2(card_info["rect"]), true, str(card_info.get("label", "")), bool(card_info.get("selected", false)))
			"blank":
				WorkshopArtData.draw_tape_card(self, Rect2(card_info["rect"]), false, "", false)
			"location":
				_draw_location_target_card_pulse(Rect2(card_info["rect"]), str(Dictionary(card_info["card_data"]).get("id", "")))
				WorkshopArtData.draw_location_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]), _location_bunker_texture, _location_cache_texture, _location_pond_texture, _location_crater_texture, _location_tower_texture, _location_surveillance_texture, _location_facility_texture, _location_field_texture, _location_dump_texture, _location_nest_texture, _location_ruin_texture)
			"enemy":
				WorkshopArtData.draw_enemy_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"material":
				WorkshopArtData.draw_material_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"dog":
				var dog_card_state := Dictionary(card_info["card_data"]).duplicate(true)
				var dog_id := str(dog_card_state.get("id", ""))
				dog_card_state["equipment_totals"] = GameState.get_dog_combat_totals(dog_id)
				WorkshopArtData.draw_dog_card(self, Rect2(card_info["rect"]), dog_card_state)
			"equipment":
				WorkshopArtData.draw_equipment_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"blueprint":
				WorkshopArtData.draw_blueprint_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"mechanism":
				WorkshopArtData.draw_mechanism_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"structure":
				WorkshopArtData.draw_structure_card(self, Rect2(card_info["rect"]), Dictionary(card_info["card_data"]))
			"bot":
				_draw_table_drone_card(Dictionary(card_info["slot"]))
			"trash_card":
				WorkshopArtData.draw_trash_card(self, Rect2(card_info["rect"]), _active_drag.is_empty() == false and _is_point_in_recycle_zone(_drag_mouse_root))
	for process_info in _get_active_process_overlays(rect):
		_draw_process_bar(Rect2(process_info["rect"]), float(process_info["progress"]))
	if GameState.has_unread_journal_entries():
		_draw_unread_badge(Rect2(Vector2(_table_journal_position.x + CARD_SIZE.x - 18.0, _table_journal_position.y - 6.0), Vector2(18.0, 18.0)))

func _draw_drag_overlay():
	if _active_drag.is_empty():
		return
	var drag_kind := str(_active_drag.get("kind", ""))
	var tape_data := _get_tape_hand_data(_rect_in_root(map_region))
	var tape_rect: Rect2 = tape_data["hand_zone"]
	var drone_slots := _get_table_drone_data(_rect_in_root(map_region))
	var dog_slots := _get_table_dog_data(_rect_in_root(map_region))
	if drag_kind == "cartridge":
		var drag_rect := _get_drop_rect(_drag_mouse_root)
		if _is_rect_in_tape_hand(drag_rect) and str(_active_drag.get("source", "")) == "bot":
			draw_rect(tape_rect.grow(4.0), Color(0.80, 0.66, 0.27, 0.10))
		if _is_rect_in_recycle_zone(drag_rect):
			draw_rect(Rect2(tape_data["recycle_hotspot"]).grow(3.0), Color(0.66, 0.28, 0.18, 0.20))
		for slot in drone_slots:
			if Rect2(slot["rect"]).intersects(drag_rect) and bool(slot["available_in_workshop"]):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "bot":
		var drag_rect := _get_drop_rect(_drag_mouse_root)
		if _is_rect_in_route_machine(drag_rect):
			draw_rect(Rect2(_get_machine_card_data(_rect_in_root(map_region))["route_rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		if _is_rect_in_charge_machine(drag_rect):
			draw_rect(Rect2(_get_machine_card_data(_rect_in_root(map_region))["charge_rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "equipment":
		var drag_rect := _get_drop_rect(_drag_mouse_root)
		if _has_meaningful_overlap(Rect2(_table_operator_position, CARD_SIZE), drag_rect, 0.18):
			draw_rect(Rect2(_table_operator_position, CARD_SIZE).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		for slot in drone_slots:
			if not bool(slot.get("available_in_workshop", false)):
				continue
			if Rect2(slot["rect"]).intersects(drag_rect):
				draw_rect(Rect2(slot["rect"]).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		for dog_slot_variant in dog_slots:
			var dog_slot: Dictionary = dog_slot_variant
			if Rect2(dog_slot.get("rect", Rect2())).intersects(drag_rect):
				draw_rect(Rect2(dog_slot.get("rect", Rect2())).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "material":
		var material_drag_rect := _get_drop_rect(_drag_mouse_root)
		var drag_material: Dictionary = Dictionary(_active_drag.get("card_data", {}))
		var tank_target := _get_tank_target(material_drag_rect)
		if not tank_target.is_empty():
			draw_rect(Rect2(tank_target.get("rect", Rect2())).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		if str(drag_material.get("type", "")) == "bone":
			var taming_target := _get_wolf_taming_cage_target(material_drag_rect)
			if not taming_target.is_empty():
				draw_rect(Rect2(taming_target.get("rect", Rect2())).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
		for dog_slot_variant in dog_slots:
			var dog_slot: Dictionary = dog_slot_variant
			if Rect2(dog_slot.get("rect", Rect2())).intersects(material_drag_rect):
				draw_rect(Rect2(dog_slot.get("rect", Rect2())).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))
	elif drag_kind == "blueprint":
		var blueprint_drag_rect := _get_drop_rect(_drag_mouse_root)
		var blueprint_tank_target := _get_tank_target(blueprint_drag_rect)
		if not blueprint_tank_target.is_empty():
			draw_rect(Rect2(blueprint_tank_target.get("rect", Rect2())).grow(6.0), Color(0.80, 0.66, 0.27, 0.12))

	var preview_rect := Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE)
	if drag_kind == "cartridge":
		var preview_label := ""
		var cartridge_id := str(_active_drag.get("cartridge_id", ""))
		if not cartridge_id.is_empty():
			var cartridge := GameState.get_programmed_cartridge_by_id(cartridge_id)
			preview_label = str(cartridge.get("label", ""))
		WorkshopArtData.draw_tape_card(self, preview_rect, true, preview_label, false)
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
	elif drag_kind == "material":
		WorkshopArtData.draw_material_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "dog":
		var dog_preview_state := Dictionary(_active_drag.get("card_data", {})).duplicate(true)
		var dog_preview_id := str(dog_preview_state.get("id", ""))
		dog_preview_state["equipment_totals"] = GameState.get_dog_combat_totals(dog_preview_id)
		WorkshopArtData.draw_dog_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), dog_preview_state)
	elif drag_kind == "equipment":
		WorkshopArtData.draw_equipment_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "blueprint":
		WorkshopArtData.draw_blueprint_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "mechanism":
		WorkshopArtData.draw_mechanism_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "structure":
		WorkshopArtData.draw_structure_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), Dictionary(_active_drag.get("card_data", {})))
	elif drag_kind == "operator":
		var operator_drag_state := GameState.get_operator_state()
		operator_drag_state["equipment_totals"] = GameState.get_operator_equipment_totals()
		WorkshopArtData.draw_operator_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), operator_drag_state, _get_operator_card_name(), _get_operator_card_focus(), _get_current_operator_photo())
	elif drag_kind == "trash_card":
		WorkshopArtData.draw_trash_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), false)
	elif drag_kind == "bench_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "bench")
	elif drag_kind == "route_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "route", Callable(self, "_draw_route_card_overlay"))
	elif drag_kind == "charge_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "charge")
	elif drag_kind == "journal_card":
		WorkshopArtData.draw_machine_card(self, Rect2(_drag_mouse_root - _drag_pickup_offset, CARD_SIZE), "journal")

func _get_active_process_overlays(rect: Rect2) -> Array:
	var overlays: Array = []
	for process_state in _get_active_process_states(rect):
		overlays.append(WorkshopCardRuntimeData.build_process_overlay(
			Rect2(process_state.get("rect", Rect2())),
			float(process_state.get("cooldown", 0.0)),
			float(process_state.get("duration", 0.001))
		))
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

func _get_active_process_states(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var states: Array = []
	if _is_charge_machine_operating() and _get_charge_machine_target_bot_index(rect) != -1 and GameState.has_charged_power_unit_available():
		states.append({
			"rect": Rect2(_table_charge_position, CARD_SIZE),
			"cooldown": _charge_production_cooldown,
			"duration": CHARGE_PRODUCTION_INTERVAL,
		})
	if _is_route_scan_operating() and GameState.can_operator_scan_route():
		states.append({
			"rect": Rect2(_table_route_position, CARD_SIZE),
			"cooldown": _route_scan_cooldown,
			"duration": ROUTE_SCAN_INTERVAL,
		})
	if _is_journal_research_operating():
		states.append({
			"rect": Rect2(_table_journal_position, CARD_SIZE),
			"cooldown": _journal_research_cooldown,
			"duration": JOURNAL_RESEARCH_INTERVAL,
		})
	if not _bot_recovery_process.is_empty():
		states.append({
			"rect": Rect2(_bot_recovery_process.get("rect", Rect2())),
			"cooldown": float(_bot_recovery_process.get("cooldown", 0.0)),
			"duration": float(_bot_recovery_process.get("duration", BOT_RECOVERY_BASE_INTERVAL)),
		})
	if not _enemy_cage_capture_process.is_empty():
		states.append({
			"rect": Rect2(_enemy_cage_capture_process.get("rect", Rect2())),
			"cooldown": float(_enemy_cage_capture_process.get("cooldown", 0.0)),
			"duration": float(_enemy_cage_capture_process.get("duration", ENEMY_CAGE_CAPTURE_BASE_INTERVAL)),
		})
	if not _dog_taming_process.is_empty():
		states.append({
			"rect": Rect2(_dog_taming_process.get("rect", Rect2())),
			"cooldown": float(_dog_taming_process.get("cooldown", 0.0)),
			"duration": float(_dog_taming_process.get("duration", DOG_TAMING_BASE_INTERVAL)),
		})
	for tank_batch_variant in GameState.get_active_tank_batches():
		if typeof(tank_batch_variant) != TYPE_DICTIONARY:
			continue
		var tank_batch: Dictionary = tank_batch_variant
		var tank_id := str(tank_batch.get("tank_id", ""))
		if tank_id.is_empty():
			continue
		var tank_rect := Rect2(Vector2(_table_mechanism_positions.get(tank_id, rect.position)), CARD_SIZE)
		states.append({
			"rect": tank_rect,
			"cooldown": float(tank_batch.get("remaining", 0.0)),
			"duration": float(tank_batch.get("duration", 0.001)),
		})
	var craft_state := _get_active_blueprint_craft_state(rect)
	if not craft_state.is_empty():
		states.append({
			"rect": Rect2(craft_state.get("machine_rect", Rect2())),
			"cooldown": _blueprint_craft_cooldown,
			"duration": BLUEPRINT_CRAFT_INTERVAL,
		})
	for fight_info in _get_enemy_fight_states(rect):
		var enemy_id := str(fight_info.get("enemy_id", ""))
		if enemy_id.is_empty():
			continue
		states.append({
			"rect": Rect2(fight_info.get("rect", Rect2())),
			"cooldown": float(_enemy_fight_cooldowns.get(enemy_id, ENEMY_FIGHT_INTERVAL)),
			"duration": ENEMY_FIGHT_INTERVAL,
		})
	return states

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
		_draw_outlined_text(position + Vector2(0.0, 1.0), str(entry.get("value", "")), HORIZONTAL_ALIGNMENT_CENTER, float(entry.get("width", 32.0)), font_size, color, outline)

func _draw_floating_announcements():
	for entry in _floating_announcements:
		var timer := float(entry.get("timer", DISCOVERY_BANNER_DURATION))
		var duration := maxf(float(entry.get("duration", DISCOVERY_BANNER_DURATION)), 0.001)
		var progress := 1.0 - timer / duration
		var position := Vector2(entry.get("position", Vector2.ZERO)) + Vector2(0.0, -18.0 * progress)
		var color := Color(0.90, 0.24, 0.20, clampf(1.0 - progress * 0.9, 0.0, 1.0))
		var outline := Color(0.12, 0.05, 0.05, color.a)
		_draw_outlined_text(position, str(entry.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, 220.0, FONT_SIZE_BANNER + 2, color, outline)
		var subtext := str(entry.get("subtext", ""))
		if not subtext.is_empty():
			_draw_outlined_text(position + Vector2(0.0, 16.0), subtext, HORIZONTAL_ALIGNMENT_CENTER, 220.0, FONT_SIZE_CARD_VALUE + 1, Color(0.95, 0.90, 0.81, color.a), outline)

func _draw_unread_badge(rect: Rect2) -> void:
	var wobble := sin(Time.get_ticks_msec() * 0.012) * 1.5
	var badge_rect := Rect2(rect.position + Vector2(wobble, 0.0), rect.size)
	draw_rect(badge_rect, Color(0.65, 0.14, 0.12))
	draw_rect(badge_rect.grow(-1.0), Color(0.83, 0.22, 0.18))
	draw_rect(badge_rect, Color(0.18, 0.08, 0.07), false, 1.0)
	_draw_outlined_text(badge_rect.position + Vector2(0.0, badge_rect.size.y - 4.0), "!", HORIZONTAL_ALIGNMENT_CENTER, badge_rect.size.x, FONT_SIZE_BANNER + 1, TEXT, Color(0.18, 0.08, 0.07))

func _commit_current_journal_page_read() -> void:
	if _journal_viewed_subject_key.is_empty():
		return
	GameState.mark_journal_entry_read(_journal_viewed_subject_key)
	_journal_viewed_subject_key = ""

func _get_current_journal_subject_key() -> String:
	var entries := _get_journal_display_entries()
	if entries.is_empty():
		return ""
	var page_index := clampi(_journal_page_index, 0, entries.size() - 1)
	return str(Dictionary(entries[page_index]).get("subject_key", ""))

func _get_journal_display_entries() -> Array:
	var entries := GameState.get_journal_display_entries()
	var index_entry := _build_journal_index_entry(entries)
	var display_entries: Array = [index_entry]
	display_entries.append_array(entries)
	return display_entries

func _build_journal_index_entry(entries: Array) -> Dictionary:
	var categories := _build_journal_index_categories(entries)
	return {
		"subject_key": "__index__",
		"subject_kind": "index",
		"subject_type": "index",
		"title": "INDEX",
		"description": "Use the index to jump between knowledge families. Locked entries still appear inside each family, so the journal shows both what is known and what remains unknown.",
		"locked": false,
		"unread": false,
		"attempts": 0,
		"recipes": [],
		"recipe_ids": [],
		"categories": categories,
	}

func _find_journal_page_index_by_subject_key(subject_key: String) -> int:
	if subject_key.is_empty():
		return -1
	var entries := _get_journal_display_entries()
	for entry_index in range(entries.size()):
		var entry: Dictionary = Dictionary(entries[entry_index])
		if str(entry.get("subject_key", "")) == subject_key:
			return entry_index
	return -1

func _build_journal_index_categories(entries: Array) -> Array:
	var specs := [
		{"kind": "location", "label": "LOCATIONS"},
		{"kind": "material", "label": "MATERIALS"},
		{"kind": "equipment", "label": "EQUIPMENT"},
		{"kind": "mechanism", "label": "MECHANISMS"},
		{"kind": "structure", "label": "STRUCTURES"},
		{"kind": "drone", "label": "DRONES"},
		{"kind": "enemy", "label": "ENEMIES"},
		{"kind": "machine", "label": "MACHINES"},
		{"kind": "tape", "label": "MEDIA"},
	]
	var categories: Array = []
	for spec_variant in specs:
		var spec: Dictionary = spec_variant
		var kind := str(spec.get("kind", ""))
		var total := 0
		var discovered := 0
		var unread := false
		var first_page_index := -1
		for entry_index in range(entries.size()):
			var entry: Dictionary = Dictionary(entries[entry_index])
			if str(entry.get("subject_kind", "")) != kind:
				continue
			total += 1
			if not bool(entry.get("locked", true)):
				discovered += 1
			if bool(entry.get("unread", false)):
				unread = true
			if first_page_index == -1:
				first_page_index = entry_index + 1
		if total <= 0:
			continue
		categories.append({
			"kind": kind,
			"label": str(spec.get("label", kind.to_upper())),
			"total": total,
			"discovered": discovered,
			"unread": unread,
			"page_index": first_page_index,
		})
	return categories

func _draw_run_end_overlay():
	var overlay_rect := Rect2(Vector2.ZERO, size)
	draw_rect(overlay_rect, Color(0.0, 0.0, 0.0, 0.28))
	var plaque_rect := Rect2(Vector2(size.x * 0.5 - 120.0, 36.0), Vector2(240.0, 30.0))
	draw_rect(plaque_rect, Color(0.28, 0.10, 0.10))
	draw_rect(plaque_rect.grow(-2.0), Color(0.18, 0.08, 0.08))
	draw_rect(plaque_rect, PANEL_BORDER, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(plaque_rect.position.x, plaque_rect.position.y + 20.0), "RUN ENDED", HORIZONTAL_ALIGNMENT_CENTER, plaque_rect.size.x, FONT_SIZE_BANNER, TEXT)

func _get_journal_overlay_rect() -> Rect2:
	return Rect2(Vector2(size.x * 0.5 - 320.0, size.y * 0.5 - 220.0), Vector2(640.0, 440.0))

func _get_bot_log_overlay_rect() -> Rect2:
	return Rect2(Vector2(size.x * 0.5 - 320.0, size.y * 0.5 - 220.0), Vector2(640.0, 440.0))

func _get_storage_overlay_rect() -> Rect2:
	return Rect2(Vector2(size.x * 0.5 - 320.0, size.y * 0.5 - 220.0), Vector2(640.0, 440.0))

func _get_latest_bot_log_page_index(bot_index: int) -> int:
	var entries := GameState.get_bot_activity_log(bot_index)
	if entries.is_empty():
		return 0
	return maxi(int(ceili(float(entries.size()) / float(BOT_LOG_PAGE_SIZE))) - 1, 0)

func _handle_journal_modal_click(root_point: Vector2):
	var overlay_rect := _get_journal_overlay_rect()
	if _journal_close_rect.has_point(root_point) or not overlay_rect.has_point(root_point):
		_commit_current_journal_page_read()
		_journal_open = false
		_journal_recipe_page_index = 0
		_journal_recipe_click_rects.clear()
		_journal_related_click_rects.clear()
		return
	if _journal_prev_rect.has_point(root_point):
		_commit_current_journal_page_read()
		_journal_page_index = maxi(_journal_page_index - 1, 0)
		_journal_recipe_page_index = 0
		_journal_viewed_subject_key = _get_current_journal_subject_key()
		return
	if _journal_next_rect.has_point(root_point):
		_commit_current_journal_page_read()
		_journal_page_index = mini(_journal_page_index + 1, maxi(_get_journal_display_entries().size() - 1, 0))
		_journal_recipe_page_index = 0
		_journal_viewed_subject_key = _get_current_journal_subject_key()
		return
	for click_info_variant in _journal_index_click_rects:
		if typeof(click_info_variant) != TYPE_DICTIONARY:
			continue
		var click_info: Dictionary = click_info_variant
		if not Rect2(click_info.get("rect", Rect2())).has_point(root_point):
			continue
		_commit_current_journal_page_read()
		_journal_page_index = int(click_info.get("page_index", 0))
		_journal_recipe_page_index = 0
		_journal_viewed_subject_key = _get_current_journal_subject_key()
		return
	if _journal_recipe_prev_rect.has_point(root_point):
		_journal_recipe_page_index = maxi(_journal_recipe_page_index - 1, 0)
		return
	if _journal_recipe_next_rect.has_point(root_point):
		var entry := Dictionary(_get_journal_display_entries()[clampi(_journal_page_index, 0, maxi(_get_journal_display_entries().size() - 1, 0))])
		var recipes: Array = Array(entry.get("recipes", []))
		var page_count := maxi(int(ceili(float(recipes.size()) / 2.0)), 1)
		_journal_recipe_page_index = mini(_journal_recipe_page_index + 1, page_count - 1)
		return
	for click_info in _journal_recipe_click_rects:
		var recipe_rect := Rect2(click_info.get("rect", Rect2()))
		if not recipe_rect.has_point(root_point):
			continue
		var recipe: Dictionary = Dictionary(click_info.get("recipe", {}))
		if not bool(recipe.get("copyable", false)):
			return
		var blueprint := GameState.create_blueprint_card(recipe)
		var blueprint_id := str(blueprint.get("id", ""))
		if not blueprint_id.is_empty():
			_place_generated_blueprint_card(blueprint_id, Rect2(_table_journal_position, CARD_SIZE))
			EventBus.log_message.emit("%s copied as blueprint" % str(blueprint.get("result", "Blueprint")))
		return
	for click_info_variant in _journal_related_click_rects:
		if typeof(click_info_variant) != TYPE_DICTIONARY:
			continue
		var click_info: Dictionary = click_info_variant
		if not Rect2(click_info.get("rect", Rect2())).has_point(root_point):
			continue
		var subject_key := str(click_info.get("subject_key", ""))
		var target_page_index := _find_journal_page_index_by_subject_key(subject_key)
		if target_page_index == -1:
			return
		_commit_current_journal_page_read()
		_journal_page_index = target_page_index
		_journal_recipe_page_index = 0
		_journal_viewed_subject_key = _get_current_journal_subject_key()
		return

func _handle_bot_log_modal_click(root_point: Vector2):
	var overlay_rect := _get_bot_log_overlay_rect()
	if _bot_log_close_rect.has_point(root_point) or not overlay_rect.has_point(root_point):
		_bot_log_open = false
		return
	if _bot_log_prev_rect.has_point(root_point):
		_bot_log_page_index = maxi(_bot_log_page_index - 1, 0)
		return
	if _bot_log_next_rect.has_point(root_point):
		_bot_log_page_index = mini(_bot_log_page_index + 1, _get_latest_bot_log_page_index(_bot_log_bot_index))
		return

func _handle_storage_modal_click(root_point: Vector2):
	var overlay_rect := _get_storage_overlay_rect()
	if _storage_close_rect.has_point(root_point) or not overlay_rect.has_point(root_point):
		_storage_open = false
		_storage_item_click_rects.clear()
		return
	if _storage_prev_rect.has_point(root_point):
		_storage_page_index = maxi(_storage_page_index - 1, 0)
		return
	if _storage_next_rect.has_point(root_point):
		var stored_entries := GameState.get_crafted_storage_contents(_storage_container_id)
		var page_count := maxi(int(ceili(float(stored_entries.size()) / float(STORAGE_PAGE_SIZE))), 1)
		_storage_page_index = mini(_storage_page_index + 1, page_count - 1)
		return
	for click_info in _storage_item_click_rects:
		var item_rect := Rect2(click_info.get("rect", Rect2()))
		if not item_rect.has_point(root_point):
			continue
		var withdrawn := GameState.withdraw_crafted_storage_item(_storage_container_id, str(click_info.get("entry_id", "")))
		if withdrawn.is_empty():
			return
		var container_rect := Rect2(Vector2(_table_structure_positions.get(_storage_container_id, Vector2(size.x * 0.5 - CARD_SIZE.x * 0.5, size.y * 0.5 - CARD_SIZE.y * 0.5))), CARD_SIZE)
		_place_withdrawn_storage_card(withdrawn, container_rect)
		EventBus.log_message.emit("%s withdrawn" % str(withdrawn.get("display_name", withdrawn.get("result", "Stored item"))))
		return

func _draw_journal_overlay():
	_journal_recipe_click_rects.clear()
	_journal_index_click_rects.clear()
	_journal_related_click_rects.clear()
	_journal_recipe_prev_rect = Rect2()
	_journal_recipe_next_rect = Rect2()
	_journal_prev_rect = Rect2()
	_journal_next_rect = Rect2()
	_journal_close_rect = Rect2()
	var overlay_rect := Rect2(Vector2.ZERO, size)
	var page_rect := _get_journal_overlay_rect()
	draw_rect(overlay_rect, Color(0.02, 0.02, 0.03, 0.42))
	draw_rect(page_rect, TAPE)
	draw_rect(page_rect.grow(-6.0), Color(0.90, 0.84, 0.71))
	draw_rect(page_rect, PANEL_BORDER, false, 2.0)
	var spine_x := page_rect.position.x + page_rect.size.x * 0.5
	draw_line(Vector2(spine_x, page_rect.position.y + 18.0), Vector2(spine_x, page_rect.end.y - 18.0), Color(0.67, 0.57, 0.35), 2.0)
	_journal_close_rect = Rect2(Vector2(page_rect.end.x - 34.0, page_rect.position.y + 12.0), Vector2(20.0, 20.0))
	draw_rect(_journal_close_rect, Color(0.42, 0.18, 0.16))
	draw_rect(_journal_close_rect.grow(-1.0), Color(0.31, 0.14, 0.13))
	_draw_outlined_text(_journal_close_rect.position + Vector2(0.0, 15.0), "X", HORIZONTAL_ALIGNMENT_CENTER, _journal_close_rect.size.x, FONT_SIZE_BANNER, TEXT, Color(0.12, 0.08, 0.06))
	var entries := _get_journal_display_entries()
	if entries.is_empty():
		_draw_outlined_text(Vector2(page_rect.position.x + 32.0, page_rect.position.y + 42.0), "JOURNAL", HORIZONTAL_ALIGNMENT_LEFT, 180.0, FONT_SIZE_BANNER, STEEL_DARK, Color(0.95, 0.92, 0.84))
		var empty_lines := _wrap_journal_text("No research notes yet. Place the operator and another card on the journal to start a research attempt.", page_rect.size.x - 64.0, FONT_SIZE_VALUE, 4)
		for line_index in range(empty_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x + 32.0, page_rect.position.y + 94.0 + float(line_index) * 18.0), empty_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, page_rect.size.x - 64.0, FONT_SIZE_VALUE, STEEL_DARK)
		return
	_journal_page_index = clampi(_journal_page_index, 0, entries.size() - 1)
	var entry: Dictionary = entries[_journal_page_index]
	var entry_locked := bool(entry.get("locked", false))
	var left_page := Rect2(page_rect.position + Vector2(20.0, 26.0), Vector2(page_rect.size.x * 0.5 - 32.0, page_rect.size.y - 52.0))
	var right_page := Rect2(Vector2(spine_x + 12.0, page_rect.position.y + 26.0), Vector2(page_rect.size.x * 0.5 - 32.0, page_rect.size.y - 52.0))
	if str(entry.get("subject_kind", "")) == "index":
		_draw_journal_index_page(page_rect, left_page, right_page, entry)
		if _journal_page_index > 0:
			_journal_prev_rect = Rect2(Vector2(page_rect.position.x + 16.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
			draw_rect(_journal_prev_rect, Color(0.79, 0.72, 0.56))
			draw_rect(_journal_prev_rect, PANEL_BORDER, false, 1.0)
			draw_string(ThemeDB.fallback_font, Vector2(_journal_prev_rect.position.x, _journal_prev_rect.position.y + 14.0), "<", HORIZONTAL_ALIGNMENT_CENTER, _journal_prev_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
		if _journal_page_index < entries.size() - 1:
			_journal_next_rect = Rect2(Vector2(page_rect.end.x - 56.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
			draw_rect(_journal_next_rect, Color(0.79, 0.72, 0.56))
			draw_rect(_journal_next_rect, PANEL_BORDER, false, 1.0)
			draw_string(ThemeDB.fallback_font, Vector2(_journal_next_rect.position.x, _journal_next_rect.position.y + 14.0), ">", HORIZONTAL_ALIGNMENT_CENTER, _journal_next_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
		draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x, page_rect.end.y - 18.0), "PAGE %d / %d" % [_journal_page_index + 1, entries.size()], HORIZONTAL_ALIGNMENT_CENTER, page_rect.size.x, FONT_SIZE_CARD_META + 2, STEEL_DARK)
		return
	_draw_outlined_text(Vector2(left_page.position.x, left_page.position.y + 4.0), str(entry.get("title", "ENTRY")), HORIZONTAL_ALIGNMENT_LEFT, left_page.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	if bool(entry.get("unread", false)) and not entry_locked:
		_draw_unread_badge(Rect2(Vector2(left_page.end.x - 24.0, left_page.position.y - 4.0), Vector2(18.0, 18.0)))
	_draw_outlined_text(Vector2(right_page.position.x, right_page.position.y + 4.0), "LOCKED NOTES" if entry_locked else "RECIPES", HORIZONTAL_ALIGNMENT_LEFT, right_page.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	var preview_rect := Rect2(left_page.position + Vector2(8.0, 28.0), Vector2(132.0, 164.0))
	if entry_locked:
		_draw_locked_journal_entry_preview(preview_rect, entry)
	else:
		_draw_journal_entry_preview(preview_rect, entry)
	_draw_journal_entry_sections(left_page, preview_rect, entry)
	_draw_journal_recipe_panel(page_rect, right_page, entry)
	if _journal_page_index > 0:
		_journal_prev_rect = Rect2(Vector2(page_rect.position.x + 16.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_journal_prev_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_journal_prev_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_journal_prev_rect.position.x, _journal_prev_rect.position.y + 14.0), "<", HORIZONTAL_ALIGNMENT_CENTER, _journal_prev_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	if _journal_page_index < entries.size() - 1:
		_journal_next_rect = Rect2(Vector2(page_rect.end.x - 56.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_journal_next_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_journal_next_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_journal_next_rect.position.x, _journal_next_rect.position.y + 14.0), ">", HORIZONTAL_ALIGNMENT_CENTER, _journal_next_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x, page_rect.end.y - 18.0), "PAGE %d / %d" % [_journal_page_index + 1, entries.size()], HORIZONTAL_ALIGNMENT_CENTER, page_rect.size.x, FONT_SIZE_CARD_META + 2, STEEL_DARK)

func _draw_bot_log_overlay():
	_bot_log_prev_rect = Rect2()
	_bot_log_next_rect = Rect2()
	_bot_log_close_rect = Rect2()
	var overlay_rect := Rect2(Vector2.ZERO, size)
	var page_rect := _get_bot_log_overlay_rect()
	draw_rect(overlay_rect, Color(0.02, 0.02, 0.03, 0.42))
	draw_rect(page_rect, TAPE)
	draw_rect(page_rect.grow(-6.0), Color(0.90, 0.84, 0.71))
	draw_rect(page_rect, PANEL_BORDER, false, 2.0)
	_bot_log_close_rect = Rect2(Vector2(page_rect.end.x - 34.0, page_rect.position.y + 12.0), Vector2(20.0, 20.0))
	draw_rect(_bot_log_close_rect, Color(0.42, 0.18, 0.16))
	draw_rect(_bot_log_close_rect.grow(-1.0), Color(0.31, 0.14, 0.13))
	_draw_outlined_text(_bot_log_close_rect.position + Vector2(0.0, 15.0), "X", HORIZONTAL_ALIGNMENT_CENTER, _bot_log_close_rect.size.x, FONT_SIZE_BANNER, TEXT, Color(0.12, 0.08, 0.06))
	var bot_name := _bot_display_name(_bot_log_bot_index).to_upper()
	_draw_outlined_text(Vector2(page_rect.position.x + 28.0, page_rect.position.y + 34.0), "%s LOG" % bot_name, HORIZONTAL_ALIGNMENT_LEFT, page_rect.size.x - 56.0, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	var entries := GameState.get_bot_activity_log(_bot_log_bot_index)
	if entries.is_empty():
		var empty_lines := _wrap_journal_text("No bot activity recorded yet. Load a tape, launch the drone, or run recovery to populate the log.", page_rect.size.x - 56.0, FONT_SIZE_VALUE, 5)
		for line_index in range(empty_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x + 28.0, page_rect.position.y + 86.0 + float(line_index) * 18.0), empty_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, page_rect.size.x - 56.0, FONT_SIZE_VALUE, STEEL_DARK)
		return
	var page_count := maxi(int(ceili(float(entries.size()) / float(BOT_LOG_PAGE_SIZE))), 1)
	_bot_log_page_index = clampi(_bot_log_page_index, 0, page_count - 1)
	var start_index := _bot_log_page_index * BOT_LOG_PAGE_SIZE
	var end_index := mini(start_index + BOT_LOG_PAGE_SIZE, entries.size())
	var list_rect := Rect2(page_rect.position + Vector2(24.0, 58.0), Vector2(page_rect.size.x - 48.0, page_rect.size.y - 100.0))
	draw_rect(list_rect, Color(0.86, 0.80, 0.66))
	draw_rect(list_rect, PANEL_BORDER, false, 1.0)
	var row_y := list_rect.position.y + 18.0
	for entry_index in range(start_index, end_index):
		var entry: Dictionary = entries[entry_index]
		var position := Vector2.ZERO
		if typeof(entry.get("position", {})) == TYPE_DICTIONARY:
			var position_data: Dictionary = Dictionary(entry.get("position", {}))
			position = Vector2(int(position_data.get("x", 0)), int(position_data.get("y", 0)))
		var line := "#%03d [%d,%d] EN %d ACC %d %s" % [
			maxi(int(entry.get("tick", 0)), 0),
			int(position.x),
			int(position.y),
			int(entry.get("power_charge", 0)),
			int(entry.get("acc", 0)),
			str(entry.get("message", "")),
		]
		var wrapped_lines := _wrap_journal_text(line, list_rect.size.x - 16.0, FONT_SIZE_CARD_VALUE, 3)
		draw_string(ThemeDB.fallback_font, Vector2(list_rect.position.x + 8.0, row_y), wrapped_lines[0], HORIZONTAL_ALIGNMENT_LEFT, list_rect.size.x - 16.0, FONT_SIZE_CARD_VALUE, STEEL_DARK)
		for wrap_index in range(1, wrapped_lines.size()):
			row_y += 14.0
			draw_string(ThemeDB.fallback_font, Vector2(list_rect.position.x + 16.0, row_y), wrapped_lines[wrap_index], HORIZONTAL_ALIGNMENT_LEFT, list_rect.size.x - 24.0, FONT_SIZE_CARD_VALUE, TAPE_HOLE)
		row_y += 12.0
		if entry_index < end_index - 1:
			draw_line(Vector2(list_rect.position.x + 8.0, row_y), Vector2(list_rect.end.x - 8.0, row_y), Color(0.67, 0.57, 0.35, 0.65), 1.0)
			row_y += 16.0
	if _bot_log_page_index > 0:
		_bot_log_prev_rect = Rect2(Vector2(page_rect.position.x + 16.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_bot_log_prev_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_bot_log_prev_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_bot_log_prev_rect.position.x, _bot_log_prev_rect.position.y + 14.0), "<", HORIZONTAL_ALIGNMENT_CENTER, _bot_log_prev_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	if _bot_log_page_index < page_count - 1:
		_bot_log_next_rect = Rect2(Vector2(page_rect.end.x - 56.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_bot_log_next_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_bot_log_next_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_bot_log_next_rect.position.x, _bot_log_next_rect.position.y + 14.0), ">", HORIZONTAL_ALIGNMENT_CENTER, _bot_log_next_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x, page_rect.end.y - 18.0), "PAGE %d / %d" % [_bot_log_page_index + 1, page_count], HORIZONTAL_ALIGNMENT_CENTER, page_rect.size.x, FONT_SIZE_CARD_META + 2, STEEL_DARK)

func _is_card_locked_by_active_process(kind: String, identifier) -> bool:
	if kind == "mechanism":
		for tank_batch_variant in GameState.get_active_tank_batches():
			if typeof(tank_batch_variant) != TYPE_DICTIONARY:
				continue
			if str(Dictionary(tank_batch_variant).get("tank_id", "")) == str(identifier):
				return true
	if not _enemy_cage_capture_process.is_empty():
		match kind:
			"enemy":
				if str(identifier) == str(_enemy_cage_capture_process.get("enemy_id", "")):
					return true
			"structure":
				if str(identifier) == str(_enemy_cage_capture_process.get("cage_id", "")):
					return true
	if not _dog_taming_process.is_empty():
		match kind:
			"material":
				if str(identifier) == str(_dog_taming_process.get("material_id", "")):
					return true
			"structure":
				if str(identifier) == str(_dog_taming_process.get("cage_id", "")):
					return true
	return false

func _get_enemy_card_by_id(enemy_id: String) -> Dictionary:
	if enemy_id.is_empty():
		return {}
	for enemy_card_variant in GameState.get_state_table_cards("enemy"):
		if typeof(enemy_card_variant) != TYPE_DICTIONARY:
			continue
		var enemy_card: Dictionary = enemy_card_variant
		if str(enemy_card.get("id", "")) == enemy_id:
			return Dictionary(enemy_card).duplicate(true)
	return {}

func _get_material_card_by_id(material_id: String) -> Dictionary:
	if material_id.is_empty():
		return {}
	for material_card_variant in GameState.get_state_table_cards("material"):
		if typeof(material_card_variant) != TYPE_DICTIONARY:
			continue
		var material_card: Dictionary = material_card_variant
		if str(material_card.get("id", "")) == material_id:
			return Dictionary(material_card).duplicate(true)
	return {}

func _get_dog_card_by_id(dog_id: String) -> Dictionary:
	if dog_id.is_empty():
		return {}
	for dog_card_variant in GameState.get_state_table_cards("dog"):
		if typeof(dog_card_variant) != TYPE_DICTIONARY:
			continue
		var dog_card: Dictionary = dog_card_variant
		if str(dog_card.get("id", "")) == dog_id:
			return Dictionary(dog_card).duplicate(true)
	return {}

func _start_enemy_cage_capture_process(cage_id: String, enemy_id: String, process_rect: Rect2, enemy_card: Dictionary) -> void:
	if cage_id.is_empty() or enemy_id.is_empty() or enemy_card.is_empty():
		return
	var enemy_hp := maxi(int(enemy_card.get("hp", 1)), 1)
	var enemy_attack := maxi(int(enemy_card.get("attack", 1)), 1)
	var duration := ENEMY_CAGE_CAPTURE_BASE_INTERVAL + float(enemy_hp) * 0.32 + float(enemy_attack) * 0.45
	_enemy_cage_capture_process = {
		"cage_id": cage_id,
		"enemy_id": enemy_id,
		"enemy_name": str(enemy_card.get("display_name", "Enemy")),
		"rect": process_rect,
		"duration": duration,
		"cooldown": duration,
	}
	EventBus.log_message.emit("Capture started: %s" % str(enemy_card.get("display_name", "Enemy")))
	queue_redraw()

func _start_dog_taming_process(cage_id: String, material_id: String, process_rect: Rect2) -> void:
	if cage_id.is_empty() or material_id.is_empty():
		return
	var captive_enemy := GameState.get_caged_enemy(cage_id)
	var enemy_hp := maxi(int(captive_enemy.get("hp", 1)), 1)
	var enemy_attack := maxi(int(captive_enemy.get("attack", 1)), 1)
	var duration := DOG_TAMING_BASE_INTERVAL + float(enemy_hp) * 0.35 + float(enemy_attack) * 0.40
	_dog_taming_process = {
		"cage_id": cage_id,
		"material_id": material_id,
		"rect": process_rect,
		"duration": duration,
		"cooldown": duration,
	}
	EventBus.log_message.emit("Taming started: captured wolf")
	queue_redraw()

func _draw_storage_overlay():
	_storage_item_click_rects.clear()
	_storage_prev_rect = Rect2()
	_storage_next_rect = Rect2()
	_storage_close_rect = Rect2()
	var overlay_rect := Rect2(Vector2.ZERO, size)
	var page_rect := _get_storage_overlay_rect()
	draw_rect(overlay_rect, Color(0.02, 0.02, 0.03, 0.42))
	draw_rect(page_rect, TAPE)
	draw_rect(page_rect.grow(-6.0), Color(0.90, 0.84, 0.71))
	draw_rect(page_rect, PANEL_BORDER, false, 2.0)
	_storage_close_rect = Rect2(Vector2(page_rect.end.x - 34.0, page_rect.position.y + 12.0), Vector2(20.0, 20.0))
	draw_rect(_storage_close_rect, Color(0.42, 0.18, 0.16))
	draw_rect(_storage_close_rect.grow(-1.0), Color(0.31, 0.14, 0.13))
	_draw_outlined_text(_storage_close_rect.position + Vector2(0.0, 15.0), "X", HORIZONTAL_ALIGNMENT_CENTER, _storage_close_rect.size.x, FONT_SIZE_BANNER, TEXT, Color(0.12, 0.08, 0.06))
	var container_card := _get_crafted_card_by_id(_storage_container_id)
	if container_card.is_empty():
		_storage_open = false
		return
	var title := str(container_card.get("display_name", container_card.get("result", "STORAGE"))).to_upper()
	_draw_outlined_text(Vector2(page_rect.position.x + 28.0, page_rect.position.y + 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, page_rect.size.x - 56.0, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	var left_rect := Rect2(page_rect.position + Vector2(24.0, 58.0), Vector2(180.0, page_rect.size.y - 96.0))
	var right_rect := Rect2(page_rect.position + Vector2(226.0, 58.0), Vector2(page_rect.size.x - 250.0, page_rect.size.y - 96.0))
	var preview_rect := Rect2(left_rect.position, Vector2(140.0, 172.0))
	WorkshopArtData.draw_structure_card(self, preview_rect, container_card)
	var stored_entries := GameState.get_crafted_storage_contents(_storage_container_id)
	draw_string(ThemeDB.fallback_font, Vector2(left_rect.position.x, left_rect.position.y + 198.0), "STORED %d" % stored_entries.size(), HORIZONTAL_ALIGNMENT_LEFT, left_rect.size.x, FONT_SIZE_CARD_VALUE, STEEL_DARK)
	var storage_lines := _wrap_journal_text("Archive storage for portable table cards. Hostile enemy cards cannot be stored here. Click any row to withdraw it back to the table.", left_rect.size.x, FONT_SIZE_CARD_VALUE, 7)
	for line_index in range(storage_lines.size()):
		draw_string(ThemeDB.fallback_font, Vector2(left_rect.position.x, left_rect.position.y + 226.0 + float(line_index) * 16.0), storage_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, left_rect.size.x, FONT_SIZE_CARD_VALUE, STEEL_DARK)
	if stored_entries.is_empty():
		var empty_lines := _wrap_journal_text("Drop portable cards onto this shelf to archive them. Hostile enemies stay out.", right_rect.size.x, FONT_SIZE_VALUE, 5)
		for line_index in range(empty_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(right_rect.position.x, right_rect.position.y + 28.0 + float(line_index) * 18.0), empty_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, right_rect.size.x, FONT_SIZE_VALUE, STEEL_DARK)
		return
	var page_count := maxi(int(ceili(float(stored_entries.size()) / float(STORAGE_PAGE_SIZE))), 1)
	_storage_page_index = clampi(_storage_page_index, 0, page_count - 1)
	var start_index := _storage_page_index * STORAGE_PAGE_SIZE
	var end_index := mini(start_index + STORAGE_PAGE_SIZE, stored_entries.size())
	var row_y := right_rect.position.y
	for entry_index in range(start_index, end_index):
		var entry: Dictionary = stored_entries[entry_index]
		var row_rect := Rect2(Vector2(right_rect.position.x, row_y), Vector2(right_rect.size.x, 34.0))
		draw_rect(row_rect, Color(0.84, 0.78, 0.62))
		draw_rect(row_rect, PANEL_BORDER, false, 1.0)
		var label := str(entry.get("display_name", entry.get("result", "ITEM"))).to_upper()
		if str(entry.get("kind", "")) == "material":
			label = "%s  x%d" % [label, maxi(int(entry.get("quantity", 1)), 1)]
		elif not Dictionary(entry.get("captive_enemy", {})).is_empty():
			label = "%s [%s]" % [label, str(Dictionary(entry.get("captive_enemy", {})).get("display_name", "CAGED")).to_upper()]
		draw_string(ThemeDB.fallback_font, Vector2(row_rect.position.x + 8.0, row_rect.position.y + 22.0), label, HORIZONTAL_ALIGNMENT_LEFT, row_rect.size.x - 90.0, FONT_SIZE_CARD_VALUE, STEEL_DARK)
		draw_string(ThemeDB.fallback_font, Vector2(row_rect.end.x - 76.0, row_rect.position.y + 22.0), "WITHDRAW", HORIZONTAL_ALIGNMENT_LEFT, 70.0, FONT_SIZE_CARD_META + 1, TAPE_SHADE)
		_storage_item_click_rects.append({"rect": row_rect, "entry_id": str(entry.get("entry_id", ""))})
		row_y += 40.0
	if _storage_page_index > 0:
		_storage_prev_rect = Rect2(Vector2(page_rect.position.x + 16.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_storage_prev_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_storage_prev_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_storage_prev_rect.position.x, _storage_prev_rect.position.y + 14.0), "<", HORIZONTAL_ALIGNMENT_CENTER, _storage_prev_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	if _storage_page_index < page_count - 1:
		_storage_next_rect = Rect2(Vector2(page_rect.end.x - 56.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
		draw_rect(_storage_next_rect, Color(0.79, 0.72, 0.56))
		draw_rect(_storage_next_rect, PANEL_BORDER, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(_storage_next_rect.position.x, _storage_next_rect.position.y + 14.0), ">", HORIZONTAL_ALIGNMENT_CENTER, _storage_next_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK)
	draw_string(ThemeDB.fallback_font, Vector2(page_rect.position.x, page_rect.end.y - 18.0), "PAGE %d / %d" % [_storage_page_index + 1, page_count], HORIZONTAL_ALIGNMENT_CENTER, page_rect.size.x, FONT_SIZE_CARD_META + 2, STEEL_DARK)

func _get_crafted_card_by_id(card_id: String) -> Dictionary:
	if card_id.is_empty():
		return {}
	for crafted_card in GameState.get_crafted_cards():
		if str(Dictionary(crafted_card).get("id", "")) == card_id:
			return Dictionary(crafted_card)
	return {}

func _draw_journal_index_page(page_rect: Rect2, left_page: Rect2, right_page: Rect2, entry: Dictionary) -> void:
	_draw_outlined_text(Vector2(left_page.position.x, left_page.position.y + 4.0), str(entry.get("title", "INDEX")), HORIZONTAL_ALIGNMENT_LEFT, left_page.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	_draw_outlined_text(Vector2(right_page.position.x, right_page.position.y + 4.0), "SECTIONS", HORIZONTAL_ALIGNMENT_LEFT, right_page.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	var intro_lines := _wrap_journal_text(str(entry.get("description", "")), left_page.size.x - 8.0, FONT_SIZE_CARD_VALUE + 1, 9)
	for line_index in range(intro_lines.size()):
		draw_string(ThemeDB.fallback_font, Vector2(left_page.position.x, left_page.position.y + 52.0 + float(line_index) * 18.0), intro_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, left_page.size.x - 8.0, FONT_SIZE_CARD_VALUE + 1, STEEL_DARK)
	var categories: Array = Array(entry.get("categories", []))
	var item_height := 42.0
	var top_y := right_page.position.y + 34.0
	for category_index in range(categories.size()):
		var category: Dictionary = Dictionary(categories[category_index])
		var item_rect := Rect2(Vector2(right_page.position.x, top_y + float(category_index) * (item_height + 8.0)), Vector2(right_page.size.x - 8.0, item_height))
		draw_rect(item_rect, Color(0.84, 0.78, 0.62))
		draw_rect(item_rect, PANEL_BORDER, false, 1.0)
		var label := str(category.get("label", "ENTRY"))
		var counts := "%d / %d" % [int(category.get("discovered", 0)), int(category.get("total", 0))]
		draw_string(ThemeDB.fallback_font, Vector2(item_rect.position.x + 8.0, item_rect.position.y + 16.0), label, HORIZONTAL_ALIGNMENT_LEFT, item_rect.size.x - 16.0, FONT_SIZE_CARD_VALUE + 1, STEEL_DARK)
		draw_string(ThemeDB.fallback_font, Vector2(item_rect.position.x + 8.0, item_rect.end.y - 8.0), counts, HORIZONTAL_ALIGNMENT_LEFT, item_rect.size.x - 32.0, FONT_SIZE_CARD_META + 2, TAPE_SHADE)
		draw_string(ThemeDB.fallback_font, Vector2(item_rect.position.x, item_rect.position.y + 28.0), "OPEN", HORIZONTAL_ALIGNMENT_RIGHT, item_rect.size.x - 10.0, FONT_SIZE_CARD_META + 2, STEEL_DARK)
		if bool(category.get("unread", false)):
			_draw_unread_badge(Rect2(Vector2(item_rect.end.x - 18.0, item_rect.position.y + 4.0), Vector2(14.0, 14.0)))
		_journal_index_click_rects.append({"rect": item_rect, "page_index": int(category.get("page_index", 0))})
	draw_string(ThemeDB.fallback_font, Vector2(left_page.position.x, left_page.end.y - 10.0), "DISCOVERED / TOTAL", HORIZONTAL_ALIGNMENT_LEFT, left_page.size.x, FONT_SIZE_CARD_META + 2, TAPE_SHADE)

func _draw_journal_entry_sections(left_page: Rect2, preview_rect: Rect2, entry: Dictionary) -> void:
	var body_top := left_page.position.y + 34.0
	var right_column := Rect2(Vector2(preview_rect.end.x + 16.0, body_top), Vector2(left_page.end.x - (preview_rect.end.x + 16.0), preview_rect.size.y))
	var lower_rect := Rect2(Vector2(left_page.position.x, preview_rect.end.y + 12.0), Vector2(left_page.size.x, left_page.end.y - (preview_rect.end.y + 22.0)))
	var sections: Array = Array(entry.get("notes_sections", []))
	if sections.is_empty():
		sections = [{"title": "SUMMARY", "text": str(entry.get("description", ""))}]
	var next_index := _draw_journal_section_list(right_column, sections, 0, 3)
	if next_index < sections.size():
		_draw_journal_section_list(lower_rect, sections, next_index, 4)
	draw_string(ThemeDB.fallback_font, Vector2(left_page.position.x, left_page.end.y - 10.0), "ATTEMPTS %d" % int(entry.get("attempts", 0)), HORIZONTAL_ALIGNMENT_LEFT, left_page.size.x, FONT_SIZE_CARD_META + 2, TAPE_SHADE)

func _draw_journal_section_list(rect: Rect2, sections: Array, start_index: int, max_sections: int) -> int:
	var y := rect.position.y
	var drawn := 0
	for section_index in range(start_index, sections.size()):
		if drawn >= max_sections:
			return section_index
		var section: Dictionary = Dictionary(sections[section_index])
		var title := str(section.get("title", "NOTES"))
		var text := str(section.get("text", "")).strip_edges()
		if text.is_empty():
			continue
		draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, y + 12.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, FONT_SIZE_CARD_META + 2, TAPE_SHADE)
		var lines := _wrap_journal_text(text, rect.size.x - 4.0, FONT_SIZE_CARD_VALUE, 4 if rect.size.y > 120.0 else 3)
		for line_index in range(lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, y + 28.0 + float(line_index) * 15.0), lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 4.0, FONT_SIZE_CARD_VALUE, STEEL_DARK)
		y += 28.0 + float(lines.size()) * 15.0 + 8.0
		drawn += 1
	return sections.size()

func _draw_journal_recipe_panel(page_rect: Rect2, right_page: Rect2, entry: Dictionary) -> void:
	var recipes: Array = Array(entry.get("recipes", []))
	var related_subjects: Array = Array(entry.get("related_subjects", []))
	var recipes_title_y := right_page.position.y + 4.0
	_draw_outlined_text(Vector2(right_page.position.x, recipes_title_y), "RECIPES", HORIZONTAL_ALIGNMENT_LEFT, right_page.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	var page_size := 2
	var recipe_card_height := 72.0
	var recipe_card_gap := 8.0
	var recipes_panel_height := recipe_card_height * float(page_size) + recipe_card_gap
	if recipes.is_empty():
		var no_result_lines := _wrap_journal_text("No stable formula recorded yet. Further research may still fail, but can surface a usable blueprint.", right_page.size.x - 16.0, FONT_SIZE_CARD_VALUE, 6)
		for line_index in range(no_result_lines.size()):
			draw_string(ThemeDB.fallback_font, Vector2(right_page.position.x, right_page.position.y + 40.0 + float(line_index) * 16.0), no_result_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, right_page.size.x - 16.0, FONT_SIZE_CARD_VALUE, STEEL_DARK)
	else:
		var page_count := maxi(int(ceili(float(recipes.size()) / float(page_size))), 1)
		_journal_recipe_page_index = clampi(_journal_recipe_page_index, 0, page_count - 1)
		var start_index := _journal_recipe_page_index * page_size
		var end_index := mini(start_index + page_size, recipes.size())
		for recipe_index in range(start_index, end_index):
			var display_index := recipe_index - start_index
			var recipe: Dictionary = recipes[recipe_index]
			var recipe_state := str(recipe.get("state", "locked"))
			var recipe_locked := recipe_state == "locked"
			var recipe_partial := recipe_state == "partial"
			var recipe_complete := recipe_state == "complete"
			var recipe_rect := Rect2(Vector2(right_page.position.x, right_page.position.y + 36.0 + float(display_index) * (recipe_card_height + recipe_card_gap)), Vector2(right_page.size.x - 10.0, recipe_card_height))
			var fill := Color(0.78, 0.73, 0.60)
			if recipe_complete:
				fill = Color(0.84, 0.78, 0.62)
			elif recipe_partial:
				fill = Color(0.81, 0.75, 0.58)
			draw_rect(recipe_rect, fill)
			draw_rect(recipe_rect, PANEL_BORDER, false, 1.0)
			var result_name := str(recipe.get("result", "UNKNOWN"))
			draw_string(ThemeDB.fallback_font, Vector2(recipe_rect.position.x + 6.0, recipe_rect.position.y + 14.0), result_name, HORIZONTAL_ALIGNMENT_LEFT, recipe_rect.size.x - 12.0, FONT_SIZE_CARD_META + 3, STEEL_DARK)
			var formula_lines := _build_journal_recipe_formula_lines(recipe, recipe_rect.size.x - 12.0, 3)
			for line_index in range(formula_lines.size()):
				draw_string(ThemeDB.fallback_font, Vector2(recipe_rect.position.x + 6.0, recipe_rect.position.y + 28.0 + float(line_index) * 11.0), formula_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, recipe_rect.size.x - 12.0, FONT_SIZE_CARD_META + 2, STEEL_DARK)
			var state_text := "RESEARCH REQUIRED"
			if recipe_partial:
				state_text = "PARTIAL FORMULA"
			elif recipe_complete:
				state_text = "CLICK TO COPY BLUEPRINT"
			draw_string(ThemeDB.fallback_font, Vector2(recipe_rect.position.x + 6.0, recipe_rect.end.y - 6.0), state_text, HORIZONTAL_ALIGNMENT_LEFT, recipe_rect.size.x - 12.0, FONT_SIZE_CARD_META + 1, TAPE_SHADE)
			if bool(recipe.get("unread", false)) and not recipe_locked:
				_draw_unread_badge(Rect2(Vector2(recipe_rect.end.x - 18.0, recipe_rect.position.y + 4.0), Vector2(14.0, 14.0)))
			if recipe_complete:
				_journal_recipe_click_rects.append({"rect": recipe_rect, "recipe": recipe})
		if page_count > 1:
			if _journal_recipe_page_index > 0:
				_journal_recipe_prev_rect = Rect2(Vector2(right_page.position.x, right_page.position.y + 36.0 + recipes_panel_height + 4.0), Vector2(22.0, 16.0))
				draw_rect(_journal_recipe_prev_rect, Color(0.79, 0.72, 0.56))
				draw_rect(_journal_recipe_prev_rect, PANEL_BORDER, false, 1.0)
				draw_string(ThemeDB.fallback_font, Vector2(_journal_recipe_prev_rect.position.x, _journal_recipe_prev_rect.position.y + 13.0), "<", HORIZONTAL_ALIGNMENT_CENTER, _journal_recipe_prev_rect.size.x, FONT_SIZE_CARD_META + 1, STEEL_DARK)
			if _journal_recipe_page_index < page_count - 1:
				_journal_recipe_next_rect = Rect2(Vector2(right_page.end.x - 32.0, right_page.position.y + 36.0 + recipes_panel_height + 4.0), Vector2(22.0, 16.0))
				draw_rect(_journal_recipe_next_rect, Color(0.79, 0.72, 0.56))
				draw_rect(_journal_recipe_next_rect, PANEL_BORDER, false, 1.0)
				draw_string(ThemeDB.fallback_font, Vector2(_journal_recipe_next_rect.position.x, _journal_recipe_next_rect.position.y + 13.0), ">", HORIZONTAL_ALIGNMENT_CENTER, _journal_recipe_next_rect.size.x, FONT_SIZE_CARD_META + 1, STEEL_DARK)
			draw_string(ThemeDB.fallback_font, Vector2(right_page.position.x + 28.0, right_page.position.y + 36.0 + recipes_panel_height + 17.0), "RECIPES %d / %d" % [_journal_recipe_page_index + 1, page_count], HORIZONTAL_ALIGNMENT_LEFT, right_page.size.x - 60.0, FONT_SIZE_CARD_META + 1, TAPE_SHADE)
	var related_panel := Rect2(Vector2(right_page.position.x, right_page.position.y + 236.0), Vector2(right_page.size.x - 10.0, right_page.size.y - 244.0))
	_draw_outlined_text(Vector2(related_panel.position.x, related_panel.position.y + 4.0), "RELATED", HORIZONTAL_ALIGNMENT_LEFT, related_panel.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.96, 0.92, 0.84))
	if related_subjects.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(related_panel.position.x, related_panel.position.y + 28.0), "No cross-references yet.", HORIZONTAL_ALIGNMENT_LEFT, related_panel.size.x, FONT_SIZE_CARD_VALUE, TAPE_SHADE)
		return
	var columns := 2
	var cell_gap := 8.0
	var cell_width := (related_panel.size.x - cell_gap) * 0.5
	var cell_height := 34.0
	var max_items := mini(related_subjects.size(), 6)
	for related_index in range(max_items):
		var related_entry: Dictionary = Dictionary(related_subjects[related_index])
		var column := related_index % columns
		var row := related_index / columns
		var cell_rect := Rect2(Vector2(related_panel.position.x + float(column) * (cell_width + cell_gap), related_panel.position.y + 24.0 + float(row) * (cell_height + 6.0)), Vector2(cell_width, cell_height))
		draw_rect(cell_rect, Color(0.78, 0.73, 0.60) if bool(related_entry.get("locked", false)) else Color(0.84, 0.78, 0.62))
		draw_rect(cell_rect, PANEL_BORDER, false, 1.0)
		var label := str(related_entry.get("title", "ENTRY"))
		draw_string(ThemeDB.fallback_font, Vector2(cell_rect.position.x + 6.0, cell_rect.position.y + 20.0), label, HORIZONTAL_ALIGNMENT_LEFT, cell_rect.size.x - 12.0, FONT_SIZE_CARD_META + 2, STEEL_DARK)
		draw_string(ThemeDB.fallback_font, Vector2(cell_rect.position.x + 6.0, cell_rect.end.y - 6.0), "LOCKED" if bool(related_entry.get("locked", false)) else "OPEN PAGE", HORIZONTAL_ALIGNMENT_LEFT, cell_rect.size.x - 12.0, FONT_SIZE_CARD_META, TAPE_SHADE)
		if bool(related_entry.get("unread", false)) and not bool(related_entry.get("locked", false)):
			_draw_unread_badge(Rect2(Vector2(cell_rect.end.x - 18.0, cell_rect.position.y + 4.0), Vector2(14.0, 14.0)))
		_journal_related_click_rects.append({"rect": cell_rect, "subject_key": str(related_entry.get("subject_key", ""))})

func _draw_journal_entry_preview(preview_rect: Rect2, entry: Dictionary):
	var subject_kind := str(entry.get("subject_kind", ""))
	var subject_type := str(entry.get("subject_type", ""))
	match subject_kind:
		"location":
			WorkshopArtData.draw_location_card(self, preview_rect, {"type": subject_type, "position": {"x": 0, "y": 0}}, _location_bunker_texture, _location_cache_texture, _location_pond_texture, _location_crater_texture, _location_tower_texture, _location_surveillance_texture, _location_facility_texture, _location_field_texture, _location_dump_texture, _location_nest_texture, _location_ruin_texture)
		"enemy":
			WorkshopArtData.draw_enemy_card(self, preview_rect, {"type": subject_type, "display_name": str(entry.get("title", subject_type)).capitalize(), "threat_level": 1, "hp": 1})
		"material":
			WorkshopArtData.draw_material_card(self, preview_rect, {"type": subject_type, "quantity": 1})
		"machine":
			WorkshopArtData.draw_machine_card(self, preview_rect, subject_type if subject_type != "route" else "route", Callable(self, "_draw_route_card_overlay"))
		"drone":
			WorkshopArtData.draw_table_drone_card(self, preview_rect, {
				"index": 0,
				"drone_type": subject_type,
				"rect": preview_rect,
				"body_hotspot": preview_rect,
				"loaded_cartridge": {},
				"power_charge": 0,
				"power_card_count": 0,
				"available_in_workshop": true,
				"outside_status": "cabinet",
				"tape_badge_rect": Rect2(Vector2(preview_rect.position.x + 14.0, preview_rect.end.y - 48.0), Vector2(48.0, 16.0)),
			}, false, false)
		"tape":
			WorkshopArtData.draw_tape_card(self, preview_rect, subject_type == "programmed", subject_type.to_upper(), false)
		"resource":
			WorkshopArtData.draw_material_card(self, preview_rect, {"type": "power_unit", "quantity": GameState.CHARGE_MACHINE_TRANSFER_UNITS})
		"equipment":
			WorkshopArtData.draw_equipment_card(self, preview_rect, {"type": subject_type, "display_name": str(entry.get("title", subject_type.to_upper()))})
		"structure":
			WorkshopArtData.draw_structure_card(self, preview_rect, {"type": subject_type, "display_name": str(entry.get("title", subject_type.to_upper()))})
		"mechanism":
			WorkshopArtData.draw_mechanism_card(self, preview_rect, {"type": subject_type, "display_name": str(entry.get("title", subject_type.to_upper()))})
		_:
			draw_rect(preview_rect, TAPE)
			draw_rect(preview_rect, PANEL_BORDER, false, 1.0)

func _draw_locked_journal_entry_preview(preview_rect: Rect2, _entry: Dictionary):
	draw_rect(preview_rect, TAPE)
	draw_rect(preview_rect.grow(-6.0), Color(0.89, 0.83, 0.70))
	draw_rect(preview_rect, PANEL_BORDER, false, 1.0)
	var inner_rect := preview_rect.grow(-18.0)
	draw_rect(inner_rect, Color(0.78, 0.72, 0.58))
	draw_rect(inner_rect, PANEL_BORDER, false, 1.0)
	var lock_body_rect := Rect2(Vector2(inner_rect.position.x + inner_rect.size.x * 0.5 - 18.0, inner_rect.position.y + 54.0), Vector2(36.0, 28.0))
	draw_rect(lock_body_rect, STEEL_DARK)
	draw_arc(Vector2(lock_body_rect.position.x + 18.0, lock_body_rect.position.y + 2.0), 10.0, PI, TAU, 16, STEEL_DARK, 4.0)
	_draw_outlined_text(Vector2(inner_rect.position.x, inner_rect.position.y + 100.0), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, inner_rect.size.x, FONT_SIZE_BANNER, STEEL_DARK, Color(0.95, 0.92, 0.84))
	_draw_outlined_text(Vector2(inner_rect.position.x, inner_rect.position.y + 132.0), "??", HORIZONTAL_ALIGNMENT_CENTER, inner_rect.size.x, FONT_SIZE_BANNER + 6, ACCENT_DIM, Color(0.95, 0.92, 0.84))

func _build_journal_recipe_formula_lines(recipe: Dictionary, max_width: float, max_lines: int) -> Array:
	var formula_body := str(recipe.get("formula", "")).strip_edges()
	var result_name := str(recipe.get("result", "UNKNOWN")).strip_edges()
	var prefix := "%s = " % result_name
	if formula_body.begins_with(prefix):
		formula_body = formula_body.substr(prefix.length(), formula_body.length() - prefix.length()).strip_edges()
	var parts: Array[String] = []
	if not formula_body.is_empty():
		for piece in formula_body.split(" + ", false):
			var normalized_piece := str(piece).strip_edges()
			if not normalized_piece.is_empty():
				parts.append(normalized_piece)
	if parts.is_empty():
		for part_variant in Array(recipe.get("formula_parts", [])).duplicate(true):
			var normalized_part := str(part_variant).strip_edges()
			if not normalized_part.is_empty():
				parts.append(normalized_part)
	if parts.is_empty():
		return []
	var font := ThemeDB.fallback_font
	var lines: Array = []
	var current_line := ""
	for part in parts:
		var proposal := part if current_line.is_empty() else "%s + %s" % [current_line, part]
		if font.get_string_size(proposal, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE_CARD_META + 2).x <= max_width:
			current_line = proposal
			continue
		if not current_line.is_empty():
			lines.append(current_line)
			if lines.size() >= max_lines:
				break
		current_line = part
	if lines.size() < max_lines and not current_line.is_empty():
		lines.append(current_line)
	if lines.size() > max_lines:
		lines = lines.slice(0, max_lines)
	if parts.size() > 0 and lines.size() == max_lines:
		var last_index := lines.size() - 1
		if not str(lines[last_index]).ends_with("..."):
			lines[last_index] = str(lines[last_index]) + "..."
	return lines

func _wrap_journal_text(text: String, max_width: float, font_size: int, max_lines: int) -> Array:
	var font := ThemeDB.fallback_font
	var words := text.split(" ")
	var lines: Array = []
	var current_line := ""
	for word in words:
		var proposal := word if current_line.is_empty() else "%s %s" % [current_line, word]
		if font.get_string_size(proposal, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= max_width:
			current_line = proposal
			continue
		if not current_line.is_empty():
			lines.append(current_line)
			if lines.size() >= max_lines:
				break
		current_line = word
	if lines.size() < max_lines and not current_line.is_empty():
		lines.append(current_line)
	if lines.size() > max_lines:
		lines = lines.slice(0, max_lines)
	if words.size() > 0 and lines.size() == max_lines:
		var last_index := lines.size() - 1
		if not str(lines[last_index]).ends_with("..."):
			lines[last_index] = str(lines[last_index]) + "..."
	return lines

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
		"journal_rect": Rect2(_table_journal_position, CARD_SIZE),
	}

func _get_table_visual_cards(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var cards: Array = []
	var machine_cards := _get_machine_card_data(rect)
	if not _is_dragging_table_card("bench_card", 0):
		var bench_rect := Rect2(machine_cards["bench_rect"])
		bench_rect.position += _get_card_feedback_offset("bench_card", 0)
		cards.append({
			"kind": "bench_card",
			"rect": bench_rect,
			"z": bench_rect.end.y,
		})
	if not _is_dragging_table_card("route_card", 0):
		var route_rect := Rect2(machine_cards["route_rect"])
		route_rect.position += _get_card_feedback_offset("route_card", 0)
		cards.append({
			"kind": "route_card",
			"rect": route_rect,
			"z": route_rect.end.y,
		})
	if not _is_dragging_table_card("charge_card", 0):
		var charge_rect := Rect2(machine_cards["charge_rect"])
		charge_rect.position += _get_card_feedback_offset("charge_card", 0)
		cards.append({
			"kind": "charge_card",
			"rect": charge_rect,
			"z": charge_rect.end.y,
		})
	if not _is_dragging_table_card("journal_card", 0):
		var journal_rect := Rect2(machine_cards["journal_rect"])
		journal_rect.position += _get_card_feedback_offset("journal_card", 0)
		cards.append({
			"kind": "journal_card",
			"rect": journal_rect,
			"z": journal_rect.end.y,
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
		var trash_rect := Rect2(_table_trash_position, CARD_SIZE)
		trash_rect.position += _get_card_feedback_offset("trash_card", 0)
		cards.append({
			"kind": "trash_card",
			"rect": trash_rect,
			"z": trash_rect.end.y,
		})
	for kind in WorkshopCardRuntimeData.STATE_TABLE_CARD_KINDS:
		_append_state_table_visual_cards(cards, kind, rect)
	var tape_data := _get_tape_hand_data(rect)
	_append_programmed_cartridge_visual_cards(cards, tape_data)
	_append_blank_visual_cards(cards, tape_data)
	_append_drone_visual_cards(cards, rect)
	cards.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["z"]) < float(b["z"]))
	return cards

func _get_top_tape_badge_at_point(drone_slots: Array, root_point: Vector2) -> Dictionary:
	return WorkshopTableControllerData.get_top_tape_badge_at_point(drone_slots, root_point)

func _get_top_table_card_at_point(rect: Rect2, root_point: Vector2) -> Dictionary:
	return WorkshopTableControllerData.get_top_table_card_at_point(_get_table_visual_cards(rect), root_point)

func _is_dragging_table_card(kind: String, identifier) -> bool:
	return WorkshopTableControllerData.is_dragging_table_card(_active_drag, kind, identifier)

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
	for cartridge_variant in GameState.get_shelf_programmed_cartridges():
		var cartridge: Dictionary = cartridge_variant
		var cartridge_id := str(cartridge.get("id", ""))
		programmed_slots.append({
			"rect": Rect2(Vector2(_table_cartridge_positions.get(cartridge_id, hand_zone.position)), CARD_SIZE),
			"cartridge": cartridge,
			"selected": cartridge_id == GameState.selected_cartridge_id,
		})
	for blank_index in range(GameState.get_blank_cartridge_count()):
		blank_slots.append({
			"index": blank_index,
			"rect": Rect2(Vector2(_table_blank_positions.get(blank_index, hand_zone.position)), CARD_SIZE),
			"filled": true,
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
	for drone_index in range(GameState.bot_loadouts.size()):
		var drone_type := GameState.get_bot_drone_type(drone_index)
		var drone_rect := Rect2(Vector2(_table_drone_positions.get(drone_index, workspace.position)), CARD_SIZE)
		var tape_badge_rect := Rect2(
			Vector2(drone_rect.position.x + 14.0, drone_rect.end.y - 48.0),
			Vector2(48.0, 16.0)
		)
		var available_in_workshop: bool = GameState.is_bot_available_in_workshop(drone_index)
		var control_y := drone_rect.end.y + 10.0
		slots.append({
			"index": drone_index,
			"drone_type": drone_type,
			"rect": drone_rect,
			"body_hotspot": drone_rect,
			"tape_badge_rect": tape_badge_rect,
			"equipment_slot_rects": _get_equipment_slot_rects_for_card(drone_rect),
			"loaded_cartridge": GameState.get_bot_loaded_cartridge(drone_index),
			"power_charge": int(GameState.bot_loadouts[drone_index].get("power_charge", 0)),
			"power_card_count": int(GameState.bot_loadouts[drone_index].get("power_card_count", 0)),
			"max_power_charge": int(GameState.bot_loadouts[drone_index].get("max_power_charge", GameState.BOT_POWER_CAPACITY)),
			"outside_status": str(GameState.bot_loadouts[drone_index].get("outside_status", "cabinet")),
			"equipment_slots": Array(GameState.bot_loadouts[drone_index].get("equipment_slots", [])).duplicate(true),
			"equipment_totals": GameState.get_bot_equipment_totals(drone_index),
			"available_in_workshop": available_in_workshop,
			"play_hotspot": Rect2(Vector2(drone_rect.position.x + 24.0, control_y), Vector2(drone_rect.size.x - 48.0, 20.0)),
		})
	return slots

func _get_table_dog_data(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var slots: Array = []
	for dog_card_variant in GameState.get_dog_cards():
		if typeof(dog_card_variant) != TYPE_DICTIONARY:
			continue
		var dog_card: Dictionary = Dictionary(dog_card_variant).duplicate(true)
		var dog_id := str(dog_card.get("id", ""))
		if dog_id.is_empty():
			continue
		var dog_rect := Rect2(Vector2(_table_dog_positions.get(dog_id, rect.position)), CARD_SIZE)
		slots.append({
			"dog_id": dog_id,
			"rect": dog_rect,
			"card_data": dog_card,
			"equipment_slots": Array(dog_card.get("equipment_slots", [])).duplicate(true),
			"equipment_slot_rects": _get_equipment_slot_rects_for_card(dog_rect),
			"equipment_totals": GameState.get_dog_combat_totals(dog_id),
		})
	return slots

func _get_enemy_fight_states(rect: Rect2) -> Array:
	_ensure_table_layout(rect)
	var states: Array = []
	var operator_rect := Rect2(_table_operator_position, CARD_SIZE)
	var drones := _get_table_drone_data(rect)
	var dogs := _get_table_dog_data(rect)
	for enemy_card in GameState.get_enemy_cards():
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		var enemy_rect := Rect2(Vector2(_table_enemy_positions.get(enemy_id, rect.position)), CARD_SIZE)
		var use_operator := _has_meaningful_overlap(enemy_rect, operator_rect, 0.30)
		var bot_indices: Array = []
		var dog_ids: Array = []
		for drone_slot in drones:
			if not bool(drone_slot.get("available_in_workshop", false)):
				continue
			if int(drone_slot.get("power_charge", 0)) <= 0:
				continue
			if _has_meaningful_overlap(enemy_rect, Rect2(drone_slot.get("rect", Rect2())), 0.30):
				bot_indices.append(int(drone_slot.get("index", -1)))
		for dog_slot in dogs:
			var dog_card: Dictionary = Dictionary(dog_slot.get("card_data", {}))
			if int(dog_card.get("energy", 0)) <= 0:
				continue
			if int(dog_card.get("hp", 0)) <= 0:
				continue
			if str(dog_card.get("status", "active")) == "dead":
				continue
			if _has_meaningful_overlap(enemy_rect, Rect2(dog_slot.get("rect", Rect2())), 0.30):
				dog_ids.append(str(dog_slot.get("dog_id", "")))
		if not use_operator and bot_indices.is_empty() and dog_ids.is_empty():
			_enemy_fight_cooldowns.erase(enemy_id)
			continue
		if not _enemy_fight_cooldowns.has(enemy_id):
			_enemy_fight_cooldowns[enemy_id] = ENEMY_FIGHT_INTERVAL
		states.append({
			"enemy_id": enemy_id,
			"rect": enemy_rect,
			"use_operator": use_operator,
			"bot_indices": bot_indices,
			"dog_ids": dog_ids,
		})
	return states

func _draw_shelter_marker(origin: Vector2, cell_size: float):
	var shelter_center: Vector2 = origin + (GameState.get_shelter_position() + Vector2.ONE * 0.5) * cell_size
	var shelter_rect := Rect2(shelter_center - Vector2(5.0, 4.0), Vector2(10.0, 8.0))
	draw_rect(shelter_rect, STEEL_DARK)
	draw_rect(shelter_rect.grow(-1.0), TAPE)
	draw_line(shelter_center + Vector2(0.0, -7.0), shelter_center + Vector2(0.0, 7.0), PANEL_BORDER, 1.0)

func _is_location_target_active(location_id: String) -> bool:
	if location_id.is_empty():
		return false
	for bot_state in GameState.bot_loadouts:
		if str(bot_state.get("outside_status", "cabinet")) != "active":
			continue
		if str(bot_state.get("mission_location_id", "")) == location_id:
			return true
	return false

func _get_location_mission_progress(location_id: String) -> Dictionary:
	if location_id.is_empty():
		return {}
	var shelter := GameState.get_shelter_position()
	for bot_state in GameState.bot_loadouts:
		if str(bot_state.get("outside_status", "cabinet")) != "active":
			continue
		if str(bot_state.get("mission_location_id", "")) != location_id:
			continue
		var target := Vector2(bot_state.get("mission_location_position", shelter))
		var current := Vector2(bot_state.get("outside_position", shelter))
		var total_leg := maxf(target.distance_to(shelter), 1.0)
		var progress := 0.0
		var pickup_attempts := int(bot_state.get("mission_pickup_attempts", 0))
		if pickup_attempts <= 0:
			progress = 0.08 + 0.42 * clampf(1.0 - current.distance_to(target) / total_leg, 0.0, 1.0)
		else:
			progress = 0.55 + 0.40 * clampf(1.0 - current.distance_to(shelter) / total_leg, 0.0, 1.0)
		return {
			"active": true,
			"progress": clampf(progress, 0.0, 0.98),
			"pickup_attempts": pickup_attempts,
			"bot_id": str(bot_state.get("id", "")),
		}
	return {}

func _draw_location_marker_progress(center: Vector2, cell_size: float, progress: float) -> void:
	var bar_width := maxf(cell_size * 0.84, 10.0)
	var bar_height := 3.0
	var bar_rect := Rect2(
		Vector2(center.x - bar_width * 0.5, center.y + cell_size * 0.42),
		Vector2(bar_width, bar_height)
	)
	draw_rect(bar_rect, Color(0.12, 0.11, 0.09, 0.95))
	draw_rect(bar_rect.grow(-1.0), Color(0.34, 0.30, 0.20, 0.85))
	var fill_width := maxf((bar_rect.size.x - 2.0) * clampf(progress, 0.0, 1.0), 0.0)
	if fill_width > 0.0:
		var fill_rect := Rect2(bar_rect.position + Vector2(1.0, 1.0), Vector2(fill_width, bar_rect.size.y - 2.0))
		draw_rect(fill_rect, Color(0.97, 0.86, 0.42, 0.95))
	draw_rect(bar_rect, Color(0.62, 0.53, 0.28, 1.0), false, 1.0)

func _draw_discovery_markers(origin: Vector2, cell_size: float):
	for object_entry in GameState.get_discovered_outside_objects():
		var position := Vector2(object_entry.get("position", Vector2.ZERO))
		var location_id := str(object_entry.get("id", ""))
		var center := origin + (position + Vector2.ONE * 0.5) * cell_size
		var mission_state := _get_location_mission_progress(location_id)
		var active_target := bool(mission_state.get("active", false))
		var feedback_entry: Dictionary = Dictionary(_location_marker_fx.get(location_id, {}))
		var should_pulse := active_target or not feedback_entry.is_empty()
		if should_pulse:
			var duration := maxf(float(feedback_entry.get("duration", TARGET_MARKER_FEEDBACK_DURATION)), 0.001)
			var timer := float(feedback_entry.get("timer", TARGET_MARKER_FEEDBACK_DURATION))
			var progress := 1.0 - timer / duration
			if active_target and feedback_entry.is_empty():
				progress = fmod(float(Time.get_ticks_msec()) * 0.0022, 1.0)
			var pulse_radius := (cell_size * 0.34) + sin(progress * TAU * 2.0) * (cell_size * 0.12)
			var pulse_fill := Color(0.95, 0.78, 0.23, 0.22 if active_target else 0.16)
			var pulse_stroke := Color(0.98, 0.88, 0.48, 0.95 if active_target else 0.72)
			draw_circle(center, pulse_radius, pulse_fill)
			draw_arc(center, pulse_radius + 1.8, 0.0, TAU, 28, pulse_stroke, 1.8)
		var fill_color := TAPE_SHADE
		var detail_color := TAPE_HOLE
		var accent_color := ACCENT_DIM
		if active_target:
			fill_color = Color(0.95, 0.76, 0.24)
			detail_color = STEEL_DARK
			accent_color = Color(0.99, 0.90, 0.60)
		var object_type := str(object_entry.get("type", ""))
		match object_type:
			"resource", "cache", "field", "pond", "facility", "dump", "bunker":
				draw_circle(center, 3.8 if active_target else 3.4, fill_color)
				draw_circle(center, 1.7 if active_target else 1.6, detail_color)
				draw_line(center + Vector2(-4.0, 0.0), center + Vector2(4.0, 0.0), accent_color, 1.0)
				draw_line(center + Vector2(0.0, -4.0), center + Vector2(0.0, 4.0), accent_color, 1.0)
			"hazard", "crater", "anomaly_zone":
				draw_circle(center, 3.5 if active_target else 3.2, fill_color)
				draw_line(center + Vector2(-3.6, -3.6), center + Vector2(3.6, 3.6), detail_color, 1.2)
				draw_line(center + Vector2(-3.6, 3.6), center + Vector2(3.6, -3.6), detail_color, 1.2)
			"landmark", "tower", "bridge", "road_node":
				var tower_size := Vector2(6.6, 6.6) if active_target else Vector2(6.0, 6.0)
				draw_rect(Rect2(center - tower_size * 0.5, tower_size), fill_color)
				draw_rect(Rect2(center - Vector2(1.2, 1.2), Vector2(2.4, 2.4)), detail_color)
				draw_rect(Rect2(center - tower_size * 0.5, tower_size), accent_color, false, 1.0)
			"surveillance", "surveillance_zone", "nest":
				var triangle := PackedVector2Array([
					center + Vector2(0.0, -4.5),
					center + Vector2(4.0, 3.5),
					center + Vector2(-4.0, 3.5),
				])
				draw_colored_polygon(triangle, fill_color)
				draw_line(triangle[0], triangle[1], detail_color, 1.0)
				draw_line(triangle[1], triangle[2], detail_color, 1.0)
				draw_line(triangle[2], triangle[0], detail_color, 1.0)
				draw_circle(center + Vector2(0.0, 0.8), 1.1, detail_color)
			_:
				draw_circle(center, 3.1 if active_target else 2.8, fill_color)
				draw_circle(center, 1.2 if active_target else 1.1, detail_color)
		if active_target:
			_draw_location_marker_progress(center, cell_size, float(mission_state.get("progress", 0.0)))

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
	return GameState.get_bot_display_name(bot_index)

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

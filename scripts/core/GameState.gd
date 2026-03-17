extends Node

const PunchEncodingData = preload("res://scripts/data/PunchEncoding.gd")
const TapeDecoderData = preload("res://scripts/data/TapeDecoder.gd")

const START_POSITION := Vector2(5, 5)
const START_FACING := "north"
const SHELTER_MARKER := "shelter"
const CARTRIDGE_STORAGE_PATH := "user://programmed_cartridges.json"
const PROGRAMMED_CARTRIDGE_CAPACITY := 8
const BLANK_CARTRIDGE_SLOT_COUNT := 4
const BOT_CABINET_CAPACITY := 2
const BOT_POWER_CAPACITY := 10
const POWER_UNIT_SLOT_COUNT := 4
const MAX_PREDICTION_STEPS := 64

var automaton_position: Vector2 = START_POSITION
var automaton_facing: String = START_FACING
var automaton_energy: int = 100
var automaton_acc: int = 0
var automaton_ptr: int = 0
var automaton_status: String = "idle"
var tape_program: Array = []
var inventory: Array = []
var trail_positions: Array = [START_POSITION]
var grid_size: Vector2 = Vector2(11, 11)
var max_energy: int = 100
var energy_per_move: int = 5
var energy_per_action: int = 2
var programmed_cartridges: Array = []
var blank_cartridge_slots: Array = []
var power_unit_slots: Array = []
var selected_cartridge_id: String = ""
var bot_loadouts: Array = []
var outside_objects: Array = []

func _ready():
	load_programmed_cartridges()

func set_automaton_position(new_position: Vector2):
	automaton_position = new_position
	if trail_positions.is_empty() or trail_positions[-1] != new_position:
		trail_positions.append(new_position)

func reset_trail():
	trail_positions = [automaton_position]

func get_default_cartridge_label() -> String:
	return "Tape %02d" % [_get_next_program_number()]

func get_shelter_position() -> Vector2:
	return Vector2(floori(grid_size.x * 0.5), floori(grid_size.y * 0.5))

func has_blank_cartridge_available() -> bool:
	return _get_first_blank_slot_index() != -1

func has_charged_power_unit_available() -> bool:
	return _get_first_charged_power_unit_slot_index() != -1

func has_free_programmed_slot() -> bool:
	return _get_first_free_programmed_slot_index() != -1

func can_open_programming_bench() -> bool:
	return has_blank_cartridge_available() and has_free_programmed_slot()

func get_blank_cartridge_count() -> int:
	var count := 0
	for filled in blank_cartridge_slots:
		if bool(filled):
			count += 1
	return count

func get_free_programmed_slot_count() -> int:
	var free_count := 0
	for slot_index in range(PROGRAMMED_CARTRIDGE_CAPACITY):
		if get_programmed_cartridge_in_slot(slot_index).is_empty():
			free_count += 1
	return free_count

func save_programmed_cartridge(label: String, rows: Array) -> Dictionary:
	var blank_slot_index := _get_first_blank_slot_index()
	var programmed_slot_index := _get_first_free_programmed_slot_index()
	if blank_slot_index == -1 or programmed_slot_index == -1:
		return {}

	var trimmed_label := label.strip_edges()
	if trimmed_label.is_empty():
		trimmed_label = get_default_cartridge_label()

	var normalized_rows := _duplicate_rows(rows)
	var cartridge := {
		"id": str(Time.get_unix_time_from_system()) + "_" + str(randi()),
		"label": trimmed_label,
		"rows": normalized_rows,
		"slot_index": programmed_slot_index,
		"location": "shelf",
		"use_count": 0,
		"wear": 0.0,
		"saved_at": Time.get_unix_time_from_system(),
	}

	blank_cartridge_slots[blank_slot_index] = false
	programmed_cartridges.append(cartridge)
	selected_cartridge_id = str(cartridge.get("id", ""))
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.cartridge_selected.emit(selected_cartridge_id)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return cartridge

func select_programmed_cartridge(cartridge_id: String):
	var cartridge := get_programmed_cartridge_by_id(cartridge_id)
	if cartridge.is_empty() or str(cartridge.get("location", "")) != "shelf":
		selected_cartridge_id = ""
	else:
		selected_cartridge_id = cartridge_id
	save_programmed_cartridges()
	EventBus.cartridge_selected.emit(selected_cartridge_id)

func get_selected_cartridge() -> Dictionary:
	var cartridge := get_programmed_cartridge_by_id(selected_cartridge_id)
	if cartridge.is_empty() or str(cartridge.get("location", "")) != "shelf":
		return {}
	return cartridge

func get_programmed_cartridge_by_id(cartridge_id: String) -> Dictionary:
	for cartridge in programmed_cartridges:
		if str(cartridge.get("id", "")) == cartridge_id:
			return cartridge
	return {}

func get_programmed_cartridge_in_slot(slot_index: int) -> Dictionary:
	for cartridge in programmed_cartridges:
		if int(cartridge.get("slot_index", -1)) == slot_index and str(cartridge.get("location", "")) == "shelf":
			return cartridge
	return {}

func recycle_programmed_cartridge(cartridge_id: String) -> bool:
	var cartridge_index := _get_programmed_cartridge_index(cartridge_id)
	if cartridge_index == -1:
		return false
	var cartridge: Dictionary = programmed_cartridges[cartridge_index]
	if str(cartridge.get("location", "")) != "shelf":
		return false
	var empty_blank_slot := _get_first_empty_blank_slot_index()
	if empty_blank_slot == -1:
		return false
	blank_cartridge_slots[empty_blank_slot] = true
	programmed_cartridges.remove_at(cartridge_index)
	if selected_cartridge_id == cartridge_id:
		selected_cartridge_id = ""
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.cartridge_selected.emit(selected_cartridge_id)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func is_blank_slot_filled(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= blank_cartridge_slots.size():
		return false
	return bool(blank_cartridge_slots[slot_index])

func get_power_unit_in_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return {}
	return power_unit_slots[slot_index]

func is_power_unit_charged(slot_index: int) -> bool:
	var power_unit := get_power_unit_in_slot(slot_index)
	return not power_unit.is_empty() and int(power_unit.get("charge", 0)) > 0

func create_power_unit_in_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return false
	if not power_unit_slots[slot_index].is_empty():
		return false
	power_unit_slots[slot_index] = {
		"id": "power_unit_%d" % slot_index,
		"charge": BOT_POWER_CAPACITY,
		"max_charge": BOT_POWER_CAPACITY,
	}
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func is_bot_available_in_workshop(bot_index: int) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	var outside_status := str(bot_loadouts[bot_index].get("outside_status", "cabinet"))
	return outside_status == "cabinet" or outside_status == "returned"

func load_selected_cartridge_into_bot(bot_index: int) -> bool:
	return load_cartridge_into_bot(bot_index, selected_cartridge_id)

func load_cartridge_into_bot(bot_index: int, cartridge_id: String) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	if not is_bot_available_in_workshop(bot_index):
		return false

	if cartridge_id.is_empty():
		return false

	var selected_index := _get_programmed_cartridge_index(cartridge_id)
	if selected_index == -1:
		return false
	var selected: Dictionary = programmed_cartridges[selected_index]
	if str(selected.get("location", "")) != "shelf":
		return false

	var existing_loaded := get_bot_loaded_cartridge(bot_index)
	if not existing_loaded.is_empty():
		var existing_index := _get_programmed_cartridge_index(str(existing_loaded.get("id", "")))
		if existing_index != -1:
			programmed_cartridges[existing_index]["location"] = "shelf"

	programmed_cartridges[selected_index]["location"] = "bot:%d" % bot_index
	programmed_cartridges[selected_index]["use_count"] = int(programmed_cartridges[selected_index].get("use_count", 0)) + 1
	bot_loadouts[bot_index]["loaded_cartridge_id"] = cartridge_id
	if selected_cartridge_id == cartridge_id:
		selected_cartridge_id = ""
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.cartridge_selected.emit(selected_cartridge_id)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func unload_bot_cartridge(bot_index: int) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	if not is_bot_available_in_workshop(bot_index):
		return false

	var loaded := get_bot_loaded_cartridge(bot_index)
	if loaded.is_empty():
		return false
	var loaded_index := _get_programmed_cartridge_index(str(loaded.get("id", "")))
	if loaded_index == -1:
		return false

	programmed_cartridges[loaded_index]["location"] = "shelf"
	bot_loadouts[bot_index]["loaded_cartridge_id"] = ""
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func install_power_unit(bot_index: int) -> int:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return -1
	if not is_bot_available_in_workshop(bot_index):
		return -1

	var current_energy := int(bot_loadouts[bot_index].get("power_charge", 0))
	var max_power_charge := int(bot_loadouts[bot_index].get("max_power_charge", BOT_POWER_CAPACITY))
	if current_energy >= max_power_charge:
		return current_energy
	var slot_index := _get_first_charged_power_unit_slot_index()
	if slot_index == -1:
		return -1

	var power_unit: Dictionary = power_unit_slots[slot_index]
	bot_loadouts[bot_index]["power_charge"] = int(bot_loadouts[bot_index].get("power_charge", 0)) + int(power_unit.get("charge", max_power_charge))
	bot_loadouts[bot_index]["power_card_count"] = int(bot_loadouts[bot_index].get("power_card_count", 0)) + 1
	bot_loadouts[bot_index]["installed_power_slot_index"] = -1
	power_unit_slots[slot_index] = {}
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return int(bot_loadouts[bot_index].get("power_charge", 0))

func install_power_unit_from_slot(bot_index: int, slot_index: int) -> int:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return -1
	if not is_bot_available_in_workshop(bot_index):
		return -1
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return -1
	var power_unit: Dictionary = power_unit_slots[slot_index]
	if power_unit.is_empty():
		return -1
	if int(power_unit.get("charge", 0)) <= 0:
		return -1
	var added_charge := int(power_unit.get("charge", BOT_POWER_CAPACITY))
	bot_loadouts[bot_index]["power_charge"] = int(bot_loadouts[bot_index].get("power_charge", 0)) + added_charge
	bot_loadouts[bot_index]["power_card_count"] = int(bot_loadouts[bot_index].get("power_card_count", 0)) + 1
	bot_loadouts[bot_index]["installed_power_slot_index"] = -1
	power_unit_slots[slot_index] = {}
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return int(bot_loadouts[bot_index].get("power_charge", 0))

func remove_power_unit(bot_index: int) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	if not is_bot_available_in_workshop(bot_index):
		return false
	return false

func get_bot_loaded_cartridge(bot_index: int) -> Dictionary:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return {}
	var cartridge_id := str(bot_loadouts[bot_index].get("loaded_cartridge_id", ""))
	if cartridge_id.is_empty():
		return {}
	for cartridge in programmed_cartridges:
		if str(cartridge.get("id", "")) == cartridge_id:
			return cartridge
	return {}

func get_bot_launch_blocker(bot_index: int) -> String:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return "Invalid bot"
	var bot: Dictionary = bot_loadouts[bot_index]
	if not is_bot_available_in_workshop(bot_index):
		return "Bot is already outside"
	if get_bot_loaded_cartridge(bot_index).is_empty():
		return "No cartridge loaded"
	if int(bot.get("power_charge", 0)) <= 0:
		return "No power unit installed"
	return ""

func launch_bot(bot_index: int) -> bool:
	var blocker := get_bot_launch_blocker(bot_index)
	if not blocker.is_empty():
		return false

	var shelter := get_shelter_position()
	bot_loadouts[bot_index]["outside_status"] = "active"
	bot_loadouts[bot_index]["outside_position"] = shelter
	bot_loadouts[bot_index]["outside_facing"] = START_FACING
	bot_loadouts[bot_index]["outside_acc"] = 0
	bot_loadouts[bot_index]["outside_ptr"] = 0
	bot_loadouts[bot_index]["outside_trail"] = [shelter]
	bot_loadouts[bot_index]["pending_discovery_ids"] = []
	bot_loadouts[bot_index]["last_mission_summary"] = ""
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return true

func tick_active_bots() -> bool:
	var changed := false
	for bot_index in range(bot_loadouts.size()):
		if str(bot_loadouts[bot_index].get("outside_status", "cabinet")) != "active":
			continue
		var previous_status := str(bot_loadouts[bot_index].get("outside_status", "active"))
		if _step_active_bot(bot_index):
			changed = true
			var current_status := str(bot_loadouts[bot_index].get("outside_status", "active"))
			if current_status != previous_status and current_status != "active":
				var summary := str(bot_loadouts[bot_index].get("last_mission_summary", ""))
				EventBus.log_message.emit(summary if not summary.is_empty() else "%s %s" % [_bot_display_name(bot_index), current_status])
	if changed:
		_refresh_bot_predictions()
		save_programmed_cartridges()
		EventBus.bot_loadouts_changed.emit(bot_loadouts)
		EventBus.outside_world_changed.emit()
	return changed

func can_recover_bot(bot_index: int) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	var status := str(bot_loadouts[bot_index].get("outside_status", "cabinet"))
	return status == "halted" or status == "stranded"

func recover_bot(bot_index: int) -> bool:
	if not can_recover_bot(bot_index):
		return false
	var bot_state: Dictionary = bot_loadouts[bot_index]
	bot_state["outside_position"] = get_shelter_position()
	var trail: Array = bot_state.get("outside_trail", []).duplicate()
	if trail.is_empty() or trail[-1] != get_shelter_position():
		trail.append(get_shelter_position())
	bot_state["outside_trail"] = trail
	_set_terminal_status(bot_state, "halted")
	bot_loadouts[bot_index] = bot_state
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	EventBus.log_message.emit("Dangerous recovery completed: %s" % str(bot_state.get("last_mission_summary", _bot_display_name(bot_index))))
	return true

func get_active_or_away_bots() -> Array:
	var bots: Array = []
	for bot in bot_loadouts:
		var status := str(bot.get("outside_status", "cabinet"))
		if status != "cabinet":
			bots.append(bot)
	return bots

func get_discovered_outside_objects() -> Array:
	var discovered: Array = []
	for object_entry in outside_objects:
		if bool(object_entry.get("discovered", false)):
			discovered.append(object_entry)
	return discovered

func load_programmed_cartridges():
	programmed_cartridges.clear()
	_initialize_blank_slots()
	_initialize_power_unit_slots()
	selected_cartridge_id = ""
	_initialize_bot_loadouts()
	_initialize_outside_objects()
	if not FileAccess.file_exists(CARTRIDGE_STORAGE_PATH):
		_refresh_bot_predictions()
		return

	var file := FileAccess.open(CARTRIDGE_STORAGE_PATH, FileAccess.READ)
	if file == null:
		_refresh_bot_predictions()
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_refresh_bot_predictions()
		return

	var cartridges_data: Array = parsed.get("cartridges", [])
	if typeof(cartridges_data) == TYPE_ARRAY:
		var fallback_slot_index := 0
		for entry in cartridges_data:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var normalized: Dictionary = {
				"id": str(entry.get("id", "")),
				"label": str(entry.get("label", get_default_cartridge_label())),
				"rows": _duplicate_rows(entry.get("rows", [])),
				"slot_index": int(entry.get("slot_index", fallback_slot_index)),
				"location": str(entry.get("location", "shelf")),
				"use_count": int(entry.get("use_count", 0)),
				"wear": float(entry.get("wear", 0.0)),
				"saved_at": int(entry.get("saved_at", 0)),
			}
			if not normalized["id"].is_empty():
				programmed_cartridges.append(normalized)
				fallback_slot_index += 1

	var blank_data: Array = parsed.get("blank_cartridge_slots", [])
	if typeof(blank_data) == TYPE_ARRAY:
		for blank_index in range(mini(blank_data.size(), blank_cartridge_slots.size())):
			blank_cartridge_slots[blank_index] = bool(blank_data[blank_index])
	var power_data: Array = parsed.get("power_unit_slots", [])
	if typeof(power_data) == TYPE_ARRAY:
		for power_index in range(mini(power_data.size(), power_unit_slots.size())):
			var power_entry: Variant = power_data[power_index]
			if typeof(power_entry) == TYPE_DICTIONARY:
				var saved_max_charge := int(power_entry.get("max_charge", BOT_POWER_CAPACITY))
				var normalized_charge := int(power_entry.get("charge", BOT_POWER_CAPACITY))
				if saved_max_charge < BOT_POWER_CAPACITY:
					saved_max_charge = BOT_POWER_CAPACITY
					normalized_charge = BOT_POWER_CAPACITY
				if normalized_charge > 0:
					power_unit_slots[power_index] = {
						"id": str(power_entry.get("id", "power_unit_%d" % power_index)),
						"charge": normalized_charge,
						"max_charge": saved_max_charge,
					}
				else:
					power_unit_slots[power_index] = {}
			else:
				power_unit_slots[power_index] = {}

	selected_cartridge_id = str(parsed.get("selected_cartridge_id", ""))

	var bot_data: Array = parsed.get("bot_loadouts", [])
	if typeof(bot_data) == TYPE_ARRAY:
		for bot_index in range(mini(bot_data.size(), bot_loadouts.size())):
			var bot_entry: Variant = bot_data[bot_index]
			if typeof(bot_entry) != TYPE_DICTIONARY:
				continue
			_apply_saved_bot_entry(bot_index, bot_entry)

	var object_data: Array = parsed.get("outside_objects", [])
	if typeof(object_data) == TYPE_ARRAY:
		_apply_saved_outside_objects(object_data)

	for bot_index in range(bot_loadouts.size()):
		var loaded_id := str(bot_loadouts[bot_index].get("loaded_cartridge_id", ""))
		if loaded_id.is_empty():
			continue
		var loaded_index := _get_programmed_cartridge_index(loaded_id)
		if loaded_index != -1:
			var status := str(bot_loadouts[bot_index].get("outside_status", "cabinet"))
			programmed_cartridges[loaded_index]["location"] = "shelf" if status == "cabinet" else "bot:%d" % bot_index

	if get_selected_cartridge().is_empty():
		selected_cartridge_id = ""
		for cartridge in programmed_cartridges:
			if str(cartridge.get("location", "")) == "shelf":
				selected_cartridge_id = str(cartridge.get("id", ""))
				break

	_refresh_bot_predictions()

func save_programmed_cartridges():
	var file := FileAccess.open(CARTRIDGE_STORAGE_PATH, FileAccess.WRITE)
	if file == null:
		return

	var data := {
		"selected_cartridge_id": selected_cartridge_id,
		"cartridges": programmed_cartridges,
		"blank_cartridge_slots": blank_cartridge_slots,
		"power_unit_slots": power_unit_slots,
		"bot_loadouts": _serialize_bot_loadouts(),
		"outside_objects": _serialize_outside_objects(),
	}
	file.store_string(JSON.stringify(data))

func _duplicate_rows(rows: Array) -> Array:
	var normalized: Array = []
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		normalized.append({
			"bits": str(row.get("bits", "")),
			"index": int(row.get("index", 0)),
		})
	return normalized

func _initialize_bot_loadouts():
	bot_loadouts.clear()
	for bot_index in range(BOT_CABINET_CAPACITY):
		bot_loadouts.append(_default_bot_state(bot_index))

func _default_bot_state(bot_index: int) -> Dictionary:
	return {
		"id": "cabinet_a%d" % [bot_index + 1],
		"drone_type": "spider" if bot_index == 0 else "butterfly",
		"loaded_cartridge_id": "",
		"power_charge": 0,
		"power_card_count": 0,
		"max_power_charge": BOT_POWER_CAPACITY,
		"installed_power_slot_index": -1,
		"outside_status": "cabinet",
		"outside_position": get_shelter_position(),
		"outside_facing": START_FACING,
		"outside_acc": 0,
		"outside_ptr": 0,
		"outside_trail": [],
		"predicted_trail": [],
		"pending_discovery_ids": [],
		"last_mission_summary": "",
	}

func _initialize_blank_slots():
	blank_cartridge_slots.clear()
	for _slot_index in range(BLANK_CARTRIDGE_SLOT_COUNT):
		blank_cartridge_slots.append(true)

func _initialize_power_unit_slots():
	power_unit_slots.clear()
	for slot_index in range(POWER_UNIT_SLOT_COUNT):
		power_unit_slots.append({
			"id": "power_unit_%d" % slot_index,
			"charge": BOT_POWER_CAPACITY,
			"max_charge": BOT_POWER_CAPACITY,
		})

func _initialize_outside_objects():
	outside_objects = [
		{"id": "supply_cache", "type": "resource", "position": Vector2(2, 3), "discovered": false},
		{"id": "rust_pit", "type": "hazard", "position": Vector2(8, 2), "discovered": false},
		{"id": "old_tower", "type": "landmark", "position": Vector2(8, 8), "discovered": false},
		{"id": "watch_arc", "type": "surveillance", "position": Vector2(3, 8), "discovered": false},
	]

func _get_next_program_number() -> int:
	var max_number := 0
	for cartridge in programmed_cartridges:
		var label := str(cartridge.get("label", ""))
		if label.begins_with("Tape "):
			var value := label.substr(5).to_int()
			max_number = maxi(max_number, value)
	return max_number + 1

func _get_programmed_cartridge_index(cartridge_id: String) -> int:
	for cartridge_index in range(programmed_cartridges.size()):
		if str(programmed_cartridges[cartridge_index].get("id", "")) == cartridge_id:
			return cartridge_index
	return -1

func _get_first_blank_slot_index() -> int:
	for slot_index in range(blank_cartridge_slots.size()):
		if bool(blank_cartridge_slots[slot_index]):
			return slot_index
	return -1

func _get_first_empty_blank_slot_index() -> int:
	for slot_index in range(blank_cartridge_slots.size()):
		if not bool(blank_cartridge_slots[slot_index]):
			return slot_index
	return -1

func _get_first_free_programmed_slot_index() -> int:
	for slot_index in range(PROGRAMMED_CARTRIDGE_CAPACITY):
		var occupied := false
		for cartridge in programmed_cartridges:
			if int(cartridge.get("slot_index", -1)) == slot_index:
				occupied = true
				break
		if not occupied:
			return slot_index
	return -1

func _decode_program_from_rows(rows: Array) -> Array:
	var decoded_rows: Dictionary = PunchEncodingData.decode_rows(rows)
	var program_lines: Array = decoded_rows.get("program_lines", [])
	if program_lines.is_empty():
		return []
	var decoder = TapeDecoderData.new()
	return decoder.decode_tape("\n".join(program_lines))

func _step_active_bot(bot_index: int) -> bool:
	var program := _decode_program_from_rows(get_bot_loaded_cartridge(bot_index).get("rows", []))
	if program.is_empty():
		_set_terminal_status(bot_loadouts[bot_index], "halted")
		return true

	var bot_state: Dictionary = bot_loadouts[bot_index]
	if int(bot_state.get("outside_ptr", 0)) >= program.size():
		_set_terminal_status(bot_loadouts[bot_index], "halted")
		return true

	var execution_result := _execute_instruction_on_state(bot_state, program, true)
	bot_loadouts[bot_index] = execution_result["state"]
	return bool(execution_result["changed"])

func _execute_instruction_on_state(source_state: Dictionary, program: Array, discover_objects: bool) -> Dictionary:
	var state: Dictionary = source_state.duplicate(true)
	var changed := false
	var pointer := int(state.get("outside_ptr", 0))
	if pointer < 0 or pointer >= program.size():
		_set_terminal_status(state, "halted")
		return {"state": state, "changed": true}

	var instruction: Dictionary = program[pointer]
	var instruction_type := str(instruction.get("type", ""))
	var instruction_arg := int(instruction.get("arg", 0))
	state["outside_ptr"] = pointer + 1
	changed = true

	match instruction_type:
		"nop":
			pass
		"mov":
			var remaining_energy := int(state.get("power_charge", 0))
			if remaining_energy <= 0:
				_set_terminal_status(state, "stranded")
			else:
				remaining_energy -= 1
				state["power_charge"] = remaining_energy
				_sync_power_card_count(state)
				var direction := _get_direction_vector(str(state.get("outside_facing", START_FACING)))
				var new_position := Vector2(state.get("outside_position", get_shelter_position())) + direction
				if _is_inside_grid(new_position):
					state["outside_position"] = new_position
					var trail: Array = state.get("outside_trail", []).duplicate()
					if trail.is_empty() or trail[-1] != new_position:
						trail.append(new_position)
					state["outside_trail"] = trail
				if remaining_energy <= 0:
					_set_terminal_status(state, "stranded")
		"scn":
			if discover_objects:
				_queue_discovery_for_state(state, Vector2(state.get("outside_position", get_shelter_position())) + _get_direction_vector(str(state.get("outside_facing", START_FACING))))
		"pck":
			pass
		"drp":
			pass
		"chg":
			state["power_charge"] = mini(int(state.get("power_charge", 0)) + 1, int(state.get("max_power_charge", BOT_POWER_CAPACITY)))
			_sync_power_card_count(state)
		"jmp":
			state["outside_ptr"] = instruction_arg
		"jnz":
			if int(state.get("outside_acc", 0)) != 0:
				state["outside_ptr"] = instruction_arg
		"dec":
			state["outside_acc"] = int(state.get("outside_acc", 0)) - 1
		"inc":
			state["outside_acc"] = int(state.get("outside_acc", 0)) + 1
		"set":
			state["outside_acc"] = instruction_arg
		"out":
			pass
		"die":
			_set_terminal_status(state, "halted")
		"rot":
			state["outside_facing"] = _rotate_facing(str(state.get("outside_facing", START_FACING)), instruction_arg)
		_:
			_set_terminal_status(state, "halted")

	if str(state.get("outside_status", "active")) == "active" and int(state.get("outside_ptr", 0)) >= program.size():
		_set_terminal_status(state, "halted")

	return {"state": state, "changed": changed}

func _set_terminal_status(state: Dictionary, terminal_status: String):
	var position := Vector2(state.get("outside_position", get_shelter_position()))
	if terminal_status != "stranded" and position == get_shelter_position():
		var discoveries := _commit_pending_discoveries(state)
		state["outside_status"] = "returned"
		state["last_mission_summary"] = _build_mission_summary(state, "returned", discoveries)
	else:
		state["outside_status"] = terminal_status
		state["last_mission_summary"] = _build_mission_summary(state, terminal_status, 0)

func _bot_display_name(bot_index: int) -> String:
	match bot_index:
		0:
			return "Spider drone"
		1:
			return "Butterfly drone"
		_:
			return "Bot %d" % [bot_index + 1]

func _refresh_bot_predictions():
	for bot_index in range(bot_loadouts.size()):
		bot_loadouts[bot_index]["predicted_trail"] = _predict_bot_trail(bot_index)

func _predict_bot_trail(bot_index: int) -> Array:
	var program := _decode_program_from_rows(get_bot_loaded_cartridge(bot_index).get("rows", []))
	if program.is_empty():
		return []

	var status := str(bot_loadouts[bot_index].get("outside_status", "cabinet"))
	var simulation_state: Dictionary = bot_loadouts[bot_index].duplicate(true)
	if status == "cabinet" or status == "returned":
		simulation_state["outside_status"] = "active"
		simulation_state["outside_position"] = get_shelter_position()
		simulation_state["outside_facing"] = START_FACING
		simulation_state["outside_acc"] = 0
		simulation_state["outside_ptr"] = 0
		simulation_state["outside_trail"] = [get_shelter_position()]

	if str(simulation_state.get("outside_status", "active")) != "active":
		return []

	var starting_trail: Array = simulation_state.get("outside_trail", []).duplicate()
	for _step_index in range(MAX_PREDICTION_STEPS):
		var result := _execute_instruction_on_state(simulation_state, program, false)
		simulation_state = result["state"]
		if str(simulation_state.get("outside_status", "active")) != "active":
			break
		if int(simulation_state.get("outside_ptr", 0)) >= program.size():
			break

	var predicted_trail: Array = simulation_state.get("outside_trail", []).duplicate()
	if not starting_trail.is_empty():
		for _remove_index in range(starting_trail.size()):
			if predicted_trail.is_empty():
				break
			predicted_trail.pop_front()
	return predicted_trail

func _get_direction_vector(facing: String) -> Vector2:
	match facing:
		"north":
			return Vector2(0, -1)
		"south":
			return Vector2(0, 1)
		"east":
			return Vector2(1, 0)
		"west":
			return Vector2(-1, 0)
		"northeast":
			return Vector2(1, -1)
		"southeast":
			return Vector2(1, 1)
		"southwest":
			return Vector2(-1, 1)
		"northwest":
			return Vector2(-1, -1)
		_:
			return Vector2.ZERO

func _rotate_facing(facing: String, amount: int) -> String:
	var facings := ["north", "northeast", "east", "southeast", "south", "southwest", "west", "northwest"]
	var current_index := facings.find(facing)
	if current_index == -1:
		current_index = 0
	return facings[posmod(current_index + amount, facings.size())]

func _is_inside_grid(position: Vector2) -> bool:
	return position.x >= 0 and position.x < grid_size.x and position.y >= 0 and position.y < grid_size.y

func _discover_at(position: Vector2):
	for object_index in range(outside_objects.size()):
		var object_entry: Dictionary = outside_objects[object_index]
		if Vector2(object_entry.get("position", Vector2(-1, -1))) != position:
			continue
		if bool(object_entry.get("discovered", false)):
			return
		outside_objects[object_index]["discovered"] = true
		return

func _queue_discovery_for_state(state: Dictionary, position: Vector2):
	for object_entry in outside_objects:
		if Vector2(object_entry.get("position", Vector2(-1, -1))) != position:
			continue
		if bool(object_entry.get("discovered", false)):
			return
		var object_id := str(object_entry.get("id", ""))
		if object_id.is_empty():
			return
		var pending_ids: Array = state.get("pending_discovery_ids", []).duplicate()
		if not pending_ids.has(object_id):
			pending_ids.append(object_id)
		state["pending_discovery_ids"] = pending_ids
		return

func _commit_pending_discoveries(state: Dictionary) -> int:
	var pending_ids: Array = state.get("pending_discovery_ids", []).duplicate()
	var discoveries := 0
	for object_id in pending_ids:
		for object_index in range(outside_objects.size()):
			var object_entry: Dictionary = outside_objects[object_index]
			if str(object_entry.get("id", "")) != str(object_id):
				continue
			if not bool(object_entry.get("discovered", false)):
				outside_objects[object_index]["discovered"] = true
				discoveries += 1
			break
	state["pending_discovery_ids"] = []
	return discoveries

func _build_mission_summary(state: Dictionary, status: String, discoveries: int) -> String:
	var bot_name := _bot_display_name(_get_bot_index_from_state(state))
	match status:
		"returned":
			if discoveries > 0:
				var noun := "discovery" if discoveries == 1 else "discoveries"
				return "%s returned with %d new %s" % [bot_name, discoveries, noun]
			return "%s returned with no new discoveries" % bot_name
		"stranded":
			return "%s stranded in the field" % bot_name
		"halted":
			return "%s halted in the field" % bot_name
		_:
			return "%s %s" % [bot_name, status]

func _get_bot_index_from_state(state: Dictionary) -> int:
	var bot_id := str(state.get("id", ""))
	for bot_index in range(bot_loadouts.size()):
		if str(bot_loadouts[bot_index].get("id", "")) == bot_id:
			return bot_index
	return -1

func _apply_saved_bot_entry(bot_index: int, bot_entry: Dictionary):
	bot_loadouts[bot_index]["loaded_cartridge_id"] = str(bot_entry.get("loaded_cartridge_id", ""))
	var saved_power_charge := int(bot_entry.get("power_charge", bot_entry.get("wound_energy", 0)))
	var saved_max_power := int(bot_entry.get("max_power_charge", bot_entry.get("max_wound_energy", BOT_POWER_CAPACITY)))
	if saved_max_power < BOT_POWER_CAPACITY and saved_power_charge > 0:
		saved_power_charge = BOT_POWER_CAPACITY
	saved_max_power = maxi(saved_max_power, BOT_POWER_CAPACITY)
	bot_loadouts[bot_index]["power_charge"] = saved_power_charge
	bot_loadouts[bot_index]["power_card_count"] = maxi(int(bot_entry.get("power_card_count", ceili(float(saved_power_charge) / float(BOT_POWER_CAPACITY)))), 0)
	bot_loadouts[bot_index]["max_power_charge"] = saved_max_power
	bot_loadouts[bot_index]["installed_power_slot_index"] = int(bot_entry.get("installed_power_slot_index", -1))
	bot_loadouts[bot_index]["outside_status"] = str(bot_entry.get("outside_status", "cabinet"))
	bot_loadouts[bot_index]["outside_position"] = _vector_from_variant(bot_entry.get("outside_position", {}), get_shelter_position())
	bot_loadouts[bot_index]["outside_facing"] = str(bot_entry.get("outside_facing", START_FACING))
	bot_loadouts[bot_index]["outside_acc"] = int(bot_entry.get("outside_acc", 0))
	bot_loadouts[bot_index]["outside_ptr"] = int(bot_entry.get("outside_ptr", 0))
	bot_loadouts[bot_index]["outside_trail"] = _vector_array_from_variant(bot_entry.get("outside_trail", []))
	bot_loadouts[bot_index]["predicted_trail"] = _vector_array_from_variant(bot_entry.get("predicted_trail", []))
	bot_loadouts[bot_index]["pending_discovery_ids"] = bot_entry.get("pending_discovery_ids", []).duplicate()
	bot_loadouts[bot_index]["last_mission_summary"] = str(bot_entry.get("last_mission_summary", ""))
	_sync_power_card_count(bot_loadouts[bot_index])

func _apply_saved_outside_objects(object_data: Array):
	var defaults := {}
	for object_entry in outside_objects:
		defaults[str(object_entry.get("id", ""))] = object_entry
	for entry in object_data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var object_id := str(entry.get("id", ""))
		if not defaults.has(object_id):
			continue
		var target: Dictionary = defaults[object_id]
		target["type"] = str(entry.get("type", target.get("type", "")))
		target["position"] = _vector_from_variant(entry.get("position", {}), Vector2(target.get("position", get_shelter_position())))
		target["discovered"] = bool(entry.get("discovered", false))
		defaults[object_id] = target
	outside_objects.clear()
	for key in defaults.keys():
		outside_objects.append(defaults[key])

func _serialize_bot_loadouts() -> Array:
	var data: Array = []
	for bot in bot_loadouts:
		data.append({
			"id": str(bot.get("id", "")),
			"drone_type": str(bot.get("drone_type", "")),
			"loaded_cartridge_id": str(bot.get("loaded_cartridge_id", "")),
			"power_charge": int(bot.get("power_charge", 0)),
			"power_card_count": int(bot.get("power_card_count", 0)),
			"max_power_charge": int(bot.get("max_power_charge", BOT_POWER_CAPACITY)),
			"installed_power_slot_index": int(bot.get("installed_power_slot_index", -1)),
			"outside_status": str(bot.get("outside_status", "cabinet")),
			"outside_position": _serialize_vector(Vector2(bot.get("outside_position", get_shelter_position()))),
			"outside_facing": str(bot.get("outside_facing", START_FACING)),
			"outside_acc": int(bot.get("outside_acc", 0)),
			"outside_ptr": int(bot.get("outside_ptr", 0)),
			"outside_trail": _serialize_vector_array(bot.get("outside_trail", [])),
			"predicted_trail": _serialize_vector_array(bot.get("predicted_trail", [])),
			"pending_discovery_ids": bot.get("pending_discovery_ids", []).duplicate(),
			"last_mission_summary": str(bot.get("last_mission_summary", "")),
		})
	return data

func _serialize_outside_objects() -> Array:
	var data: Array = []
	for object_entry in outside_objects:
		data.append({
			"id": str(object_entry.get("id", "")),
			"type": str(object_entry.get("type", "")),
			"position": _serialize_vector(Vector2(object_entry.get("position", Vector2.ZERO))),
			"discovered": bool(object_entry.get("discovered", false)),
		})
	return data

func _serialize_vector(vector: Vector2) -> Dictionary:
	return {"x": int(vector.x), "y": int(vector.y)}

func _serialize_vector_array(vectors: Array) -> Array:
	var data: Array = []
	for vector in vectors:
		data.append(_serialize_vector(Vector2(vector)))
	return data

func _vector_from_variant(value: Variant, fallback: Vector2) -> Vector2:
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(int(value.get("x", fallback.x)), int(value.get("y", fallback.y)))
	if value is Vector2:
		return value
	return fallback

func _vector_array_from_variant(value: Variant) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		result.append(_vector_from_variant(entry, get_shelter_position()))
	return result

func _sync_power_card_count(state: Dictionary):
	var power_charge := int(state.get("power_charge", 0))
	if power_charge <= 0:
		state["power_card_count"] = 0
		return
	state["power_card_count"] = maxi(ceili(float(power_charge) / float(BOT_POWER_CAPACITY)), 1)

func _get_first_charged_power_unit_slot_index() -> int:
	for slot_index in range(power_unit_slots.size()):
		if is_power_unit_charged(slot_index):
			return slot_index
	return -1

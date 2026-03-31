extends RefCounted

class_name WorkshopEnemyProcesses

static func get_card_interaction_target(
	cards: Array,
	enemy_id: String,
	enemy_rect: Rect2,
	has_meaningful_overlap: Callable,
	get_target_id: Callable,
	is_locked_by_active_process: Callable,
	get_action: Callable,
	get_target_name: Callable
) -> Dictionary:
	for card_index in range(cards.size() - 1, -1, -1):
		var card_info: Dictionary = Dictionary(cards[card_index])
		var kind := str(card_info.get("kind", ""))
		if kind in ["enemy", "operator", "bot", "dog", "bench_card", "route_card", "charge_card", "journal_card", "trash_card"]:
			continue
		if kind == "enemy" and str(card_info.get("enemy_id", "")) == enemy_id:
			continue
		var card_rect := Rect2(card_info.get("rect", Rect2()))
		if not bool(has_meaningful_overlap.call(enemy_rect, card_rect, 0.18)):
			continue
		var target_identifier = get_target_id.call(kind, card_info)
		if target_identifier == null:
			continue
		if kind in ["location", "material", "blueprint", "mechanism", "structure", "equipment"] and bool(is_locked_by_active_process.call(kind, target_identifier)):
			continue
		var action := str(get_action.call(kind))
		if action.is_empty():
			continue
		return {
			"target_kind": kind,
			"target_id": target_identifier,
			"target_name": str(get_target_name.call(kind, card_info)),
			"target_rect": card_rect,
			"action": action,
		}
	return {}

static func get_card_interaction_action(kind: String) -> String:
	match kind:
		"material", "blueprint", "equipment", "cartridge", "blank":
			return "steal"
		"location", "mechanism", "structure":
			return "destroy"
	return ""

static func get_card_interaction_target_id(kind: String, card_info: Dictionary):
	match kind:
		"location":
			return str(card_info.get("location_id", ""))
		"material":
			return str(card_info.get("material_id", ""))
		"blueprint":
			return str(card_info.get("blueprint_id", ""))
		"mechanism":
			return str(card_info.get("mechanism_id", ""))
		"structure":
			return str(card_info.get("structure_id", ""))
		"equipment":
			return str(card_info.get("equipment_id", ""))
		"cartridge":
			return str(card_info.get("cartridge_id", ""))
		"blank":
			return int(card_info.get("blank_index", -1))
	return null

static func get_card_interaction_target_name(kind: String, card_info: Dictionary) -> String:
	var card_data: Dictionary = Dictionary(card_info.get("card_data", {}))
	match kind:
		"material", "blueprint", "mechanism", "structure", "location", "equipment":
			var display_name := str(card_data.get("display_name", card_data.get("result", card_data.get("type", ""))))
			if not display_name.is_empty():
				return display_name.replace("_", " ").to_upper()
		"cartridge":
			var label := str(card_info.get("label", "")).strip_edges()
			return label if not label.is_empty() else "PROGRAMMED TAPE"
		"blank":
			return "BLANK TAPE"
	return kind.replace("_", " ").to_upper()

static func wander_position_is_clear(
	enemy_id: String,
	candidate_rect: Rect2,
	machine_cards: Dictionary,
	table_visual_cards: Array,
	has_meaningful_overlap: Callable
) -> bool:
	for machine_key in ["bench_rect", "route_rect", "charge_rect", "journal_rect", "trash_rect"]:
		if bool(has_meaningful_overlap.call(candidate_rect, Rect2(machine_cards.get(machine_key, Rect2())), 0.08)):
			return false
	for card_info_variant in table_visual_cards:
		if typeof(card_info_variant) != TYPE_DICTIONARY:
			continue
		var card_info: Dictionary = Dictionary(card_info_variant)
		var kind := str(card_info.get("kind", ""))
		if kind == "enemy" and str(card_info.get("enemy_id", "")) == enemy_id:
			continue
		if not bool(has_meaningful_overlap.call(candidate_rect, Rect2(card_info.get("rect", Rect2())), 0.08)):
			continue
		if kind in ["operator", "bot", "dog", "material", "blueprint", "equipment", "cartridge", "blank", "location", "mechanism", "structure"]:
			continue
		return false
	return true

static func get_fight_states(
	enemy_cards: Array,
	enemy_positions: Dictionary,
	default_position: Vector2,
	operator_position: Vector2,
	card_size: Vector2,
	drones: Array,
	dogs: Array,
	fight_cooldowns: Dictionary,
	fight_interval: float,
	has_meaningful_overlap: Callable
) -> Dictionary:
	var next_cooldowns := fight_cooldowns.duplicate(true)
	var states: Array = []
	var operator_rect := Rect2(operator_position, card_size)
	for enemy_card_variant in enemy_cards:
		if typeof(enemy_card_variant) != TYPE_DICTIONARY:
			continue
		var enemy_card: Dictionary = Dictionary(enemy_card_variant)
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		var enemy_rect := Rect2(Vector2(enemy_positions.get(enemy_id, default_position)), card_size)
		var use_operator := bool(has_meaningful_overlap.call(enemy_rect, operator_rect, 0.30))
		var bot_indices: Array = []
		var dog_ids: Array = []
		for drone_slot_variant in drones:
			var drone_slot: Dictionary = Dictionary(drone_slot_variant)
			if not bool(drone_slot.get("available_in_workshop", false)):
				continue
			if int(drone_slot.get("power_charge", 0)) <= 0:
				continue
			if bool(has_meaningful_overlap.call(enemy_rect, Rect2(drone_slot.get("rect", Rect2())), 0.30)):
				bot_indices.append(int(drone_slot.get("index", -1)))
		for dog_slot_variant in dogs:
			var dog_slot: Dictionary = Dictionary(dog_slot_variant)
			var dog_card: Dictionary = Dictionary(dog_slot.get("card_data", {}))
			if int(dog_card.get("energy", 0)) <= 0:
				continue
			if int(dog_card.get("hp", 0)) <= 0:
				continue
			if str(dog_card.get("status", "active")) == "dead":
				continue
			if bool(has_meaningful_overlap.call(enemy_rect, Rect2(dog_slot.get("rect", Rect2())), 0.30)):
				dog_ids.append(str(dog_slot.get("dog_id", "")))
		if not use_operator and bot_indices.is_empty() and dog_ids.is_empty():
			next_cooldowns.erase(enemy_id)
			continue
		if not next_cooldowns.has(enemy_id):
			next_cooldowns[enemy_id] = fight_interval
		states.append({
			"enemy_id": enemy_id,
			"rect": enemy_rect,
			"use_operator": use_operator,
			"bot_indices": bot_indices,
			"dog_ids": dog_ids,
		})
	return {
		"states": states,
		"cooldowns": next_cooldowns,
	}

static func emit_fight_feedback(
	enemy_id: String,
	fight_info: Dictionary,
	result: Dictionary,
	get_table_card_center: Callable,
	trigger_attack_feedback: Callable,
	trigger_damage_feedback: Callable
) -> void:
	var enemy_center := Vector2(get_table_card_center.call("enemy", enemy_id))
	if bool(fight_info.get("use_operator", false)):
		var operator_center := Vector2(get_table_card_center.call("operator", 0))
		trigger_attack_feedback.call("operator", 0, enemy_center - operator_center, int(result.get("operator_attack", 0)))
		trigger_damage_feedback.call("operator", 0, int(result.get("operator_damage", 0)))
	for bot_attack_variant in Array(result.get("bot_attacks", [])):
		var attack_entry: Dictionary = Dictionary(bot_attack_variant)
		var bot_index := int(attack_entry.get("bot_index", -1))
		if bot_index == -1:
			continue
		var bot_center := Vector2(get_table_card_center.call("bot", bot_index))
		trigger_attack_feedback.call("bot", bot_index, enemy_center - bot_center, int(attack_entry.get("attack", 0)))
	for bot_damage_variant in Array(result.get("bot_damage", [])):
		var damage_entry: Dictionary = Dictionary(bot_damage_variant)
		trigger_damage_feedback.call("bot", int(damage_entry.get("bot_index", -1)), int(damage_entry.get("damage", 0)))
	for dog_attack_variant in Array(result.get("dog_attacks", [])):
		var dog_attack_entry: Dictionary = Dictionary(dog_attack_variant)
		var dog_id := str(dog_attack_entry.get("dog_id", ""))
		if dog_id.is_empty():
			continue
		var dog_center := Vector2(get_table_card_center.call("dog", dog_id))
		trigger_attack_feedback.call("dog", dog_id, enemy_center - dog_center, int(dog_attack_entry.get("attack", 0)))
	for dog_damage_variant in Array(result.get("dog_damage", [])):
		var dog_damage_entry: Dictionary = Dictionary(dog_damage_variant)
		trigger_damage_feedback.call("dog", str(dog_damage_entry.get("dog_id", "")), int(dog_damage_entry.get("damage", 0)))
	trigger_damage_feedback.call("enemy", enemy_id, int(result.get("total_attack", 0)))

static func get_card_interaction_states(
	enemy_cards: Array,
	enemy_positions: Dictionary,
	default_position: Vector2,
	card_size: Vector2,
	active_fight_states: Array,
	interaction_cooldowns: Dictionary,
	interaction_interval: float,
	is_card_locked_by_active_process: Callable,
	is_dragging_table_card: Callable,
	get_card_interaction_target: Callable
) -> Dictionary:
	var active_fight_enemy_ids := {}
	for fight_info_variant in active_fight_states:
		if typeof(fight_info_variant) != TYPE_DICTIONARY:
			continue
		var fight_info: Dictionary = Dictionary(fight_info_variant)
		var fight_enemy_id := str(fight_info.get("enemy_id", ""))
		if fight_enemy_id.is_empty():
			continue
		active_fight_enemy_ids[fight_enemy_id] = true
	var next_cooldowns := interaction_cooldowns.duplicate(true)
	var states: Array = []
	for enemy_card_variant in enemy_cards:
		if typeof(enemy_card_variant) != TYPE_DICTIONARY:
			continue
		var enemy_card: Dictionary = Dictionary(enemy_card_variant)
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		if active_fight_enemy_ids.has(enemy_id):
			next_cooldowns.erase(enemy_id)
			continue
		if bool(is_card_locked_by_active_process.call("enemy", enemy_id)):
			next_cooldowns.erase(enemy_id)
			continue
		if bool(is_dragging_table_card.call("enemy", enemy_id)):
			next_cooldowns.erase(enemy_id)
			continue
		var enemy_rect := Rect2(Vector2(enemy_positions.get(enemy_id, default_position)), card_size)
		var interaction_target: Dictionary = Dictionary(get_card_interaction_target.call(enemy_id, enemy_rect))
		if interaction_target.is_empty():
			next_cooldowns.erase(enemy_id)
			continue
		if not next_cooldowns.has(enemy_id):
			next_cooldowns[enemy_id] = interaction_interval
		interaction_target["enemy_id"] = enemy_id
		interaction_target["enemy_name"] = str(enemy_card.get("display_name", "Hostile"))
		interaction_target["rect"] = enemy_rect
		states.append(interaction_target)
	return {
		"states": states,
		"cooldowns": next_cooldowns,
	}

static func get_wander_candidates(
	enemy_cards: Array,
	enemy_positions: Dictionary,
	default_position: Vector2,
	card_size: Vector2,
	active_fight_states: Array,
	active_interaction_states: Array,
	wander_cooldowns: Dictionary,
	wander_interval: float,
	is_card_locked_by_active_process: Callable,
	is_dragging_table_card: Callable
) -> Dictionary:
	var active_fight_enemy_ids := {}
	for fight_info_variant in active_fight_states:
		if typeof(fight_info_variant) != TYPE_DICTIONARY:
			continue
		var fight_info: Dictionary = Dictionary(fight_info_variant)
		var fight_enemy_id := str(fight_info.get("enemy_id", ""))
		if fight_enemy_id.is_empty():
			continue
		active_fight_enemy_ids[fight_enemy_id] = true
	var active_interaction_enemy_ids := {}
	for interaction_info_variant in active_interaction_states:
		if typeof(interaction_info_variant) != TYPE_DICTIONARY:
			continue
		var interaction_info: Dictionary = Dictionary(interaction_info_variant)
		var interaction_enemy_id := str(interaction_info.get("enemy_id", ""))
		if interaction_enemy_id.is_empty():
			continue
		active_interaction_enemy_ids[interaction_enemy_id] = true
	var next_cooldowns := wander_cooldowns.duplicate(true)
	var candidates: Array = []
	for enemy_card_variant in enemy_cards:
		if typeof(enemy_card_variant) != TYPE_DICTIONARY:
			continue
		var enemy_card: Dictionary = Dictionary(enemy_card_variant)
		var enemy_id := str(enemy_card.get("id", ""))
		if enemy_id.is_empty():
			continue
		if active_fight_enemy_ids.has(enemy_id):
			next_cooldowns.erase(enemy_id)
			continue
		if active_interaction_enemy_ids.has(enemy_id):
			next_cooldowns.erase(enemy_id)
			continue
		if bool(is_card_locked_by_active_process.call("enemy", enemy_id)):
			next_cooldowns.erase(enemy_id)
			continue
		if bool(is_dragging_table_card.call("enemy", enemy_id)):
			next_cooldowns.erase(enemy_id)
			continue
		var enemy_rect := Rect2(Vector2(enemy_positions.get(enemy_id, default_position)), card_size)
		if not next_cooldowns.has(enemy_id):
			next_cooldowns[enemy_id] = wander_interval
		candidates.append({
			"enemy_id": enemy_id,
			"rect": enemy_rect,
		})
	return {
		"candidates": candidates,
		"cooldowns": next_cooldowns,
	}

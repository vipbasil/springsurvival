extends RefCounted

class_name WorkshopCombatRuntime

static func build_enemy_fight_leak_updates(result: Dictionary, fight_info: Dictionary) -> Dictionary:
	var leak_updates := {
		"noise": 8.0,
	}
	if str(result.get("enemy_type", "")) in ["surveillance_drone", "infantry_drone", "warden"]:
		leak_updates["heat"] = 2.0
	if not Array(fight_info.get("bot_indices", [])).is_empty() or bool(fight_info.get("use_operator", false)):
		leak_updates["trace"] = 1.0
	return leak_updates

static func build_enemy_fight_outcome(
	result: Dictionary,
	fight_info: Dictionary,
	enemy_positions: Dictionary,
	dog_positions: Dictionary,
	default_position: Vector2,
	card_size: Vector2,
	get_state_table_card_layout_key: Callable
) -> Dictionary:
	var enemy_id := str(fight_info.get("enemy_id", ""))
	var outcome := {
		"enemy_id": enemy_id,
		"enemy_removed": false,
		"enemy_drop_id": "",
		"enemy_drop_name": "",
		"enemy_drop_rect": Rect2(fight_info.get("rect", Rect2())),
		"enemy_message": "",
		"dog_outcomes": [],
	}
	if bool(result.get("defeated", false)):
		var drop_card: Dictionary = Dictionary(result.get("drop_card", {}))
		outcome["enemy_removed"] = true
		outcome["enemy_drop_id"] = str(drop_card.get("id", ""))
		outcome["enemy_drop_name"] = str(drop_card.get("display_name", "Material"))
		outcome["enemy_message"] = "%s defeated" % str(result.get("enemy_name", "Hostile"))
	else:
		outcome["enemy_message"] = "%s fought back" % str(result.get("enemy_name", "Hostile"))
	for dog_drop_variant in Array(result.get("dog_drops", [])):
		if typeof(dog_drop_variant) != TYPE_DICTIONARY:
			continue
		var dog_drop: Dictionary = Dictionary(dog_drop_variant)
		var fallen_dog_id := str(dog_drop.get("dog_id", ""))
		var dog_drop_card: Dictionary = Dictionary(dog_drop.get("drop_card", {}))
		var dog_rect := Rect2(Vector2(dog_positions.get(fallen_dog_id, default_position)), card_size)
		outcome["dog_outcomes"].append({
			"dog_id": fallen_dog_id,
			"dog_name": str(dog_drop.get("display_name", "DOG")),
			"drop_id": str(dog_drop_card.get("id", "")),
			"drop_name": str(dog_drop_card.get("display_name", "Material")),
			"drop_rect": dog_rect,
			"layout_key": str(get_state_table_card_layout_key.call("dog", fallen_dog_id)),
		})
	return outcome

static func resolve_enemy_card_interaction(
	interaction_info: Dictionary,
	table_cartridge_positions: Dictionary,
	table_blank_positions: Dictionary,
	forget_state_table_card: Callable,
	discard_programmed_cartridge: Callable,
	discard_blank_cartridge: Callable,
	clear_workshop_card_position: Callable
) -> Dictionary:
	var enemy_id := str(interaction_info.get("enemy_id", ""))
	var action := str(interaction_info.get("action", ""))
	var target_kind := str(interaction_info.get("target_kind", ""))
	var target_id = interaction_info.get("target_id", null)
	var result := {
		"ok": false,
		"enemy_id": enemy_id,
		"action": action,
		"enemy_name": str(interaction_info.get("enemy_name", "Hostile")),
		"target_name": str(interaction_info.get("target_name", "Card")),
		"target_rect": Rect2(interaction_info.get("target_rect", Rect2())),
		"table_cartridge_positions": table_cartridge_positions.duplicate(true),
		"table_blank_positions": table_blank_positions.duplicate(true),
	}
	if enemy_id.is_empty() or action.is_empty() or target_kind.is_empty() or target_id == null:
		return result
	var success := false
	match target_kind:
		"cartridge":
			var cartridge_id := str(target_id)
			success = bool(discard_programmed_cartridge.call(cartridge_id))
			if success:
				Dictionary(result["table_cartridge_positions"]).erase(cartridge_id)
				clear_workshop_card_position.call("cartridge_%s" % cartridge_id)
		"blank":
			var blank_index := int(target_id)
			success = bool(discard_blank_cartridge.call(blank_index))
			if success:
				for stored_blank_index in Dictionary(result["table_blank_positions"]).keys():
					clear_workshop_card_position.call("blank_%d" % int(stored_blank_index))
				result["table_blank_positions"] = {}
		_:
			success = bool(forget_state_table_card.call(target_kind, str(target_id)))
	if not success:
		return result
	result["ok"] = true
	result["action_label"] = "STOLEN" if action == "steal" else "DESTROYED"
	result["log_message"] = "%s %s %s" % [
		str(result.get("enemy_name", "Hostile")),
		"stole" if action == "steal" else "destroyed",
		str(result.get("target_name", "Card"))
	]
	return result

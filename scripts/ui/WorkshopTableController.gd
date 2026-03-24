extends RefCounted

class_name WorkshopTableController

const CONTROL_CARD_KINDS := {
	"bench_card": true,
	"route_card": true,
	"charge_card": true,
	"journal_card": true,
	"trash_card": true,
	"operator": true,
}

static func get_top_tape_badge_at_point(drone_slots: Array, root_point: Vector2) -> Dictionary:
	var sorted_slots := drone_slots.duplicate()
	sorted_slots.sort_custom(func(a: Dictionary, b: Dictionary): return Rect2(a["rect"]).end.y > Rect2(b["rect"]).end.y)
	for slot in sorted_slots:
		if Rect2(slot["tape_badge_rect"]).has_point(root_point) and not Dictionary(slot["loaded_cartridge"]).is_empty():
			return slot
	return {}

static func get_top_table_card_at_point(cards: Array, root_point: Vector2) -> Dictionary:
	for card_index in range(cards.size() - 1, -1, -1):
		var card_info: Dictionary = cards[card_index]
		if Rect2(card_info["rect"]).has_point(root_point):
			return card_info
	return {}

static func is_dragging_table_card(active_drag: Dictionary, kind: String, identifier) -> bool:
	if active_drag.is_empty():
		return false
	if str(active_drag.get("kind", "")) != kind:
		return false
	match kind:
		"cartridge":
			return str(active_drag.get("identifier", active_drag.get("cartridge_id", ""))) == str(identifier)
		"power":
			return int(active_drag.get("identifier", active_drag.get("slot_index", -1))) == int(identifier)
		"blank":
			return int(active_drag.get("identifier", active_drag.get("blank_index", -1))) == int(identifier)
		"bot":
			return int(active_drag.get("identifier", active_drag.get("bot_index", -1))) == int(identifier)
		"location":
			return str(active_drag.get("identifier", active_drag.get("location_id", ""))) == str(identifier)
		"enemy":
			return str(active_drag.get("identifier", active_drag.get("enemy_id", ""))) == str(identifier)
		"material":
			return str(active_drag.get("identifier", active_drag.get("material_id", ""))) == str(identifier)
		"blueprint":
			return str(active_drag.get("identifier", active_drag.get("blueprint_id", ""))) == str(identifier)
		"crafted":
			return str(active_drag.get("identifier", active_drag.get("crafted_id", ""))) == str(identifier)
		"equipment":
			return str(active_drag.get("identifier", active_drag.get("equipment_id", ""))) == str(identifier)
		_:
			return CONTROL_CARD_KINDS.has(kind)

static func build_badge_drag_state(root_point: Vector2, badge_hit: Dictionary) -> Dictionary:
	var bot_index := int(badge_hit.get("index", -1))
	var loaded_cartridge: Dictionary = badge_hit.get("loaded_cartridge", {})
	var badge_rect := Rect2(badge_hit.get("tape_badge_rect", Rect2()))
	if bot_index == -1 or loaded_cartridge.is_empty() or badge_rect == Rect2():
		return {}
	return {
		"kind": "cartridge",
		"identifier": str(loaded_cartridge.get("id", "")),
		"source": "bot",
		"bot_index": bot_index,
		"cartridge_id": str(loaded_cartridge.get("id", "")),
		"rect": badge_rect,
		"drag_start_root": root_point,
		"drag_pickup_offset": Vector2(18.0, 24.0),
	}

static func build_top_card_drag_state(root_point: Vector2, top_card: Dictionary) -> Dictionary:
	var kind := str(top_card.get("kind", ""))
	var rect := Rect2(top_card.get("rect", Rect2()))
	if kind.is_empty() or rect == Rect2():
		return {}
	var base := {
		"kind": kind,
		"rect": rect,
		"drag_start_root": root_point,
		"drag_pickup_offset": root_point - rect.position,
	}
	match kind:
		"cartridge":
			var cartridge_id := str(top_card.get("cartridge_id", ""))
			if cartridge_id.is_empty():
				return {}
			base["identifier"] = cartridge_id
			base["source"] = "table"
			base["cartridge_id"] = cartridge_id
		"blank":
			var blank_index := int(top_card.get("blank_index", -1))
			base["identifier"] = blank_index
			base["blank_index"] = blank_index
		"power":
			var slot_index := int(top_card.get("slot_index", -1))
			base["identifier"] = slot_index
			base["source"] = "table"
			base["slot_index"] = slot_index
		"location", "enemy", "material", "blueprint", "crafted", "equipment":
			var card_id := str(top_card.get("%s_id" % kind, ""))
			if card_id.is_empty():
				return {}
			base["identifier"] = card_id
			base["%s_id" % kind] = card_id
			base["card_data"] = Dictionary(top_card.get("card_data", {}))
		"bot":
			var bot_index2 := int(top_card.get("bot_index", -1))
			base["identifier"] = bot_index2
			base["bot_index"] = bot_index2
		"bench_card", "route_card", "charge_card", "journal_card", "operator", "trash_card":
			pass
		_:
			return {}
	return base

static func is_valid_drop_target(active_drag: Dictionary, drop_rect: Rect2, options: Dictionary) -> bool:
	match str(active_drag.get("kind", "")):
		"cartridge":
			return bool(options.get("has_drop_drone", false)) or bool(options.get("in_tape_hand", false)) or bool(options.get("in_recycle_zone", false))
		"power":
			return bool(options.get("has_drop_drone", false)) or bool(options.get("in_charge_machine", false)) or bool(options.get("in_table_workspace", false)) or bool(options.get("in_recycle_zone", false))
		"location", "material", "blueprint", "equipment":
			return bool(options.get("in_table_workspace", false)) or bool(options.get("in_recycle_zone", false))
		"crafted":
			return bool(options.get("in_table_workspace", false)) or bool(options.get("in_recycle_zone", false)) or bool(options.get("overlaps_operator", false))
		"bot", "blank", "operator", "enemy":
			return bool(options.get("in_table_workspace", false)) or bool(options.get("in_route_machine", false))
		"bench_card", "route_card", "charge_card", "trash_card":
			return bool(options.get("in_table_workspace", false))
	return false

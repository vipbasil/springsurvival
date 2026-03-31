extends RefCounted

class_name WorkshopStorageRuntime

static func get_structure_card_by_id(structure_cards: Array, card_id: String) -> Dictionary:
	if card_id.is_empty():
		return {}
	for structure_card_variant in structure_cards:
		if typeof(structure_card_variant) != TYPE_DICTIONARY:
			continue
		var structure_card: Dictionary = Dictionary(structure_card_variant)
		if str(structure_card.get("id", "")) == card_id:
			return structure_card
	return {}

static func build_storage_overlay_model(
	container_card: Dictionary,
	stored_entries: Array,
	page_rect: Rect2,
	page_index: int,
	page_size: int
) -> Dictionary:
	var left_rect := Rect2(page_rect.position + Vector2(24.0, 58.0), Vector2(180.0, page_rect.size.y - 96.0))
	var right_rect := Rect2(page_rect.position + Vector2(226.0, 58.0), Vector2(page_rect.size.x - 250.0, page_rect.size.y - 96.0))
	var preview_rect := Rect2(left_rect.position, Vector2(140.0, 172.0))
	var page_count := maxi(int(ceili(float(stored_entries.size()) / float(page_size))), 1)
	var clamped_page_index := clampi(page_index, 0, page_count - 1)
	var start_index := clamped_page_index * page_size
	var end_index := mini(start_index + page_size, stored_entries.size())
	var row_y := right_rect.position.y
	var rows: Array = []
	for entry_index in range(start_index, end_index):
		var entry: Dictionary = Dictionary(stored_entries[entry_index])
		var row_rect := Rect2(Vector2(right_rect.position.x, row_y), Vector2(right_rect.size.x, 34.0))
		var label := str(entry.get("display_name", entry.get("result", "ITEM"))).to_upper()
		if str(entry.get("kind", "")) == "material":
			label = "%s  x%d" % [label, maxi(int(entry.get("quantity", 1)), 1)]
		elif not Dictionary(entry.get("captive_enemy", {})).is_empty():
			label = "%s [%s]" % [label, str(Dictionary(entry.get("captive_enemy", {})).get("display_name", "CAGED")).to_upper()]
		rows.append({
			"rect": row_rect,
			"entry_id": str(entry.get("entry_id", "")),
			"label": label,
		})
		row_y += 40.0
	var prev_rect := Rect2()
	if clamped_page_index > 0:
		prev_rect = Rect2(Vector2(page_rect.position.x + 16.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
	var next_rect := Rect2()
	if clamped_page_index < page_count - 1:
		next_rect = Rect2(Vector2(page_rect.end.x - 56.0, page_rect.end.y - 34.0), Vector2(24.0, 18.0))
	return {
		"title": str(container_card.get("display_name", container_card.get("result", "STORAGE"))).to_upper(),
		"left_rect": left_rect,
		"right_rect": right_rect,
		"preview_rect": preview_rect,
		"stored_count": stored_entries.size(),
		"page_count": page_count,
		"page_index": clamped_page_index,
		"rows": rows,
		"prev_rect": prev_rect,
		"next_rect": next_rect,
	}

static func get_storage_target(
	table_cards: Array,
	source_kind: String,
	source_id: String,
	drop_rect: Rect2,
	has_meaningful_overlap: Callable,
	is_storage_crafted_card: Callable,
	is_tool_chest_crafted_card: Callable
) -> Dictionary:
	for card_info_variant in table_cards:
		if typeof(card_info_variant) != TYPE_DICTIONARY:
			continue
		var card_info: Dictionary = Dictionary(card_info_variant)
		if str(card_info.get("kind", "")) != "structure":
			continue
		var crafted_id := str(card_info.get("structure_id", ""))
		if crafted_id.is_empty() or crafted_id == source_id:
			continue
		if not bool(is_storage_crafted_card.call(crafted_id)):
			continue
		if bool(is_tool_chest_crafted_card.call(crafted_id)) and source_kind not in ["material", "structure", "blueprint", "equipment"]:
			continue
		if bool(has_meaningful_overlap.call(Rect2(card_info.get("rect", Rect2())), drop_rect, 0.30)):
			return card_info
	return {}

static func place_withdrawn_storage_card(
	withdrawn: Dictionary,
	source_rect: Rect2,
	place_location: Callable,
	place_material: Callable,
	place_dog: Callable,
	place_mechanism: Callable,
	place_structure: Callable,
	place_blueprint: Callable,
	place_equipment: Callable
) -> void:
	var withdrawn_kind := str(withdrawn.get("kind", ""))
	var withdrawn_id := str(withdrawn.get("id", ""))
	if withdrawn_id.is_empty():
		return
	match withdrawn_kind:
		"location":
			place_location.call(withdrawn_id, source_rect)
		"material":
			place_material.call(withdrawn_id, source_rect)
		"dog":
			place_dog.call(withdrawn_id, source_rect)
		"mechanism":
			place_mechanism.call(withdrawn_id, source_rect)
		"structure":
			place_structure.call(withdrawn_id, source_rect)
		"blueprint":
			place_blueprint.call(withdrawn_id, source_rect)
		"equipment":
			place_equipment.call(withdrawn_id, source_rect)

static func handle_storage_modal_click(
	root_point: Vector2,
	overlay_rect: Rect2,
	close_rect: Rect2,
	prev_rect: Rect2,
	next_rect: Rect2,
	item_click_rects: Array,
	page_index: int,
	container_id: String,
	page_size: int,
	fallback_container_rect: Rect2,
	get_crafted_storage_contents: Callable,
	withdraw_crafted_storage_item: Callable,
	place_withdrawn_storage_card: Callable
) -> Dictionary:
	var result := {
		"storage_open": true,
		"storage_page_index": page_index,
		"clear_click_rects": false,
		"log_message": "",
	}
	if close_rect.has_point(root_point) or not overlay_rect.has_point(root_point):
		result["storage_open"] = false
		result["clear_click_rects"] = true
		return result
	if prev_rect.has_point(root_point):
		result["storage_page_index"] = maxi(page_index - 1, 0)
		return result
	if next_rect.has_point(root_point):
		var stored_entries := Array(get_crafted_storage_contents.call(container_id))
		var page_count := maxi(int(ceili(float(stored_entries.size()) / float(page_size))), 1)
		result["storage_page_index"] = mini(page_index + 1, page_count - 1)
		return result
	for click_info_variant in item_click_rects:
		if typeof(click_info_variant) != TYPE_DICTIONARY:
			continue
		var click_info: Dictionary = Dictionary(click_info_variant)
		var item_rect := Rect2(click_info.get("rect", Rect2()))
		if not item_rect.has_point(root_point):
			continue
		var withdrawn: Dictionary = Dictionary(withdraw_crafted_storage_item.call(container_id, str(click_info.get("entry_id", ""))))
		if withdrawn.is_empty():
			return result
		place_withdrawn_storage_card.call(withdrawn, fallback_container_rect)
		result["log_message"] = "%s withdrawn" % str(withdrawn.get("display_name", withdrawn.get("result", "Stored item")))
		return result
	return result

extends RefCounted

class_name JournalCrossrefs

static func get_recipe_related_subject_keys(recipe: Dictionary) -> Array:
	var related_keys: Array[String] = []
	var owner_subject_key := str(recipe.get("subject_key", ""))
	if not owner_subject_key.is_empty():
		related_keys.append(owner_subject_key)
	var result_subject_key := get_named_subject_key(str(recipe.get("result", "")))
	if not result_subject_key.is_empty():
		related_keys.append(result_subject_key)
	for part_variant in Array(recipe.get("formula_parts", [])):
		var part_subject_key := get_formula_part_subject_key(str(part_variant))
		if not part_subject_key.is_empty():
			related_keys.append(part_subject_key)
	return dedupe_strings(related_keys)

static func get_formula_part_subject_key(part: String) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return ""
	var quantity_marker := normalized.to_lower().rfind(" x")
	if quantity_marker != -1:
		normalized = normalized.substr(0, quantity_marker).strip_edges()
	return get_named_subject_key(normalized)

static func get_named_subject_key(token: String) -> String:
	match token.strip_edges().to_upper():
		"METAL":
			return "material_metal"
		"SPRING":
			return "material_spring"
		"PAPER":
			return "material_paper"
		"FIBER":
			return "material_fiber"
		"BIOMASS":
			return "material_biomass"
		"DRY RATIONS":
			return "material_dry_rations"
		"MEDICINE":
			return "material_medicine"
		"GROWTH MEDIUM":
			return "material_growth_medium"
		"MUSHROOMS":
			return "material_mushrooms"
		"ALGAE":
			return "material_algae"
		"BACTERIA":
			return "material_bacteria"
		"MEALWORMS":
			return "material_mealworms"
		"BONE MEAL":
			return "material_bone_meal"
		"HIDE":
			return "material_hide"
		"BONE":
			return "material_bone"
		"POND":
			return "location_pond"
		"CRATER":
			return "location_crater"
		"TOWER":
			return "location_tower"
		"SURVEILLANCE ZONE":
			return "location_surveillance_zone"
		"FACILITY":
			return "location_facility"
		"BUNKER":
			return "location_bunker"
		"FIELD":
			return "location_field"
		"DUMP":
			return "location_dump"
		"CACHE":
			return "location_cache"
		"NEST":
			return "location_nest"
		"RUIN":
			return "location_ruin"
		"SURVEILLANCE DRONE":
			return "enemy_surveillance_drone"
		"INFANTRY DRONE":
			return "enemy_infantry_drone"
		"STALKER":
			return "enemy_stalker"
		"GRIZZLY":
			return "enemy_grizzly"
		"WOLF PACK":
			return "enemy_wolf_pack"
		"WARDEN":
			return "enemy_warden"
		"BENCH":
			return "machine_bench"
		"ROUTE TABLE":
			return "machine_route"
		"CHARGE MACHINE":
			return "machine_charge"
		"TRASH":
			return "machine_trash"
		"SPIDER DRONE":
			return "drone_spider"
		"BUTTERFLY DRONE":
			return "drone_butterfly"
		"PROGRAMMED TAPE":
			return "tape_programmed"
		"BLANK TAPE":
			return "tape_blank"
		"POWER UNIT", "SPRING CHARGE":
			return "material_power_unit"
		"KNIFE":
			return "equipment_knife"
		"BOW":
			return "equipment_bow"
		"PLATE MAIL":
			return "equipment_plate_mail"
		"HIDE CLOAK":
			return "equipment_hide_cloak"
		"TOOL KIT":
			return "equipment_tool_kit"
		"TANK":
			return "mechanism_tank"
		"LEAK DETECTOR":
			return "mechanism_leak_detector"
		"TOOL CHEST":
			return "structure_tool_chest"
		"BROOD CAGE":
			return "structure_brood_cage"
		"ARCHIVE SHELF":
			return "structure_archive_shelf"
		_:
			return ""

static func dedupe_strings(values: Array) -> Array:
	var unique := {}
	var result: Array = []
	for value_variant in values:
		var value := str(value_variant)
		if value.is_empty() or unique.has(value):
			continue
		unique[value] = true
		result.append(value)
	return result

extends RefCounted

class_name TankProcessRules

const PROCESS_SPECS := {
	"fiber_cycle": {
		"recipe_result": "FIBER",
		"culture_type": "algae",
		"feed_type": "growth_medium",
		"result_type": "fiber",
		"display_name": "Fiber",
		"quantity": 1,
		"duration": 36.0,
		"feed_consumed": false,
	},
	"medicine_cycle": {
		"recipe_result": "MEDICINE",
		"culture_type": "bacteria",
		"feed_type": "biomass",
		"result_type": "medicine",
		"display_name": "Medicine",
		"quantity": 1,
		"duration": 54.0,
		"feed_consumed": true,
	},
	"rations_cycle": {
		"recipe_result": "DRY RATIONS",
		"culture_type": "mealworms",
		"feed_type": "biomass",
		"result_type": "dry_rations",
		"display_name": "Dry Rations",
		"quantity": 1,
		"duration": 18.0,
		"feed_consumed": true,
	},
	"biomass_cycle": {
		"recipe_result": "BIOMASS",
		"culture_type": "mushrooms",
		"feed_type": "growth_medium",
		"result_type": "biomass",
		"display_name": "Biomass",
		"quantity": 1,
		"duration": 36.0,
		"feed_consumed": false,
	},
}

const RECIPE_RESULT_TO_PROCESS := {
	"FIBER": "fiber_cycle",
	"MEDICINE": "medicine_cycle",
	"DRY RATIONS": "rations_cycle",
	"BIOMASS": "biomass_cycle",
}

const CULTURE_TYPES := ["algae", "bacteria", "mealworms", "mushrooms"]
const FEED_TYPES := ["growth_medium", "biomass"]
const LEGACY_PROCESS_IDS := {
	"algae_to_fiber": "fiber_cycle",
	"bacteria_to_medicine": "medicine_cycle",
	"mealworms_to_rations": "rations_cycle",
}

static func process_specs() -> Dictionary:
	return PROCESS_SPECS.duplicate(true)

static func default_slots() -> Dictionary:
	return {
		"culture": {},
		"feed": {},
		"recipe": {},
	}

static func normalize_slots(entry: Dictionary) -> Dictionary:
	var slots := default_slots()
	if entry.is_empty():
		return slots
	slots["culture"] = Dictionary(entry.get("culture", {})).duplicate(true)
	slots["feed"] = Dictionary(entry.get("feed", {})).duplicate(true)
	slots["recipe"] = Dictionary(entry.get("recipe", {})).duplicate(true)
	return slots

static func normalize_batch(entry: Dictionary, default_duration: float) -> Dictionary:
	if entry.is_empty():
		return {}
	var process_id := normalize_process_id(str(entry.get("process_id", "")))
	if process_id.is_empty():
		return {}
	var spec := spec_for_process_id(process_id)
	if spec.is_empty():
		return {}
	var duration := maxf(float(entry.get("duration", default_duration)), 0.1)
	var ends_at := float(entry.get("ends_at", 0.0))
	if ends_at <= 0.0:
		ends_at = float(Time.get_unix_time_from_system()) + duration
	return {
		"process_id": process_id,
		"result_type": str(entry.get("result_type", spec.get("result_type", ""))),
		"display_name": str(entry.get("display_name", spec.get("display_name", "Tank Batch"))),
		"quantity": maxi(int(entry.get("quantity", int(spec.get("quantity", 1)))), 1),
		"duration": duration,
		"ends_at": ends_at,
	}

static func normalize_process_id(process_id: String) -> String:
	var normalized := process_id.strip_edges()
	if normalized.is_empty():
		return ""
	return str(LEGACY_PROCESS_IDS.get(normalized, normalized))

static func is_tank_recipe_result(recipe_result: String) -> bool:
	return RECIPE_RESULT_TO_PROCESS.has(recipe_result.strip_edges().to_upper())

static func process_id_for_recipe_result(recipe_result: String) -> String:
	return str(RECIPE_RESULT_TO_PROCESS.get(recipe_result.strip_edges().to_upper(), ""))

static func spec_for_process_id(process_id: String) -> Dictionary:
	var normalized := normalize_process_id(process_id)
	if normalized.is_empty():
		return {}
	return Dictionary(PROCESS_SPECS.get(normalized, {})).duplicate(true)

static func slot_name_for_material(material_type: String) -> String:
	var normalized := material_type.strip_edges().to_lower()
	if normalized in CULTURE_TYPES:
		return "culture"
	if normalized in FEED_TYPES:
		return "feed"
	return ""

static func process_spec_for_slots(tank_slots: Dictionary) -> Dictionary:
	var slots := normalize_slots(tank_slots)
	var culture_card: Dictionary = Dictionary(slots.get("culture", {}))
	var feed_card: Dictionary = Dictionary(slots.get("feed", {}))
	var recipe_card: Dictionary = Dictionary(slots.get("recipe", {}))
	if culture_card.is_empty() or feed_card.is_empty() or recipe_card.is_empty():
		return {}
	if maxi(int(feed_card.get("quantity", 0)), 0) <= 0:
		return {}
	var process_id := process_id_for_recipe_result(str(recipe_card.get("result", "")))
	if process_id.is_empty():
		return {}
	var spec := spec_for_process_id(process_id)
	if spec.is_empty():
		return {}
	if str(culture_card.get("type", "")) != str(spec.get("culture_type", "")):
		return {}
	if str(feed_card.get("type", "")) != str(spec.get("feed_type", "")):
		return {}
	spec["process_id"] = process_id
	return spec

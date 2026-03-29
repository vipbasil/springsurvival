extends Node

const PunchEncodingData = preload("res://scripts/data/PunchEncoding.gd")
const TapeDecoderData = preload("res://scripts/data/TapeDecoder.gd")

const RECIPE_CATALOG_PATH := "res://resources/instructions/recipes.json"
const ENEMY_LOOT_CATALOG_PATH := "res://resources/instructions/enemy_loot.json"
const START_POSITION := Vector2(5, 5)
const START_FACING := "north"
const SHELTER_MARKER := "shelter"
const CARTRIDGE_STORAGE_PATH := "user://programmed_cartridges.json"
const PROGRAMMED_CARTRIDGE_CAPACITY := 8
const BLANK_CARTRIDGE_SLOT_COUNT := 4
const BOT_POWER_CAPACITY := 200
const CHARGE_MACHINE_TRANSFER_UNITS := 50
const UNIT_EQUIPMENT_SLOT_COUNT := 3
const OPERATOR_MAX_ENERGY := 12
const OPERATOR_MAX_HP := 6
const DOG_MAX_ENERGY := 8
const DOG_MAX_HP := 5
const DOG_BASE_ATTACK := 2
const DOG_BASE_ARMOR := 0
const CHARGE_WORK_COST := 2
const MAX_PREDICTION_STEPS := 64
const TANK_PROCESS_DEFAULT_DURATION := 18.0
const LOCATION_NAME_CORPUS := [
	"watchtower",
	"waystation",
	"relay",
	"bunker",
	"spillway",
	"scrapyard",
	"redoubt",
	"reservoir",
	"glassfield",
	"ironbank",
	"drywell",
	"coldpit",
	"brinepond",
	"windcut",
	"crateredge",
	"foundry",
	"longditch",
	"underpass",
	"nestfield",
	"vaultgate",
]
const RESEARCH_MATERIAL_TYPES := ["metal", "spring", "paper", "fiber", "biomass", "dry_rations", "medicine", "growth_medium", "mushrooms", "algae", "bacteria", "mealworms", "bone_meal", "hide", "bone", "power_unit"]
const RESEARCH_LOCATION_TYPES := ["pond", "crater", "tower", "surveillance_zone", "facility", "bunker", "field", "dump", "cache", "nest", "ruin"]
const RESEARCH_ENEMY_TYPES := ["surveillance_drone", "infantry_drone", "stalker", "grizzly", "wolf_pack", "warden"]
const RESEARCH_MACHINE_TYPES := ["bench", "route", "charge", "trash"]
const START_BOT_TYPES := ["spider", "butterfly"]
const RESEARCH_TAPE_TYPES := ["programmed", "blank"]
const RESEARCH_RESOURCE_TYPES: Array[String] = []
const RESEARCH_EQUIPMENT_TYPES := ["knife", "bow", "plate_mail", "hide_cloak", "tool_kit"]
const RESEARCH_CRAFTED_TYPES := ["tool_chest", "brood_cage", "archive_shelf"]
const RESEARCH_MECHANISM_TYPES := ["tank"]
const START_OPERATOR_PROFILES := [
	{
		"id": "lera",
		"name": "OP. LERA",
		"focus": "MECH / ARCHIVE",
		"summary": "Balanced mechanic with a cleaner start on paper, tapes, and workshop handling.",
		"starting_equipment": "tool_kit",
		"extra_materials": [{"type": "paper", "quantity": 1}],
		"known_subjects": ["material_paper"],
	},
	{
		"id": "mira",
		"name": "OP. MIRA",
		"focus": "BIO / SURVEY",
		"summary": "Stealth-biased surveyor with better early biomass and substrate intuition.",
		"starting_equipment": "hide_cloak",
		"extra_materials": [{"type": "biomass", "quantity": 1}, {"type": "fiber", "quantity": 1}],
		"known_subjects": ["material_mushrooms"],
	},
	{
		"id": "dren",
		"name": "OP. DREN",
		"focus": "SALVAGE / SECURITY",
		"summary": "Harder salvage start with better metal handling and rough hostile containment prep.",
		"starting_equipment": "knife",
		"extra_materials": [{"type": "metal", "quantity": 1}],
		"known_subjects": ["material_metal", "structure_tool_chest", "structure_brood_cage"],
	},
]
const STARTER_DISCOVERED_SUBJECT_KEYS := ["location_field", "location_pond", "material_fiber", "material_biomass"]

const ENEMY_TYPE_DEFS := {
	"grizzly": {
		"label": "Grizzly",
		"attack": 4,
		"hp": 7,
		"threat_level": 4,
	},
	"infantry_drone": {
		"label": "Infantry Drone",
		"attack": 3,
		"hp": 5,
		"armor": 1,
		"threat_level": 3,
	},
	"stalker": {
		"label": "Stalker",
		"attack": 2,
		"hp": 4,
		"threat_level": 2,
	},
	"surveillance_drone": {
		"label": "Surveillance Drone",
		"attack": 1,
		"hp": 3,
		"threat_level": 1,
	},
	"warden": {
		"label": "Warden",
		"attack": 6,
		"hp": 12,
		"armor": 4,
		"threat_level": 6,
	},
	"wolf_pack": {
		"label": "Wolf Pack",
		"attack": 2,
		"hp": 4,
		"threat_level": 2,
	},
}
const LOCATION_SCAVENGE_TABLES := {
	"pond": [
		{"kind": "material", "type": "biomass", "weight": 45, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "algae", "weight": 35, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "mushrooms", "weight": 20, "quantity_min": 1, "quantity_max": 1},
	],
	"crater": [
		{"kind": "material", "type": "metal", "weight": 45, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "bone", "weight": 30, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "biomass", "weight": 25, "quantity_min": 1, "quantity_max": 1},
	],
	"tower": [
		{"kind": "material", "type": "metal", "weight": 35, "quantity_min": 1, "quantity_max": 2},
		{"kind": "power", "weight": 20},
		{"kind": "equipment", "type": "knife", "result": "KNIFE", "display_name": "Knife", "weight": 15},
		{"kind": "equipment", "type": "bow", "result": "BOW", "display_name": "Bow", "weight": 15},
		{"kind": "equipment", "type": "plate_mail", "result": "PLATE MAIL", "display_name": "Plate Mail", "weight": 15},
	],
	"surveillance_zone": [
		{"kind": "material", "type": "metal", "weight": 55, "quantity_min": 1, "quantity_max": 2},
		{"kind": "power", "weight": 35},
		{"kind": "equipment", "type": "bow", "result": "BOW", "display_name": "Bow", "weight": 10},
	],
	"facility": [
		{"kind": "material", "type": "metal", "weight": 35, "quantity_min": 1, "quantity_max": 3},
		{"kind": "power", "weight": 20},
		{"kind": "material", "type": "dry_rations", "weight": 20, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "mushrooms", "weight": 15, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "algae", "weight": 10, "quantity_min": 1, "quantity_max": 1},
	],
	"bunker": [
		{"kind": "material", "type": "paper", "weight": 18, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "metal", "weight": 18, "quantity_min": 1, "quantity_max": 2},
		{"kind": "power", "weight": 14},
		{"kind": "material", "type": "medicine", "weight": 10, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "dry_rations", "weight": 10, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "mushrooms", "weight": 8, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "algae", "weight": 6, "quantity_min": 1, "quantity_max": 1},
		{"kind": "equipment", "type": "knife", "result": "KNIFE", "display_name": "Knife", "weight": 6},
		{"kind": "equipment", "type": "bow", "result": "BOW", "display_name": "Bow", "weight": 4},
		{"kind": "equipment", "type": "plate_mail", "result": "PLATE MAIL", "display_name": "Plate Mail", "weight": 4},
		{"kind": "equipment", "type": "tool_kit", "result": "TOOL KIT", "display_name": "Tool Kit", "weight": 2},
	],
	"field": [
		{"kind": "material", "type": "biomass", "weight": 55, "quantity_min": 1, "quantity_max": 3},
		{"kind": "material", "type": "fiber", "weight": 25, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "hide", "weight": 15, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "mushrooms", "weight": 5, "quantity_min": 1, "quantity_max": 1},
	],
	"dump": [
		{"kind": "material", "type": "metal", "weight": 35, "quantity_min": 1, "quantity_max": 3},
		{"kind": "material", "type": "fiber", "weight": 18, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "bone", "weight": 15, "quantity_min": 1, "quantity_max": 2},
		{"kind": "power", "weight": 12},
		{"kind": "equipment", "type": "knife", "result": "KNIFE", "display_name": "Knife", "weight": 8},
		{"kind": "equipment", "type": "plate_mail", "result": "PLATE MAIL", "display_name": "Plate Mail", "weight": 6},
		{"kind": "equipment", "type": "tool_kit", "result": "TOOL KIT", "display_name": "Tool Kit", "weight": 6},
	],
	"cache": [
		{"kind": "material", "type": "medicine", "weight": 24, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "dry_rations", "weight": 20, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "paper", "weight": 12, "quantity_min": 1, "quantity_max": 2},
		{"kind": "equipment", "type": "knife", "result": "KNIFE", "display_name": "Knife", "weight": 16},
		{"kind": "equipment", "type": "bow", "result": "BOW", "display_name": "Bow", "weight": 14},
		{"kind": "equipment", "type": "plate_mail", "result": "PLATE MAIL", "display_name": "Plate Mail", "weight": 14},
	],
	"nest": [
		{"kind": "material", "type": "biomass", "weight": 34, "quantity_min": 1, "quantity_max": 3},
		{"kind": "material", "type": "bone", "weight": 22, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "hide", "weight": 18, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "bacteria", "weight": 14, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "mealworms", "weight": 7, "quantity_min": 1, "quantity_max": 1},
		{"kind": "material", "type": "mushrooms", "weight": 5, "quantity_min": 1, "quantity_max": 1},
	],
	"ruin": [
		{"kind": "material", "type": "metal", "weight": 28, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "paper", "weight": 22, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "bone", "weight": 15, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "fiber", "weight": 12, "quantity_min": 1, "quantity_max": 2},
		{"kind": "material", "type": "mushrooms", "weight": 15, "quantity_min": 1, "quantity_max": 1},
		{"kind": "equipment", "type": "knife", "result": "KNIFE", "display_name": "Knife", "weight": 8},
	],
}
const LOCATION_SCAVENGE_CHANCES := {
	"pond": 0.75,
	"crater": 0.75,
	"tower": 0.75,
	"surveillance_zone": 0.75,
	"facility": 0.78,
	"bunker": 0.75,
	"field": 0.80,
	"dump": 0.78,
	"cache": 0.82,
	"nest": 0.78,
	"ruin": 0.75,
}
const LOCATION_ENCOUNTER_TABLES := {
	"pond": {"chance": 0.18, "types": [{"type": "wolf_pack", "weight": 45}, {"type": "stalker", "weight": 35}, {"type": "grizzly", "weight": 20}]},
	"crater": {"chance": 0.22, "types": [{"type": "stalker", "weight": 45}, {"type": "wolf_pack", "weight": 35}, {"type": "grizzly", "weight": 20}]},
	"tower": {"chance": 0.32, "types": [{"type": "surveillance_drone", "weight": 45}, {"type": "infantry_drone", "weight": 25}, {"type": "warden", "weight": 15}, {"type": "stalker", "weight": 15}]},
	"surveillance_zone": {"chance": 0.40, "types": [{"type": "surveillance_drone", "weight": 45}, {"type": "infantry_drone", "weight": 25}, {"type": "warden", "weight": 25}, {"type": "stalker", "weight": 5}]},
	"facility": {"chance": 0.30, "types": [{"type": "infantry_drone", "weight": 35}, {"type": "surveillance_drone", "weight": 25}, {"type": "warden", "weight": 20}, {"type": "stalker", "weight": 20}]},
	"bunker": {"chance": 0.34, "types": [{"type": "stalker", "weight": 45}, {"type": "infantry_drone", "weight": 30}, {"type": "surveillance_drone", "weight": 20}, {"type": "wolf_pack", "weight": 5}]},
	"field": {"chance": 0.20, "types": [{"type": "wolf_pack", "weight": 50}, {"type": "grizzly", "weight": 30}, {"type": "stalker", "weight": 20}]},
	"dump": {"chance": 0.28, "types": [{"type": "stalker", "weight": 40}, {"type": "wolf_pack", "weight": 25}, {"type": "grizzly", "weight": 20}, {"type": "infantry_drone", "weight": 15}]},
	"cache": {"chance": 0.22, "types": [{"type": "stalker", "weight": 50}, {"type": "wolf_pack", "weight": 30}, {"type": "infantry_drone", "weight": 20}]},
	"nest": {"chance": 0.38, "types": [{"type": "wolf_pack", "weight": 40}, {"type": "grizzly", "weight": 35}, {"type": "stalker", "weight": 25}]},
	"ruin": {"chance": 0.27, "types": [{"type": "stalker", "weight": 45}, {"type": "wolf_pack", "weight": 25}, {"type": "grizzly", "weight": 15}, {"type": "infantry_drone", "weight": 10}, {"type": "warden", "weight": 5}]},
}
const ENEMY_NAME_CORPUS := [
	"stalker",
	"skitter",
	"marauder",
	"shrike",
	"rattler",
	"prowler",
	"drifter",
	"scavver",
	"mangler",
	"needleback",
	"wretch",
	"fangmite",
	"thornjaw",
	"scrapling",
	"gnashhound",
	"brittleswarm",
	"redmaw",
	"coilrunner",
	"ashraider",
	"spinecrawler",
]

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
var location_cards: Array = []
var enemy_cards: Array = []
var dog_cards: Array = []
var material_cards: Array = []
var blueprint_cards: Array = []
var crafted_cards: Array = []
var equipment_cards: Array = []
var journal_entries: Array = []
var workshop_layout: Dictionary = {}
var operator_state: Dictionary = {}
var recipe_catalog: Dictionary = {}
var enemy_loot_catalog: Dictionary = {}

const DRONE_TYPE_DEFS := {
	"spider": {
		"display_name": "Spider drone",
		"title": "SPIDER DRONE",
		"short_label": "spider",
		"attack": 3,
		"action_commands": ["mov", "rot", "scn", "pck", "drp", "atk"],
		"description": "Stable low-profile field frame.",
		"role_text": "Salvage, carrying, drop placement, close terrain work, direct attack approach.",
		"limits_text": "Shared interpreter. Pickup, drop, or attack only work when the frame and mission state support them.",
		"programming_text": "Write explicit outward and return paths. Pickup only matters at valid target sites. ATK only resolves during combat.",
		"scan_mode": "direct",
	},
	"butterfly": {
		"display_name": "Butterfly drone",
		"title": "BUTTERFLY DRONE",
		"short_label": "butterfly",
		"attack": 2,
		"action_commands": ["mov", "rot", "scn"],
		"description": "Light winged scouting platform.",
		"role_text": "Scouting, movement, turning, visual survey, and light route discovery.",
		"limits_text": "No pickup, drop, or direct attack. Scan favors wide safe observation over close interaction.",
		"programming_text": "Use movement and scan loops, then write a clean return path. This frame is for discovery, not hauling or fighting.",
		"scan_mode": "wide_scan",
	},
}
const DRONE_SHARED_COMMANDS := ["nop", "jmp", "jnz", "dec", "inc", "set", "die"]
const STACKABLE_CRAFT_RESULT_SPECS := {
	"DRY RATIONS": {"type": "dry_rations", "display_name": "Dry Rations", "quantity": 1},
	"MEDICINE": {"type": "medicine", "display_name": "Medicine", "quantity": 1},
	"GROWTH MEDIUM": {"type": "growth_medium", "display_name": "Growth Medium", "quantity": 1},
	"MUSHROOMS": {"type": "mushrooms", "display_name": "Mushrooms", "quantity": 1},
	"ALGAE": {"type": "algae", "display_name": "Algae", "quantity": 1},
	"BACTERIA": {"type": "bacteria", "display_name": "Bacteria", "quantity": 1},
	"MEALWORMS": {"type": "mealworms", "display_name": "Mealworms", "quantity": 1},
	"BONE MEAL": {"type": "bone_meal", "display_name": "Bone Meal", "quantity": 1},
	"FIBER": {"type": "fiber", "display_name": "Fiber", "quantity": 1},
	"PAPER": {"type": "paper", "display_name": "Paper", "quantity": 1},
}
const EQUIPMENT_TYPE_SPECS := {
	"knife": {
		"type": "knife",
		"display_name": "Knife",
		"stats": {"attack": 1, "armor": 0, "stealth": 0, "utility": 0},
	},
	"bow": {
		"type": "bow",
		"display_name": "Bow",
		"stats": {"attack": 3, "armor": -1, "stealth": 0, "utility": 0},
	},
	"plate_mail": {
		"type": "plate_mail",
		"display_name": "Plate Mail",
		"stats": {"attack": 0, "armor": 3, "stealth": -1, "utility": 0},
	},
	"hide_cloak": {
		"type": "hide_cloak",
		"display_name": "Hide Cloak",
		"stats": {"attack": 0, "armor": 0, "stealth": 3, "utility": 0},
	},
	"tool_kit": {
		"type": "tool_kit",
		"display_name": "Tool Kit",
		"stats": {"attack": 0, "armor": 0, "stealth": 0, "utility": 3},
	},
}
const STORAGE_CRAFTED_TYPES := ["tool_chest", "archive_shelf"]
const TANK_PROCESS_SPECS := {
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
const TANK_RECIPE_RESULT_TO_PROCESS := {
	"FIBER": "fiber_cycle",
	"MEDICINE": "medicine_cycle",
	"DRY RATIONS": "rations_cycle",
	"BIOMASS": "biomass_cycle",
}

func _ready():
	_load_recipe_catalog()
	_load_enemy_loot_catalog()
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
	return _get_total_material_quantity("power_unit") > 0

func has_free_programmed_slot() -> bool:
	return true

func is_run_active() -> bool:
	return int(operator_state.get("hp", 0)) > 0 and str(operator_state.get("status", "active")) != "dead"

func get_operator_state() -> Dictionary:
	return operator_state.duplicate(true)

func get_start_operator_profiles() -> Array:
	return START_OPERATOR_PROFILES.duplicate(true)

func has_persistent_run_data() -> bool:
	return FileAccess.file_exists(CARTRIDGE_STORAGE_PATH)

func needs_operator_selection() -> bool:
	return not has_persistent_run_data() and str(operator_state.get("profile_id", "")).is_empty()

func start_new_run_with_operator(profile_id: String) -> bool:
	var profile := _get_start_operator_profile(profile_id)
	if profile.is_empty():
		return false
	var persistent_journal_entries := Array(journal_entries).duplicate(true)
	programmed_cartridges.clear()
	_initialize_operator_state()
	_initialize_bot_loadouts()
	_initialize_outside_objects()
	location_cards = []
	enemy_cards = []
	dog_cards = []
	material_cards = []
	blueprint_cards = []
	crafted_cards = []
	equipment_cards = []
	journal_entries = persistent_journal_entries
	workshop_layout = {}
	_initialize_power_unit_slots()
	_initialize_blank_slots()
	selected_cartridge_id = ""
	_apply_start_operator_profile(profile)
	_seed_starter_shelter()
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.cartridges_changed.emit(programmed_cartridges)
	EventBus.cartridge_selected.emit(selected_cartridge_id)
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return true

func _get_start_operator_profile(profile_id: String) -> Dictionary:
	var normalized_id := profile_id.strip_edges().to_lower()
	if normalized_id.is_empty():
		return {}
	for profile_variant in START_OPERATOR_PROFILES:
		if typeof(profile_variant) != TYPE_DICTIONARY:
			continue
		var profile: Dictionary = profile_variant
		if str(profile.get("id", "")).to_lower() == normalized_id:
			return profile.duplicate(true)
	return {}

func _apply_operator_profile_defaults() -> void:
	var profile_id := str(operator_state.get("profile_id", "")).strip_edges().to_lower()
	if profile_id.is_empty():
		return
	var profile := _get_start_operator_profile(profile_id)
	if profile.is_empty():
		return
	if str(operator_state.get("display_name", "")).strip_edges().is_empty():
		operator_state["display_name"] = str(profile.get("name", "OPERATOR"))
	if str(operator_state.get("focus", "")).strip_edges().is_empty():
		operator_state["focus"] = str(profile.get("focus", ""))

func _apply_start_operator_profile(profile: Dictionary) -> void:
	operator_state["profile_id"] = str(profile.get("id", ""))
	operator_state["display_name"] = str(profile.get("name", "OPERATOR"))
	operator_state["focus"] = str(profile.get("focus", ""))
	operator_state["equipment_slots"] = _default_equipment_slots()
	var equipment_type := str(profile.get("starting_equipment", "")).strip_edges().to_lower()
	if not equipment_type.is_empty():
		var spec := _get_equipment_type_spec(equipment_type)
		if not spec.is_empty():
			var slots := _default_equipment_slots()
			slots[0] = {
				"slot_index": 0,
				"item_type": equipment_type,
				"display_name": str(spec.get("display_name", _get_equipment_display_name(equipment_type))),
			}
			operator_state["equipment_slots"] = slots

func _seed_starter_shelter() -> void:
	_add_material_card({"type": "power_unit", "quantity": CHARGE_MACHINE_TRANSFER_UNITS * 2})
	_add_material_card({"type": "metal", "quantity": 2})
	_add_material_card({"type": "biomass", "quantity": 2})
	_add_material_card({"type": "fiber", "quantity": 2})
	_add_material_card({"type": "paper", "quantity": 1})
	var profile := _get_start_operator_profile(str(operator_state.get("profile_id", "")))
	for extra_variant in Array(profile.get("extra_materials", [])):
		if typeof(extra_variant) != TYPE_DICTIONARY:
			continue
		var extra_material: Dictionary = extra_variant
		_add_material_card({
			"type": str(extra_material.get("type", "")),
			"quantity": maxi(int(extra_material.get("quantity", 0)), 0),
		})
	for subject_key in STARTER_DISCOVERED_SUBJECT_KEYS:
		_seed_journal_subject(str(subject_key))
	for subject_key_variant in Array(profile.get("known_subjects", [])):
		_seed_journal_subject(str(subject_key_variant))
	save_programmed_cartridge("START LOOP", _build_starter_demo_cartridge_rows())

func _seed_journal_subject(subject_key: String, unread: bool = false) -> void:
	if subject_key.is_empty():
		return
	if _get_journal_entry_index(subject_key) != -1:
		return
	var subject_def := _get_research_subject_definition_by_key(subject_key)
	if subject_def.is_empty():
		return
	journal_entries.append({
		"subject_key": subject_key,
		"subject_kind": str(subject_def.get("subject_kind", "")),
		"subject_type": str(subject_def.get("subject_type", "")),
		"title": str(subject_def.get("title", subject_key.replace("_", " ").to_upper())),
		"description": str(subject_def.get("description", "")),
		"notes_sections": Array(subject_def.get("notes_sections", [])).duplicate(true),
		"recipe_ids": _get_related_recipe_ids(subject_key),
		"recipes": [],
		"related_subjects": [],
		"unread": unread,
		"attempts": 0,
	})

func _build_starter_demo_cartridge_rows() -> Array:
	var row_indices := [
		5,   # SCN
		1,   # MOV
		2,   # ROT
		4,   # arg 4
		17,  # DIE
	]
	var rows: Array = []
	for row_number in range(row_indices.size()):
		var opcode_index := int(row_indices[row_number])
		rows.append({
			"index": row_number,
			"bits": PunchEncodingData.bits_for_index(opcode_index),
		})
	return rows

func can_open_programming_bench() -> bool:
	return has_blank_cartridge_available()

func get_blank_cartridge_count() -> int:
	return blank_cartridge_slots.size()

func get_free_programmed_slot_count() -> int:
	return 999999

func get_workshop_card_position(layout_key: String, fallback: Vector2) -> Vector2:
	if not workshop_layout.has(layout_key):
		if layout_key.begins_with("mechanism_"):
			var structure_key := "structure_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
			if workshop_layout.has(structure_key):
				return _vector_from_variant(workshop_layout[structure_key], fallback)
			var legacy_key := "crafted_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
			if workshop_layout.has(legacy_key):
				return _vector_from_variant(workshop_layout[legacy_key], fallback)
		if layout_key.begins_with("structure_"):
			var legacy_key := "crafted_%s" % layout_key.substr("structure_".length(), layout_key.length() - "structure_".length())
			if workshop_layout.has(legacy_key):
				return _vector_from_variant(workshop_layout[legacy_key], fallback)
		return fallback
	return _vector_from_variant(workshop_layout[layout_key], fallback)

func set_workshop_card_position(layout_key: String, position: Vector2):
	var serialized := _serialize_vector(position)
	if workshop_layout.has(layout_key) and workshop_layout[layout_key] == serialized:
		return
	workshop_layout[layout_key] = serialized
	if layout_key.begins_with("mechanism_"):
		var structure_key := "structure_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
		workshop_layout.erase(structure_key)
		var crafted_key := "crafted_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
		workshop_layout.erase(crafted_key)
	if layout_key.begins_with("structure_"):
		var legacy_key := "crafted_%s" % layout_key.substr("structure_".length(), layout_key.length() - "structure_".length())
		workshop_layout.erase(legacy_key)
	save_programmed_cartridges()

func clear_workshop_card_position(layout_key: String):
	var changed := false
	if workshop_layout.has(layout_key):
		workshop_layout.erase(layout_key)
		changed = true
	if layout_key.begins_with("mechanism_"):
		var structure_key := "structure_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
		if workshop_layout.has(structure_key):
			workshop_layout.erase(structure_key)
			changed = true
		var crafted_key := "crafted_%s" % layout_key.substr("mechanism_".length(), layout_key.length() - "mechanism_".length())
		if workshop_layout.has(crafted_key):
			workshop_layout.erase(crafted_key)
			changed = true
	if layout_key.begins_with("structure_"):
		var legacy_key := "crafted_%s" % layout_key.substr("structure_".length(), layout_key.length() - "structure_".length())
		if workshop_layout.has(legacy_key):
			workshop_layout.erase(legacy_key)
			changed = true
	if not changed:
		return
	save_programmed_cartridges()

func save_programmed_cartridge(label: String, rows: Array) -> Dictionary:
	var blank_slot_index := _get_first_blank_slot_index()
	if blank_slot_index == -1:
		return {}

	var trimmed_label := label.strip_edges()
	if trimmed_label.is_empty():
		trimmed_label = get_default_cartridge_label()

	var normalized_rows := _duplicate_rows(rows)
	var cartridge := {
		"id": str(Time.get_unix_time_from_system()) + "_" + str(randi()),
		"label": trimmed_label,
		"rows": normalized_rows,
		"slot_index": programmed_cartridges.size(),
		"location": "shelf",
		"use_count": 0,
		"wear": 0.0,
		"saved_at": Time.get_unix_time_from_system(),
	}

	blank_cartridge_slots.remove_at(blank_slot_index)
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
	var shelf_cartridges := get_shelf_programmed_cartridges()
	if slot_index < 0 or slot_index >= shelf_cartridges.size():
		return {}
	return Dictionary(shelf_cartridges[slot_index]).duplicate(true)

func get_shelf_programmed_cartridges() -> Array:
	var shelf_cartridges: Array = []
	for cartridge in programmed_cartridges:
		if str(cartridge.get("location", "")) == "shelf":
			shelf_cartridges.append(Dictionary(cartridge).duplicate(true))
	return shelf_cartridges

func recycle_programmed_cartridge(cartridge_id: String) -> bool:
	var cartridge_index := _get_programmed_cartridge_index(cartridge_id)
	if cartridge_index == -1:
		return false
	var cartridge: Dictionary = programmed_cartridges[cartridge_index]
	if str(cartridge.get("location", "")) != "shelf":
		return false
	blank_cartridge_slots.append(true)
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
	return true

func has_empty_blank_cartridge_slot() -> bool:
	return true

func get_power_unit_in_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return {}
	return power_unit_slots[slot_index]

func is_power_unit_charged(slot_index: int) -> bool:
	var power_unit := get_power_unit_in_slot(slot_index)
	return not power_unit.is_empty() and int(power_unit.get("charge", 0)) > 0

func create_power_unit_in_slot(slot_index: int) -> bool:
	if slot_index < 0:
		return false
	if slot_index == power_unit_slots.size():
		power_unit_slots.append({})
	elif slot_index > power_unit_slots.size():
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

func recharge_power_unit_in_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return false
	if power_unit_slots[slot_index].is_empty():
		return false
	power_unit_slots[slot_index]["max_charge"] = maxi(int(power_unit_slots[slot_index].get("max_charge", BOT_POWER_CAPACITY)), BOT_POWER_CAPACITY)
	power_unit_slots[slot_index]["charge"] = int(power_unit_slots[slot_index]["max_charge"])
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func discard_power_unit_in_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= power_unit_slots.size():
		return false
	if power_unit_slots[slot_index].is_empty():
		return false
	power_unit_slots[slot_index] = {}
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	return true

func consume_operator_charge_work(cost: int = CHARGE_WORK_COST) -> bool:
	if cost <= 0:
		return is_run_active()
	var remaining_cost := cost
	var current_energy := int(operator_state.get("energy", 0))
	if current_energy > 0:
		var energy_spent := mini(current_energy, remaining_cost)
		current_energy -= energy_spent
		remaining_cost -= energy_spent
		operator_state["energy"] = current_energy
	if remaining_cost > 0:
		operator_state["hp"] = int(operator_state.get("hp", 0)) - remaining_cost
	if int(operator_state.get("hp", 0)) <= 0:
		operator_state["hp"] = 0
		operator_state["status"] = "dead"
	else:
		operator_state["status"] = "exhausted" if int(operator_state.get("energy", 0)) <= 0 else "active"
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	if str(operator_state.get("status", "")) == "dead":
		EventBus.log_message.emit("Operator collapsed. Run ended.")
	return is_run_active()

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
	bot_loadouts[bot_index]["combat_ptr"] = 0
	_append_bot_log_entry(bot_loadouts[bot_index], "load", "Loaded tape %s" % str(selected.get("label", cartridge_id)))
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
	bot_loadouts[bot_index]["combat_ptr"] = 0
	_append_bot_log_entry(bot_loadouts[bot_index], "unload", "Unloaded tape %s" % str(loaded.get("label", "")))
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

func get_location_card_by_id(location_id: String) -> Dictionary:
	if location_id.is_empty():
		return {}
	for location_card in location_cards:
		if str(location_card.get("id", "")) == location_id:
			return Dictionary(location_card).duplicate(true)
	return {}

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
	bot_loadouts[bot_index]["combat_ptr"] = 0
	bot_loadouts[bot_index]["outside_trail"] = [shelter]
	bot_loadouts[bot_index]["pending_discovery_ids"] = []
	bot_loadouts[bot_index]["pending_salvage_drops"] = []
	bot_loadouts[bot_index]["last_mission_summary"] = ""
	bot_loadouts[bot_index]["mission_location_id"] = ""
	bot_loadouts[bot_index]["mission_location_type"] = ""
	bot_loadouts[bot_index]["mission_location_position"] = shelter
	bot_loadouts[bot_index]["mission_pickups"] = 0
	bot_loadouts[bot_index]["mission_pickup_attempts"] = 0
	bot_loadouts[bot_index]["mission_encounters"] = 0
	_append_bot_log_entry(bot_loadouts[bot_index], "launch", "Launched from shelter")
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return true

func launch_bot_to_location(bot_index: int, location_id: String) -> bool:
	var location_card := get_location_card_by_id(location_id)
	if location_card.is_empty():
		return false
	if not launch_bot(bot_index):
		return false
	bot_loadouts[bot_index]["mission_location_id"] = location_id
	bot_loadouts[bot_index]["mission_location_type"] = str(location_card.get("type", ""))
	bot_loadouts[bot_index]["mission_location_position"] = _vector_from_variant(location_card.get("position", {}), get_shelter_position())
	bot_loadouts[bot_index]["mission_pickups"] = 0
	bot_loadouts[bot_index]["mission_pickup_attempts"] = 0
	bot_loadouts[bot_index]["mission_encounters"] = 0
	_append_bot_log_entry(bot_loadouts[bot_index], "target", "Assigned location target %s at (%d,%d)" % [
		str(location_card.get("type", "site")).to_upper(),
		int(Vector2(bot_loadouts[bot_index]["mission_location_position"]).x),
		int(Vector2(bot_loadouts[bot_index]["mission_location_position"]).y),
	])
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return true

func _clear_bot_mission_state(bot_state: Dictionary) -> void:
	bot_state["mission_location_id"] = ""
	bot_state["mission_location_type"] = ""
	bot_state["mission_location_position"] = get_shelter_position()
	bot_state["pending_salvage_drops"] = []
	bot_state["mission_pickups"] = 0
	bot_state["mission_pickup_attempts"] = 0
	bot_state["mission_encounters"] = 0

func get_bot_activity_log(bot_index: int) -> Array:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return []
	return Array(bot_loadouts[bot_index].get("activity_log", [])).duplicate(true)

func _append_bot_log_entry(bot_state: Dictionary, kind: String, message: String, count_as_tick: bool = false) -> void:
	var log_entries: Array = Array(bot_state.get("activity_log", [])).duplicate(true)
	var activity_tick := maxi(int(bot_state.get("activity_tick", 0)), 0)
	if count_as_tick:
		activity_tick += 1
		bot_state["activity_tick"] = activity_tick
	log_entries.append({
		"tick": activity_tick,
		"kind": kind,
		"position": _serialize_vector(Vector2(bot_state.get("outside_position", get_shelter_position()))),
		"power_charge": int(bot_state.get("power_charge", 0)),
		"acc": int(bot_state.get("outside_acc", 0)),
		"ptr": int(bot_state.get("outside_ptr", 0)),
		"message": message,
	})
	while log_entries.size() > 128:
		log_entries.pop_front()
	bot_state["activity_log"] = log_entries

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

func can_operator_retrieve_bot(bot_index: int) -> bool:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return false
	var status := str(bot_loadouts[bot_index].get("outside_status", "cabinet"))
	return status == "active" or status == "halted" or status == "stranded"

func get_bot_recovery_distance(bot_index: int) -> int:
	if not can_operator_retrieve_bot(bot_index):
		return 0
	var bot_state: Dictionary = bot_loadouts[bot_index]
	var bot_position := Vector2(bot_state.get("outside_position", get_shelter_position()))
	var shelter := get_shelter_position()
	return absi(int(bot_position.x - shelter.x)) + absi(int(bot_position.y - shelter.y))

func get_bot_recovery_energy_cost(bot_index: int) -> int:
	var distance := maxi(get_bot_recovery_distance(bot_index), 1)
	return maxi(1, int(ceil(float(distance) / 2.0)) + 1)

func resolve_bot_recovery(bot_index: int) -> Dictionary:
	if not can_operator_retrieve_bot(bot_index):
		return {"ok": false, "message": "Recovery unavailable"}
	var bot_name := _bot_display_name(bot_index)
	var bot_state: Dictionary = bot_loadouts[bot_index]
	var retrieval_from_active := str(bot_state.get("outside_status", "cabinet")) == "active"
	var energy_before := int(operator_state.get("energy", 0))
	var hp_before := int(operator_state.get("hp", 0))
	var energy_cost := get_bot_recovery_energy_cost(bot_index)
	_apply_operator_loss(energy_cost)
	bot_state["outside_position"] = get_shelter_position()
	var trail: Array = bot_state.get("outside_trail", []).duplicate()
	if trail.is_empty() or trail[-1] != get_shelter_position():
		trail.append(get_shelter_position())
	bot_state["outside_trail"] = trail
	_set_terminal_status(bot_state, "halted")
	bot_loadouts[bot_index] = bot_state
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"bot_index": bot_index,
		"bot_name": bot_name,
		"energy_cost": energy_cost,
		"energy_loss": maxi(energy_before - int(operator_state.get("energy", 0)), 0),
		"hp_loss": maxi(hp_before - int(operator_state.get("hp", 0)), 0),
		"collapsed": str(operator_state.get("status", "")) == "dead",
		"retrieval_from_active": retrieval_from_active,
		"summary": str(bot_state.get("last_mission_summary", "%s %s" % [bot_name, "retrieved" if retrieval_from_active else "recovered"])),
	}

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

func spawn_random_enemy_card(source: String = "operator_scan") -> Dictionary:
	var enemy_card := _build_enemy_scan_card(source)
	enemy_cards.append(enemy_card)
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return enemy_card.duplicate(true)

func get_active_or_away_bots() -> Array:
	var bots: Array = []
	for bot in bot_loadouts:
		var status := str(bot.get("outside_status", "cabinet"))
		if status != "cabinet":
			bots.append(bot)
	return bots

func get_discovered_outside_objects() -> Array:
	var discovered: Array = []
	for location_card in location_cards:
		discovered.append({
			"id": str(location_card.get("id", "")),
			"type": str(location_card.get("type", "site")),
			"position": _vector_from_variant(location_card.get("position", {}), Vector2.ZERO),
			"discovered": true,
		})
	return discovered

func get_location_cards() -> Array:
	return location_cards.duplicate(true)

func get_enemy_cards() -> Array:
	return enemy_cards.duplicate(true)

func get_dog_cards() -> Array:
	return dog_cards.duplicate(true)

func get_material_cards() -> Array:
	return material_cards.duplicate(true)

func get_blueprint_cards() -> Array:
	return blueprint_cards.duplicate(true)

func get_crafted_cards() -> Array:
	return crafted_cards.duplicate(true)

func get_structure_cards() -> Array:
	var result: Array = []
	for entry_variant in crafted_cards:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		if str(entry.get("type", "")) == "tank":
			continue
		result.append(entry.duplicate(true))
	return result

func get_mechanism_cards() -> Array:
	var result: Array = []
	for entry_variant in crafted_cards:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		if str(entry.get("type", "")) != "tank":
			continue
		result.append(entry.duplicate(true))
	return result

func get_equipment_cards() -> Array:
	return equipment_cards.duplicate(true)

func get_state_table_cards(kind: String) -> Array:
	match kind:
		"location":
			return get_location_cards()
		"enemy":
			return get_enemy_cards()
		"dog":
			return get_dog_cards()
		"material":
			return get_material_cards()
		"blueprint":
			return get_blueprint_cards()
		"mechanism":
			return get_mechanism_cards()
		"structure", "crafted":
			return get_structure_cards()
		"equipment":
			return get_equipment_cards()
		_:
			return []

func get_state_table_card_layout_key(kind: String, card_id: String) -> String:
	if card_id.is_empty():
		return ""
	match kind:
		"location", "enemy", "dog", "material", "blueprint", "mechanism", "structure", "crafted", "equipment":
			return "%s_%s" % [kind, card_id]
		_:
			return ""

func get_journal_entries() -> Array:
	return journal_entries.duplicate(true)

func get_journal_display_entries() -> Array:
	var discovered_by_key := {}
	var discovered_recipes_by_id := {}
	for entry_variant in journal_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		var subject_key := str(entry.get("subject_key", ""))
		if subject_key.is_empty():
			continue
		for recipe_variant in Array(entry.get("recipes", [])):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = Dictionary(recipe_variant).duplicate(true)
			var recipe_id := str(recipe.get("id", ""))
			if recipe_id.is_empty():
				continue
			discovered_recipes_by_id[recipe_id] = recipe
		discovered_by_key[subject_key] = entry
	var visible_by_key := _build_formula_known_journal_entries(discovered_by_key)
	var display_entries: Array = []
	var seen_subject_keys := {}
	for subject in _get_all_research_subjects():
		var subject_key := _get_research_subject_key(subject)
		if subject_key.is_empty() or seen_subject_keys.has(subject_key):
			continue
		seen_subject_keys[subject_key] = true
		var subject_def := _get_research_subject_definition(subject)
		if subject_def.is_empty():
			continue
		var related_recipe_ids := _get_related_recipe_ids(subject_key)
		if visible_by_key.has(subject_key):
			var visible_entry: Dictionary = Dictionary(visible_by_key[subject_key]).duplicate(true)
			visible_entry["recipes"] = _build_journal_recipe_display_list(
				subject_key,
				discovered_recipes_by_id,
				related_recipe_ids,
				visible_by_key
			)
			visible_entry["recipe_ids"] = related_recipe_ids.duplicate()
			visible_entry["related_subjects"] = _build_journal_related_subjects(subject_key, related_recipe_ids, visible_by_key)
			visible_entry["locked"] = false
			visible_entry = _apply_live_journal_subject_fields(visible_entry, subject_def)
			display_entries.append(visible_entry)
			continue
		var locked_entry := _build_locked_journal_entry(subject_key, subject_def)
		locked_entry["recipes"] = _build_journal_recipe_display_list(subject_key, discovered_recipes_by_id, related_recipe_ids, visible_by_key)
		locked_entry["recipe_ids"] = related_recipe_ids.duplicate()
		locked_entry["related_subjects"] = _build_journal_related_subjects(subject_key, related_recipe_ids, visible_by_key)
		display_entries.append(locked_entry)
	for subject_key_variant in visible_by_key.keys():
		var subject_key := str(subject_key_variant)
		if seen_subject_keys.has(subject_key):
			continue
		var fallback_entry: Dictionary = Dictionary(visible_by_key[subject_key]).duplicate(true)
		var fallback_recipe_ids := _get_related_recipe_ids(subject_key)
		fallback_entry["recipe_ids"] = fallback_recipe_ids.duplicate()
		fallback_entry["recipes"] = _build_journal_recipe_display_list(subject_key, discovered_recipes_by_id, fallback_recipe_ids, visible_by_key)
		fallback_entry["related_subjects"] = _build_journal_related_subjects(subject_key, fallback_recipe_ids, visible_by_key)
		fallback_entry["locked"] = false
		display_entries.append(fallback_entry)
	return display_entries

func _apply_live_journal_subject_fields(entry: Dictionary, subject_def: Dictionary) -> Dictionary:
	var result := entry.duplicate(true)
	if subject_def.has("notes_sections"):
		result["notes_sections"] = Array(subject_def.get("notes_sections", [])).duplicate(true)
	return result

func _build_formula_known_journal_entries(discovered_by_key: Dictionary) -> Dictionary:
	var visible_by_key := {}
	for subject_key_variant in discovered_by_key.keys():
		var subject_key := str(subject_key_variant)
		visible_by_key[subject_key] = Dictionary(discovered_by_key[subject_key]).duplicate(true)
	var changed := true
	while changed:
		changed = false
		for recipe_variant in _get_all_loaded_research_recipes():
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = Dictionary(recipe_variant)
			var result_subject_key := _get_named_subject_key(str(recipe.get("result", "")))
			if result_subject_key.is_empty() or visible_by_key.has(result_subject_key):
				continue
			var formula_parts: Array = _normalize_recipe_result_parts(str(recipe.get("result", "")).to_upper(), _sanitize_recipe_parts(Array(recipe.get("formula_parts", [])).duplicate(true)))
			if _get_journal_recipe_state(result_subject_key, formula_parts, visible_by_key) != "complete":
				continue
			var subject_def := _get_research_subject_definition_by_key(result_subject_key)
			if subject_def.is_empty():
				continue
			visible_by_key[result_subject_key] = _build_formula_known_journal_entry(result_subject_key, subject_def)
			changed = true
	return visible_by_key

func _build_formula_known_journal_entry(subject_key: String, subject_def: Dictionary) -> Dictionary:
	return {
		"subject_key": subject_key,
		"subject_kind": str(subject_def.get("subject_kind", "")),
		"subject_type": str(subject_def.get("subject_type", "")),
		"title": str(subject_def.get("title", "UNKNOWN ENTRY")),
		"description": str(subject_def.get("description", "")),
		"recipe_ids": _get_related_recipe_ids(subject_key),
		"recipes": [],
		"unread": false,
		"attempts": 0,
		"locked": false,
		"known_from_formula": true,
	}

func _build_journal_related_subjects(subject_key: String, related_recipe_ids: Array, discovered_by_key: Dictionary) -> Array:
	var related_keys: Array[String] = []
	for recipe_id_variant in related_recipe_ids:
		var recipe_id := str(recipe_id_variant)
		if recipe_id.is_empty():
			continue
		var live_recipe := _get_loaded_recipe_by_id(recipe_id)
		if live_recipe.is_empty():
			continue
		for related_subject_key_variant in _get_recipe_related_subject_keys(live_recipe):
			var related_subject_key := str(related_subject_key_variant)
			if related_subject_key.is_empty() or related_subject_key == subject_key:
				continue
			related_keys.append(related_subject_key)
	var related_subjects: Array = []
	for related_subject_key in _dedupe_strings(related_keys):
		var subject_def := _get_research_subject_definition_by_key(related_subject_key)
		var discovered := discovered_by_key.has(related_subject_key)
		var title := ""
		if discovered:
			title = str(Dictionary(discovered_by_key[related_subject_key]).get("title", "")).strip_edges()
		if title.is_empty() and not subject_def.is_empty():
			title = str(subject_def.get("title", "")).strip_edges()
		if title.is_empty():
			continue
		related_subjects.append({
			"subject_key": related_subject_key,
			"title": title if discovered else _mask_locked_journal_label(title),
			"locked": not discovered,
			"subject_kind": str(subject_def.get("subject_kind", "")),
			"subject_type": str(subject_def.get("subject_type", "")),
			"unread": is_journal_entry_unread(related_subject_key),
		})
	return related_subjects

func _get_research_subject_definition_by_key(subject_key: String) -> Dictionary:
	var subject := _build_research_subject_from_key(subject_key)
	if subject.is_empty():
		return {}
	return _get_research_subject_definition(subject)

func _build_research_subject_from_key(subject_key: String) -> Dictionary:
	var normalized_key := _normalize_legacy_subject_key(subject_key)
	var split_index := normalized_key.find("_")
	if split_index == -1 or split_index >= normalized_key.length() - 1:
		return {}
	return {
		"kind": normalized_key.substr(0, split_index),
		"type": normalized_key.substr(split_index + 1, normalized_key.length() - split_index - 1),
	}

func has_unread_journal_entries() -> bool:
	for entry_variant in journal_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		if bool(entry.get("unread", false)):
			return true
		for recipe_variant in Array(entry.get("recipes", [])):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			if bool(Dictionary(recipe_variant).get("unread", false)):
				return true
	return false

func is_journal_entry_unread(subject_key: String) -> bool:
	if subject_key.is_empty():
		return false
	for entry_variant in journal_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		if str(entry.get("subject_key", "")) == subject_key:
			if bool(entry.get("unread", false)):
				return true
			for recipe_variant in Array(entry.get("recipes", [])):
				if typeof(recipe_variant) != TYPE_DICTIONARY:
					continue
				if bool(Dictionary(recipe_variant).get("unread", false)):
					return true
			return false
	return false

func is_journal_recipe_unread(subject_key: String, recipe_id: String) -> bool:
	if subject_key.is_empty() or recipe_id.is_empty():
		return false
	for entry_variant in journal_entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		if str(entry.get("subject_key", "")) != subject_key:
			continue
		for recipe_variant in Array(entry.get("recipes", [])):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = recipe_variant
			if str(recipe.get("id", "")) == recipe_id:
				return bool(recipe.get("unread", false))
		return false
	return false

func mark_journal_entry_read(subject_key: String) -> bool:
	if subject_key.is_empty():
		return false
	for entry_index in range(journal_entries.size()):
		var entry: Dictionary = journal_entries[entry_index]
		if str(entry.get("subject_key", "")) != subject_key:
			continue
		var changed := bool(entry.get("unread", false))
		entry["unread"] = false
		var entry_recipes: Array = Array(entry.get("recipes", [])).duplicate(true)
		for recipe_index in range(entry_recipes.size()):
			if typeof(entry_recipes[recipe_index]) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = Dictionary(entry_recipes[recipe_index]).duplicate(true)
			if bool(recipe.get("unread", false)):
				changed = true
			recipe["unread"] = false
			entry_recipes[recipe_index] = recipe
		entry["recipes"] = entry_recipes
		if not changed:
			return false
		journal_entries[entry_index] = entry
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return true
	return false

func forget_location_card(card_id: String) -> bool:
	return forget_state_table_card("location", card_id)

func forget_material_card(card_id: String) -> bool:
	return forget_state_table_card("material", card_id)

func merge_material_cards(source_card_id: String, target_card_id: String) -> Dictionary:
	if source_card_id.is_empty() or target_card_id.is_empty() or source_card_id == target_card_id:
		return {}
	var source_index := -1
	var target_index := -1
	for card_index in range(material_cards.size()):
		var card: Dictionary = material_cards[card_index]
		var card_id := str(card.get("id", ""))
		if card_id == source_card_id:
			source_index = card_index
		elif card_id == target_card_id:
			target_index = card_index
	if source_index == -1 or target_index == -1:
		return {}
	var source_card: Dictionary = material_cards[source_index]
	var target_card: Dictionary = material_cards[target_index]
	if str(source_card.get("type", "")) != str(target_card.get("type", "")):
		return {}
	var source_quantity := maxi(int(source_card.get("quantity", 0)), 0)
	var target_quantity := maxi(int(target_card.get("quantity", 0)), 0)
	if source_quantity <= 0 or target_quantity <= 0:
		return {}
	var merged_quantity := source_quantity + target_quantity
	target_card["quantity"] = merged_quantity
	material_cards[target_index] = target_card
	material_cards.remove_at(source_index)
	if source_index < target_index:
		target_index -= 1
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"target_id": str(target_card.get("id", "")),
		"type": str(target_card.get("type", "")),
		"quantity": merged_quantity,
	}

func forget_blueprint_card(card_id: String) -> bool:
	return forget_state_table_card("blueprint", card_id)

func forget_crafted_card(card_id: String) -> bool:
	return forget_state_table_card("structure", card_id)

func forget_structure_card(card_id: String) -> bool:
	return forget_state_table_card("structure", card_id)

func forget_mechanism_card(card_id: String) -> bool:
	return forget_state_table_card("mechanism", card_id)

func forget_equipment_card(card_id: String) -> bool:
	return forget_state_table_card("equipment", card_id)

func get_operator_equipment_totals() -> Dictionary:
	return _sum_equipment_slot_totals(Array(operator_state.get("equipment_slots", [])))

func get_bot_equipment_totals(bot_index: int) -> Dictionary:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return _default_equipment_totals()
	return _sum_equipment_slot_totals(Array(bot_loadouts[bot_index].get("equipment_slots", [])))

func get_dog_equipment_totals(card_id: String) -> Dictionary:
	var dog_index := _find_dog_card_index(card_id)
	if dog_index == -1:
		return _default_equipment_totals()
	return _sum_equipment_slot_totals(Array(dog_cards[dog_index].get("equipment_slots", [])))

func get_dog_combat_totals(card_id: String) -> Dictionary:
	var dog_index := _find_dog_card_index(card_id)
	if dog_index == -1:
		return _default_equipment_totals()
	var dog_card := Dictionary(dog_cards[dog_index])
	var totals := get_dog_equipment_totals(card_id)
	totals["attack"] = int(dog_card.get("base_attack", DOG_BASE_ATTACK)) + int(totals.get("attack", 0))
	totals["armor"] = int(dog_card.get("base_armor", DOG_BASE_ARMOR)) + int(totals.get("armor", 0))
	return totals

func equip_equipment_on_operator(card_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No equipment selected"}
	if not is_run_active():
		return {"ok": false, "message": "Operator can no longer equip gear"}
	var result := _equip_equipment_into_slots(card_id, Array(operator_state.get("equipment_slots", [])))
	if not bool(result.get("ok", false)):
		return result
	operator_state["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"message": "%s equipped" % str(result.get("display_name", "Equipment")),
	}

func unequip_equipment_on_operator(slot_index: int) -> Dictionary:
	var result := _unequip_equipment_from_slots(Array(operator_state.get("equipment_slots", [])), slot_index)
	if not bool(result.get("ok", false)):
		return result
	operator_state["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"equipment_card": Dictionary(result.get("equipment_card", {})).duplicate(true),
		"message": "%s extracted" % str(result.get("display_name", "Equipment")),
	}

func equip_equipment_on_bot(card_id: String, bot_index: int) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No equipment selected"}
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return {"ok": false, "message": "Drone not found"}
	if not is_bot_available_in_workshop(bot_index):
		return {"ok": false, "message": "Drone is not in workshop"}
	var bot_entry := Dictionary(bot_loadouts[bot_index]).duplicate(true)
	var result := _equip_equipment_into_slots(card_id, Array(bot_entry.get("equipment_slots", [])))
	if not bool(result.get("ok", false)):
		return result
	bot_entry["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	bot_loadouts[bot_index] = bot_entry
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"message": "%s equipped on %s" % [
			str(result.get("display_name", "Equipment")),
			str(bot_entry.get("drone_type", "drone")).replace("_", " ").capitalize(),
		],
	}

func unequip_equipment_on_bot(bot_index: int, slot_index: int) -> Dictionary:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return {"ok": false, "message": "Drone not found"}
	if not is_bot_available_in_workshop(bot_index):
		return {"ok": false, "message": "Drone is not in workshop"}
	var bot_entry := Dictionary(bot_loadouts[bot_index]).duplicate(true)
	var result := _unequip_equipment_from_slots(Array(bot_entry.get("equipment_slots", [])), slot_index)
	if not bool(result.get("ok", false)):
		return result
	bot_entry["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	bot_loadouts[bot_index] = bot_entry
	save_programmed_cartridges()
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"equipment_card": Dictionary(result.get("equipment_card", {})).duplicate(true),
		"message": "%s extracted from %s" % [
			str(result.get("display_name", "Equipment")),
			str(bot_entry.get("drone_type", "drone")).replace("_", " ").capitalize(),
		],
	}

func equip_equipment_on_dog(card_id: String, dog_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No equipment selected"}
	var dog_index := _find_dog_card_index(dog_id)
	if dog_index == -1:
		return {"ok": false, "message": "Dog not found"}
	var dog_card := Dictionary(dog_cards[dog_index]).duplicate(true)
	var result := _equip_equipment_into_slots(card_id, Array(dog_card.get("equipment_slots", [])))
	if not bool(result.get("ok", false)):
		return result
	dog_card["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	dog_cards[dog_index] = dog_card
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"message": "%s equipped on dog" % str(result.get("display_name", "Equipment")),
	}

func unequip_equipment_on_dog(dog_id: String, slot_index: int) -> Dictionary:
	var dog_index := _find_dog_card_index(dog_id)
	if dog_index == -1:
		return {"ok": false, "message": "Dog not found"}
	var dog_card := Dictionary(dog_cards[dog_index]).duplicate(true)
	var result := _unequip_equipment_from_slots(Array(dog_card.get("equipment_slots", [])), slot_index)
	if not bool(result.get("ok", false)):
		return result
	dog_card["equipment_slots"] = Array(result.get("slots", _default_equipment_slots())).duplicate(true)
	dog_cards[dog_index] = dog_card
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"slot_index": int(result.get("slot_index", -1)),
		"display_name": str(result.get("display_name", "Equipment")),
		"equipment_card": Dictionary(result.get("equipment_card", {})).duplicate(true),
		"message": "%s extracted from dog" % str(result.get("display_name", "Equipment")),
	}

func is_storage_crafted_card(card_id: String) -> bool:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return false
	return _is_storage_crafted_type(str(crafted_cards[crafted_index].get("type", "")))

func is_tool_chest_crafted_card(card_id: String) -> bool:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return false
	return str(crafted_cards[crafted_index].get("type", "")) == "tool_chest"

func is_archive_shelf_crafted_card(card_id: String) -> bool:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return false
	return str(crafted_cards[crafted_index].get("type", "")) == "archive_shelf"

func get_crafted_storage_contents(card_id: String) -> Array:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return []
	return Array(crafted_cards[crafted_index].get("stored_cards", [])).duplicate(true)

func store_card_in_crafted_storage(container_id: String, source_kind: String, card_id: String) -> Dictionary:
	var container_index := _find_crafted_card_index(container_id)
	if container_index == -1:
		return {"ok": false, "message": "Storage card not found"}
	var container := Dictionary(crafted_cards[container_index])
	var container_type := str(container.get("type", ""))
	if not _is_storage_crafted_type(container_type):
		return {"ok": false, "message": "Card is not storage"}
	if container_type == "tool_chest":
		return _store_card_in_tool_chest(container_index, container, source_kind, card_id)
	return _store_card_in_archive_shelf(container_index, container, source_kind, card_id)

func _store_card_in_archive_shelf(container_index: int, container: Dictionary, source_kind: String, card_id: String) -> Dictionary:
	var stored_cards := Array(container.get("stored_cards", [])).duplicate(true)
	if card_id.is_empty():
		return {"ok": false, "message": "Card not found"}
	var entry_id := "stored_%d_%d" % [int(Time.get_unix_time_from_system()), stored_cards.size()]
	var stored_entry: Dictionary = {}
	match source_kind:
		"location":
			for card_index in range(location_cards.size()):
				var location_card: Dictionary = Dictionary(location_cards[card_index]).duplicate(true)
				if str(location_card.get("id", "")) != card_id:
					continue
				stored_entry = {
					"entry_id": entry_id,
					"kind": "location",
					"type": str(location_card.get("type", "")),
					"display_name": str(location_card.get("display_name", location_card.get("type", "Location"))),
					"card": location_card,
				}
				location_cards.remove_at(card_index)
				break
		"dog":
			var dog_index := _find_dog_card_index(card_id)
			if dog_index != -1:
				var dog_card := Dictionary(dog_cards[dog_index]).duplicate(true)
				stored_entry = {
					"entry_id": entry_id,
					"kind": "dog",
					"type": "dog",
					"display_name": str(dog_card.get("display_name", "Dog")),
					"card": dog_card,
				}
				dog_cards.remove_at(dog_index)
		"material":
			var material_index := _find_material_card_index(card_id)
			if material_index != -1:
				var material_card := Dictionary(material_cards[material_index]).duplicate(true)
				if maxi(int(material_card.get("quantity", 0)), 0) <= 0:
					return {"ok": false, "message": "Nothing to store"}
				stored_entry = {
					"entry_id": entry_id,
					"kind": "material",
					"type": str(material_card.get("type", "")),
					"display_name": str(material_card.get("display_name", _default_material_display_name(str(material_card.get("type", ""))))),
					"quantity": maxi(int(material_card.get("quantity", 1)), 1),
					"card": material_card,
				}
				material_cards.remove_at(material_index)
		"blueprint":
			var blueprint_index := _find_blueprint_card_index(card_id)
			if blueprint_index != -1:
				var blueprint_card := Dictionary(blueprint_cards[blueprint_index]).duplicate(true)
				stored_entry = {
					"entry_id": entry_id,
					"kind": "blueprint",
					"type": "blueprint",
					"display_name": str(blueprint_card.get("display_name", blueprint_card.get("result", "Blueprint"))),
					"result": str(blueprint_card.get("result", "Blueprint")),
					"recipe_id": str(blueprint_card.get("recipe_id", "")),
					"formula": str(blueprint_card.get("formula", "")),
					"formula_parts": Array(blueprint_card.get("formula_parts", [])).duplicate(true),
					"subject_key": str(blueprint_card.get("subject_key", "")),
					"card": blueprint_card,
				}
				blueprint_cards.remove_at(blueprint_index)
		"equipment":
			var equipment_index := _find_equipment_card_index(card_id)
			if equipment_index != -1:
				var equipment_card := Dictionary(equipment_cards[equipment_index]).duplicate(true)
				stored_entry = {
					"entry_id": entry_id,
					"kind": "equipment",
					"type": str(equipment_card.get("type", "")),
					"display_name": str(equipment_card.get("display_name", _get_equipment_display_name(str(equipment_card.get("type", ""))))),
					"card": equipment_card,
				}
				equipment_cards.remove_at(equipment_index)
		"mechanism", "crafted", "structure":
			var source_index := _find_crafted_card_index(card_id)
			if source_index == -1 or source_index == container_index:
				return {"ok": false, "message": "Card not found"}
			var crafted_card := Dictionary(crafted_cards[source_index]).duplicate(true)
			var stored_kind := "mechanism" if source_kind == "mechanism" or str(crafted_card.get("type", "")) == "tank" else "structure"
			stored_entry = {
				"entry_id": entry_id,
				"kind": stored_kind,
				"type": str(crafted_card.get("type", "")),
				"display_name": str(crafted_card.get("display_name", crafted_card.get("result", "Item"))),
				"result": str(crafted_card.get("result", "")),
				"recipe_id": str(crafted_card.get("recipe_id", "")),
				"formula": str(crafted_card.get("formula", "")),
				"captive_enemy": _normalize_saved_captive_enemy(Dictionary(crafted_card.get("captive_enemy", {}))),
				"card": crafted_card,
			}
			crafted_cards.remove_at(source_index)
			if source_index < container_index:
				container_index -= 1
				container = Dictionary(crafted_cards[container_index])
		"enemy":
			return {"ok": false, "message": "Hostile creatures cannot be archived"}
		_:
			return {"ok": false, "message": "Card type cannot be stored"}
	if stored_entry.is_empty():
		return {"ok": false, "message": "Card not found"}
	stored_cards.append(stored_entry)
	container["stored_cards"] = stored_cards
	crafted_cards[container_index] = container
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"kind": str(stored_entry.get("kind", "")),
		"type": str(stored_entry.get("type", "")),
		"message": "%s stored" % str(container.get("display_name", container.get("result", "Storage"))),
	}

func withdraw_crafted_storage_item(container_id: String, entry_id: String) -> Dictionary:
	var container_index := _find_crafted_card_index(container_id)
	if container_index == -1:
		return {}
	var container := Dictionary(crafted_cards[container_index])
	if not _is_storage_crafted_type(str(container.get("type", ""))):
		return {}
	var stored_cards := Array(container.get("stored_cards", [])).duplicate(true)
	for stored_index in range(stored_cards.size()):
		var stored_entry := Dictionary(stored_cards[stored_index])
		if str(stored_entry.get("entry_id", "")) != entry_id:
			continue
		stored_cards.remove_at(stored_index)
		container["stored_cards"] = stored_cards
		crafted_cards[container_index] = container
		var entry_kind := str(stored_entry.get("kind", ""))
		var created_card: Dictionary = {}
		if entry_kind == "material":
			if typeof(stored_entry.get("card", {})) == TYPE_DICTIONARY and not Dictionary(stored_entry.get("card", {})).is_empty():
				created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
				material_cards.append(created_card)
			else:
				created_card = _add_material_card({
					"type": str(stored_entry.get("type", "")),
					"display_name": str(stored_entry.get("display_name", "")),
					"quantity": maxi(int(stored_entry.get("quantity", 1)), 1),
				})
			if not created_card.is_empty():
				created_card["kind"] = "material"
		elif entry_kind == "location":
			created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
			if created_card.is_empty():
				return {}
			location_cards.append(created_card)
			created_card["kind"] = "location"
		elif entry_kind == "dog":
			created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
			if created_card.is_empty():
				return {}
			dog_cards.append(created_card)
			created_card["kind"] = "dog"
		elif entry_kind == "mechanism":
			if typeof(stored_entry.get("card", {})) == TYPE_DICTIONARY and not Dictionary(stored_entry.get("card", {})).is_empty():
				created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
			else:
				created_card = {
					"id": "mechanism_%d_%d" % [int(Time.get_unix_time_from_system()), crafted_cards.size()],
					"type": str(stored_entry.get("type", "")),
					"display_name": str(stored_entry.get("display_name", stored_entry.get("result", "Mechanism"))),
					"result": str(stored_entry.get("result", "TANK")),
					"recipe_id": str(stored_entry.get("recipe_id", "")),
					"formula": str(stored_entry.get("formula", "")),
					"stored_cards": [],
					"captive_enemy": _normalize_saved_captive_enemy(Dictionary(stored_entry.get("captive_enemy", {}))),
					"tank_batch": {},
					"tank_slots": _default_tank_slots(),
				}
			crafted_cards.append(created_card)
			created_card["kind"] = "mechanism"
		elif entry_kind in ["crafted", "structure"]:
			if typeof(stored_entry.get("card", {})) == TYPE_DICTIONARY and not Dictionary(stored_entry.get("card", {})).is_empty():
				created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
			else:
				created_card = {
					"id": "structure_%d_%d" % [int(Time.get_unix_time_from_system()), crafted_cards.size()],
					"type": str(stored_entry.get("type", "")),
					"display_name": str(stored_entry.get("display_name", stored_entry.get("result", "Item"))),
					"result": str(stored_entry.get("result", "Crafted Item")),
					"recipe_id": str(stored_entry.get("recipe_id", "")),
					"formula": str(stored_entry.get("formula", "")),
					"stored_cards": [],
					"captive_enemy": _normalize_saved_captive_enemy(Dictionary(stored_entry.get("captive_enemy", {}))),
				}
			crafted_cards.append(created_card)
			created_card["kind"] = "structure"
		elif entry_kind == "blueprint":
			if typeof(stored_entry.get("card", {})) == TYPE_DICTIONARY and not Dictionary(stored_entry.get("card", {})).is_empty():
				created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
			else:
				created_card = {
					"id": "blueprint_%d_%d" % [int(Time.get_unix_time_from_system()), blueprint_cards.size()],
					"recipe_id": str(stored_entry.get("recipe_id", "")),
					"result": str(stored_entry.get("result", "Blueprint")),
					"formula": str(stored_entry.get("formula", "")),
					"formula_parts": Array(stored_entry.get("formula_parts", [])).duplicate(true),
					"subject_key": str(stored_entry.get("subject_key", "")),
				}
			blueprint_cards.append(created_card)
			created_card["kind"] = "blueprint"
		elif entry_kind == "equipment":
			if typeof(stored_entry.get("card", {})) == TYPE_DICTIONARY and not Dictionary(stored_entry.get("card", {})).is_empty():
				created_card = Dictionary(stored_entry.get("card", {})).duplicate(true)
				equipment_cards.append(created_card)
			else:
				created_card = _add_equipment_card({
					"type": str(stored_entry.get("type", "")),
					"display_name": str(stored_entry.get("display_name", "")),
				})
			if not created_card.is_empty():
				created_card["kind"] = "equipment"
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return created_card.duplicate(true)
	return {}

func withdraw_latest_crafted_storage_item(container_id: String) -> Dictionary:
	var stored_cards := get_crafted_storage_contents(container_id)
	if stored_cards.is_empty():
		return {}
	var latest_entry: Dictionary = Dictionary(stored_cards[stored_cards.size() - 1]).duplicate(true)
	return withdraw_crafted_storage_item(container_id, str(latest_entry.get("entry_id", "")))

func forget_state_table_card(kind: String, card_id: String) -> bool:
	if card_id.is_empty():
		return false
	var removed := false
	match kind:
		"location":
			removed = _remove_table_card_by_id(location_cards, card_id)
		"enemy":
			removed = _remove_table_card_by_id(enemy_cards, card_id)
		"dog":
			removed = _remove_table_card_by_id(dog_cards, card_id)
		"material":
			removed = _remove_table_card_by_id(material_cards, card_id)
		"blueprint":
			removed = _remove_table_card_by_id(blueprint_cards, card_id)
		"mechanism":
			removed = _remove_table_card_by_id(crafted_cards, card_id)
		"crafted", "structure":
			removed = _remove_table_card_by_id(crafted_cards, card_id)
		"equipment":
			removed = _remove_table_card_by_id(equipment_cards, card_id)
	if not removed:
		return false
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return true

func _remove_table_card_by_id(cards: Array, card_id: String) -> bool:
	for card_index in range(cards.size()):
		if str(cards[card_index].get("id", "")) != card_id:
			continue
		cards.remove_at(card_index)
		return true
	return false

func _find_crafted_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(crafted_cards.size()):
		if str(crafted_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _find_blueprint_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(blueprint_cards.size()):
		if str(blueprint_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _find_enemy_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(enemy_cards.size()):
		if str(enemy_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _find_dog_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(dog_cards.size()):
		if str(dog_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _find_material_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(material_cards.size()):
		if str(material_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _is_storage_crafted_type(crafted_type: String) -> bool:
	return crafted_type in STORAGE_CRAFTED_TYPES

func _is_cage_crafted_type(crafted_type: String) -> bool:
	return crafted_type.contains("cage")

func is_enemy_cage_crafted_card(card_id: String) -> bool:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return false
	return _is_cage_crafted_type(str(crafted_cards[crafted_index].get("type", "")))

func is_enemy_cage_occupied(card_id: String) -> bool:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return false
	return not Dictionary(crafted_cards[crafted_index].get("captive_enemy", {})).is_empty()

func get_caged_enemy(card_id: String) -> Dictionary:
	var crafted_index := _find_crafted_card_index(card_id)
	if crafted_index == -1:
		return {}
	return Dictionary(crafted_cards[crafted_index].get("captive_enemy", {})).duplicate(true)

func capture_enemy_in_cage(cage_id: String, enemy_id: String) -> Dictionary:
	var cage_index := _find_crafted_card_index(cage_id)
	if cage_index == -1:
		return {"ok": false, "message": "Cage not found"}
	var cage_card := Dictionary(crafted_cards[cage_index]).duplicate(true)
	if not _is_cage_crafted_type(str(cage_card.get("type", ""))):
		return {"ok": false, "message": "Card is not a cage"}
	if not Dictionary(cage_card.get("captive_enemy", {})).is_empty():
		return {"ok": false, "message": "Cage already occupied"}
	var enemy_index := -1
	for card_index in range(enemy_cards.size()):
		if str(enemy_cards[card_index].get("id", "")) == enemy_id:
			enemy_index = card_index
			break
	if enemy_index == -1:
		return {"ok": false, "message": "Enemy not found"}
	var enemy_card: Dictionary = Dictionary(enemy_cards[enemy_index]).duplicate(true)
	enemy_cards.remove_at(enemy_index)
	cage_card["captive_enemy"] = enemy_card
	crafted_cards[cage_index] = cage_card
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"enemy": enemy_card.duplicate(true),
		"message": "%s captured" % str(enemy_card.get("display_name", "Enemy")),
	}

func release_enemy_from_cage(cage_id: String) -> Dictionary:
	var cage_index := _find_crafted_card_index(cage_id)
	if cage_index == -1:
		return {"ok": false, "message": "Cage not found"}
	var cage_card := Dictionary(crafted_cards[cage_index]).duplicate(true)
	var captive_enemy: Dictionary = Dictionary(cage_card.get("captive_enemy", {})).duplicate(true)
	if captive_enemy.is_empty():
		return {"ok": false, "message": "Cage is empty"}
	cage_card["captive_enemy"] = {}
	crafted_cards[cage_index] = cage_card
	enemy_cards.append(captive_enemy)
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"enemy": captive_enemy.duplicate(true),
		"message": "%s released" % str(captive_enemy.get("display_name", "Enemy")),
	}

func is_wolf_taming_cage(card_id: String) -> bool:
	if not is_enemy_cage_occupied(card_id):
		return false
	var captive_enemy := get_caged_enemy(card_id)
	return str(captive_enemy.get("type", "")).strip_edges() == "wolf_pack"

func resolve_enemy_cage_capture(cage_id: String, enemy_id: String) -> Dictionary:
	var cage_index := _find_crafted_card_index(cage_id)
	if cage_index == -1:
		return {"ok": false, "message": "Cage not found"}
	var cage_card := Dictionary(crafted_cards[cage_index]).duplicate(true)
	if not _is_cage_crafted_type(str(cage_card.get("type", ""))):
		return {"ok": false, "message": "Card is not a cage"}
	if not Dictionary(cage_card.get("captive_enemy", {})).is_empty():
		return {"ok": false, "message": "Cage already occupied"}
	var enemy_index := _find_enemy_card_index(enemy_id)
	if enemy_index == -1:
		return {"ok": false, "message": "Enemy not found"}
	var enemy_card: Dictionary = Dictionary(enemy_cards[enemy_index]).duplicate(true)
	var operator_energy := maxi(int(operator_state.get("energy", 0)), 0)
	var enemy_hp := maxi(int(enemy_card.get("hp", 1)), 1)
	var enemy_attack := maxi(int(enemy_card.get("attack", 1)), 1)
	var success_chance := clampf(0.52 + float(operator_energy) * 0.04 - float(enemy_hp) * 0.03 - float(enemy_attack) * 0.05, 0.12, 0.92)
	if randf() <= success_chance:
		var capture_result := capture_enemy_in_cage(cage_id, enemy_id)
		capture_result["success"] = true
		capture_result["chance"] = success_chance
		capture_result["enemy"] = enemy_card.duplicate(true)
		capture_result["enemy_hp"] = enemy_hp
		capture_result["enemy_attack"] = enemy_attack
		capture_result["operator_energy"] = operator_energy
		return capture_result
	forget_state_table_card("structure", cage_id)
	return {
		"ok": true,
		"success": false,
		"chance": success_chance,
		"enemy": enemy_card.duplicate(true),
		"enemy_hp": enemy_hp,
		"enemy_attack": enemy_attack,
		"operator_energy": operator_energy,
		"cage_destroyed": true,
		"message": "%s broke the cage" % str(enemy_card.get("display_name", "Enemy")),
	}

func resolve_wolf_taming(cage_id: String, material_id: String) -> Dictionary:
	var cage_index := _find_crafted_card_index(cage_id)
	if cage_index == -1:
		return {"ok": false, "message": "Cage not found"}
	var cage_card := Dictionary(crafted_cards[cage_index]).duplicate(true)
	if not _is_cage_crafted_type(str(cage_card.get("type", ""))):
		return {"ok": false, "message": "Card is not a cage"}
	var captive_enemy: Dictionary = Dictionary(cage_card.get("captive_enemy", {})).duplicate(true)
	if str(captive_enemy.get("type", "")).strip_edges() != "wolf_pack":
		return {"ok": false, "message": "Only captured wolves can be tamed"}
	var material_index := _find_material_card_index(material_id)
	if material_index == -1:
		return {"ok": false, "message": "Bone card not found"}
	var material_card := Dictionary(material_cards[material_index]).duplicate(true)
	if str(material_card.get("type", "")).strip_edges() != "bone":
		return {"ok": false, "message": "Use bone to start taming"}
	var operator_energy := maxi(int(operator_state.get("energy", 0)), 0)
	var enemy_hp := maxi(int(captive_enemy.get("hp", 1)), 1)
	var enemy_attack := maxi(int(captive_enemy.get("attack", 1)), 1)
	var success_chance := clampf(0.36 + float(operator_energy) * 0.03 - float(enemy_hp) * 0.03 - float(enemy_attack) * 0.04, 0.18, 0.84)
	var quantity := maxi(int(material_card.get("quantity", 0)), 0) - 1
	var removed_material := false
	if quantity <= 0:
		material_cards.remove_at(material_index)
		removed_material = true
	else:
		material_cards[material_index]["quantity"] = quantity
	if randf() <= success_chance:
		cage_card["captive_enemy"] = {}
		crafted_cards[cage_index] = cage_card
		var dog_card := _add_dog_card({
			"display_name": "DOG",
			"source_enemy_type": "wolf_pack",
		})
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return {
			"ok": true,
			"success": true,
			"chance": success_chance,
			"dog_card": dog_card,
			"removed_material": removed_material,
			"remaining_quantity": maxi(quantity, 0),
			"message": "Wolf tamed",
		}
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"success": false,
		"chance": success_chance,
		"removed_material": removed_material,
		"remaining_quantity": maxi(quantity, 0),
		"message": "Taming failed",
	}

func use_crafted_card_on_operator(card_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No crafted card selected"}
	if not is_run_active():
		return {"ok": false, "message": "Operator can no longer use supplies"}
	for card_index in range(crafted_cards.size()):
		var crafted_card: Dictionary = crafted_cards[card_index]
		if str(crafted_card.get("id", "")) != card_id:
			continue
		var use_result := _apply_operator_supply_effect(str(crafted_card.get("result", "")))
		if not bool(use_result.get("ok", false)):
			return use_result
		crafted_cards.remove_at(card_index)
		save_programmed_cartridges()
		EventBus.operator_state_changed.emit(get_operator_state())
		EventBus.outside_world_changed.emit()
		return use_result
	return {"ok": false, "message": "Crafted card not found"}

func use_material_card_on_operator(card_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No resource card selected"}
	if not is_run_active():
		return {"ok": false, "message": "Operator can no longer use supplies"}
	for card_index in range(material_cards.size()):
		var material_card: Dictionary = material_cards[card_index]
		if str(material_card.get("id", "")) != card_id:
			continue
		var use_result := _apply_operator_supply_effect(str(material_card.get("type", "")))
		if not bool(use_result.get("ok", false)):
			return use_result
		var quantity := maxi(int(material_card.get("quantity", 0)), 0) - 1
		var removed := false
		if quantity <= 0:
			material_cards.remove_at(card_index)
			removed = true
		else:
			material_cards[card_index]["quantity"] = quantity
		save_programmed_cartridges()
		EventBus.operator_state_changed.emit(get_operator_state())
		EventBus.outside_world_changed.emit()
		use_result["removed"] = removed
		use_result["remaining_quantity"] = maxi(quantity, 0)
		return use_result
	return {"ok": false, "message": "Resource card not found"}

func use_crafted_card_on_dog(card_id: String, dog_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No crafted card selected"}
	var dog_index := _find_dog_card_index(dog_id)
	if dog_index == -1:
		return {"ok": false, "message": "Dog not found"}
	for card_index in range(crafted_cards.size()):
		var crafted_card: Dictionary = crafted_cards[card_index]
		if str(crafted_card.get("id", "")) != card_id:
			continue
		var dog_card := Dictionary(dog_cards[dog_index]).duplicate(true)
		var use_result := _apply_dog_supply_effect(dog_card, str(crafted_card.get("result", "")))
		if not bool(use_result.get("ok", false)):
			return use_result
		dog_cards[dog_index] = Dictionary(use_result.get("dog_card", dog_card)).duplicate(true)
		crafted_cards.remove_at(card_index)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return use_result
	return {"ok": false, "message": "Crafted card not found"}

func use_material_card_on_dog(card_id: String, dog_id: String) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No resource card selected"}
	var dog_index := _find_dog_card_index(dog_id)
	if dog_index == -1:
		return {"ok": false, "message": "Dog not found"}
	for card_index in range(material_cards.size()):
		var material_card: Dictionary = material_cards[card_index]
		if str(material_card.get("id", "")) != card_id:
			continue
		var dog_card := Dictionary(dog_cards[dog_index]).duplicate(true)
		var use_result := _apply_dog_supply_effect(dog_card, str(material_card.get("type", "")))
		if not bool(use_result.get("ok", false)):
			return use_result
		dog_cards[dog_index] = Dictionary(use_result.get("dog_card", dog_card)).duplicate(true)
		var quantity := maxi(int(material_card.get("quantity", 0)), 0) - 1
		var removed := false
		if quantity <= 0:
			material_cards.remove_at(card_index)
			removed = true
		else:
			material_cards[card_index]["quantity"] = quantity
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		use_result["removed"] = removed
		use_result["remaining_quantity"] = maxi(quantity, 0)
		return use_result
	return {"ok": false, "message": "Resource card not found"}

func use_material_card_on_bot(card_id: String, bot_index: int) -> Dictionary:
	if card_id.is_empty():
		return {"ok": false, "message": "No resource card selected"}
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return {"ok": false, "message": "Drone not found"}
	if not is_bot_available_in_workshop(bot_index):
		return {"ok": false, "message": "Drone is not in workshop"}
	for card_index in range(material_cards.size()):
		var material_card: Dictionary = material_cards[card_index]
		if str(material_card.get("id", "")) != card_id:
			continue
		var material_type := str(material_card.get("type", ""))
		if material_type != "power_unit":
			return {"ok": false, "message": "%s cannot be used on the drone" % _default_material_display_name(material_type)}
		var max_power_charge := int(bot_loadouts[bot_index].get("max_power_charge", BOT_POWER_CAPACITY))
		var current_power := int(bot_loadouts[bot_index].get("power_charge", 0))
		var missing_power := maxi(max_power_charge - current_power, 0)
		if missing_power <= 0:
			return {"ok": false, "message": "%s is already full" % _bot_display_name(bot_index)}
		var available_units := maxi(int(material_card.get("quantity", 0)), 0)
		if available_units <= 0:
			return {"ok": false, "message": "No power units"}
		var consumed := mini(available_units, missing_power)
		bot_loadouts[bot_index]["power_charge"] = current_power + consumed
		_sync_power_card_count(bot_loadouts[bot_index])
		_refresh_bot_predictions()
		var remaining_quantity := available_units - consumed
		var removed := false
		if remaining_quantity <= 0:
			material_cards.remove_at(card_index)
			removed = true
		else:
			material_cards[card_index]["quantity"] = remaining_quantity
		save_programmed_cartridges()
		EventBus.bot_loadouts_changed.emit(bot_loadouts)
		EventBus.outside_world_changed.emit()
		return {
			"ok": true,
			"charged": consumed,
			"removed": removed,
			"remaining_quantity": maxi(remaining_quantity, 0),
			"power_charge": int(bot_loadouts[bot_index].get("power_charge", 0)),
			"message": "%s charged" % _bot_display_name(bot_index),
		}
	return {"ok": false, "message": "Resource card not found"}

func create_blueprint_card(recipe: Dictionary) -> Dictionary:
	if recipe.is_empty():
		return {}
	var recipe_id := str(recipe.get("id", ""))
	var formula_parts: Array = _sanitize_recipe_parts(Array(recipe.get("formula_parts", [])).duplicate(true))
	if formula_parts.is_empty() and not recipe_id.is_empty():
		var live_recipe := _get_loaded_recipe_by_id(recipe_id)
		if not live_recipe.is_empty():
			formula_parts = _sanitize_recipe_parts(Array(live_recipe.get("formula_parts", [])).duplicate(true))
	if formula_parts.is_empty():
		formula_parts = _sanitize_recipe_parts(_formula_parts_from_formula_string(str(recipe.get("formula", ""))))
	var blueprint_card := {
		"id": "blueprint_%d_%d" % [int(Time.get_unix_time_from_system()), blueprint_cards.size()],
		"recipe_id": str(recipe.get("id", "")),
		"result": str(recipe.get("result", "Blueprint")),
		"formula": "%s = %s" % [str(recipe.get("result", "Blueprint")).to_upper(), _join_formula_parts(formula_parts)],
		"formula_parts": formula_parts,
		"subject_key": str(recipe.get("subject_key", "")),
	}
	blueprint_cards.append(blueprint_card)
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return blueprint_card.duplicate(true)

func resolve_blueprint_craft(blueprint_id: String, material_consumptions: Array) -> Dictionary:
	if blueprint_id.is_empty():
		return {}
	var blueprint_index := -1
	for card_index in range(blueprint_cards.size()):
		if str(blueprint_cards[card_index].get("id", "")) == blueprint_id:
			blueprint_index = card_index
			break
	if blueprint_index == -1:
		return {}
	var blueprint_card: Dictionary = blueprint_cards[blueprint_index]
	var result_name := str(blueprint_card.get("result", "")).to_upper()
	var crafted_result_spec := _get_craft_result_spec(result_name)
	var result_kind := str(crafted_result_spec.get("kind", "structure"))
	if result_kind == "crafted":
		result_kind = "structure"
	for consumption_variant in material_consumptions:
		if typeof(consumption_variant) != TYPE_DICTIONARY:
			return {}
		var consumption: Dictionary = consumption_variant
		var material_id := str(consumption.get("card_id", ""))
		var quantity := maxi(int(consumption.get("quantity", 0)), 0)
		if material_id.is_empty() or quantity <= 0:
			return {}
		if not _consume_material_quantity(material_id, quantity):
			return {}
	if result_kind == "blank":
		blank_cartridge_slots.append(true)
		blueprint_cards.remove_at(blueprint_index)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return {
			"kind": "blank",
			"result": result_name,
			"type": str(crafted_result_spec.get("type", "blank_tape")),
			"display_name": str(crafted_result_spec.get("display_name", "Fresh Tape")),
			"blank_index": blank_cartridge_slots.size() - 1,
		}
	if result_kind == "material":
		var created_material := _add_material_card({
			"type": str(crafted_result_spec.get("type", _result_name_to_type(result_name))),
			"display_name": str(crafted_result_spec.get("display_name", result_name)),
			"quantity": maxi(int(crafted_result_spec.get("quantity", 1)), 1),
			"source_recipe_id": str(blueprint_card.get("recipe_id", "")),
		})
		if created_material.is_empty():
			return {}
		blueprint_cards.remove_at(blueprint_index)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		created_material["kind"] = "material"
		return created_material.duplicate(true)
	if result_kind == "equipment":
		var created_equipment := _add_equipment_card({
			"type": str(crafted_result_spec.get("type", _result_name_to_type(result_name))),
			"display_name": str(crafted_result_spec.get("display_name", result_name)),
		})
		if created_equipment.is_empty():
			return {}
		blueprint_cards.remove_at(blueprint_index)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		created_equipment["kind"] = "equipment"
		return created_equipment.duplicate(true)
	var created_kind := "structure"
	var created_id_prefix := "structure"
	if result_kind == "mechanism":
		created_kind = "mechanism"
		created_id_prefix = "mechanism"
	var crafted_card := {
		"id": "%s_%d_%d" % [created_id_prefix, int(Time.get_unix_time_from_system()), crafted_cards.size()],
		"type": str(crafted_result_spec.get("type", _result_name_to_type(result_name))),
		"display_name": str(crafted_result_spec.get("display_name", result_name.replace("_", " ").capitalize())),
		"result": str(blueprint_card.get("result", "Crafted Item")),
		"recipe_id": str(blueprint_card.get("recipe_id", "")),
		"formula": str(blueprint_card.get("formula", "")),
		"stored_cards": [],
		"captive_enemy": {},
	}
	blueprint_cards.remove_at(blueprint_index)
	crafted_cards.append(crafted_card)
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	crafted_card["kind"] = created_kind
	return crafted_card.duplicate(true)

func resolve_journal_research(subject: Dictionary) -> Dictionary:
	var subject_key := _get_research_subject_key(subject)
	if subject_key.is_empty():
		return {}
	var subject_def := _get_research_subject_definition(subject)
	if subject_def.is_empty():
		return {}
	var consumption := _consume_research_subject(subject)
	if subject.get("requires_quantity", false) and not bool(consumption.get("consumed", false)):
		return {}
	var entry_index := _get_journal_entry_index(subject_key)
	var created_entry := false
	if entry_index == -1:
		journal_entries.append({
			"subject_key": subject_key,
			"subject_kind": str(subject_def.get("subject_kind", "")),
			"subject_type": str(subject_def.get("subject_type", "")),
			"title": str(subject_def.get("title", subject_key.replace("_", " ").to_upper())),
			"description": str(subject_def.get("description", "")),
			"recipe_ids": _get_related_recipe_ids(subject_key),
			"recipes": [],
			"unread": true,
			"attempts": 0,
		})
		entry_index = journal_entries.size() - 1
		created_entry = true
	var entry: Dictionary = journal_entries[entry_index].duplicate(true)
	entry["attempts"] = int(entry.get("attempts", 0)) + 1
	var known_recipe_ids := {}
	for recipe_variant in Array(entry.get("recipes", [])):
		if typeof(recipe_variant) != TYPE_DICTIONARY:
			continue
		var recipe: Dictionary = recipe_variant
		known_recipe_ids[str(recipe.get("id", ""))] = true
	var undiscovered: Array = []
	for recipe_variant in Array(subject_def.get("recipes", [])):
		if typeof(recipe_variant) != TYPE_DICTIONARY:
			continue
		var recipe: Dictionary = recipe_variant
		if known_recipe_ids.has(str(recipe.get("id", ""))):
			continue
		undiscovered.append(recipe.duplicate(true))
	var discovered_recipe := {}
	var success := false
	var failure_penalty := {}
	var chance := 0.42 if Array(entry.get("recipes", [])).is_empty() else 0.32
	if not undiscovered.is_empty() and randf() <= chance:
		discovered_recipe = Dictionary(undiscovered[randi() % undiscovered.size()]).duplicate(true)
		discovered_recipe["unread"] = true
		var entry_recipes: Array = Array(entry.get("recipes", [])).duplicate(true)
		entry_recipes.append(discovered_recipe)
		entry["recipes"] = entry_recipes
		entry["unread"] = true
		success = true
	elif created_entry:
		entry["unread"] = true
	if not success:
		failure_penalty = _apply_operator_research_penalty(randi_range(1, 2), 1 if randf() < 0.45 else 0)
	entry["recipe_ids"] = _get_related_recipe_ids(subject_key)
	journal_entries[entry_index] = entry
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.outside_world_changed.emit()
	return {
		"success": success,
		"created_entry": created_entry,
		"subject_key": subject_key,
		"entry": entry.duplicate(true),
		"recipe": discovered_recipe.duplicate(true),
		"consumption": consumption.duplicate(true),
		"failure_penalty": failure_penalty.duplicate(true),
	}

func resolve_enemy_fight(enemy_id: String, use_operator: bool, bot_indices: Array, dog_ids: Array = []) -> Dictionary:
	if enemy_id.is_empty():
		return {}
	var enemy_index := -1
	for card_index in range(enemy_cards.size()):
		if str(enemy_cards[card_index].get("id", "")) == enemy_id:
			enemy_index = card_index
			break
	if enemy_index == -1:
		return {}
	var enemy_card: Dictionary = enemy_cards[enemy_index]
	var enemy_attack := maxi(int(enemy_card.get("attack", int(enemy_card.get("threat_level", 1)))), 1)
	var enemy_hp := maxi(int(enemy_card.get("hp", 1)), 1)
	var enemy_armor := maxi(int(enemy_card.get("armor", 0)), 0)
	var total_attack := 0
	var operator_attack := 0
	var operator_damage := 0
	var bot_damage_events: Array = []
	var bot_attack_events: Array = []
	var dog_damage_events: Array = []
	var dog_attack_events: Array = []
	var dog_drop_events: Array = []
	var combat_participants: Array = []
	var dog_participants: Array = []
	var dead_dog_indices: Array = []
	if use_operator and is_run_active():
		var operator_totals := get_operator_equipment_totals()
		operator_attack = 2 + int(operator_totals.get("attack", 0))
		total_attack += operator_attack
	for bot_index_variant in bot_indices:
		var bot_index := int(bot_index_variant)
		if bot_index < 0 or bot_index >= bot_loadouts.size():
			continue
		var bot_state: Dictionary = bot_loadouts[bot_index]
		if int(bot_state.get("power_charge", 0)) <= 0:
			continue
		var instruction_type := _get_bot_combat_instruction_type(bot_index)
		combat_participants.append(bot_index)
		if instruction_type == "atk":
			var bot_totals := get_bot_equipment_totals(bot_index)
			var bot_type := get_bot_drone_type(bot_index)
			var bot_def := get_drone_type_definition(bot_type)
			var bot_attack := int(bot_def.get("attack", 2)) + int(bot_totals.get("attack", 0))
			total_attack += bot_attack
			bot_attack_events.append({
				"bot_index": bot_index,
				"attack": bot_attack,
			})
	for dog_id_variant in dog_ids:
		var dog_id := str(dog_id_variant)
		var dog_index := _find_dog_card_index(dog_id)
		if dog_index == -1:
			continue
		var dog_card: Dictionary = Dictionary(dog_cards[dog_index]).duplicate(true)
		if int(dog_card.get("energy", 0)) <= 0:
			continue
		if int(dog_card.get("hp", 0)) <= 0:
			continue
		if str(dog_card.get("status", "active")) == "dead":
			continue
		var dog_totals := get_dog_combat_totals(dog_id)
		var dog_attack := maxi(int(dog_totals.get("attack", DOG_BASE_ATTACK)), 0)
		total_attack += dog_attack
		dog_participants.append(dog_index)
		dog_attack_events.append({
			"dog_id": dog_id,
			"attack": dog_attack,
		})
	if not use_operator and combat_participants.is_empty() and dog_participants.is_empty():
		return {}
	enemy_hp -= maxi(total_attack - enemy_armor, 0)
	if use_operator and is_run_active():
		operator_damage = maxi(enemy_attack - int(get_operator_equipment_totals().get("armor", 0)), 0)
		_apply_operator_loss(operator_damage)
	for bot_index in combat_participants:
		var bot_state: Dictionary = bot_loadouts[bot_index]
		if int(bot_state.get("power_charge", 0)) <= 0:
			continue
		var mitigated_damage := maxi(enemy_attack - int(get_bot_equipment_totals(bot_index).get("armor", 0)), 0)
		bot_state["power_charge"] = maxi(int(bot_state.get("power_charge", 0)) - mitigated_damage, 0)
		_sync_power_card_count(bot_state)
		bot_loadouts[bot_index] = bot_state
		bot_damage_events.append({
			"bot_index": bot_index,
			"damage": mitigated_damage,
		})
	for dog_index in dog_participants:
		if dog_index < 0 or dog_index >= dog_cards.size():
			continue
		var dog_card: Dictionary = Dictionary(dog_cards[dog_index]).duplicate(true)
		var dog_id := str(dog_card.get("id", ""))
		var dog_totals := get_dog_combat_totals(dog_id)
		var mitigated_damage := maxi(enemy_attack - int(dog_totals.get("armor", 0)), 0)
		dog_card["energy"] = maxi(int(dog_card.get("energy", 0)) - 1, 0)
		dog_card["hp"] = maxi(int(dog_card.get("hp", 0)) - mitigated_damage, 0)
		dog_damage_events.append({
			"dog_id": dog_id,
			"damage": mitigated_damage,
		})
		if int(dog_card.get("hp", 0)) <= 0:
			dog_card["status"] = "dead"
			dog_cards[dog_index] = dog_card
			var source_enemy_type := str(dog_card.get("source_enemy_type", "wolf_pack"))
			var dog_drop_card := _build_enemy_drop_card(source_enemy_type)
			if not dog_drop_card.is_empty() and str(dog_drop_card.get("kind", "")) == "material":
				material_cards.append(dog_drop_card)
			dog_drop_events.append({
				"dog_id": dog_id,
				"drop_card": dog_drop_card.duplicate(true),
				"display_name": str(dog_card.get("display_name", "DOG")),
			})
			dead_dog_indices.append(dog_index)
		else:
			dog_cards[dog_index] = dog_card
	dead_dog_indices.sort()
	for dead_dog_index in range(dead_dog_indices.size() - 1, -1, -1):
		var participant_index := int(dead_dog_indices[dead_dog_index])
		if participant_index < 0 or participant_index >= dog_cards.size():
			continue
		dog_cards.remove_at(participant_index)
	var defeated := enemy_hp <= 0
	var drop_card := {}
	if defeated:
		enemy_cards.remove_at(enemy_index)
		drop_card = _build_enemy_drop_card(str(enemy_card.get("type", "")))
		if not drop_card.is_empty() and str(drop_card.get("kind", "")) == "material":
			material_cards.append(drop_card)
	else:
		enemy_cards[enemy_index]["hp"] = enemy_hp
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return {
		"defeated": defeated,
		"enemy_name": str(enemy_card.get("display_name", _default_enemy_display_name(str(enemy_card.get("type", "hostile_creature"))))),
		"enemy_type": str(enemy_card.get("type", "hostile_creature")),
		"enemy_id": enemy_id,
		"total_attack": total_attack,
		"enemy_attack": enemy_attack,
		"enemy_armor": enemy_armor,
		"operator_attack": operator_attack,
		"operator_damage": operator_damage,
		"bot_attacks": bot_attack_events,
		"bot_damage": bot_damage_events,
		"dog_attacks": dog_attack_events,
		"dog_damage": dog_damage_events,
		"dog_drops": dog_drop_events,
		"remaining_hp": maxi(enemy_hp, 0),
		"drop_card": drop_card.duplicate(true),
	}

func can_operator_scan_route() -> bool:
	return is_run_active()

func resolve_operator_scan() -> Dictionary:
	if not can_operator_scan_route():
		return {}
	if randf() < 0.35:
		var enemy_card := _build_enemy_scan_card()
		enemy_cards.append(enemy_card)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return {"kind": "enemy", "card": enemy_card.duplicate(true)}
	var location_card := _build_random_operator_location_card()
	location_cards.append(location_card)
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {"kind": "location", "card": location_card.duplicate(true)}

func load_programmed_cartridges():
	programmed_cartridges.clear()
	_initialize_blank_slots()
	_initialize_power_unit_slots()
	selected_cartridge_id = ""
	_initialize_operator_state()
	_initialize_bot_loadouts()
	_initialize_outside_objects()
	location_cards = []
	enemy_cards = []
	material_cards = []
	blueprint_cards = []
	crafted_cards = []
	equipment_cards = []
	journal_entries = []
	workshop_layout = {}
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
		blank_cartridge_slots.clear()
		for blank_entry in blank_data:
			if bool(blank_entry):
				blank_cartridge_slots.append(true)
	selected_cartridge_id = str(parsed.get("selected_cartridge_id", ""))

	var bot_data: Array = parsed.get("bot_loadouts", [])
	if typeof(bot_data) == TYPE_ARRAY:
		while bot_loadouts.size() < bot_data.size():
			var next_index := bot_loadouts.size()
			var next_entry: Variant = bot_data[next_index]
			var next_type := ""
			if typeof(next_entry) == TYPE_DICTIONARY:
				next_type = str(next_entry.get("drone_type", ""))
			bot_loadouts.append(_default_bot_state(next_index, next_type))
		for bot_index in range(mini(bot_data.size(), bot_loadouts.size())):
			var bot_entry: Variant = bot_data[bot_index]
			if typeof(bot_entry) != TYPE_DICTIONARY:
				continue
			_apply_saved_bot_entry(bot_index, bot_entry)

	var saved_operator_state: Variant = parsed.get("operator_state", {})
	if typeof(saved_operator_state) == TYPE_DICTIONARY:
		operator_state["max_energy"] = maxi(int(saved_operator_state.get("max_energy", OPERATOR_MAX_ENERGY)), OPERATOR_MAX_ENERGY)
		operator_state["energy"] = clampi(int(saved_operator_state.get("energy", OPERATOR_MAX_ENERGY)), 0, int(operator_state["max_energy"]))
		operator_state["max_hp"] = maxi(int(saved_operator_state.get("max_hp", OPERATOR_MAX_HP)), OPERATOR_MAX_HP)
		operator_state["hp"] = clampi(int(saved_operator_state.get("hp", OPERATOR_MAX_HP)), 0, int(operator_state["max_hp"]))
		operator_state["status"] = str(saved_operator_state.get("status", "active"))
		operator_state["profile_id"] = str(saved_operator_state.get("profile_id", ""))
		operator_state["display_name"] = str(saved_operator_state.get("display_name", ""))
		operator_state["focus"] = str(saved_operator_state.get("focus", ""))
		operator_state["equipment_slots"] = _normalize_equipment_slots(Array(saved_operator_state.get("equipment_slots", [])))
		_apply_operator_profile_defaults()

	var object_data: Array = parsed.get("outside_objects", [])
	if typeof(object_data) == TYPE_ARRAY:
		_apply_saved_outside_objects(object_data)

	var saved_location_cards: Array = parsed.get("location_cards", [])
	if typeof(saved_location_cards) == TYPE_ARRAY:
		location_cards = _normalize_saved_location_cards(saved_location_cards)

	var saved_enemy_cards: Array = parsed.get("enemy_cards", [])
	if typeof(saved_enemy_cards) == TYPE_ARRAY:
		enemy_cards = _normalize_saved_enemy_cards(saved_enemy_cards)

	var saved_dog_cards: Array = parsed.get("dog_cards", [])
	if typeof(saved_dog_cards) == TYPE_ARRAY:
		dog_cards = _normalize_saved_dog_cards(saved_dog_cards)

	var saved_material_cards: Array = parsed.get("material_cards", [])
	if typeof(saved_material_cards) == TYPE_ARRAY:
		material_cards = _normalize_saved_material_cards(saved_material_cards)
	var migrated_power_units := 0
	var power_data: Array = parsed.get("power_unit_slots", [])
	if typeof(power_data) == TYPE_ARRAY:
		for power_entry_variant in power_data:
			if typeof(power_entry_variant) != TYPE_DICTIONARY:
				continue
			var power_entry: Dictionary = power_entry_variant
			var saved_max_charge := maxi(int(power_entry.get("max_charge", BOT_POWER_CAPACITY)), BOT_POWER_CAPACITY)
			var normalized_charge := clampi(int(power_entry.get("charge", 0)), 0, saved_max_charge)
			migrated_power_units += normalized_charge
	if migrated_power_units > 0:
		_add_material_card({"type": "power_unit", "quantity": migrated_power_units})
	power_unit_slots.clear()

	var saved_blueprint_cards: Array = parsed.get("blueprint_cards", [])
	if typeof(saved_blueprint_cards) == TYPE_ARRAY:
		blueprint_cards = _normalize_saved_blueprint_cards(saved_blueprint_cards)

	var saved_structure_cards: Array = parsed.get("structure_cards", parsed.get("crafted_cards", []))
	var saved_mechanism_cards: Array = parsed.get("mechanism_cards", [])
	var normalized_legacy_table_cards := false
	if typeof(saved_structure_cards) == TYPE_ARRAY and typeof(saved_mechanism_cards) == TYPE_ARRAY:
		var merged_table_cards := _normalize_saved_table_cards(saved_structure_cards, saved_mechanism_cards)
		crafted_cards = Array(merged_table_cards.get("cards", []))
		normalized_legacy_table_cards = bool(merged_table_cards.get("normalized_legacy", false))
	var saved_equipment_cards: Array = parsed.get("equipment_cards", [])
	if typeof(saved_equipment_cards) == TYPE_ARRAY:
		equipment_cards = _normalize_saved_equipment_cards(saved_equipment_cards)
	_migrate_stackable_crafted_cards_to_materials()
	_migrate_equipment_like_crafted_cards_to_equipment()

	var saved_journal_entries: Array = parsed.get("journal_entries", [])
	if typeof(saved_journal_entries) == TYPE_ARRAY:
		journal_entries = _normalize_saved_journal_entries(saved_journal_entries)

	var layout_data: Variant = parsed.get("workshop_layout", {})
	if typeof(layout_data) == TYPE_DICTIONARY:
		workshop_layout = layout_data.duplicate(true)

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

	var normalized_bot_states := _normalize_loaded_bot_states()
	var normalized_legacy_power_units := migrated_power_units > 0

	_refresh_bot_predictions()
	if normalized_bot_states or normalized_legacy_power_units or normalized_legacy_table_cards:
		save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())

func save_programmed_cartridges():
	var file := FileAccess.open(CARTRIDGE_STORAGE_PATH, FileAccess.WRITE)
	if file == null:
		return

	var saved_structure_cards := get_structure_cards()
	var saved_mechanism_cards := get_mechanism_cards()
	var data := {
		"selected_cartridge_id": selected_cartridge_id,
		"cartridges": programmed_cartridges,
		"blank_cartridge_slots": blank_cartridge_slots,
		"power_unit_slots": power_unit_slots,
		"bot_loadouts": _serialize_bot_loadouts(),
		"outside_objects": _serialize_outside_objects(),
		"location_cards": location_cards,
		"enemy_cards": enemy_cards,
		"dog_cards": dog_cards,
		"material_cards": material_cards,
		"blueprint_cards": blueprint_cards,
		"crafted_cards": saved_structure_cards + saved_mechanism_cards,
		"structure_cards": saved_structure_cards,
		"mechanism_cards": saved_mechanism_cards,
		"equipment_cards": equipment_cards,
		"journal_entries": journal_entries,
		"workshop_layout": workshop_layout,
		"operator_state": operator_state,
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
	for bot_index in range(START_BOT_TYPES.size()):
		bot_loadouts.append(_default_bot_state(bot_index, str(START_BOT_TYPES[bot_index])))

func _initialize_operator_state():
	operator_state = {
		"energy": OPERATOR_MAX_ENERGY,
		"max_energy": OPERATOR_MAX_ENERGY,
		"hp": OPERATOR_MAX_HP,
		"max_hp": OPERATOR_MAX_HP,
		"status": "active",
		"profile_id": "",
		"display_name": "OPERATOR",
		"focus": "",
		"equipment_slots": _default_equipment_slots(),
	}

func _default_dog_card(entry: Dictionary = {}) -> Dictionary:
	var max_energy := maxi(int(entry.get("max_energy", DOG_MAX_ENERGY)), DOG_MAX_ENERGY)
	var max_hp := maxi(int(entry.get("max_hp", DOG_MAX_HP)), DOG_MAX_HP)
	return {
		"id": str(entry.get("id", "dog_%d_%d" % [int(Time.get_unix_time_from_system()), dog_cards.size()])),
		"type": "dog",
		"display_name": str(entry.get("display_name", "DOG")),
		"energy": clampi(int(entry.get("energy", max_energy)), 0, max_energy),
		"max_energy": max_energy,
		"hp": clampi(int(entry.get("hp", max_hp)), 0, max_hp),
		"max_hp": max_hp,
		"status": str(entry.get("status", "active")),
		"base_attack": maxi(int(entry.get("base_attack", DOG_BASE_ATTACK)), 0),
		"base_armor": int(entry.get("base_armor", DOG_BASE_ARMOR)),
		"equipment_slots": _normalize_equipment_slots(Array(entry.get("equipment_slots", []))),
		"source_enemy_type": str(entry.get("source_enemy_type", "wolf_pack")),
	}

func _default_bot_state(bot_index: int, drone_type: String = "") -> Dictionary:
	var resolved_type := _normalize_drone_type(drone_type)
	return {
		"id": "cabinet_a%d" % [bot_index + 1],
		"drone_type": resolved_type,
		"loaded_cartridge_id": "",
		"combat_ptr": 0,
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
		"pending_location_cards": [],
		"mission_location_id": "",
		"mission_location_type": "",
		"mission_location_position": get_shelter_position(),
		"pending_salvage_drops": [],
		"mission_pickups": 0,
		"mission_pickup_attempts": 0,
		"mission_encounters": 0,
		"activity_tick": 0,
		"activity_log": [],
		"last_mission_summary": "",
		"equipment_slots": _default_equipment_slots(),
	}

func _default_equipment_slots() -> Array:
	var slots: Array = []
	for slot_index in range(UNIT_EQUIPMENT_SLOT_COUNT):
		slots.append({
			"slot_index": slot_index,
			"item_type": "",
			"display_name": "",
		})
	return slots

func _normalize_equipment_slots(saved_slots: Array) -> Array:
	var slots := _default_equipment_slots()
	for slot_index in range(mini(saved_slots.size(), UNIT_EQUIPMENT_SLOT_COUNT)):
		var saved_slot: Variant = saved_slots[slot_index]
		if typeof(saved_slot) != TYPE_DICTIONARY:
			continue
		var item_type := str(saved_slot.get("item_type", ""))
		var display_name := str(saved_slot.get("display_name", ""))
		if display_name.is_empty() and not item_type.is_empty():
			display_name = _get_equipment_display_name(item_type)
		slots[slot_index] = {
			"slot_index": slot_index,
			"item_type": item_type,
			"display_name": display_name,
		}
	return slots

func _initialize_blank_slots():
	blank_cartridge_slots.clear()
	for _slot_index in range(BLANK_CARTRIDGE_SLOT_COUNT):
		blank_cartridge_slots.append(true)

func _initialize_power_unit_slots():
	power_unit_slots.clear()

func _initialize_outside_objects():
	outside_objects = [
		{"id": "supply_cache", "type": "resource", "position": Vector2(2, 3), "discovered": false},
		{"id": "rust_pit", "type": "hazard", "position": Vector2(8, 2), "discovered": false},
		{"id": "old_tower", "type": "landmark", "position": Vector2(8, 8), "discovered": false},
		{"id": "watch_arc", "type": "surveillance", "position": Vector2(3, 8), "discovered": false},
	]

func _build_random_operator_location_card() -> Dictionary:
	var location_types := [
		"cache",
		"crater",
		"tower",
		"surveillance_zone",
		"facility",
		"pond",
		"bunker",
		"field",
		"dump",
		"nest",
		"ruin",
	]
	var location_type := str(location_types[randi() % location_types.size()])
	var position := _generate_random_location_position()
	var location_id := "loc_%d_%d_%d" % [int(Time.get_unix_time_from_system()), int(position.x), int(position.y)]
	return {
		"id": location_id,
		"type": location_type,
		"display_name": _generate_markov_name(LOCATION_NAME_CORPUS, true),
		"image_seed": randi(),
		"position": _serialize_vector(position),
		"survey_level": 2,
		"source": "operator_scan",
	}

func _build_enemy_scan_card(source: String = "operator_scan") -> Dictionary:
	var enemy_types: Array = ["surveillance_drone", "stalker", "infantry_drone", "grizzly", "wolf_pack", "warden"]
	var enemy_type: String = str(enemy_types[randi() % enemy_types.size()])
	return _build_enemy_card_for_type(enemy_type, source)

func _build_enemy_drop_card(enemy_type: String) -> Dictionary:
	var drop_table: Array = _get_loaded_enemy_loot_table(enemy_type)
	if drop_table.is_empty():
		return {}
	var drop_entry := _roll_weighted_material_drop_entry(drop_table)
	if drop_entry.is_empty():
		return {}
	var drop_kind := str(drop_entry.get("kind", "material"))
	if drop_kind == "power":
		return {
			"kind": "material",
			"id": "material_%d_%d" % [int(Time.get_unix_time_from_system()), material_cards.size()],
			"type": "power_unit",
			"display_name": "Power Unit",
			"quantity": CHARGE_MACHINE_TRANSFER_UNITS,
			"source_enemy_type": enemy_type,
		}
	var material_type := str(drop_entry.get("type", ""))
	var quantity_min := maxi(int(drop_entry.get("quantity_min", 1)), 1)
	var quantity_max := maxi(int(drop_entry.get("quantity_max", quantity_min)), quantity_min)
	return {
		"kind": "material",
		"id": "material_%d_%d" % [int(Time.get_unix_time_from_system()), material_cards.size()],
		"type": material_type,
		"display_name": material_type.replace("_", " ").capitalize(),
		"quantity": randi_range(quantity_min, quantity_max),
		"source_enemy_type": enemy_type,
	}

func _get_first_empty_power_drop_slot_index() -> int:
	for slot_index in range(power_unit_slots.size()):
		if power_unit_slots[slot_index].is_empty():
			return slot_index
	return power_unit_slots.size()

func _roll_weighted_material_drop_entry(drop_table: Array) -> Dictionary:
	var total_weight := 0
	for entry in drop_table:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		total_weight += maxi(int(entry.get("weight", 0)), 0)
	if total_weight <= 0:
		return {}
	var roll := randi_range(1, total_weight)
	var running_weight := 0
	for entry in drop_table:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		running_weight += maxi(int(entry.get("weight", 0)), 0)
		if roll <= running_weight:
			return Dictionary(entry)
	return Dictionary(drop_table[0])

func _generate_random_location_position() -> Vector2:
	var occupied := {}
	occupied[_serialize_vector(get_shelter_position())] = true
	for location_card in location_cards:
		occupied[_serialize_vector(_vector_from_variant(location_card.get("position", {}), Vector2.ZERO))] = true
	for _attempt in range(128):
		var candidate := Vector2(
			randi_range(0, int(grid_size.x) - 1),
			randi_range(0, int(grid_size.y) - 1)
		)
		if occupied.has(_serialize_vector(candidate)):
			continue
		return candidate
	return Vector2(
		randi_range(0, int(grid_size.x) - 1),
		randi_range(0, int(grid_size.y) - 1)
	)

func _apply_operator_loss(loss: int):
	if loss <= 0:
		return
	var remaining_loss := loss
	var current_energy := int(operator_state.get("energy", 0))
	if current_energy > 0:
		var energy_spent := mini(current_energy, remaining_loss)
		current_energy -= energy_spent
		remaining_loss -= energy_spent
		operator_state["energy"] = current_energy
	if remaining_loss > 0:
		operator_state["hp"] = int(operator_state.get("hp", 0)) - remaining_loss
	if int(operator_state.get("hp", 0)) <= 0:
		operator_state["hp"] = 0
		operator_state["status"] = "dead"
	else:
		operator_state["status"] = "exhausted" if int(operator_state.get("energy", 0)) <= 0 else "active"
	if str(operator_state.get("status", "")) == "dead":
		EventBus.log_message.emit("Operator collapsed. Run ended.")

func _apply_operator_research_penalty(energy_loss: int, hp_loss: int) -> Dictionary:
	var applied_energy := mini(maxi(energy_loss, 0), maxi(int(operator_state.get("energy", 0)), 0))
	var applied_hp := mini(maxi(hp_loss, 0), maxi(int(operator_state.get("hp", 0)), 0))
	if applied_energy > 0:
		operator_state["energy"] = int(operator_state.get("energy", 0)) - applied_energy
	if applied_hp > 0:
		operator_state["hp"] = int(operator_state.get("hp", 0)) - applied_hp
	if int(operator_state.get("hp", 0)) <= 0:
		operator_state["hp"] = 0
		operator_state["status"] = "dead"
	else:
		operator_state["status"] = "exhausted" if int(operator_state.get("energy", 0)) <= 0 else "active"
	return {
		"energy_loss": applied_energy,
		"hp_loss": applied_hp,
		"collapsed": str(operator_state.get("status", "")) == "dead",
	}

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
	return 0 if not blank_cartridge_slots.is_empty() else -1

func _get_first_empty_blank_slot_index() -> int:
	return blank_cartridge_slots.size()

func _get_first_free_programmed_slot_index() -> int:
	return programmed_cartridges.size()

func _decode_program_from_rows(rows: Array) -> Array:
	var decoded_rows: Dictionary = PunchEncodingData.decode_rows(rows)
	var program_lines: Array = decoded_rows.get("program_lines", [])
	if program_lines.is_empty():
		return []
	var decoder = TapeDecoderData.new()
	return decoder.decode_tape("\n".join(program_lines))

func _get_bot_combat_instruction_type(bot_index: int) -> String:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return ""
	var program := _decode_program_from_rows(get_bot_loaded_cartridge(bot_index).get("rows", []))
	if program.is_empty():
		bot_loadouts[bot_index]["combat_ptr"] = 0
		return ""
	var combat_ptr := posmod(int(bot_loadouts[bot_index].get("combat_ptr", 0)), program.size())
	var instruction: Dictionary = program[combat_ptr]
	bot_loadouts[bot_index]["combat_ptr"] = posmod(combat_ptr + 1, program.size())
	return str(instruction.get("type", ""))

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

func _execute_instruction_on_state(source_state: Dictionary, program: Array, discover_objects: bool, allow_world_side_effects: bool = true) -> Dictionary:
	var state: Dictionary = source_state.duplicate(true)
	var changed := false
	var start_position := Vector2(state.get("outside_position", get_shelter_position()))
	var pointer := int(state.get("outside_ptr", 0))
	if pointer < 0 or pointer >= program.size():
		_set_terminal_status(state, "halted", allow_world_side_effects)
		return {"state": state, "changed": true}

	var instruction: Dictionary = program[pointer]
	var instruction_type := str(instruction.get("type", ""))
	var instruction_arg := int(instruction.get("arg", 0))
	var action_result := ""
	state["outside_ptr"] = pointer + 1
	changed = true
	var drone_type := str(state.get("drone_type", "spider"))
	if int(state.get("power_charge", 0)) <= 0:
		_set_terminal_status(state, "halted", allow_world_side_effects)
		action_result = "NO POWER -> halt"
		if allow_world_side_effects:
			_append_bot_log_entry(state, "tick", "[%d,%d] %s -> %s" % [int(start_position.x), int(start_position.y), instruction_type.to_upper(), action_result], true)
		return {"state": state, "changed": true}
	if not _is_drone_command_supported(drone_type, instruction_type):
		_set_terminal_status(state, "halted", allow_world_side_effects)
		var bot_index := _get_bot_index_from_state(state)
		var bot_name := _bot_display_name(bot_index) if bot_index >= 0 else drone_type.capitalize()
		state["last_mission_summary"] = "%s halted: %s unsupported" % [bot_name, instruction_type.to_upper()]
		return {"state": state, "changed": true}
	var remaining_energy := int(state.get("power_charge", 0)) - 1
	state["power_charge"] = remaining_energy
	_sync_power_card_count(state)

	match instruction_type:
		"nop":
			action_result = "NOP, power %d" % remaining_energy
		"mov":
			var direction := _get_direction_vector(str(state.get("outside_facing", START_FACING)))
			var new_position := Vector2(state.get("outside_position", get_shelter_position())) + direction
			if _is_inside_grid(new_position):
				state["outside_position"] = new_position
				var trail: Array = state.get("outside_trail", []).duplicate()
				if trail.is_empty() or trail[-1] != new_position:
					trail.append(new_position)
				state["outside_trail"] = trail
				action_result = "MOV to (%d,%d), power %d" % [int(new_position.x), int(new_position.y), remaining_energy]
			else:
				action_result = "MOV blocked at edge, power %d" % remaining_energy
		"scn":
			if discover_objects:
				var drone_def := get_drone_type_definition(drone_type)
				if str(drone_def.get("scan_mode", "direct")) == "wide_scan":
					var pending_before := Array(state.get("pending_location_cards", [])).size()
					_queue_butterfly_scan_findings(state)
					var pending_after := Array(state.get("pending_location_cards", [])).size()
					action_result = "SCN radius 4 -> %d new pending finds, power %d" % [maxi(pending_after - pending_before, 0), remaining_energy]
				else:
					var pending_ids_before := Array(state.get("pending_discovery_ids", [])).size()
					_queue_discovery_for_state(state, Vector2(state.get("outside_position", get_shelter_position())) + _get_direction_vector(str(state.get("outside_facing", START_FACING))))
					var pending_ids_after := Array(state.get("pending_discovery_ids", [])).size()
					action_result = "SCN forward -> %d pending discoveries, power %d" % [maxi(pending_ids_after - pending_ids_before, 0), remaining_energy]
			else:
				action_result = "SCN prediction only, power %d" % remaining_energy
		"pck":
			if allow_world_side_effects:
				action_result = "%s, power %d" % [_attempt_location_pickup(state), remaining_energy]
			else:
				action_result = "PCK prediction only, power %d" % remaining_energy
		"drp":
			action_result = "DRP no field effect, power %d" % remaining_energy
		"atk":
			action_result = "ATK armed, power %d" % remaining_energy
		"chg":
			state["power_charge"] = mini(remaining_energy + 1, int(state.get("max_power_charge", BOT_POWER_CAPACITY)))
			_sync_power_card_count(state)
			action_result = "CHG -> power %d" % int(state.get("power_charge", 0))
		"jmp":
			state["outside_ptr"] = instruction_arg
			action_result = "JMP -> %d, power %d" % [instruction_arg, remaining_energy]
		"jnz":
			if int(state.get("outside_acc", 0)) != 0:
				state["outside_ptr"] = instruction_arg
				action_result = "JNZ taken -> %d, power %d" % [instruction_arg, remaining_energy]
			else:
				action_result = "JNZ skipped, power %d" % remaining_energy
		"dec":
			state["outside_acc"] = int(state.get("outside_acc", 0)) - 1
			action_result = "DEC -> ACC %d, power %d" % [int(state.get("outside_acc", 0)), remaining_energy]
		"inc":
			state["outside_acc"] = int(state.get("outside_acc", 0)) + 1
			action_result = "INC -> ACC %d, power %d" % [int(state.get("outside_acc", 0)), remaining_energy]
		"set":
			state["outside_acc"] = instruction_arg
			action_result = "SET -> ACC %d, power %d" % [instruction_arg, remaining_energy]
		"out":
			action_result = "OUT no field effect, power %d" % remaining_energy
		"die":
			_set_terminal_status(state, "halted", allow_world_side_effects)
			action_result = "DIE -> halt, power %d" % remaining_energy
		"rot":
			state["outside_facing"] = _rotate_facing(str(state.get("outside_facing", START_FACING)), instruction_arg)
			action_result = "ROT -> %s, power %d" % [str(state.get("outside_facing", START_FACING)).to_upper(), remaining_energy]
		_:
			_set_terminal_status(state, "halted", allow_world_side_effects)
			action_result = "%s unsupported, power %d" % [instruction_type.to_upper(), remaining_energy]

	if _should_complete_location_mission(state):
		_set_terminal_status(state, "halted", allow_world_side_effects)
		action_result = "%s; mission returned to shelter" % action_result if not action_result.is_empty() else "Mission returned to shelter"
		if allow_world_side_effects:
			_append_bot_log_entry(state, "tick", "[%d,%d] %s -> %s" % [int(start_position.x), int(start_position.y), instruction_type.to_upper(), action_result], true)
		return {"state": state, "changed": true}

	if str(state.get("outside_status", "active")) == "active" and int(state.get("outside_ptr", 0)) >= program.size():
		_set_terminal_status(state, "halted", allow_world_side_effects)
	elif str(state.get("outside_status", "active")) == "active" and int(state.get("power_charge", 0)) <= 0:
		_set_terminal_status(state, "halted", allow_world_side_effects)
		action_result = "%s; no power -> halt" % action_result if not action_result.is_empty() else "NO POWER -> halt"

	if allow_world_side_effects:
		if action_result.is_empty():
			action_result = "%s executed" % instruction_type.to_upper()
		_append_bot_log_entry(state, "tick", "[%d,%d] %s -> %s" % [int(start_position.x), int(start_position.y), instruction_type.to_upper(), action_result], true)

	return {"state": state, "changed": changed}

func _should_complete_location_mission(state: Dictionary) -> bool:
	if str(state.get("outside_status", "active")) != "active":
		return false
	if str(state.get("mission_location_id", "")).is_empty():
		return false
	if Vector2(state.get("outside_position", get_shelter_position())) != get_shelter_position():
		return false
	var trail: Array = Array(state.get("outside_trail", []))
	var did_progress := trail.size() > 1 or int(state.get("mission_pickup_attempts", 0)) > 0 or int(state.get("mission_pickups", 0)) > 0
	return did_progress

func _set_terminal_status(state: Dictionary, terminal_status: String, commit_world_side_effects: bool = true):
	var position := Vector2(state.get("outside_position", get_shelter_position()))
	if terminal_status != "stranded" and position == get_shelter_position():
		var discoveries := 0
		var salvage := {}
		if commit_world_side_effects:
			discoveries = _commit_pending_discoveries(state)
			salvage = _commit_pending_salvage(state)
		state["outside_status"] = "returned"
		_clear_bot_mission_state(state)
		state["last_mission_summary"] = _build_mission_summary(state, "returned", discoveries, salvage)
		if commit_world_side_effects:
			_append_bot_log_entry(state, "status", str(state.get("last_mission_summary", "Returned to shelter")))
	else:
		state["outside_status"] = terminal_status
		state["last_mission_summary"] = _build_mission_summary(state, terminal_status, 0)
		if commit_world_side_effects:
			_append_bot_log_entry(state, "status", str(state.get("last_mission_summary", "Status updated")))

func _bot_display_name(bot_index: int) -> String:
	var drone_type := get_bot_drone_type(bot_index)
	var drone_def := get_drone_type_definition(drone_type)
	var display_name := str(drone_def.get("display_name", ""))
	if not display_name.is_empty():
		return display_name
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
		var result := _execute_instruction_on_state(simulation_state, program, false, false)
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

func _queue_butterfly_scan_findings(state: Dictionary):
	var center := Vector2(state.get("outside_position", get_shelter_position()))
	var pending_cards: Array = Array(state.get("pending_location_cards", [])).duplicate(true)
	var known_positions := {}
	known_positions[_serialize_vector(get_shelter_position())] = true
	for location_card in location_cards:
		known_positions[_serialize_vector(_vector_from_variant(location_card.get("position", {}), Vector2.ZERO))] = true
	for pending_variant in pending_cards:
		if typeof(pending_variant) != TYPE_DICTIONARY:
			continue
		known_positions[_serialize_vector(_vector_from_variant(Dictionary(pending_variant).get("position", {}), Vector2.ZERO))] = true
	for offset_x in range(-4, 5):
		for offset_y in range(-4, 5):
			var offset := Vector2(offset_x, offset_y)
			if offset.length() > 4.0:
				continue
			var candidate := center + offset
			if not _is_inside_grid(candidate):
				continue
			var serialized := _serialize_vector(candidate)
			if known_positions.has(serialized):
				continue
			if randf() > 0.05:
				continue
			pending_cards.append(_build_scanned_location_card_at(candidate, "butterfly_scan"))
			known_positions[serialized] = true
	state["pending_location_cards"] = pending_cards

func _attempt_location_pickup(state: Dictionary) -> String:
	var mission_location_id := str(state.get("mission_location_id", ""))
	var mission_location_type := str(state.get("mission_location_type", ""))
	if mission_location_id.is_empty() or mission_location_type.is_empty():
		return "PCK ignored: no location mission"
	var mission_position := _vector_from_variant(state.get("mission_location_position", {}), get_shelter_position())
	var current_position := Vector2(state.get("outside_position", get_shelter_position()))
	if current_position != mission_position:
		return "PCK ignored: not at target"
	var pickup_attempts := int(state.get("mission_pickup_attempts", 0)) + 1
	state["mission_pickup_attempts"] = pickup_attempts
	var pending_drops: Array = Array(state.get("pending_salvage_drops", [])).duplicate(true)
	var message_parts: Array = ["PCK attempt %d at %s" % [pickup_attempts, mission_location_type.to_upper()]]
	var drop_entry := _roll_location_scavenge_drop(mission_location_type, pickup_attempts)
	if not drop_entry.is_empty():
		_add_pending_salvage_drop(pending_drops, drop_entry)
		state["pending_salvage_drops"] = pending_drops
		state["mission_pickups"] = int(state.get("mission_pickups", 0)) + 1
		var drop_kind := str(drop_entry.get("kind", "material"))
		if drop_kind == "power":
			message_parts.append("found POWER UNIT")
		elif drop_kind in ["structure", "crafted", "equipment"]:
			message_parts.append("found %s" % str(drop_entry.get("display_name", drop_entry.get("result", "item"))).to_upper())
		else:
			message_parts.append("found %dx %s" % [
				maxi(int(drop_entry.get("quantity", 1)), 1),
				str(drop_entry.get("type", "material")).to_upper(),
			])
	else:
		message_parts.append("no salvage")
	var enemy_card := _roll_location_encounter_card(mission_location_type, mission_location_id)
	if not enemy_card.is_empty():
		enemy_cards.append(enemy_card)
		state["mission_encounters"] = int(state.get("mission_encounters", 0)) + 1
		message_parts.append("encounter %s" % str(enemy_card.get("type", "hostile")).replace("_", " ").to_upper())
	return "; ".join(message_parts)

func _add_pending_salvage_drop(pending_drops: Array, drop_entry: Dictionary) -> void:
	var drop_kind := str(drop_entry.get("kind", ""))
	if drop_kind == "material":
		var material_type := str(drop_entry.get("type", ""))
		for index in range(pending_drops.size()):
			if typeof(pending_drops[index]) != TYPE_DICTIONARY:
				continue
			var existing: Dictionary = Dictionary(pending_drops[index]).duplicate(true)
			if str(existing.get("kind", "")) != "material":
				continue
			if str(existing.get("type", "")) != material_type:
				continue
			existing["quantity"] = maxi(int(existing.get("quantity", 0)), 0) + maxi(int(drop_entry.get("quantity", 0)), 0)
			pending_drops[index] = existing
			return
	pending_drops.append(drop_entry.duplicate(true))

func _roll_location_scavenge_drop(location_type: String, pickup_attempts: int = 1) -> Dictionary:
	var drop_table: Array = Array(LOCATION_SCAVENGE_TABLES.get(location_type, []))
	if drop_table.is_empty():
		return {}
	var base_chance := float(LOCATION_SCAVENGE_CHANCES.get(location_type, 0.28))
	var attempt_penalty := maxf(float(maxi(pickup_attempts - 1, 0)) * 0.08, 0.0)
	var success_chance := clampf(base_chance - attempt_penalty, 0.05, 0.90)
	if randf() > success_chance:
		return {}
	var drop_entry := _roll_weighted_material_drop_entry(drop_table)
	if drop_entry.is_empty():
		return {}
	var drop_kind := str(drop_entry.get("kind", "material"))
	if drop_kind == "power":
		return {
			"kind": "material",
			"type": "power_unit",
			"display_name": "Power Unit",
			"quantity": CHARGE_MACHINE_TRANSFER_UNITS,
			"source_location_type": location_type,
		}
	if drop_kind == "equipment":
		return {
			"kind": "equipment",
			"type": str(drop_entry.get("type", "")),
			"display_name": str(drop_entry.get("display_name", drop_entry.get("result", "Equipment"))),
			"result": str(drop_entry.get("result", "")),
			"source_location_type": location_type,
		}
	if drop_kind == "crafted":
		drop_kind = "structure"
	if drop_kind == "structure":
		return {
			"kind": "structure",
			"type": str(drop_entry.get("type", "")),
			"display_name": str(drop_entry.get("display_name", drop_entry.get("result", "Item"))),
			"result": str(drop_entry.get("result", "")),
			"source_location_type": location_type,
		}
	var material_type := str(drop_entry.get("type", ""))
	var quantity_min := maxi(int(drop_entry.get("quantity_min", 1)), 1)
	var quantity_max := maxi(int(drop_entry.get("quantity_max", quantity_min)), quantity_min)
	return {
		"kind": "material",
		"type": material_type,
		"display_name": material_type.replace("_", " ").capitalize(),
		"quantity": randi_range(quantity_min, quantity_max),
		"source_location_type": location_type,
	}

func _roll_location_encounter_card(location_type: String, location_id: String) -> Dictionary:
	var encounter_def: Dictionary = Dictionary(LOCATION_ENCOUNTER_TABLES.get(location_type, {}))
	if encounter_def.is_empty():
		return {}
	if randf() > float(encounter_def.get("chance", 0.0)):
		return {}
	var enemy_entry := _roll_weighted_material_drop_entry(Array(encounter_def.get("types", [])))
	var enemy_type := str(enemy_entry.get("type", ""))
	if enemy_type.is_empty():
		return {}
	return _build_enemy_card_for_type(enemy_type, "location_scavenge:%s:%s" % [location_type, location_id])

func _build_scanned_location_card_at(position: Vector2, source: String = "drone_scan") -> Dictionary:
	var location_types := [
		"cache",
		"crater",
		"tower",
		"surveillance_zone",
		"facility",
		"pond",
		"bunker",
		"field",
		"dump",
		"nest",
		"ruin",
	]
	var location_type := str(location_types[randi() % location_types.size()])
	var location_id := "loc_%d_%d_%d" % [int(Time.get_unix_time_from_system()), int(position.x), int(position.y)]
	return {
		"id": location_id,
		"type": location_type,
		"display_name": _generate_markov_name(LOCATION_NAME_CORPUS, true),
		"image_seed": randi(),
		"position": _serialize_vector(position),
		"survey_level": 1,
		"source": source,
	}

func _build_enemy_card_for_type(enemy_type: String, source: String = "operator_scan") -> Dictionary:
	var enemy_def := _get_enemy_type_definition(enemy_type)
	return {
		"id": "enemy_%d_%d" % [int(Time.get_unix_time_from_system()), enemy_cards.size()],
		"type": enemy_type,
		"display_name": str(enemy_def.get("label", _default_enemy_display_name(enemy_type))),
		"threat_level": int(enemy_def.get("threat_level", 1)),
		"attack": int(enemy_def.get("attack", 1)),
		"armor": maxi(int(enemy_def.get("armor", 0)), 0),
		"hp": int(enemy_def.get("hp", 3)),
		"source": source,
	}

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
	var pending_location_cards: Array = Array(state.get("pending_location_cards", [])).duplicate(true)
	for pending_variant in pending_location_cards:
		if typeof(pending_variant) != TYPE_DICTIONARY:
			continue
		var pending_card: Dictionary = Dictionary(pending_variant).duplicate(true)
		var position_key := _serialize_vector(_vector_from_variant(pending_card.get("position", {}), Vector2.ZERO))
		var already_known := false
		for location_card in location_cards:
			if _serialize_vector(_vector_from_variant(location_card.get("position", {}), Vector2.ZERO)) == position_key:
				already_known = true
				break
		if already_known:
			continue
		location_cards.append(pending_card)
		discoveries += 1
	state["pending_location_cards"] = []
	return discoveries

func _commit_pending_salvage(state: Dictionary) -> Dictionary:
	var pending_drops: Array = Array(state.get("pending_salvage_drops", [])).duplicate(true)
	var committed := 0
	var material_count := 0
	var power_count := 0
	var structure_count := 0
	var aggregated_materials := {}
	for drop_variant in pending_drops:
		if typeof(drop_variant) != TYPE_DICTIONARY:
			continue
		var drop_entry: Dictionary = Dictionary(drop_variant)
		var drop_kind := str(drop_entry.get("kind", ""))
		if drop_kind == "power":
			drop_kind = "material"
			drop_entry["type"] = "power_unit"
			drop_entry["display_name"] = "Power Unit"
			drop_entry["quantity"] = maxi(int(drop_entry.get("quantity", CHARGE_MACHINE_TRANSFER_UNITS)), 1)
		if drop_kind == "equipment":
			var equipment_card := _add_equipment_card({
				"type": str(drop_entry.get("type", "")),
				"display_name": str(drop_entry.get("display_name", drop_entry.get("result", "Equipment"))),
			})
			if equipment_card.is_empty():
				continue
			committed += 1
			structure_count += 1
			continue
		if drop_kind == "crafted":
			drop_kind = "structure"
		if drop_kind == "structure":
			var crafted_card := {
				"id": "structure_%d_%d" % [int(Time.get_unix_time_from_system()), crafted_cards.size()],
				"type": str(drop_entry.get("type", "")),
				"display_name": str(drop_entry.get("display_name", drop_entry.get("result", "Item"))),
				"result": str(drop_entry.get("result", "Crafted Item")),
				"recipe_id": "",
				"formula": "",
				"stored_cards": [],
			}
			crafted_cards.append(crafted_card)
			committed += 1
			structure_count += 1
			continue
		if drop_kind != "material":
			continue
		var material_type := str(drop_entry.get("type", ""))
		if material_type.is_empty():
			continue
		if not aggregated_materials.has(material_type):
			aggregated_materials[material_type] = {
				"type": material_type,
				"display_name": str(drop_entry.get("display_name", material_type.replace("_", " ").capitalize())),
				"quantity": 0,
				"source_location_type": str(drop_entry.get("source_location_type", "")),
			}
		var aggregate_entry: Dictionary = Dictionary(aggregated_materials[material_type]).duplicate(true)
		aggregate_entry["quantity"] = maxi(int(aggregate_entry.get("quantity", 0)), 0) + maxi(int(drop_entry.get("quantity", 1)), 1)
		aggregated_materials[material_type] = aggregate_entry
	for material_type in aggregated_materials.keys():
		var aggregate_entry: Dictionary = Dictionary(aggregated_materials[material_type]).duplicate(true)
		if _append_material_card(aggregate_entry):
			committed += 1
			material_count += 1
	state["pending_salvage_drops"] = []
	return {
		"count": committed,
		"materials": material_count,
		"power_units": power_count,
		"structures": structure_count,
	}

func _append_material_card(material_entry: Dictionary) -> bool:
	return not _add_material_card(material_entry).is_empty()

func _build_mission_summary(state: Dictionary, status: String, discoveries: int, salvage: Dictionary = {}) -> String:
	var bot_name := _bot_display_name(_get_bot_index_from_state(state))
	match status:
		"returned":
			var summary_parts: Array = []
			if discoveries > 0:
				var noun := "discovery" if discoveries == 1 else "discoveries"
				summary_parts.append("%d new %s" % [discoveries, noun])
			var salvage_count := int(salvage.get("count", 0))
			if salvage_count > 0:
				var salvage_noun := "salvage item" if salvage_count == 1 else "salvage items"
				summary_parts.append("%d %s" % [salvage_count, salvage_noun])
			if not summary_parts.is_empty():
				return "%s returned with %s" % [bot_name, " and ".join(summary_parts)]
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
	bot_loadouts[bot_index]["drone_type"] = _normalize_drone_type(str(bot_entry.get("drone_type", str(bot_loadouts[bot_index].get("drone_type", "")))))
	bot_loadouts[bot_index]["loaded_cartridge_id"] = str(bot_entry.get("loaded_cartridge_id", ""))
	bot_loadouts[bot_index]["combat_ptr"] = int(bot_entry.get("combat_ptr", 0))
	var saved_power_charge := int(bot_entry.get("power_charge", bot_entry.get("wound_energy", 0)))
	var saved_max_power := int(bot_entry.get("max_power_charge", bot_entry.get("max_wound_energy", BOT_POWER_CAPACITY)))
	if saved_max_power < BOT_POWER_CAPACITY and saved_power_charge > 0:
		saved_max_power = BOT_POWER_CAPACITY
	saved_max_power = maxi(saved_max_power, BOT_POWER_CAPACITY)
	saved_power_charge = clampi(saved_power_charge, 0, saved_max_power)
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
	bot_loadouts[bot_index]["pending_location_cards"] = _normalize_saved_location_cards(Array(bot_entry.get("pending_location_cards", [])))
	bot_loadouts[bot_index]["mission_location_id"] = str(bot_entry.get("mission_location_id", ""))
	bot_loadouts[bot_index]["mission_location_type"] = str(bot_entry.get("mission_location_type", ""))
	bot_loadouts[bot_index]["mission_location_position"] = _vector_from_variant(bot_entry.get("mission_location_position", {}), get_shelter_position())
	bot_loadouts[bot_index]["pending_salvage_drops"] = Array(bot_entry.get("pending_salvage_drops", [])).duplicate(true)
	bot_loadouts[bot_index]["mission_pickups"] = maxi(int(bot_entry.get("mission_pickups", 0)), 0)
	bot_loadouts[bot_index]["mission_pickup_attempts"] = maxi(int(bot_entry.get("mission_pickup_attempts", 0)), 0)
	bot_loadouts[bot_index]["mission_encounters"] = maxi(int(bot_entry.get("mission_encounters", 0)), 0)
	bot_loadouts[bot_index]["activity_tick"] = maxi(int(bot_entry.get("activity_tick", 0)), 0)
	bot_loadouts[bot_index]["activity_log"] = Array(bot_entry.get("activity_log", [])).duplicate(true)
	bot_loadouts[bot_index]["last_mission_summary"] = str(bot_entry.get("last_mission_summary", ""))
	bot_loadouts[bot_index]["equipment_slots"] = _normalize_equipment_slots(Array(bot_entry.get("equipment_slots", [])))
	_sync_power_card_count(bot_loadouts[bot_index])

func _normalize_loaded_bot_states() -> bool:
	var changed := false
	for bot_index in range(bot_loadouts.size()):
		var bot_state: Dictionary = bot_loadouts[bot_index].duplicate(true)
		var loaded_id := str(bot_state.get("loaded_cartridge_id", ""))
		var has_cartridge := loaded_id.is_empty() == false and not get_bot_loaded_cartridge(bot_index).is_empty()
		var outside_status := str(bot_state.get("outside_status", "cabinet"))
		var at_shelter := Vector2(bot_state.get("outside_position", get_shelter_position())) == get_shelter_position()
		if not has_cartridge and not loaded_id.is_empty():
			bot_state["loaded_cartridge_id"] = ""
			bot_state["combat_ptr"] = 0
			changed = true
		if outside_status == "active" and not has_cartridge:
			if at_shelter:
				bot_state["outside_status"] = "returned"
				_clear_bot_mission_state(bot_state)
				bot_state["last_mission_summary"] = "%s reset at shelter" % _bot_display_name(bot_index)
			else:
				_set_terminal_status(bot_state, "halted", false)
			changed = true
		elif outside_status == "active" and at_shelter and not str(bot_state.get("mission_location_id", "")).is_empty():
			var trail: Array = Array(bot_state.get("outside_trail", []))
			var did_progress := trail.size() > 1 or int(bot_state.get("mission_pickup_attempts", 0)) > 0 or int(bot_state.get("mission_pickups", 0)) > 0
			if did_progress:
				_set_terminal_status(bot_state, "halted", true)
				changed = true
		bot_loadouts[bot_index] = bot_state
	return changed

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
			"combat_ptr": int(bot.get("combat_ptr", 0)),
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
			"pending_location_cards": Array(bot.get("pending_location_cards", [])).duplicate(true),
			"mission_location_id": str(bot.get("mission_location_id", "")),
			"mission_location_type": str(bot.get("mission_location_type", "")),
			"mission_location_position": _serialize_vector(Vector2(bot.get("mission_location_position", get_shelter_position()))),
			"pending_salvage_drops": Array(bot.get("pending_salvage_drops", [])).duplicate(true),
			"mission_pickups": maxi(int(bot.get("mission_pickups", 0)), 0),
			"mission_pickup_attempts": maxi(int(bot.get("mission_pickup_attempts", 0)), 0),
			"mission_encounters": maxi(int(bot.get("mission_encounters", 0)), 0),
			"activity_tick": maxi(int(bot.get("activity_tick", 0)), 0),
			"activity_log": Array(bot.get("activity_log", [])).duplicate(true),
			"last_mission_summary": str(bot.get("last_mission_summary", "")),
			"equipment_slots": _normalize_equipment_slots(Array(bot.get("equipment_slots", []))),
		})
	return data

func _normalize_drone_type(drone_type: String) -> String:
	var normalized := str(drone_type).strip_edges().to_lower()
	if DRONE_TYPE_DEFS.has(normalized):
		return normalized
	return str(START_BOT_TYPES[0])

func get_drone_type_definition(drone_type: String) -> Dictionary:
	var normalized := _normalize_drone_type(drone_type)
	return Dictionary(DRONE_TYPE_DEFS.get(normalized, {})).duplicate(true)

func get_research_drone_types() -> Array:
	var drone_types: Array = []
	for drone_type_variant in DRONE_TYPE_DEFS.keys():
		drone_types.append(str(drone_type_variant))
	drone_types.sort()
	return drone_types

func get_bot_drone_type(bot_index: int) -> String:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return _normalize_drone_type("")
	return _normalize_drone_type(str(bot_loadouts[bot_index].get("drone_type", "")))

func get_bot_display_name(bot_index: int) -> String:
	return _bot_display_name(bot_index)

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

func _normalize_saved_location_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var location_type := str(entry.get("type", "site"))
		result.append({
			"id": str(entry.get("id", "")),
			"type": location_type,
			"display_name": str(entry.get("display_name", _default_location_display_name(location_type))),
			"image_seed": int(entry.get("image_seed", entry.get("seed", randi()))),
			"position": _serialize_vector(_vector_from_variant(entry.get("position", {}), Vector2.ZERO)),
			"survey_level": maxi(int(entry.get("survey_level", 1)), 1),
			"source": str(entry.get("source", "operator_scan")),
		})
	return result

func _normalize_saved_captive_enemy(entry: Dictionary) -> Dictionary:
	if entry.is_empty():
		return {}
	var enemy_type := str(entry.get("type", "hostile_creature"))
	var enemy_def := _get_enemy_type_definition(enemy_type)
	var threat := maxi(int(entry.get("threat_level", int(enemy_def.get("threat_level", 1)))), 1)
	return {
		"id": str(entry.get("id", "enemy_%d" % int(Time.get_unix_time_from_system()))),
		"type": enemy_type,
		"display_name": str(entry.get("display_name", str(enemy_def.get("label", _default_enemy_display_name(enemy_type))))),
		"threat_level": threat,
		"attack": maxi(int(entry.get("attack", int(enemy_def.get("attack", threat)))), 1),
		"armor": maxi(int(entry.get("armor", int(enemy_def.get("armor", 0)))), 0),
		"hp": maxi(int(entry.get("hp", int(enemy_def.get("hp", 3 + threat)))), 1),
		"source": str(entry.get("source", "operator_scan")),
	}

func _normalize_saved_enemy_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var enemy_type := str(entry.get("type", "hostile_creature"))
		var enemy_def := _get_enemy_type_definition(enemy_type)
		var threat := maxi(int(entry.get("threat_level", int(enemy_def.get("threat_level", 1)))), 1)
		result.append({
			"id": str(entry.get("id", "")),
			"type": enemy_type,
			"display_name": str(entry.get("display_name", str(enemy_def.get("label", _default_enemy_display_name(enemy_type))))),
			"threat_level": threat,
			"attack": maxi(int(entry.get("attack", int(enemy_def.get("attack", threat)))), 1),
			"armor": maxi(int(entry.get("armor", int(enemy_def.get("armor", 0)))), 0),
			"hp": maxi(int(entry.get("hp", int(enemy_def.get("hp", 3 + threat)))), 1),
			"source": str(entry.get("source", "operator_scan")),
		})
	return result

func _normalize_saved_dog_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		result.append(_default_dog_card(Dictionary(entry)))
	return result

func _normalize_saved_material_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var material_type := str(entry.get("type", "metal"))
		result.append({
			"id": str(entry.get("id", "")),
			"type": material_type,
			"display_name": str(entry.get("display_name", _default_material_display_name(material_type))),
			"quantity": maxi(int(entry.get("quantity", 1)), 1),
			"source_enemy_type": str(entry.get("source_enemy_type", "")),
		})
	return result

func _normalize_saved_equipment_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var equipment_type := str(entry.get("type", ""))
		var spec := _get_equipment_type_spec(equipment_type)
		if spec.is_empty():
			continue
		result.append({
			"id": str(entry.get("id", "")),
			"type": equipment_type,
			"display_name": str(entry.get("display_name", spec.get("display_name", _get_equipment_display_name(equipment_type)))),
		})
	return result

func _normalize_saved_blueprint_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var recipe_id := str(entry.get("recipe_id", ""))
		var live_recipe := _get_loaded_recipe_by_id(recipe_id)
		var result_name := str(entry.get("result", "Blueprint")).to_upper()
		var formula := str(entry.get("formula", ""))
		var formula_parts: Array = _sanitize_recipe_parts(Array(entry.get("formula_parts", [])).duplicate(true))
		if not live_recipe.is_empty():
			result_name = str(live_recipe.get("result", result_name)).to_upper()
			formula_parts = _sanitize_recipe_parts(Array(live_recipe.get("formula_parts", formula_parts)).duplicate(true))
		elif formula_parts.is_empty():
			formula_parts = _sanitize_recipe_parts(_formula_parts_from_formula_string(formula))
		formula_parts = _normalize_recipe_result_parts(result_name, formula_parts)
		result.append({
			"id": str(entry.get("id", "")),
			"recipe_id": recipe_id,
			"result": result_name,
			"formula": "%s = %s" % [result_name, _join_formula_parts(formula_parts)],
			"formula_parts": formula_parts,
			"subject_key": str(entry.get("subject_key", "")),
		})
	return result

func _normalize_saved_crafted_cards(cards: Array) -> Array:
	var result: Array = []
	for entry in cards:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var result_name := str(entry.get("result", "Crafted Item"))
		var result_type := str(entry.get("type", _result_name_to_type(result_name.to_upper())))
		result.append({
			"id": str(entry.get("id", "")),
			"type": result_type,
			"display_name": str(entry.get("display_name", result_name)),
			"result": result_name,
			"recipe_id": str(entry.get("recipe_id", "")),
			"formula": str(entry.get("formula", "")),
			"stored_cards": _normalize_saved_storage_entries(Array(entry.get("stored_cards", []))),
			"tank_batch": _normalize_saved_tank_batch(Dictionary(entry.get("tank_batch", {}))),
			"tank_slots": _normalize_saved_tank_slots(Dictionary(entry.get("tank_slots", {}))),
			"captive_enemy": _normalize_saved_captive_enemy(Dictionary(entry.get("captive_enemy", {}))),
	})
	return result

func _normalize_saved_table_cards(structure_entries: Array, mechanism_entries: Array) -> Dictionary:
	var merged: Array = []
	var seen_ids := {}
	var normalized_legacy := false
	for entry_variant in _normalize_saved_crafted_cards(mechanism_entries):
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		if str(entry.get("type", "")) != "tank":
			normalized_legacy = true
			continue
		var entry_id := str(entry.get("id", ""))
		if entry_id.is_empty() or seen_ids.has(entry_id):
			normalized_legacy = true
			continue
		seen_ids[entry_id] = true
		merged.append(entry)
	for entry_variant in _normalize_saved_crafted_cards(structure_entries):
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		var entry_id := str(entry.get("id", ""))
		if entry_id.is_empty():
			normalized_legacy = true
			continue
		var is_tank := str(entry.get("type", "")) == "tank"
		if seen_ids.has(entry_id):
			normalized_legacy = true
			continue
		if is_tank:
			normalized_legacy = true
		seen_ids[entry_id] = true
		merged.append(entry)
	return {
		"cards": merged,
		"normalized_legacy": normalized_legacy,
	}

func _normalize_structure_subject_key(subject_key: String) -> String:
	var normalized := subject_key.strip_edges()
	if normalized == "structure_tank":
		return "mechanism_tank"
	if normalized.begins_with("crafted_"):
		return "structure_%s" % normalized.substr("crafted_".length(), normalized.length() - "crafted_".length())
	return normalized

func _normalize_structure_subject_kind(subject_kind: String) -> String:
	var normalized := subject_kind.strip_edges()
	if normalized == "mechanism":
		return "mechanism"
	return "structure" if normalized == "crafted" else normalized

func _normalize_legacy_subject_key(subject_key: String) -> String:
	var normalized := _normalize_structure_subject_key(subject_key)
	if normalized == "resource_spring_charge":
		return "material_power_unit"
	return normalized

func _normalize_legacy_subject_kind(subject_kind: String, subject_type: String = "") -> String:
	var normalized := _normalize_structure_subject_kind(subject_kind)
	if normalized == "resource" and subject_type == "spring_charge":
		return "material"
	return normalized

func _normalize_legacy_subject_type(subject_kind: String, subject_type: String) -> String:
	if _normalize_structure_subject_kind(subject_kind) == "resource" and subject_type == "spring_charge":
		return "power_unit"
	return subject_type

func _default_tank_slots() -> Dictionary:
	return {
		"culture": {},
		"feed": {},
		"recipe": {},
	}

func _normalize_saved_tank_slots(entry: Dictionary) -> Dictionary:
	var slots := _default_tank_slots()
	if entry.is_empty():
		return slots
	slots["culture"] = Dictionary(entry.get("culture", {})).duplicate(true)
	slots["feed"] = Dictionary(entry.get("feed", {})).duplicate(true)
	slots["recipe"] = Dictionary(entry.get("recipe", {})).duplicate(true)
	return slots

func _normalize_saved_tank_batch(entry: Dictionary) -> Dictionary:
	if entry.is_empty():
		return {}
	var process_id := str(entry.get("process_id", ""))
	if process_id.is_empty():
		return {}
	match process_id:
		"algae_to_fiber":
			process_id = "fiber_cycle"
		"bacteria_to_medicine":
			process_id = "medicine_cycle"
		"mealworms_to_rations":
			process_id = "rations_cycle"
	var spec := Dictionary(TANK_PROCESS_SPECS.get(process_id, {}))
	if spec.is_empty():
		return {}
	var duration := maxf(float(entry.get("duration", TANK_PROCESS_DEFAULT_DURATION)), 0.1)
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

func _migrate_stackable_crafted_cards_to_materials() -> void:
	if crafted_cards.is_empty():
		return
	var remaining_crafted: Array = []
	for entry_variant in crafted_cards:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var result_name := str(entry.get("result", ""))
		var spec := _get_craft_result_spec(result_name)
		if str(spec.get("kind", "")) == "material":
			_add_material_card({
				"type": str(spec.get("type", _result_name_to_type(result_name))),
				"display_name": str(spec.get("display_name", result_name)),
				"quantity": maxi(int(entry.get("quantity", spec.get("quantity", 1))), 1),
				"source_recipe_id": str(entry.get("recipe_id", "")),
			})
			continue
		remaining_crafted.append(entry.duplicate(true))
	crafted_cards = remaining_crafted

func _migrate_equipment_like_crafted_cards_to_equipment() -> void:
	if crafted_cards.is_empty():
		return
	var remaining_crafted: Array = []
	for entry_variant in crafted_cards:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_variant).duplicate(true)
		var result_name := str(entry.get("result", ""))
		var spec := _get_craft_result_spec(result_name)
		if str(spec.get("kind", "")) == "equipment":
			_add_equipment_card({
				"type": str(spec.get("type", _result_name_to_type(result_name))),
				"display_name": str(spec.get("display_name", result_name)),
			})
			continue
		remaining_crafted.append(entry)
	crafted_cards = remaining_crafted

func _normalize_saved_storage_entries(entries: Array) -> Array:
	var normalized: Array = []
	for entry_variant in entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var entry_kind := str(entry.get("kind", ""))
		var entry_type := str(entry.get("type", ""))
		if entry_kind == "material":
			var quantity := maxi(int(entry.get("quantity", 0)), 0)
			var material_card := Dictionary(entry.get("card", {}))
			if material_card.is_empty() and (quantity <= 0 or entry_type.is_empty()):
				continue
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "material",
				"type": entry_type,
				"display_name": str(entry.get("display_name", _default_material_display_name(entry_type))),
				"quantity": quantity,
				"card": material_card.duplicate(true),
			})
		elif entry_kind == "location":
			var location_card := Dictionary(entry.get("card", {}))
			if location_card.is_empty() and entry_type.is_empty():
				continue
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "location",
				"type": entry_type,
				"display_name": str(entry.get("display_name", entry_type.capitalize())),
				"card": location_card.duplicate(true),
			})
		elif entry_kind == "dog":
			var dog_card := Dictionary(entry.get("card", {}))
			if dog_card.is_empty():
				continue
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "dog",
				"type": "dog",
				"display_name": str(entry.get("display_name", "Dog")),
				"card": dog_card.duplicate(true),
			})
		elif entry_kind == "mechanism":
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "mechanism",
				"type": entry_type,
				"display_name": str(entry.get("display_name", entry.get("result", "Mechanism"))),
				"result": str(entry.get("result", "TANK")),
				"recipe_id": str(entry.get("recipe_id", "")),
				"formula": str(entry.get("formula", "")),
				"captive_enemy": _normalize_saved_captive_enemy(Dictionary(entry.get("captive_enemy", {}))),
				"card": Dictionary(entry.get("card", {})).duplicate(true),
			})
		elif entry_kind in ["crafted", "structure"]:
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "structure",
				"type": entry_type,
				"display_name": str(entry.get("display_name", entry.get("result", "Item"))),
				"result": str(entry.get("result", "Crafted Item")),
				"recipe_id": str(entry.get("recipe_id", "")),
				"formula": str(entry.get("formula", "")),
				"captive_enemy": _normalize_saved_captive_enemy(Dictionary(entry.get("captive_enemy", {}))),
				"card": Dictionary(entry.get("card", {})).duplicate(true),
			})
		elif entry_kind == "blueprint":
			var blueprint_card := Dictionary(entry.get("card", {}))
			if blueprint_card.is_empty() and str(entry.get("result", "")).is_empty():
				continue
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "blueprint",
				"type": "blueprint",
				"display_name": str(entry.get("display_name", entry.get("result", "Blueprint"))),
				"result": str(entry.get("result", "Blueprint")),
				"recipe_id": str(entry.get("recipe_id", "")),
				"formula": str(entry.get("formula", "")),
				"formula_parts": Array(entry.get("formula_parts", [])).duplicate(true),
				"subject_key": str(entry.get("subject_key", "")),
				"card": blueprint_card.duplicate(true),
			})
		elif entry_kind == "equipment":
			var equipment_card := Dictionary(entry.get("card", {}))
			if equipment_card.is_empty() and entry_type.is_empty():
				continue
			normalized.append({
				"entry_id": str(entry.get("entry_id", "stored_%d" % normalized.size())),
				"kind": "equipment",
				"type": entry_type,
				"display_name": str(entry.get("display_name", _get_equipment_display_name(entry_type))),
				"card": equipment_card.duplicate(true),
			})
	return normalized

func _store_card_in_tool_chest(container_index: int, container: Dictionary, source_kind: String, card_id: String) -> Dictionary:
	var stored_cards := Array(container.get("stored_cards", [])).duplicate(true)
	var entry_id := "stored_%d_%d" % [int(Time.get_unix_time_from_system()), stored_cards.size()]
	match source_kind:
		"material":
			for card_index in range(material_cards.size()):
				var material_card: Dictionary = Dictionary(material_cards[card_index]).duplicate(true)
				if str(material_card.get("id", "")) != card_id:
					continue
				stored_cards.append({
					"entry_id": entry_id,
					"kind": "material",
					"type": str(material_card.get("type", "")),
					"display_name": str(material_card.get("display_name", _default_material_display_name(str(material_card.get("type", ""))))),
					"quantity": maxi(int(material_card.get("quantity", 1)), 1),
					"card": material_card,
				})
				material_cards.remove_at(card_index)
				container["stored_cards"] = stored_cards
				crafted_cards[container_index] = container
				save_programmed_cartridges()
				EventBus.outside_world_changed.emit()
				return {"ok": true, "kind": "material", "message": "%s stored" % str(container.get("display_name", container.get("result", "Storage")))}
			return {"ok": false, "message": "Resource card not found"}
		"blueprint":
			var blueprint_index := _find_blueprint_card_index(card_id)
			if blueprint_index == -1:
				return {"ok": false, "message": "Blueprint card not found"}
			var blueprint_card: Dictionary = Dictionary(blueprint_cards[blueprint_index]).duplicate(true)
			stored_cards.append({
				"entry_id": entry_id,
				"kind": "blueprint",
				"type": "blueprint",
				"display_name": str(blueprint_card.get("result", "Blueprint")),
				"result": str(blueprint_card.get("result", "Blueprint")),
				"recipe_id": str(blueprint_card.get("recipe_id", "")),
				"formula": str(blueprint_card.get("formula", "")),
				"formula_parts": Array(blueprint_card.get("formula_parts", [])).duplicate(true),
				"subject_key": str(blueprint_card.get("subject_key", "")),
				"card": blueprint_card,
			})
			blueprint_cards.remove_at(blueprint_index)
		"equipment":
			var equipment_index := _find_equipment_card_index(card_id)
			if equipment_index == -1:
				return {"ok": false, "message": "Equipment card not found"}
			var equipment_card: Dictionary = Dictionary(equipment_cards[equipment_index]).duplicate(true)
			stored_cards.append({
				"entry_id": entry_id,
				"kind": "equipment",
				"type": str(equipment_card.get("type", "")),
				"display_name": str(equipment_card.get("display_name", _get_equipment_display_name(str(equipment_card.get("type", ""))))),
				"card": equipment_card,
			})
			equipment_cards.remove_at(equipment_index)
		"crafted", "structure":
			var source_index := _find_crafted_card_index(card_id)
			if source_index == -1 or source_index == container_index:
				return {"ok": false, "message": "Structure card not found"}
			var crafted_card := Dictionary(crafted_cards[source_index]).duplicate(true)
			if _is_storage_crafted_type(str(crafted_card.get("type", ""))):
				return {"ok": false, "message": "Cannot nest storage"}
			stored_cards.append({
				"entry_id": entry_id,
				"kind": "structure",
				"type": str(crafted_card.get("type", "")),
				"display_name": str(crafted_card.get("display_name", crafted_card.get("result", "Item"))),
				"result": str(crafted_card.get("result", "")),
				"recipe_id": str(crafted_card.get("recipe_id", "")),
				"formula": str(crafted_card.get("formula", "")),
				"captive_enemy": _normalize_saved_captive_enemy(Dictionary(crafted_card.get("captive_enemy", {}))),
				"card": crafted_card,
			})
			crafted_cards.remove_at(source_index)
			if source_index < container_index:
				container_index -= 1
				container = Dictionary(crafted_cards[container_index])
		_:
			return {"ok": false, "message": "Card type cannot be stored"}
	container["stored_cards"] = stored_cards
	crafted_cards[container_index] = container
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	var normalized_kind := "structure" if source_kind == "crafted" else source_kind
	return {"ok": true, "kind": normalized_kind, "message": "%s stored" % str(container.get("display_name", container.get("result", "Storage")))}

func _normalize_saved_journal_entries(entries: Array) -> Array:
	var result: Array = []
	for entry_variant in entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var normalized_recipes: Array = []
		for recipe_variant in Array(entry.get("recipes", [])):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = recipe_variant
			var recipe_id := str(recipe.get("id", ""))
			var live_recipe := _get_loaded_recipe_by_id(recipe_id)
			var result_name := str(recipe.get("result", "Blueprint")).to_upper()
			var formula := str(recipe.get("formula", ""))
			var formula_parts: Array = _sanitize_recipe_parts(Array(recipe.get("formula_parts", [])).duplicate(true))
			if not live_recipe.is_empty():
				result_name = str(live_recipe.get("result", result_name)).to_upper()
				formula_parts = _sanitize_recipe_parts(Array(live_recipe.get("formula_parts", formula_parts)).duplicate(true))
			elif formula_parts.is_empty():
				formula_parts = _sanitize_recipe_parts(_formula_parts_from_formula_string(formula))
			formula_parts = _normalize_recipe_result_parts(result_name, formula_parts)
			normalized_recipes.append({
				"id": recipe_id,
				"result": result_name,
				"formula_parts": formula_parts,
				"formula": "%s = %s" % [result_name, _join_formula_parts(formula_parts)],
				"subject_key": _normalize_legacy_subject_key(str(recipe.get("subject_key", ""))),
				"unread": bool(recipe.get("unread", false)),
			})
		var raw_subject_kind := str(entry.get("subject_kind", ""))
		var raw_subject_type := str(entry.get("subject_type", ""))
		var subject_key := _normalize_legacy_subject_key(str(entry.get("subject_key", "")))
		result.append({
			"subject_key": subject_key,
			"subject_kind": _normalize_legacy_subject_kind(raw_subject_kind, raw_subject_type),
			"subject_type": _normalize_legacy_subject_type(raw_subject_kind, raw_subject_type),
			"title": _get_normalized_journal_title(entry),
			"description": _get_normalized_journal_description(entry),
			"recipe_ids": _get_related_recipe_ids(subject_key),
			"recipes": normalized_recipes,
			"unread": bool(entry.get("unread", false)),
			"attempts": maxi(int(entry.get("attempts", 0)), 0),
		})
	return result

func _formula_parts_from_formula_string(formula: String) -> Array:
	if formula.is_empty():
		return []
	var rhs := formula
	if formula.contains("="):
		var pieces := formula.split("=", false, 1)
		if pieces.size() == 2:
			rhs = str(pieces[1])
	var parts: Array = []
	for part in rhs.split("+", false):
		var normalized := str(part).strip_edges()
		if not normalized.is_empty():
			parts.append(normalized)
	return parts

func _sanitize_recipe_parts(parts: Array) -> Array:
	var sanitized: Array = []
	for part_variant in parts:
		var normalized := str(part_variant).strip_edges()
		if normalized.is_empty():
			continue
		var upper := normalized.to_upper()
		if upper == "JOURNAL" or upper == "BLUEPRINT":
			continue
		sanitized.append(normalized)
	return sanitized

func _load_recipe_catalog():
	recipe_catalog = {}
	if not FileAccess.file_exists(RECIPE_CATALOG_PATH):
		push_warning("Recipe catalog missing at %s" % RECIPE_CATALOG_PATH)
		return
	var file := FileAccess.open(RECIPE_CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_warning("Failed to open recipe catalog at %s" % RECIPE_CATALOG_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Recipe catalog at %s is not a dictionary" % RECIPE_CATALOG_PATH)
		return
	recipe_catalog = Dictionary(parsed)

func _load_enemy_loot_catalog():
	enemy_loot_catalog = {}
	if not FileAccess.file_exists(ENEMY_LOOT_CATALOG_PATH):
		push_warning("Enemy loot catalog missing at %s" % ENEMY_LOOT_CATALOG_PATH)
		return
	var file := FileAccess.open(ENEMY_LOOT_CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_warning("Failed to open enemy loot catalog at %s" % ENEMY_LOOT_CATALOG_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Enemy loot catalog at %s is not a dictionary" % ENEMY_LOOT_CATALOG_PATH)
		return
	enemy_loot_catalog = Dictionary(parsed)

func _get_loaded_research_recipes(subject_key: String) -> Array:
	var loaded: Array = []
	if recipe_catalog.is_empty():
		return loaded
	for recipe_variant in Array(recipe_catalog.get(subject_key, [])):
		if typeof(recipe_variant) != TYPE_DICTIONARY:
			continue
		var recipe: Dictionary = recipe_variant
		loaded.append(_build_recipe(
			str(recipe.get("id", "")),
			str(recipe.get("result", "")),
			Array(recipe.get("parts", [])).duplicate(true),
			subject_key
		))
	return loaded

func _get_loaded_enemy_loot_table(enemy_type: String) -> Array:
	if enemy_loot_catalog.is_empty():
		return []
	return Array(enemy_loot_catalog.get(enemy_type, [])).duplicate(true)

func _get_loaded_recipe_by_id(recipe_id: String) -> Dictionary:
	if recipe_id.is_empty() or recipe_catalog.is_empty():
		return {}
	for subject_key_variant in recipe_catalog.keys():
		var subject_key := str(subject_key_variant)
		var recipe_list_variant: Variant = recipe_catalog[subject_key_variant]
		if typeof(recipe_list_variant) != TYPE_ARRAY:
			continue
		for recipe_variant in Array(recipe_list_variant):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe := Dictionary(recipe_variant)
			if str(recipe.get("id", "")) == recipe_id:
				return _build_recipe(
					str(recipe.get("id", "")),
					str(recipe.get("result", "")),
					Array(recipe.get("parts", [])).duplicate(true),
					subject_key,
				)
	return {}

func _get_all_research_subjects() -> Array:
	var subjects: Array = []
	for material_type in RESEARCH_MATERIAL_TYPES:
		subjects.append({"kind": "material", "type": material_type})
	for location_type in RESEARCH_LOCATION_TYPES:
		subjects.append({"kind": "location", "type": location_type})
	for enemy_type in RESEARCH_ENEMY_TYPES:
		subjects.append({"kind": "enemy", "type": enemy_type})
	for machine_type in RESEARCH_MACHINE_TYPES:
		subjects.append({"kind": "machine", "type": machine_type})
	for drone_type_variant in get_research_drone_types():
		var drone_type := str(drone_type_variant)
		subjects.append({"kind": "drone", "type": drone_type})
	for tape_type in RESEARCH_TAPE_TYPES:
		subjects.append({"kind": "tape", "type": tape_type})
	for resource_type in RESEARCH_RESOURCE_TYPES:
		subjects.append({"kind": "resource", "type": resource_type})
	for equipment_type in RESEARCH_EQUIPMENT_TYPES:
		subjects.append({"kind": "equipment", "type": equipment_type})
	for crafted_type in RESEARCH_CRAFTED_TYPES:
		subjects.append({"kind": "structure", "type": crafted_type})
	for mechanism_type in RESEARCH_MECHANISM_TYPES:
		subjects.append({"kind": "mechanism", "type": mechanism_type})
	return subjects

func _get_all_loaded_research_recipes() -> Array:
	var loaded: Array = []
	if recipe_catalog.is_empty():
		return loaded
	for subject_key_variant in recipe_catalog.keys():
		var subject_key := str(subject_key_variant)
		for recipe_variant in Array(recipe_catalog.get(subject_key, [])):
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = Dictionary(recipe_variant)
			loaded.append(_build_recipe(
				str(recipe.get("id", "")),
				str(recipe.get("result", "")),
				Array(recipe.get("parts", [])).duplicate(true),
				subject_key
			))
	return loaded

func _get_related_recipe_ids(subject_key: String) -> Array:
	var related_ids: Array[String] = []
	for recipe_variant in _get_all_loaded_research_recipes():
		if typeof(recipe_variant) != TYPE_DICTIONARY:
			continue
		var recipe: Dictionary = Dictionary(recipe_variant)
		if subject_key in _get_recipe_related_subject_keys(recipe):
			var recipe_id := str(recipe.get("id", ""))
			if not recipe_id.is_empty():
				related_ids.append(recipe_id)
	return _dedupe_strings(related_ids)

func _build_journal_recipe_display_list(subject_key: String, discovered_recipes_by_id: Dictionary, related_recipe_ids: Array, discovered_by_key: Dictionary) -> Array:
	var display_recipes: Array = []
	var seen_recipe_ids := {}
	for recipe_id_variant in related_recipe_ids:
		var recipe_id := str(recipe_id_variant)
		if recipe_id.is_empty():
			continue
		var live_recipe := _get_loaded_recipe_by_id(recipe_id)
		if live_recipe.is_empty():
			continue
		seen_recipe_ids[recipe_id] = true
		var discovered_recipe := {}
		if discovered_recipes_by_id.has(recipe_id):
			discovered_recipe = Dictionary(discovered_recipes_by_id[recipe_id]).duplicate(true)
		display_recipes.append(_build_journal_recipe_entry(subject_key, live_recipe, discovered_by_key, discovered_recipe))
	for recipe_id_variant in discovered_recipes_by_id.keys():
		var recipe_id := str(recipe_id_variant)
		if seen_recipe_ids.has(recipe_id):
			continue
		var discovered_recipe: Dictionary = Dictionary(discovered_recipes_by_id[recipe_id]).duplicate(true)
		if subject_key in _get_recipe_related_subject_keys(discovered_recipe):
			display_recipes.append(_build_journal_recipe_entry(subject_key, discovered_recipe, discovered_by_key, discovered_recipe))
	return display_recipes

func _build_journal_recipe_entry(subject_key: String, recipe_source: Dictionary, discovered_by_key: Dictionary, discovered_recipe: Dictionary = {}) -> Dictionary:
	var recipe := recipe_source.duplicate(true)
	var recipe_id := str(recipe.get("id", ""))
	var result_name := str(recipe.get("result", "UNKNOWN")).to_upper()
	var formula_parts: Array = _sanitize_recipe_parts(Array(recipe.get("formula_parts", [])).duplicate(true))
	if formula_parts.is_empty():
		formula_parts = _sanitize_recipe_parts(_formula_parts_from_formula_string(str(recipe.get("formula", ""))))
	formula_parts = _normalize_recipe_result_parts(result_name, formula_parts)
	var state := _get_journal_recipe_state(subject_key, formula_parts, discovered_by_key)
	var formula_text := _build_journal_recipe_formula_text(result_name, formula_parts, discovered_by_key, state)
	return {
		"id": recipe_id,
		"result": result_name,
		"formula_parts": formula_parts,
		"formula": formula_text,
		"subject_key": subject_key,
		"unread": bool(discovered_recipe.get("unread", false)),
		"locked": state == "locked",
		"state": state,
		"copyable": state == "complete",
	}

func _get_journal_recipe_state(subject_key: String, formula_parts: Array, discovered_by_key: Dictionary) -> String:
	var has_known_subject := discovered_by_key.has(subject_key)
	var has_unknown_subject := false
	for part_variant in formula_parts:
		var part_subject_key := _get_formula_part_subject_key(str(part_variant))
		if part_subject_key.is_empty():
			continue
		if discovered_by_key.has(part_subject_key):
			has_known_subject = true
		else:
			has_unknown_subject = true
	if not has_unknown_subject:
		return "complete"
	return "partial" if has_known_subject else "locked"

func _build_journal_recipe_formula_text(result_name: String, formula_parts: Array, discovered_by_key: Dictionary, state: String) -> String:
	if state == "locked":
		return _build_locked_formula_text(result_name, formula_parts)
	var display_parts: Array[String] = []
	for part_variant in formula_parts:
		display_parts.append(_build_journal_formula_part_display(str(part_variant), discovered_by_key))
	return "%s = %s" % [result_name, " + ".join(display_parts)]

func _build_journal_formula_part_display(part: String, discovered_by_key: Dictionary) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return "??"
	var part_subject_key := _get_formula_part_subject_key(normalized)
	if part_subject_key.is_empty() or discovered_by_key.has(part_subject_key):
		return normalized
	return _mask_locked_formula_part(normalized)

func _get_recipe_related_subject_keys(recipe: Dictionary) -> Array:
	var related_keys: Array[String] = []
	var owner_subject_key := str(recipe.get("subject_key", ""))
	if not owner_subject_key.is_empty():
		related_keys.append(owner_subject_key)
	var result_subject_key := _get_named_subject_key(str(recipe.get("result", "")))
	if not result_subject_key.is_empty():
		related_keys.append(result_subject_key)
	for part_variant in Array(recipe.get("formula_parts", [])):
		var part_subject_key := _get_formula_part_subject_key(str(part_variant))
		if not part_subject_key.is_empty():
			related_keys.append(part_subject_key)
	return _dedupe_strings(related_keys)

func _get_formula_part_subject_key(part: String) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return ""
	var quantity_marker := normalized.to_lower().rfind(" x")
	if quantity_marker != -1:
		normalized = normalized.substr(0, quantity_marker).strip_edges()
	return _get_named_subject_key(normalized)

func _get_named_subject_key(token: String) -> String:
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
		"TOOL CHEST":
			return "structure_tool_chest"
		"BROOD CAGE":
			return "structure_brood_cage"
		"ARCHIVE SHELF":
			return "structure_archive_shelf"
		_:
			return ""

func _build_locked_journal_entry(subject_key: String, subject_def: Dictionary) -> Dictionary:
	return {
		"subject_key": subject_key,
		"subject_kind": str(subject_def.get("subject_kind", "")),
		"subject_type": str(subject_def.get("subject_type", "")),
		"title": _mask_locked_journal_label(str(subject_def.get("title", "UNKNOWN ENTRY"))),
		"description": _build_locked_journal_description(subject_def),
		"recipe_ids": _get_related_recipe_ids(subject_key),
		"recipes": _build_locked_journal_recipe_list(subject_key, Array(subject_def.get("recipes", []))),
		"unread": false,
		"attempts": 0,
		"locked": true,
	}

func _build_locked_journal_recipe_list(subject_key: String, live_recipes: Array) -> Array:
	var recipes: Array = []
	for live_recipe_variant in live_recipes:
		if typeof(live_recipe_variant) != TYPE_DICTIONARY:
			continue
		recipes.append(_build_locked_journal_recipe(subject_key, Dictionary(live_recipe_variant)))
	return recipes

func _build_locked_journal_recipe(subject_key: String, live_recipe: Dictionary) -> Dictionary:
	var formula_parts: Array = Array(live_recipe.get("formula_parts", [])).duplicate(true)
	return {
		"id": str(live_recipe.get("id", "")),
		"result": _mask_locked_journal_label(str(live_recipe.get("result", "UNKNOWN"))),
		"formula_parts": formula_parts,
		"formula": _build_locked_formula_text(str(live_recipe.get("result", "UNKNOWN")), formula_parts),
		"subject_key": subject_key,
		"unread": false,
		"locked": true,
	}

func _build_locked_formula_text(result_name: String, formula_parts: Array) -> String:
	var masked_parts: Array[String] = []
	for part_variant in formula_parts:
		masked_parts.append(_mask_locked_formula_part(str(part_variant)))
	return "%s = %s" % [_mask_locked_journal_label(result_name), " + ".join(masked_parts)]

func _mask_locked_formula_part(part: String) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return "??"
	var quantity_marker := normalized.to_lower().rfind(" x")
	if quantity_marker != -1 and quantity_marker < normalized.length() - 2:
		return "?? %s" % normalized.substr(quantity_marker + 1, normalized.length() - quantity_marker - 1)
	return "??"

func _mask_locked_journal_label(label: String) -> String:
	var normalized := label.strip_edges().replace("_", " ").to_upper()
	if normalized.is_empty():
		return "???"
	var masked := ""
	for char_index in range(normalized.length()):
		var char := normalized.substr(char_index, 1)
		if char == " ":
			masked += char
			continue
		masked += char if char_index % 3 == 0 else "?"
	return masked

func _build_locked_journal_description(subject_def: Dictionary) -> String:
	var recipe_count := Array(subject_def.get("recipes", [])).size()
	if recipe_count <= 0:
		return "Undiscovered notes. The page structure is present, but no stable fragments are readable yet."
	var formula_noun := "formula" if recipe_count == 1 else "formulas"
	return "Undiscovered notes. Fragmented observations suggest %d locked %s under this subject." % [recipe_count, formula_noun]

func _normalize_recipe_result_parts(result_name: String, parts: Array) -> Array:
	var normalized_result := result_name.to_upper()
	if normalized_result != "ENERGY BAR" and normalized_result != "DRY RATIONS":
		return parts
	var filtered: Array = []
	for part_variant in parts:
		var normalized_part := str(part_variant).strip_edges()
		if normalized_part.to_upper() == "PAPER x1".to_upper():
			continue
		filtered.append(normalized_part)
	return filtered

func _get_journal_entry_index(subject_key: String) -> int:
	for entry_index in range(journal_entries.size()):
		if str(journal_entries[entry_index].get("subject_key", "")) == subject_key:
			return entry_index
	return -1

func _get_research_subject_key(subject: Dictionary) -> String:
	var raw_subject_kind := str(subject.get("kind", ""))
	var raw_subject_type := str(subject.get("type", ""))
	var subject_kind := _normalize_legacy_subject_kind(raw_subject_kind, raw_subject_type)
	var subject_type := _normalize_legacy_subject_type(raw_subject_kind, raw_subject_type)
	if subject_kind.is_empty():
		return ""
	match subject_kind:
		"machine":
			return "machine_%s" % subject_type
		"drone":
			return "drone_%s" % subject_type
		"tape":
			return "tape_%s" % subject_type
		"resource":
			return "resource_%s" % subject_type
		"equipment":
			return "equipment_%s" % subject_type
		"location":
			return "location_%s" % subject_type
		"enemy":
			return "enemy_%s" % subject_type
		"material":
			return "material_%s" % subject_type
		"mechanism":
			return "mechanism_%s" % subject_type
		"structure":
			return "structure_%s" % subject_type
		_:
			return "%s_%s" % [subject_kind, subject_type]

func _consume_research_subject(subject: Dictionary) -> Dictionary:
	var raw_subject_kind := str(subject.get("kind", ""))
	var raw_subject_type := str(subject.get("type", ""))
	var subject_kind := _normalize_legacy_subject_kind(raw_subject_kind, raw_subject_type)
	match subject_kind:
		"material":
			var card_id := str(subject.get("card_id", ""))
			if card_id.is_empty():
				return {"consumed": false, "depleted": false}
			for card_index in range(material_cards.size()):
				if str(material_cards[card_index].get("id", "")) != card_id:
					continue
				var quantity := maxi(int(material_cards[card_index].get("quantity", 0)), 0)
				if quantity <= 0:
					return {"consumed": false, "depleted": false}
				quantity -= 1
				if quantity <= 0:
					material_cards.remove_at(card_index)
					return {"consumed": true, "depleted": true}
				material_cards[card_index]["quantity"] = quantity
				return {"consumed": true, "depleted": false}
			return {"consumed": false, "depleted": false}
		"equipment":
			var equipment_card_id := str(subject.get("card_id", ""))
			if equipment_card_id.is_empty():
				return {"consumed": false, "depleted": false}
			for card_index in range(equipment_cards.size()):
				if str(equipment_cards[card_index].get("id", "")) != equipment_card_id:
					continue
				equipment_cards.remove_at(card_index)
				return {"consumed": true, "depleted": true}
			return {"consumed": false, "depleted": false}
		"resource":
			return {"consumed": true, "depleted": false}
		_:
			return {"consumed": true, "depleted": false}

func _get_normalized_journal_title(entry: Dictionary) -> String:
	var subject_def := _get_research_subject_definition({
		"kind": str(entry.get("subject_kind", "")),
		"type": str(entry.get("subject_type", "")),
	})
	var normalized_title := str(subject_def.get("title", ""))
	if not normalized_title.is_empty():
		return normalized_title
	return str(entry.get("title", ""))

func _get_normalized_journal_description(entry: Dictionary) -> String:
	var subject_def := _get_research_subject_definition({
		"kind": str(entry.get("subject_kind", "")),
		"type": str(entry.get("subject_type", "")),
	})
	var normalized_description := str(subject_def.get("description", ""))
	if not normalized_description.is_empty():
		return normalized_description
	return str(entry.get("description", ""))

func _get_research_subject_definition(subject: Dictionary) -> Dictionary:
	var subject_kind := str(subject.get("kind", ""))
	var subject_type := str(subject.get("type", ""))
	match subject_kind:
		"material":
			return _get_material_research_definition(subject_type)
		"location":
			return _get_location_research_definition(subject_type)
		"enemy":
			return _get_enemy_research_definition(subject_type)
		"machine":
			return _get_machine_research_definition(subject_type)
		"mechanism":
			return _get_mechanism_research_definition(subject_type)
		"drone":
			return _get_drone_research_definition(subject_type)
		"tape":
			return _get_tape_research_definition(subject_type)
		"resource":
			return _get_resource_research_definition(subject_type)
		"equipment":
			return _get_equipment_research_definition(subject_type)
		"crafted", "structure":
			return _get_structure_research_definition(subject_type)
		_:
			return {}

func _get_drone_action_command_list(drone_type: String) -> Array:
	var drone_def := get_drone_type_definition(drone_type)
	return Array(drone_def.get("action_commands", []))

func _get_drone_action_command_text(drone_type: String) -> String:
	var command_labels: Array[String] = []
	for command_name_variant in _get_drone_action_command_list(drone_type):
		command_labels.append(str(command_name_variant).to_upper())
	return ", ".join(command_labels)

func _get_drone_action_command_code_text(drone_type: String) -> String:
	var command_specs: Array[String] = []
	for command_name_variant in _get_drone_action_command_list(drone_type):
		var command_name := str(command_name_variant).to_upper()
		var bits := _get_instruction_opcode_bits(command_name)
		if bits.is_empty():
			command_specs.append(command_name)
		else:
			command_specs.append("%s %s" % [command_name, bits])
	return ", ".join(command_specs)

func _get_instruction_opcode_bits(command_name: String) -> String:
	for index in range(32):
		if PunchEncodingData.get_opcode_name(index) == command_name:
			return PunchEncodingData.bits_for_index(index)
	return ""

func _is_drone_command_supported(drone_type: String, instruction_type: String) -> bool:
	if DRONE_SHARED_COMMANDS.has(instruction_type):
		return true
	return _get_drone_action_command_list(drone_type).has(instruction_type)

func _get_material_research_definition(material_type: String) -> Dictionary:
	var subject_key := "material_%s" % material_type
	match material_type:
		"metal":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "METAL",
				"description": "Recovered structural stock. Best used for frames, braces, mounts, and hard-wearing shells.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"spring":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "SPRING",
				"description": "Tension stock. Stores work in a compact form and anchors most wound or snapping mechanisms.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"paper":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "PAPER",
				"description": "Recording stock. Useful for labels, disposable notes, and the outer layers of printable media.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"fiber":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "FIBER",
				"description": "Dry plant stock. Useful for processing into paper, packing, and preserved food binders.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"biomass":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "BIOMASS",
				"description": "Wet organic stock. Ferments, binds, and carries scent more readily than harder materials.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"dry_rations":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "DRY RATIONS",
				"description": "Packed preserved food. Stable shelf stock for restoring operator energy.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"medicine":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "MEDICINE",
				"description": "Prepared treatment stock. Used to restore operator health in the workshop.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"growth_medium":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "GROWTH MEDIUM",
				"description": "Prepared bio substrate. Stable organic stock for later cultivation or cage work.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"mushrooms":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "MUSHROOMS",
				"description": "Fungal food stock. Grows from wet substrate and can be dried or processed into rough rations.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"algae":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "ALGAE",
				"description": "Wet filament stock. Useful as a fiber-rich biological source for pond-side growth processes.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"bacteria":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "BACTERIA",
				"description": "Microbial stock. Useful for breakdown, fermentation, and medical processing lines.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"mealworms":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "MEALWORMS",
				"description": "Insect protein stock. Useful for dense biomass conversion and compact food-chain processes.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"bone_meal":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "BONE MEAL",
				"description": "Ground mineral powder. Useful for feeding growth processes and bacterial work.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"hide":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "HIDE",
				"description": "Flexible organic sheet stock. Good for wraps, satchels, and quiet padded layers.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"bone":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "BONE",
				"description": "Hard organic stock. Light, rigid, and easy to shape into hooks, pins, and points.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"power_unit":
			return {
				"subject_kind": "material",
				"subject_type": material_type,
				"title": "POWER UNIT",
				"description": "Portable stored charge. A compact workshop reserve used by the charge machine to refill field units.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_location_research_definition(location_type: String) -> Dictionary:
	var subject_key := "location_%s" % location_type
	var extract_text := _get_location_extracts_text(location_type)
	var risk_text := _get_location_risk_text(location_type)
	match location_type:
		"pond":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "POND",
				"description": "Shallow basin with recoverable wet stock.",
				"notes_sections": _build_location_note_sections("Wet collection site. Good for regenerative biological stock and low-grade harvest.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"crater":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "CRATER",
				"description": "Impact basin with sifted dust and hard edges.",
				"notes_sections": _build_location_note_sections("Broken mineral basin. Good for hard salvage and exposed remains.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"tower":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "TOWER",
				"description": "Elevated relay structure.",
				"notes_sections": _build_location_note_sections("Raised sight and relay point. Valuable, exposed, and usually watched.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"surveillance_zone":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "SURVEILLANCE ZONE",
				"description": "Observed corridor with repeated watch coverage.",
				"notes_sections": _build_location_note_sections("High-signature danger area. Route discipline matters more than yield here.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"facility":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "FACILITY",
				"description": "Industrial structure with repeated joints and work surfaces.",
				"notes_sections": _build_location_note_sections("Dense mechanical salvage site. Better yield, higher risk, good for structural work.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"bunker":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "BUNKER",
				"description": "Sealed shelter construction.",
				"notes_sections": _build_location_note_sections("High-value closed shelter site. Supplies and gear may survive, but access is dangerous.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"field":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "FIELD",
				"description": "Open productive ground.",
				"notes_sections": _build_location_note_sections("Renewable organic ground. Lower salvage density, better long-term biological value.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"dump":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "DUMP",
				"description": "Mixed discard site.",
				"notes_sections": _build_location_note_sections("Chaotic salvage field. Good for mixed recovery, bad for predictable safe routes.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"cache":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "CACHE",
				"description": "Small reserve layout.",
				"notes_sections": _build_location_note_sections("Compact stash site. Good for concentrated finds if it has not already been stripped.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"nest":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "NEST",
				"description": "Organic clustered structure.",
				"notes_sections": _build_location_note_sections("High organic yield with biological risk. Good for cages, bad for safe extraction.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"ruin":
			return {
				"subject_kind": "location",
				"subject_type": location_type,
				"title": "RUIN",
				"description": "Broken structure with surviving edges and voids.",
				"notes_sections": _build_location_note_sections("Fragmented old structure. Good for mixed salvage and slow careful reading of the site.", extract_text, risk_text),
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _build_location_note_sections(summary_text: String, extract_text: String, risk_text: String) -> Array:
	return [
		{"title": "SUMMARY", "text": summary_text},
		{"title": "EXTRACTS", "text": extract_text},
		{"title": "THREATS", "text": risk_text},
	]

func _get_location_extracts_text(location_type: String) -> String:
	var drop_table: Array = Array(LOCATION_SCAVENGE_TABLES.get(location_type, []))
	if drop_table.is_empty():
		return "no confirmed salvage"
	var parts: Array[String] = []
	for entry_variant in drop_table:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var entry_kind := str(entry.get("kind", "material"))
		if entry_kind == "power":
			parts.append("POWER UNIT")
			continue
		if entry_kind in ["crafted", "structure", "equipment"]:
			var crafted_name := str(entry.get("display_name", entry.get("result", ""))).strip_edges()
			if crafted_name.is_empty():
				crafted_name = str(entry.get("type", "")).replace("_", " ")
			if not crafted_name.is_empty():
				parts.append(crafted_name.to_upper())
			continue
		var material_type := str(entry.get("type", ""))
		if material_type.is_empty():
			continue
		parts.append(material_type.replace("_", " ").to_upper())
	if parts.is_empty():
		return "no confirmed salvage"
	return _join_readable_list(_dedupe_strings(parts))

func _get_location_risk_text(location_type: String) -> String:
	var encounter_table: Dictionary = Dictionary(LOCATION_ENCOUNTER_TABLES.get(location_type, {}))
	var type_entries: Array = Array(encounter_table.get("types", []))
	if type_entries.is_empty():
		return "no confirmed hostile pattern"
	var parts: Array[String] = []
	for type_entry_variant in type_entries:
		if typeof(type_entry_variant) != TYPE_DICTIONARY:
			continue
		var type_entry: Dictionary = type_entry_variant
		var enemy_type := str(type_entry.get("type", ""))
		if enemy_type.is_empty():
			continue
		parts.append(enemy_type.replace("_", " ").to_upper())
	if parts.is_empty():
		return "no confirmed hostile pattern"
	return _join_readable_list(_dedupe_strings(parts))

func _dedupe_strings(values: Array[String]) -> Array[String]:
	var deduped: Array[String] = []
	var seen := {}
	for value in values:
		if seen.has(value):
			continue
		seen[value] = true
		deduped.append(value)
	return deduped

func _join_readable_list(items: Array[String]) -> String:
	if items.is_empty():
		return ""
	if items.size() == 1:
		return items[0]
	if items.size() == 2:
		return "%s and %s" % [items[0], items[1]]
	var head := ""
	for item_index in range(items.size() - 1):
		if item_index > 0:
			head += ", "
		head += items[item_index]
	return "%s, and %s" % [head, items[items.size() - 1]]

func _get_enemy_research_definition(enemy_type: String) -> Dictionary:
	var subject_key := "enemy_%s" % enemy_type
	match enemy_type:
		"surveillance_drone":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "SURVEILLANCE DRONE",
				"description": "A light machine watcher. Useful for masking sightlines and redirecting observation.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"infantry_drone":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "INFANTRY DRONE",
				"description": "A heavier combat chassis. Teaches armor layering and recoil management.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"stalker":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "STALKER",
				"description": "A hostile scavenger. Its carried remnants suggest note-keeping, stalking gear, and field improvisation.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"grizzly":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "GRIZZLY",
				"description": "Heavy animal mass. Suggests insulation, load-bearing hide use, and hook geometry from bone.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"wolf_pack":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "WOLF PACK",
				"description": "Coordinated animal threat. Reveals pack spacing, tether logic, and scent-driven movement.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"warden":
			return {
				"subject_kind": "enemy",
				"subject_type": enemy_type,
				"title": "WARDEN",
				"description": "Heavy enforcement chassis. Dense plating, high strike force, and direct pursuit logic make it the most dangerous field machine yet.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_machine_research_definition(machine_type: String) -> Dictionary:
	var subject_key := "machine_%s" % machine_type
	match machine_type:
		"bench":
			return {
				"subject_kind": "machine",
				"subject_type": machine_type,
				"title": "PROGRAMMING BENCH",
				"description": "Punch-driven media station. Best for discovering recording layouts and tape handling procedures.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"route":
			return {
				"subject_kind": "machine",
				"subject_type": machine_type,
				"title": "ROUTE TABLE",
				"description": "Paper plotting station. Useful for route slips, survey marks, and path abstractions.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"charge":
			return {
				"subject_kind": "machine",
				"subject_type": machine_type,
				"title": "CHARGE MACHINE",
				"description": "Spring winding apparatus. A direct reference for charge handling and tension storage.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"trash":
			return {
				"subject_kind": "machine",
				"subject_type": machine_type,
				"title": "TRASH",
				"description": "Sorting and discard point. Good for learning reclamation, pulping, and material separation.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_mechanism_research_definition(mechanism_type: String) -> Dictionary:
	var subject_key := "mechanism_%s" % mechanism_type
	match mechanism_type:
		"tank":
			return {
				"subject_kind": "mechanism",
				"subject_type": mechanism_type,
				"title": "TANK",
				"description": "Portable bioprocess mechanism. Holds a living culture, a consumable feed stock, and a recipe blueprint for continuous slow output.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_drone_research_definition(drone_type: String) -> Dictionary:
	var subject_key := "drone_%s" % drone_type
	var drone_def := get_drone_type_definition(drone_type)
	if drone_def.is_empty():
		return {}
	return {
		"subject_kind": "drone",
		"subject_type": drone_type,
		"title": str(drone_def.get("title", drone_type.replace("_", " ").to_upper())),
		"description": str(drone_def.get("description", "")),
		"notes_sections": [
			{"title": "ROLE", "text": str(drone_def.get("role_text", ""))},
			{"title": "COMMANDS", "text": _get_drone_action_command_text(drone_type)},
			{"title": "PUNCH CODES", "text": _get_drone_action_command_code_text(drone_type)},
			{"title": "LIMITS", "text": str(drone_def.get("limits_text", ""))},
			{"title": "PROGRAMMING", "text": str(drone_def.get("programming_text", ""))},
		],
		"recipes": _get_loaded_research_recipes(subject_key),
	}

func _get_tape_research_definition(tape_type: String) -> Dictionary:
	var subject_key := "tape_%s" % tape_type
	match tape_type:
		"programmed":
			return {
				"subject_kind": "tape",
				"subject_type": tape_type,
				"title": "PROGRAMMED TAPE",
				"description": "Punched instruction medium. Reveals sequencing, loops, and reusable command patterns.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"blank":
			return {
				"subject_kind": "tape",
				"subject_type": tape_type,
				"title": "BLANK TAPE",
				"description": "Unused media stock. Useful for fresh recording surfaces and clean punched layouts.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_resource_research_definition(resource_type: String) -> Dictionary:
	match resource_type:
		"spring_charge":
			return _get_material_research_definition("power_unit")
		_:
			return {}

func _get_equipment_research_definition(equipment_type: String) -> Dictionary:
	var subject_key := "equipment_%s" % equipment_type
	match equipment_type:
		"knife":
			return {
				"subject_kind": "equipment",
				"subject_type": equipment_type,
				"title": "KNIFE",
				"description": "Close combat tool. Grants ATTACK +1 per copy when equipped in a universal slot.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"bow":
			return {
				"subject_kind": "equipment",
				"subject_type": equipment_type,
				"title": "BOW",
				"description": "Ranged weapon platform. Grants ATTACK +3 and ARMOR -1 per copy when equipped.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"plate_mail":
			return {
				"subject_kind": "equipment",
				"subject_type": equipment_type,
				"title": "PLATE MAIL",
				"description": "Heavy layered protection. Grants ARMOR +3 and STEALTH -1 per copy when equipped.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"hide_cloak":
			return {
				"subject_kind": "equipment",
				"subject_type": equipment_type,
				"title": "HIDE CLOAK",
				"description": "Soft concealment layer. Grants STEALTH +3 per copy when equipped.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"tool_kit":
			return {
				"subject_kind": "equipment",
				"subject_type": equipment_type,
				"title": "TOOL KIT",
				"description": "Field repair and build bundle. Grants UTILITY +3 per copy when equipped.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_structure_research_definition(crafted_type: String) -> Dictionary:
	var subject_key := "structure_%s" % crafted_type
	match crafted_type:
		"tool_chest":
			return {
				"subject_kind": "structure",
				"subject_type": crafted_type,
				"title": "TOOL CHEST",
				"description": "Heavy workshop storage. Holds stacks and cage items without using table space.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"brood_cage":
			return {
				"subject_kind": "structure",
				"subject_type": crafted_type,
				"title": "BROOD CAGE",
				"description": "Containment cage for hostile biological subjects. Empty or occupied, and valid for enemy research when loaded.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		"archive_shelf":
			return {
				"subject_kind": "structure",
				"subject_type": crafted_type,
				"title": "ARCHIVE SHELF",
				"description": "Paper and archive storage. Keeps knowledge stock organized without consuming active table area.",
				"recipes": _get_loaded_research_recipes(subject_key),
			}
		_:
			return {}

func _get_crafted_research_definition(crafted_type: String) -> Dictionary:
	return _get_structure_research_definition(crafted_type)

func _apply_operator_supply_effect(supply_key: String) -> Dictionary:
	var normalized := supply_key.strip_edges().to_upper().replace("_", " ")
	var energy_gain := 0
	var hp_gain := 0
	var success_message := ""
	match normalized:
		"ENERGY BAR":
			energy_gain = 4
			success_message = "Operator fed"
		"DRY RATIONS":
			energy_gain = 3
			success_message = "Operator fed"
		"MEDICINE":
			hp_gain = 2
			success_message = "Operator treated"
		_:
			return {"ok": false, "message": "%s cannot be used on the operator" % _default_material_display_name(_result_name_to_type(normalized))}
	var current_energy := int(operator_state.get("energy", 0))
	var max_operator_energy := int(operator_state.get("max_energy", OPERATOR_MAX_ENERGY))
	var current_hp := int(operator_state.get("hp", 0))
	var max_operator_hp := int(operator_state.get("max_hp", OPERATOR_MAX_HP))
	if energy_gain > 0:
		if current_energy >= max_operator_energy:
			return {"ok": false, "message": "Operator energy is already full"}
		operator_state["energy"] = mini(current_energy + energy_gain, max_operator_energy)
	if hp_gain > 0:
		if current_hp >= max_operator_hp:
			return {"ok": false, "message": "Operator HP is already full"}
		operator_state["hp"] = mini(current_hp + hp_gain, max_operator_hp)
	if int(operator_state.get("hp", 0)) > 0:
		operator_state["status"] = "active"
	return {"ok": true, "message": success_message}

func _get_craft_result_spec(result_name: String) -> Dictionary:
	var normalized := result_name.strip_edges().to_upper()
	if normalized == "FRESH TAPE":
		return {
			"kind": "blank",
			"type": "blank_tape",
			"display_name": "Fresh Tape",
		}
	if STACKABLE_CRAFT_RESULT_SPECS.has(normalized):
		var spec: Dictionary = Dictionary(STACKABLE_CRAFT_RESULT_SPECS[normalized]).duplicate(true)
		spec["kind"] = "material"
		return spec
	if _is_equipment_result_name(normalized):
		var equipment_type := _result_name_to_type(normalized)
		var equipment_spec := _get_equipment_type_spec(equipment_type)
		if not equipment_spec.is_empty():
			return {
				"kind": "equipment",
				"type": equipment_type,
				"display_name": str(equipment_spec.get("display_name", _get_equipment_display_name(equipment_type))),
			}
	if normalized == "TANK":
		return {
			"kind": "mechanism",
			"type": "tank",
			"display_name": "Tank",
		}
	return {
		"kind": "structure",
		"type": _result_name_to_type(normalized),
		"display_name": normalized.replace("_", " ").capitalize(),
	}

func get_tank_process_specs() -> Dictionary:
	return TANK_PROCESS_SPECS.duplicate(true)

func insert_card_into_tank(tank_id: String, source_kind: String, card_id: String) -> Dictionary:
	if tank_id.is_empty() or card_id.is_empty():
		return {"ok": false, "message": "Tank load is incomplete"}
	var tank_index := _find_crafted_card_index(tank_id)
	if tank_index == -1:
		return {"ok": false, "message": "Tank not found"}
	var tank_card: Dictionary = Dictionary(crafted_cards[tank_index]).duplicate(true)
	if str(tank_card.get("type", "")) != "tank":
		return {"ok": false, "message": "Card is not a tank"}
	var tank_slots := _normalize_saved_tank_slots(Dictionary(tank_card.get("tank_slots", {})))
	match source_kind:
		"material":
			var material_index := _find_material_card_index(card_id)
			if material_index == -1:
				return {"ok": false, "message": "Material not found"}
			var material_card: Dictionary = Dictionary(material_cards[material_index]).duplicate(true)
			var material_type := str(material_card.get("type", ""))
			if material_type in ["algae", "bacteria", "mealworms", "mushrooms"]:
				if not Dictionary(tank_slots.get("culture", {})).is_empty():
					return {"ok": false, "message": "Tank culture slot is occupied"}
				tank_slots["culture"] = material_card
			elif material_type in ["growth_medium", "biomass"]:
				if not Dictionary(tank_slots.get("feed", {})).is_empty():
					return {"ok": false, "message": "Tank feed slot is occupied"}
				tank_slots["feed"] = material_card
			else:
				return {"ok": false, "message": "Material cannot be loaded into tank"}
			material_cards.remove_at(material_index)
		"blueprint":
			var blueprint_index := _find_blueprint_card_index(card_id)
			if blueprint_index == -1:
				return {"ok": false, "message": "Blueprint not found"}
			var blueprint_card: Dictionary = Dictionary(blueprint_cards[blueprint_index]).duplicate(true)
			var recipe_result := str(blueprint_card.get("result", "")).to_upper()
			if not TANK_RECIPE_RESULT_TO_PROCESS.has(recipe_result):
				return {"ok": false, "message": "Blueprint is not a tank recipe"}
			if not Dictionary(tank_slots.get("recipe", {})).is_empty():
				return {"ok": false, "message": "Tank recipe slot is occupied"}
			tank_slots["recipe"] = blueprint_card
			blueprint_cards.remove_at(blueprint_index)
		_:
			return {"ok": false, "message": "Card cannot be loaded into tank"}
	tank_card["tank_slots"] = tank_slots
	crafted_cards[tank_index] = tank_card
	save_programmed_cartridges()
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"tank_id": tank_id,
		"message": "Tank loaded",
	}

func _get_tank_process_spec_for_card(tank_card: Dictionary) -> Dictionary:
	var tank_slots := _normalize_saved_tank_slots(Dictionary(tank_card.get("tank_slots", {})))
	var culture_card: Dictionary = Dictionary(tank_slots.get("culture", {}))
	var feed_card: Dictionary = Dictionary(tank_slots.get("feed", {}))
	var recipe_card: Dictionary = Dictionary(tank_slots.get("recipe", {}))
	if culture_card.is_empty() or feed_card.is_empty() or recipe_card.is_empty():
		return {}
	if maxi(int(feed_card.get("quantity", 0)), 0) <= 0:
		return {}
	var process_id := str(TANK_RECIPE_RESULT_TO_PROCESS.get(str(recipe_card.get("result", "")).to_upper(), ""))
	if process_id.is_empty():
		return {}
	var spec := Dictionary(TANK_PROCESS_SPECS.get(process_id, {})).duplicate(true)
	if spec.is_empty():
		return {}
	if str(culture_card.get("type", "")) != str(spec.get("culture_type", "")):
		return {}
	if str(feed_card.get("type", "")) != str(spec.get("feed_type", "")):
		return {}
	spec["process_id"] = process_id
	return spec

func withdraw_tank_slot(tank_id: String) -> Dictionary:
	if tank_id.is_empty():
		return {}
	var tank_index := _find_crafted_card_index(tank_id)
	if tank_index == -1:
		return {}
	var tank_card: Dictionary = Dictionary(crafted_cards[tank_index]).duplicate(true)
	if str(tank_card.get("type", "")) != "tank":
		return {}
	var tank_slots := _normalize_saved_tank_slots(Dictionary(tank_card.get("tank_slots", {})))
	var order := ["recipe", "feed", "culture"]
	for slot_name in order:
		var slot_card: Dictionary = Dictionary(tank_slots.get(slot_name, {})).duplicate(true)
		if slot_card.is_empty():
			continue
		tank_slots[slot_name] = {}
		tank_card["tank_slots"] = tank_slots
		crafted_cards[tank_index] = tank_card
		var slot_kind := "material"
		if slot_name == "recipe":
			slot_kind = "blueprint"
			blueprint_cards.append(slot_card)
		else:
			material_cards.append(slot_card)
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
		return {
			"kind": slot_kind,
			"id": str(slot_card.get("id", "")),
			"display_name": str(slot_card.get("display_name", slot_card.get("result", slot_card.get("type", "")))),
			"slot": slot_name,
		}
	return {}

func abort_tank_process_and_unload_all(tank_id: String) -> Dictionary:
	if tank_id.is_empty():
		return {"ok": false, "message": "Tank not found", "cards": []}
	var tank_index := _find_crafted_card_index(tank_id)
	if tank_index == -1:
		return {"ok": false, "message": "Tank not found", "cards": []}
	var tank_card: Dictionary = Dictionary(crafted_cards[tank_index]).duplicate(true)
	if str(tank_card.get("type", "")) != "tank":
		return {"ok": false, "message": "Card is not a tank", "cards": []}
	var had_active_batch := not Dictionary(tank_card.get("tank_batch", {})).is_empty()
	var tank_slots := _normalize_saved_tank_slots(Dictionary(tank_card.get("tank_slots", {})))
	var unloaded_cards: Array = []
	for slot_name in ["recipe", "feed", "culture"]:
		var slot_card: Dictionary = Dictionary(tank_slots.get(slot_name, {})).duplicate(true)
		if slot_card.is_empty():
			continue
		tank_slots[slot_name] = {}
		var withdrawn_kind := "material"
		if slot_name == "recipe":
			withdrawn_kind = "blueprint"
			blueprint_cards.append(slot_card)
		else:
			material_cards.append(slot_card)
		unloaded_cards.append({
			"kind": withdrawn_kind,
			"id": str(slot_card.get("id", "")),
			"display_name": str(slot_card.get("display_name", slot_card.get("result", slot_card.get("type", "")))),
			"slot": slot_name,
		})
	tank_card["tank_batch"] = {}
	tank_card["tank_slots"] = tank_slots
	crafted_cards[tank_index] = tank_card
	if had_active_batch or not unloaded_cards.is_empty():
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
	return {
		"ok": had_active_batch or not unloaded_cards.is_empty(),
		"stopped": had_active_batch,
		"cards": unloaded_cards,
		"message": "Tank stopped and unloaded" if had_active_batch else "Tank unloaded",
	}

func get_active_tank_batches() -> Array:
	var batches: Array = []
	var now := float(Time.get_unix_time_from_system())
	for crafted_card_variant in crafted_cards:
		if typeof(crafted_card_variant) != TYPE_DICTIONARY:
			continue
		var crafted_card: Dictionary = crafted_card_variant
		if str(crafted_card.get("type", "")) != "tank":
			continue
		var tank_batch: Dictionary = Dictionary(crafted_card.get("tank_batch", {}))
		if tank_batch.is_empty():
			continue
		var duration := maxf(float(tank_batch.get("duration", TANK_PROCESS_DEFAULT_DURATION)), 0.1)
		var remaining := maxf(float(tank_batch.get("ends_at", now)) - now, 0.0)
		batches.append({
			"tank_id": str(crafted_card.get("id", "")),
			"process_id": str(tank_batch.get("process_id", "")),
			"display_name": str(tank_batch.get("display_name", "Tank Batch")),
			"duration": duration,
			"remaining": remaining,
		})
	return batches

func start_available_tank_processes() -> Array:
	var started: Array = []
	var now := float(Time.get_unix_time_from_system())
	var changed := false
	for tank_index in range(crafted_cards.size()):
		var tank_card: Dictionary = Dictionary(crafted_cards[tank_index]).duplicate(true)
		if str(tank_card.get("type", "")) != "tank":
			continue
		if not Dictionary(tank_card.get("tank_batch", {})).is_empty():
			continue
		var tank_spec := _get_tank_process_spec_for_card(tank_card)
		if tank_spec.is_empty():
			continue
		var duration := maxf(float(tank_spec.get("duration", TANK_PROCESS_DEFAULT_DURATION)), 0.1)
		tank_card["tank_batch"] = {
			"process_id": str(tank_spec.get("process_id", "")),
			"result_type": str(tank_spec.get("result_type", "")),
			"display_name": str(tank_spec.get("display_name", "Tank Batch")),
			"quantity": maxi(int(tank_spec.get("quantity", 1)), 1),
			"duration": duration,
			"ends_at": now + duration,
		}
		crafted_cards[tank_index] = tank_card
		changed = true
		started.append({
			"tank_id": str(tank_card.get("id", "")),
			"display_name": str(tank_spec.get("display_name", "Tank Batch")),
		})
	if changed:
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
	return started

func tick_tank_processes() -> Array:
	var completions: Array = []
	var now := float(Time.get_unix_time_from_system())
	var changed := false
	for tank_index in range(crafted_cards.size()):
		var crafted_card: Dictionary = Dictionary(crafted_cards[tank_index]).duplicate(true)
		if str(crafted_card.get("type", "")) != "tank":
			continue
		var tank_batch: Dictionary = Dictionary(crafted_card.get("tank_batch", {}))
		if tank_batch.is_empty():
			continue
		if float(tank_batch.get("ends_at", now + 1.0)) > now:
			continue
		var result_type := str(tank_batch.get("result_type", ""))
		if result_type.is_empty():
			crafted_card["tank_batch"] = {}
			crafted_cards[tank_index] = crafted_card
			changed = true
			continue
		var created_material := _add_material_card({
			"type": result_type,
			"display_name": str(tank_batch.get("display_name", _default_material_display_name(result_type))),
			"quantity": maxi(int(tank_batch.get("quantity", 1)), 1),
			"source_recipe_id": str(tank_batch.get("process_id", "")),
		})
		var tank_slots := _normalize_saved_tank_slots(Dictionary(crafted_card.get("tank_slots", {})))
		var feed_card: Dictionary = Dictionary(tank_slots.get("feed", {})).duplicate(true)
		var process_spec := Dictionary(TANK_PROCESS_SPECS.get(str(tank_batch.get("process_id", "")), {}))
		var feed_consumed := bool(process_spec.get("feed_consumed", true))
		if feed_consumed and not feed_card.is_empty():
			var next_quantity := maxi(int(feed_card.get("quantity", 0)) - 1, 0)
			if next_quantity <= 0:
				tank_slots["feed"] = {}
			else:
				feed_card["quantity"] = next_quantity
				tank_slots["feed"] = feed_card
		crafted_card["tank_slots"] = tank_slots
		crafted_card["tank_batch"] = {}
		crafted_cards[tank_index] = crafted_card
		changed = true
		if not created_material.is_empty():
			created_material["kind"] = "material"
			completions.append({
				"tank_id": str(crafted_card.get("id", "")),
				"material": created_material.duplicate(true),
			})
	if changed:
		save_programmed_cartridges()
		EventBus.outside_world_changed.emit()
	return completions

func _result_name_to_type(result_name: String) -> String:
	return result_name.strip_edges().to_lower().replace(" ", "_").replace("-", "_")

func _default_material_display_name(material_type: String) -> String:
	return material_type.replace("_", " ").capitalize()

func _add_dog_card(entry: Dictionary = {}) -> Dictionary:
	var dog_card := _default_dog_card(entry)
	dog_cards.append(dog_card)
	return dog_card.duplicate(true)

func _apply_dog_supply_effect(dog_card: Dictionary, supply_key: String) -> Dictionary:
	var normalized := supply_key.strip_edges().to_upper().replace("_", " ")
	var energy_gain := 0
	var hp_gain := 0
	var success_message := ""
	match normalized:
		"BONE":
			energy_gain = 2
			success_message = "Dog fed"
		"DRY RATIONS":
			energy_gain = 3
			success_message = "Dog fed"
		"MEDICINE":
			hp_gain = 2
			success_message = "Dog treated"
		_:
			return {"ok": false, "message": "%s cannot be used on the dog" % _default_material_display_name(_result_name_to_type(normalized))}
	var next_dog := dog_card.duplicate(true)
	var current_energy := int(next_dog.get("energy", 0))
	var max_dog_energy := int(next_dog.get("max_energy", DOG_MAX_ENERGY))
	var current_hp := int(next_dog.get("hp", 0))
	var max_dog_hp := int(next_dog.get("max_hp", DOG_MAX_HP))
	if energy_gain > 0:
		if current_energy >= max_dog_energy:
			return {"ok": false, "message": "Dog energy is already full"}
		next_dog["energy"] = mini(current_energy + energy_gain, max_dog_energy)
	if hp_gain > 0:
		if current_hp >= max_dog_hp:
			return {"ok": false, "message": "Dog HP is already full"}
		next_dog["hp"] = mini(current_hp + hp_gain, max_dog_hp)
	if int(next_dog.get("hp", 0)) > 0:
		next_dog["status"] = "active"
	return {"ok": true, "message": success_message, "dog_card": next_dog}

func _default_equipment_totals() -> Dictionary:
	return {
		"attack": 0,
		"armor": 0,
		"stealth": 0,
		"utility": 0,
	}

func _sum_equipment_slot_totals(slots: Array) -> Dictionary:
	var totals := _default_equipment_totals()
	for slot_variant in slots:
		if typeof(slot_variant) != TYPE_DICTIONARY:
			continue
		var slot_entry := Dictionary(slot_variant)
		var spec := _get_equipment_type_spec(str(slot_entry.get("item_type", "")))
		if spec.is_empty():
			continue
		var stats: Dictionary = Dictionary(spec.get("stats", {}))
		for stat_name in totals.keys():
			totals[stat_name] = int(totals.get(stat_name, 0)) + int(stats.get(stat_name, 0))
	return totals

func _get_equipment_type_spec(equipment_type: String) -> Dictionary:
	if EQUIPMENT_TYPE_SPECS.has(equipment_type):
		return Dictionary(EQUIPMENT_TYPE_SPECS[equipment_type]).duplicate(true)
	return {}

func _get_equipment_display_name(equipment_type: String) -> String:
	var spec := _get_equipment_type_spec(equipment_type)
	if not spec.is_empty():
		return str(spec.get("display_name", equipment_type.replace("_", " ").capitalize()))
	return equipment_type.replace("_", " ").capitalize()

func _is_equipment_result_name(result_name: String) -> bool:
	return not _get_equipment_type_spec(_result_name_to_type(result_name)).is_empty()

func _find_equipment_card_index(card_id: String) -> int:
	if card_id.is_empty():
		return -1
	for card_index in range(equipment_cards.size()):
		if str(equipment_cards[card_index].get("id", "")) == card_id:
			return card_index
	return -1

func _add_equipment_card(entry: Dictionary) -> Dictionary:
	var equipment_type := str(entry.get("type", ""))
	var spec := _get_equipment_type_spec(equipment_type)
	if spec.is_empty():
		return {}
	var card := {
		"id": "equipment_%d_%d" % [int(Time.get_unix_time_from_system()), equipment_cards.size()],
		"type": equipment_type,
		"display_name": str(entry.get("display_name", spec.get("display_name", _get_equipment_display_name(equipment_type)))),
	}
	equipment_cards.append(card)
	return card.duplicate(true)

func _equip_equipment_into_slots(card_id: String, slots: Array) -> Dictionary:
	var equipment_index := _find_equipment_card_index(card_id)
	if equipment_index == -1:
		return {"ok": false, "message": "Equipment card not found"}
	var equipment_card := Dictionary(equipment_cards[equipment_index]).duplicate(true)
	var equipment_type := str(equipment_card.get("type", ""))
	var spec := _get_equipment_type_spec(equipment_type)
	if spec.is_empty():
		return {"ok": false, "message": "Unsupported equipment"}
	var next_slots := _normalize_equipment_slots(slots)
	for slot_index in range(next_slots.size()):
		var slot_entry := Dictionary(next_slots[slot_index]).duplicate(true)
		if not str(slot_entry.get("item_type", "")).is_empty():
			continue
		slot_entry["item_type"] = equipment_type
		slot_entry["display_name"] = str(spec.get("display_name", _get_equipment_display_name(equipment_type)))
		next_slots[slot_index] = slot_entry
		equipment_cards.remove_at(equipment_index)
		return {
			"ok": true,
			"slots": next_slots,
			"slot_index": slot_index,
			"display_name": str(slot_entry.get("display_name", "Equipment")),
			"type": equipment_type,
		}
	return {"ok": false, "message": "No free equipment slot"}

func _unequip_equipment_from_slots(slots: Array, slot_index: int) -> Dictionary:
	var next_slots := _normalize_equipment_slots(slots)
	if slot_index < 0 or slot_index >= next_slots.size():
		return {"ok": false, "message": "Equipment slot not found"}
	var slot_entry := Dictionary(next_slots[slot_index]).duplicate(true)
	var equipment_type := str(slot_entry.get("item_type", ""))
	if equipment_type.is_empty():
		return {"ok": false, "message": "Equipment slot is empty"}
	var display_name := str(slot_entry.get("display_name", ""))
	if display_name.is_empty():
		display_name = _get_equipment_display_name(equipment_type)
	var equipment_card := _add_equipment_card({
		"type": equipment_type,
		"display_name": display_name,
	})
	if equipment_card.is_empty():
		return {"ok": false, "message": "Failed to extract equipment"}
	next_slots[slot_index] = {
		"slot_index": slot_index,
		"item_type": "",
		"display_name": "",
	}
	return {
		"ok": true,
		"slots": next_slots,
		"slot_index": slot_index,
		"display_name": display_name,
		"type": equipment_type,
		"equipment_card": equipment_card,
	}

func _build_recipe(recipe_id: String, result_name: String, parts: Array, subject_key: String) -> Dictionary:
	var normalized_parts: Array = _sanitize_recipe_parts(parts.duplicate(true))
	return {
		"id": recipe_id,
		"result": result_name.to_upper(),
		"formula_parts": normalized_parts,
		"formula": "%s = %s" % [result_name.to_upper(), _join_formula_parts(normalized_parts)],
		"subject_key": subject_key,
	}

func _join_formula_parts(parts: Array) -> String:
	var text_parts: Array[String] = []
	for part_variant in parts:
		text_parts.append(str(part_variant))
	return " + ".join(text_parts)

func _consume_material_quantity(card_id: String, amount: int) -> bool:
	if card_id.is_empty() or amount <= 0:
		return false
	for card_index in range(material_cards.size()):
		var card: Dictionary = material_cards[card_index]
		if str(card.get("id", "")) != card_id:
			continue
		var quantity := maxi(int(card.get("quantity", 0)), 0)
		if quantity < amount:
			return false
		quantity -= amount
		if quantity <= 0:
			material_cards.remove_at(card_index)
		else:
			material_cards[card_index]["quantity"] = quantity
		return true
	return false

func _has_material_quantity(card_id: String, amount: int) -> bool:
	if card_id.is_empty() or amount <= 0:
		return false
	for card_variant in material_cards:
		if typeof(card_variant) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = card_variant
		if str(card.get("id", "")) != card_id:
			continue
		return maxi(int(card.get("quantity", 0)), 0) >= amount
	return false

func _add_material_card(material_entry: Dictionary) -> Dictionary:
	var material_type := str(material_entry.get("type", ""))
	if material_type.is_empty():
		return {}
	var quantity := maxi(int(material_entry.get("quantity", 0)), 0)
	if quantity <= 0:
		return {}
	var card := {
		"id": "material_%d_%d" % [int(Time.get_unix_time_from_system()), material_cards.size()],
		"type": material_type,
		"display_name": str(material_entry.get("display_name", _default_material_display_name(material_type))),
		"quantity": quantity,
		"source_enemy_type": str(material_entry.get("source_enemy_type", "")),
		"source_location_type": str(material_entry.get("source_location_type", "")),
		"source_recipe_id": str(material_entry.get("source_recipe_id", "")),
	}
	material_cards.append(card)
	return card.duplicate(true)

func _get_total_material_quantity(material_type: String) -> int:
	var total := 0
	for material_variant in material_cards:
		if typeof(material_variant) != TYPE_DICTIONARY:
			continue
		var material_card: Dictionary = material_variant
		if str(material_card.get("type", "")) != material_type:
			continue
		total += maxi(int(material_card.get("quantity", 0)), 0)
	return total

func consume_material_type_quantity(material_type: String, amount: int) -> int:
	if material_type.is_empty() or amount <= 0:
		return 0
	var remaining := amount
	var consumed := 0
	for card_index in range(material_cards.size() - 1, -1, -1):
		var material_card: Dictionary = material_cards[card_index]
		if str(material_card.get("type", "")) != material_type:
			continue
		var quantity := maxi(int(material_card.get("quantity", 0)), 0)
		if quantity <= 0:
			continue
		var spend := mini(quantity, remaining)
		quantity -= spend
		remaining -= spend
		consumed += spend
		if quantity <= 0:
			material_cards.remove_at(card_index)
		else:
			material_cards[card_index]["quantity"] = quantity
		if remaining <= 0:
			break
	return consumed

func charge_bot_with_power_units(bot_index: int, max_units: int = BOT_POWER_CAPACITY) -> Dictionary:
	return charge_bot_with_power_units_and_operator_cost(bot_index, max_units, 0)

func charge_bot_with_power_units_and_operator_cost(bot_index: int, max_units: int = BOT_POWER_CAPACITY, operator_energy_cost: int = 0) -> Dictionary:
	if bot_index < 0 or bot_index >= bot_loadouts.size():
		return {"ok": false, "message": "Invalid bot"}
	if not is_bot_available_in_workshop(bot_index):
		return {"ok": false, "message": "Bot is outside"}
	if operator_energy_cost > 0:
		if not is_run_active():
			return {"ok": false, "message": "Operator unavailable"}
		if int(operator_state.get("energy", 0)) < operator_energy_cost:
			return {"ok": false, "message": "Operator too tired"}
	var max_power_charge := int(bot_loadouts[bot_index].get("max_power_charge", BOT_POWER_CAPACITY))
	var current_power := int(bot_loadouts[bot_index].get("power_charge", 0))
	var missing_power := maxi(max_power_charge - current_power, 0)
	if missing_power <= 0:
		return {"ok": false, "message": "Bot already full"}
	var consumed := consume_material_type_quantity("power_unit", mini(missing_power, maxi(max_units, 0)))
	if consumed <= 0:
		return {"ok": false, "message": "No power units"}
	if operator_energy_cost > 0:
		operator_state["energy"] = maxi(int(operator_state.get("energy", 0)) - operator_energy_cost, 0)
		operator_state["status"] = "exhausted" if int(operator_state.get("energy", 0)) <= 0 else "active"
	bot_loadouts[bot_index]["power_charge"] = current_power + consumed
	_sync_power_card_count(bot_loadouts[bot_index])
	_refresh_bot_predictions()
	save_programmed_cartridges()
	EventBus.operator_state_changed.emit(get_operator_state())
	EventBus.bot_loadouts_changed.emit(bot_loadouts)
	EventBus.outside_world_changed.emit()
	return {
		"ok": true,
		"charged": consumed,
		"operator_energy_cost": operator_energy_cost,
		"operator_energy": int(operator_state.get("energy", 0)),
		"power_charge": int(bot_loadouts[bot_index].get("power_charge", 0)),
		"message": "%s charged" % _bot_display_name(bot_index),
	}

func _get_enemy_type_definition(enemy_type: String) -> Dictionary:
	if ENEMY_TYPE_DEFS.has(enemy_type):
		return Dictionary(ENEMY_TYPE_DEFS[enemy_type])
	return {
		"label": enemy_type.replace("_", " ").capitalize(),
		"attack": 1,
		"hp": 3,
		"threat_level": 1,
	}

func _generate_markov_name(corpus: Array, allow_two_words: bool) -> String:
	var base_name := _generate_markov_token(corpus)
	if allow_two_words and randf() < 0.28:
		return "%s %s" % [base_name, _generate_markov_token(corpus)]
	return base_name

func _generate_markov_token(corpus: Array) -> String:
	if corpus.is_empty():
		return "Unknown"
	var chain := {}
	var starters: Array = []
	for sample_variant in corpus:
		var sample := "^" + str(sample_variant).to_lower() + "$"
		for index in range(sample.length() - 1):
			var current_char := sample[index]
			var next_char := sample[index + 1]
			if current_char == "^":
				starters.append(next_char)
			if not chain.has(current_char):
				chain[current_char] = []
			chain[current_char].append(next_char)
	var token := ""
	var current := "^"
	var min_length := 5
	var max_length := 11
	while token.length() < max_length:
		var options: Array = starters if current == "^" else chain.get(current, [])
		if options.is_empty():
			break
		var next_char := str(options[randi() % options.size()])
		if next_char == "$":
			if token.length() >= min_length:
				break
			current = "^"
			continue
		token += next_char
		current = next_char
	if token.is_empty():
		token = str(corpus[0])
	return token.capitalize()

func _default_location_display_name(location_type: String) -> String:
	return location_type.replace("_", " ").capitalize()

func _default_enemy_display_name(enemy_type: String) -> String:
	var enemy_def := _get_enemy_type_definition(enemy_type)
	return str(enemy_def.get("label", enemy_type.replace("_", " ").capitalize()))

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

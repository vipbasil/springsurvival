extends RefCounted

class_name EncounterWeightRules

const ShelterLeakRulesData = preload("res://scripts/data/ShelterLeakRules.gd")

static func location_encounter_chance(encounter_def: Dictionary, shelter_leaks: Dictionary) -> float:
	var base_chance := clampf(float(encounter_def.get("chance", 0.0)), 0.0, 1.0)
	var type_entries := Array(encounter_def.get("types", []))
	if type_entries.is_empty():
		return base_chance
	var total_weight := 0.0
	var weighted_bonus := 0.0
	for type_entry_variant in type_entries:
		if typeof(type_entry_variant) != TYPE_DICTIONARY:
			continue
		var type_entry: Dictionary = type_entry_variant
		var base_weight := maxf(float(type_entry.get("weight", 0.0)), 0.0)
		if base_weight <= 0.0:
			continue
		total_weight += base_weight
		weighted_bonus += enemy_leak_encounter_bonus(str(type_entry.get("type", "")), shelter_leaks) * base_weight
	if total_weight <= 0.0:
		return base_chance
	return clampf(base_chance + weighted_bonus / total_weight, 0.0, 0.95)

static func adjusted_entries(type_entries: Array, shelter_leaks: Dictionary) -> Array:
	var adjusted_entries: Array = []
	for type_entry_variant in type_entries:
		if typeof(type_entry_variant) != TYPE_DICTIONARY:
			continue
		var type_entry: Dictionary = Dictionary(type_entry_variant).duplicate(true)
		var enemy_type := str(type_entry.get("type", ""))
		if enemy_type.is_empty():
			continue
		var base_weight := maxf(float(type_entry.get("weight", 0.0)), 0.0)
		var adjusted_weight := int(round(base_weight * (1.0 + enemy_leak_weight_multiplier(enemy_type, shelter_leaks))))
		type_entry["weight"] = maxi(adjusted_weight, 1)
		adjusted_entries.append(type_entry)
	return adjusted_entries

static func enemy_leak_weight_multiplier(enemy_type: String, shelter_leaks: Dictionary) -> float:
	return enemy_leak_encounter_bonus(enemy_type, shelter_leaks) * 2.0

static func enemy_leak_encounter_bonus(enemy_type: String, shelter_leaks: Dictionary) -> float:
	var trace_ratio := ShelterLeakRulesData.ratio(shelter_leaks, "trace")
	var noise_ratio := ShelterLeakRulesData.ratio(shelter_leaks, "noise")
	var waste_ratio := ShelterLeakRulesData.ratio(shelter_leaks, "waste")
	var heat_ratio := ShelterLeakRulesData.ratio(shelter_leaks, "heat")
	match enemy_type:
		"surveillance_drone":
			return heat_ratio * 0.22 + trace_ratio * 0.08
		"infantry_drone":
			return trace_ratio * 0.18 + heat_ratio * 0.06
		"warden":
			return heat_ratio * 0.18 + trace_ratio * 0.05
		"stalker":
			return trace_ratio * 0.18
		"wolf_pack":
			return noise_ratio * 0.20 + waste_ratio * 0.10
		"grizzly":
			return noise_ratio * 0.12 + waste_ratio * 0.18
		_:
			return 0.0

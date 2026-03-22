extends RefCounted

class_name WorkshopCardRuntime

const FEEDBACK_PHASES := {
	"attack": {"timer": "attack_timer", "duration": "attack_duration"},
	"damage": {"timer": "damage_timer", "duration": "damage_duration"},
	"research": {"timer": "research_timer", "duration": "research_duration"},
	"merge": {"timer": "merge_timer", "duration": "merge_duration"},
	"failure": {"timer": "failure_timer", "duration": "failure_duration"},
}
const STATE_TABLE_CARD_KINDS := ["location", "enemy", "material", "blueprint", "crafted"]
const STATE_TABLE_CARD_RECYCLE_MESSAGES := {
	"location": "Location card forgotten",
	"material": "Material discarded",
	"blueprint": "Blueprint discarded",
	"crafted": "Crafted card discarded",
}

static func build_drag_payload(kind: String, rect: Rect2, extra: Dictionary = {}) -> Dictionary:
	var payload := {
		"kind": kind,
		"identifier": extra.get("identifier", null),
		"source": str(extra.get("source", "")),
		"card_data": Dictionary(extra.get("card_data", {})),
		"rect": rect,
	}
	for key_variant in extra.keys():
		var key := str(key_variant)
		payload[key] = extra[key_variant]
	return payload

static func begin_drag_candidate(root_point: Vector2, rect: Rect2, kind: String, extra: Dictionary = {}) -> Dictionary:
	return {
		"drag_start_root": root_point,
		"drag_pickup_offset": root_point - rect.position,
		"payload": build_drag_payload(kind, rect, extra),
	}

static func set_feedback_phase(entry: Dictionary, phase: String, duration: float, extra: Dictionary = {}) -> Dictionary:
	if not FEEDBACK_PHASES.has(phase):
		return entry
	var next_entry := entry.duplicate(true)
	var phase_def: Dictionary = FEEDBACK_PHASES[phase]
	next_entry[str(phase_def.get("timer", ""))] = duration
	next_entry[str(phase_def.get("duration", ""))] = duration
	for key_variant in extra.keys():
		next_entry[str(key_variant)] = extra[key_variant]
	return next_entry

static func tick_feedback_entry(entry: Dictionary, delta: float) -> Dictionary:
	var next_entry := entry.duplicate(true)
	var active := false
	for phase_name in FEEDBACK_PHASES.keys():
		var phase_def: Dictionary = FEEDBACK_PHASES[phase_name]
		var timer_key := str(phase_def.get("timer", ""))
		var timer_value := maxf(float(next_entry.get(timer_key, 0.0)) - delta, 0.0)
		next_entry[timer_key] = timer_value
		if timer_value > 0.0:
			active = true
	return {
		"entry": next_entry,
		"active": active,
	}

static func build_process_overlay(card_rect: Rect2, cooldown: float, duration: float) -> Dictionary:
	return {
		"rect": card_rect,
		"progress": clampf(1.0 - (cooldown / maxf(duration, 0.001)), 0.0, 1.0),
	}

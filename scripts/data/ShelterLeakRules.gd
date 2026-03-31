extends RefCounted

class_name ShelterLeakRules

const MAX_VALUE := 100.0
const CHANNELS := ["trace", "noise", "waste", "heat"]
const DECAY_PER_SECOND := {
	"trace": 0.08,
	"noise": 0.22,
	"waste": 0.05,
	"heat": 0.12,
}

static func default_profile() -> Dictionary:
	var defaults := {}
	for channel_variant in CHANNELS:
		defaults[str(channel_variant)] = 0.0
	return defaults

static func normalize(entry: Dictionary) -> Dictionary:
	var leaks := default_profile()
	if typeof(entry) != TYPE_DICTIONARY:
		return leaks
	for channel_variant in CHANNELS:
		var channel := str(channel_variant)
		leaks[channel] = clampf(float(entry.get(channel, 0.0)), 0.0, MAX_VALUE)
	return leaks

static func apply_updates(current: Dictionary, updates: Dictionary) -> Dictionary:
	var leaks := normalize(current)
	for channel_variant in updates.keys():
		var channel := str(channel_variant).strip_edges().to_lower()
		if not leaks.has(channel):
			continue
		var amount := float(updates.get(channel_variant, 0.0))
		if is_zero_approx(amount):
			continue
		leaks[channel] = clampf(float(leaks.get(channel, 0.0)) + amount, 0.0, MAX_VALUE)
	return leaks

static func decay(current: Dictionary, delta: float) -> Dictionary:
	var leaks := normalize(current)
	if delta <= 0.0:
		return leaks
	for channel_variant in CHANNELS:
		var channel := str(channel_variant)
		var decay_amount := float(DECAY_PER_SECOND.get(channel, 0.0)) * delta
		if decay_amount <= 0.0:
			continue
		leaks[channel] = maxf(float(leaks.get(channel, 0.0)) - decay_amount, 0.0)
	return leaks

static func ratio(current: Dictionary, channel: String) -> float:
	var leaks := normalize(current)
	return clampf(float(leaks.get(channel.strip_edges().to_lower(), 0.0)) / MAX_VALUE, 0.0, 1.0)

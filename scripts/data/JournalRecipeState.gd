extends RefCounted

class_name JournalRecipeState

static func get_recipe_state(subject_key: String, formula_parts: Array, discovered_by_key: Dictionary, get_formula_part_subject_key: Callable) -> String:
	var has_known_subject := discovered_by_key.has(subject_key)
	var has_unknown_subject := false
	for part_variant in formula_parts:
		var part_subject_key := str(get_formula_part_subject_key.call(str(part_variant)))
		if part_subject_key.is_empty():
			continue
		if discovered_by_key.has(part_subject_key):
			has_known_subject = true
		else:
			has_unknown_subject = true
	if not has_unknown_subject:
		return "complete"
	return "partial" if has_known_subject else "locked"

static func build_formula_text(result_name: String, formula_parts: Array, discovered_by_key: Dictionary, state: String, get_formula_part_subject_key: Callable, mask_locked_journal_label: Callable) -> String:
	if state == "locked":
		return build_locked_formula_text(result_name, formula_parts, mask_locked_journal_label)
	var display_parts: Array[String] = []
	for part_variant in formula_parts:
		display_parts.append(build_formula_part_display(str(part_variant), discovered_by_key, get_formula_part_subject_key))
	return "%s = %s" % [result_name, " + ".join(display_parts)]

static func build_formula_part_display(part: String, discovered_by_key: Dictionary, get_formula_part_subject_key: Callable) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return "??"
	var part_subject_key := str(get_formula_part_subject_key.call(normalized))
	if part_subject_key.is_empty() or discovered_by_key.has(part_subject_key):
		return normalized
	return mask_locked_formula_part(normalized)

static func build_locked_formula_text(result_name: String, formula_parts: Array, mask_locked_journal_label: Callable) -> String:
	var masked_parts: Array[String] = []
	for part_variant in formula_parts:
		masked_parts.append(mask_locked_formula_part(str(part_variant)))
	return "%s = %s" % [str(mask_locked_journal_label.call(result_name)), " + ".join(masked_parts)]

static func mask_locked_formula_part(part: String) -> String:
	var normalized := part.strip_edges()
	if normalized.is_empty():
		return "??"
	var quantity_marker := normalized.to_lower().rfind(" x")
	if quantity_marker != -1 and quantity_marker < normalized.length() - 2:
		return "?? %s" % normalized.substr(quantity_marker + 1, normalized.length() - quantity_marker - 1)
	return "??"

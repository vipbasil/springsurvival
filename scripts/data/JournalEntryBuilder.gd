extends RefCounted

class_name JournalEntryBuilder

static func build_display_entries(
	journal_entries: Array,
	all_research_subjects: Array,
	get_research_subject_key: Callable,
	get_research_subject_definition: Callable,
	get_related_recipe_ids: Callable,
	build_journal_recipe_display_list: Callable,
	loaded_research_recipes: Array,
	get_named_subject_key: Callable,
	normalize_recipe_result_parts: Callable,
	sanitize_recipe_parts: Callable,
	get_journal_recipe_state: Callable,
	get_research_subject_definition_by_key: Callable,
	get_loaded_recipe_by_id: Callable,
	get_recipe_related_subject_keys: Callable,
	dedupe_strings: Callable,
	mask_locked_journal_label: Callable,
	is_journal_entry_unread: Callable,
	build_locked_journal_recipe_list: Callable,
	build_locked_journal_description: Callable
) -> Array:
	var discovered := collect_discovered_maps(journal_entries)
	var discovered_by_key: Dictionary = Dictionary(discovered.get("discovered_by_key", {}))
	var discovered_recipes_by_id: Dictionary = Dictionary(discovered.get("discovered_recipes_by_id", {}))
	var visible_by_key := build_formula_known_entries(
		discovered_by_key,
		loaded_research_recipes,
		get_named_subject_key,
		normalize_recipe_result_parts,
		sanitize_recipe_parts,
		get_journal_recipe_state,
		get_research_subject_definition_by_key,
		get_related_recipe_ids
	)
	var display_entries: Array = []
	var seen_subject_keys := {}
	for subject_variant in all_research_subjects:
		var subject: Dictionary = Dictionary(subject_variant)
		var subject_key := str(get_research_subject_key.call(subject))
		if subject_key.is_empty() or seen_subject_keys.has(subject_key):
			continue
		seen_subject_keys[subject_key] = true
		var subject_def: Dictionary = Dictionary(get_research_subject_definition.call(subject))
		if subject_def.is_empty():
			continue
		var related_recipe_ids: Array = Array(get_related_recipe_ids.call(subject_key))
		if visible_by_key.has(subject_key):
			var visible_entry: Dictionary = Dictionary(visible_by_key[subject_key]).duplicate(true)
			visible_entry["recipes"] = build_journal_recipe_display_list.call(
				subject_key,
				discovered_recipes_by_id,
				related_recipe_ids,
				visible_by_key
			)
			visible_entry["recipe_ids"] = related_recipe_ids.duplicate()
			visible_entry["related_subjects"] = build_related_subjects(
				subject_key,
				related_recipe_ids,
				visible_by_key,
				get_loaded_recipe_by_id,
				get_recipe_related_subject_keys,
				dedupe_strings,
				get_research_subject_definition_by_key,
				mask_locked_journal_label,
				is_journal_entry_unread
			)
			visible_entry["locked"] = false
			visible_entry = apply_live_subject_fields(visible_entry, subject_def)
			display_entries.append(visible_entry)
			continue
		var locked_entry := build_locked_journal_entry(
			subject_key,
			subject_def,
			get_related_recipe_ids,
			mask_locked_journal_label,
			build_locked_journal_recipe_list,
			build_locked_journal_description
		)
		locked_entry["recipes"] = build_journal_recipe_display_list.call(subject_key, discovered_recipes_by_id, related_recipe_ids, visible_by_key)
		locked_entry["recipe_ids"] = related_recipe_ids.duplicate()
		locked_entry["related_subjects"] = build_related_subjects(
			subject_key,
			related_recipe_ids,
			visible_by_key,
			get_loaded_recipe_by_id,
			get_recipe_related_subject_keys,
			dedupe_strings,
			get_research_subject_definition_by_key,
			mask_locked_journal_label,
			is_journal_entry_unread
		)
		display_entries.append(locked_entry)
	for subject_key_variant in visible_by_key.keys():
		var subject_key := str(subject_key_variant)
		if seen_subject_keys.has(subject_key):
			continue
		var fallback_entry: Dictionary = Dictionary(visible_by_key[subject_key]).duplicate(true)
		var fallback_recipe_ids: Array = Array(get_related_recipe_ids.call(subject_key))
		fallback_entry["recipe_ids"] = fallback_recipe_ids.duplicate()
		fallback_entry["recipes"] = build_journal_recipe_display_list.call(subject_key, discovered_recipes_by_id, fallback_recipe_ids, visible_by_key)
		fallback_entry["related_subjects"] = build_related_subjects(
			subject_key,
			fallback_recipe_ids,
			visible_by_key,
			get_loaded_recipe_by_id,
			get_recipe_related_subject_keys,
			dedupe_strings,
			get_research_subject_definition_by_key,
			mask_locked_journal_label,
			is_journal_entry_unread
		)
		fallback_entry["locked"] = false
		display_entries.append(fallback_entry)
	return display_entries

static func collect_discovered_maps(journal_entries: Array) -> Dictionary:
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
	return {
		"discovered_by_key": discovered_by_key,
		"discovered_recipes_by_id": discovered_recipes_by_id,
	}

static func apply_live_subject_fields(entry: Dictionary, subject_def: Dictionary) -> Dictionary:
	var result := entry.duplicate(true)
	if subject_def.has("notes_sections"):
		result["notes_sections"] = Array(subject_def.get("notes_sections", [])).duplicate(true)
	return result

static func build_formula_known_entries(
	discovered_by_key: Dictionary,
	loaded_research_recipes: Array,
	get_named_subject_key: Callable,
	normalize_recipe_result_parts: Callable,
	sanitize_recipe_parts: Callable,
	get_journal_recipe_state: Callable,
	get_research_subject_definition_by_key: Callable,
	get_related_recipe_ids: Callable
) -> Dictionary:
	var visible_by_key := {}
	for subject_key_variant in discovered_by_key.keys():
		var subject_key := str(subject_key_variant)
		visible_by_key[subject_key] = Dictionary(discovered_by_key[subject_key]).duplicate(true)
	var changed := true
	while changed:
		changed = false
		for recipe_variant in loaded_research_recipes:
			if typeof(recipe_variant) != TYPE_DICTIONARY:
				continue
			var recipe: Dictionary = Dictionary(recipe_variant)
			var result_subject_key := str(get_named_subject_key.call(str(recipe.get("result", ""))))
			if result_subject_key.is_empty() or visible_by_key.has(result_subject_key):
				continue
			var formula_parts: Array = get_normalized_formula_parts(recipe, normalize_recipe_result_parts, sanitize_recipe_parts)
			if str(get_journal_recipe_state.call(result_subject_key, formula_parts, visible_by_key)) != "complete":
				continue
			var subject_def: Dictionary = Dictionary(get_research_subject_definition_by_key.call(result_subject_key))
			if subject_def.is_empty():
				continue
			visible_by_key[result_subject_key] = build_formula_known_entry(result_subject_key, subject_def, get_related_recipe_ids)
			changed = true
	return visible_by_key

static func build_formula_known_entry(subject_key: String, subject_def: Dictionary, get_related_recipe_ids: Callable) -> Dictionary:
	return {
		"subject_key": subject_key,
		"subject_kind": str(subject_def.get("subject_kind", "")),
		"subject_type": str(subject_def.get("subject_type", "")),
		"title": str(subject_def.get("title", "UNKNOWN ENTRY")),
		"description": str(subject_def.get("description", "")),
		"recipe_ids": Array(get_related_recipe_ids.call(subject_key)),
		"recipes": [],
		"unread": false,
		"attempts": 0,
		"locked": false,
		"known_from_formula": true,
	}

static func build_related_subjects(
	subject_key: String,
	related_recipe_ids: Array,
	discovered_by_key: Dictionary,
	get_loaded_recipe_by_id: Callable,
	get_recipe_related_subject_keys: Callable,
	dedupe_strings: Callable,
	get_research_subject_definition_by_key: Callable,
	mask_locked_journal_label: Callable,
	is_journal_entry_unread: Callable
) -> Array:
	var related_keys: Array[String] = []
	for recipe_id_variant in related_recipe_ids:
		var recipe_id := str(recipe_id_variant)
		if recipe_id.is_empty():
			continue
		var live_recipe: Dictionary = Dictionary(get_loaded_recipe_by_id.call(recipe_id))
		if live_recipe.is_empty():
			continue
		for related_subject_key_variant in Array(get_recipe_related_subject_keys.call(live_recipe)):
			var related_subject_key := str(related_subject_key_variant)
			if related_subject_key.is_empty() or related_subject_key == subject_key:
				continue
			related_keys.append(related_subject_key)
	var related_subjects: Array = []
	for related_subject_key_variant in Array(dedupe_strings.call(related_keys)):
		var related_subject_key := str(related_subject_key_variant)
		var subject_def: Dictionary = Dictionary(get_research_subject_definition_by_key.call(related_subject_key))
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
			"title": title if discovered else str(mask_locked_journal_label.call(title)),
			"locked": not discovered,
			"subject_kind": str(subject_def.get("subject_kind", "")),
			"subject_type": str(subject_def.get("subject_type", "")),
			"unread": bool(is_journal_entry_unread.call(related_subject_key)),
		})
	return related_subjects

static func build_locked_journal_entry(
	subject_key: String,
	subject_def: Dictionary,
	get_related_recipe_ids: Callable,
	mask_locked_journal_label: Callable,
	build_locked_journal_recipe_list: Callable,
	build_locked_journal_description: Callable
) -> Dictionary:
	return {
		"subject_key": subject_key,
		"subject_kind": str(subject_def.get("subject_kind", "")),
		"subject_type": str(subject_def.get("subject_type", "")),
		"title": str(mask_locked_journal_label.call(str(subject_def.get("title", "UNKNOWN ENTRY")))),
		"description": str(build_locked_journal_description.call(subject_def)),
		"recipe_ids": Array(get_related_recipe_ids.call(subject_key)),
		"recipes": Array(build_locked_journal_recipe_list.call(subject_key, Array(subject_def.get("recipes", [])))),
		"unread": false,
		"attempts": 0,
		"locked": true,
	}

static func get_normalized_formula_parts(recipe: Dictionary, normalize_recipe_result_parts: Callable, sanitize_recipe_parts: Callable) -> Array:
	var result_name := str(recipe.get("result", "")).to_upper()
	var formula_parts: Array = Array(sanitize_recipe_parts.call(Array(recipe.get("formula_parts", [])).duplicate(true)))
	if formula_parts.is_empty():
		formula_parts = Array(sanitize_recipe_parts.call(build_formula_parts_from_formula_string(str(recipe.get("formula", "")))))
	return Array(normalize_recipe_result_parts.call(result_name, formula_parts))

static func build_formula_parts_from_formula_string(formula: String) -> Array:
	var normalized := formula.strip_edges()
	if normalized.is_empty():
		return []
	var equal_index := normalized.find("=")
	if equal_index == -1 or equal_index >= normalized.length() - 1:
		return []
	var rhs := normalized.substr(equal_index + 1, normalized.length() - equal_index - 1).strip_edges()
	if rhs.is_empty():
		return []
	var parts: Array = []
	for part_variant in rhs.split("+", false):
		var part := str(part_variant).strip_edges()
		if part.is_empty():
			continue
		parts.append(part)
	return parts

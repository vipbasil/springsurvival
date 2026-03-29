extends RefCounted

class_name WorkshopArt

const TAPE := Color(0.84, 0.78, 0.60)
const TAPE_SHADE := Color(0.68, 0.61, 0.42)
const STEEL_DARK := Color(0.10, 0.10, 0.11)
const SHADOW := Color(0.0, 0.0, 0.0, 0.24)
const ACCENT := Color(0.80, 0.66, 0.27)
const ACCENT_DIM := Color(0.53, 0.43, 0.18)
const PANEL_BORDER := Color(0.47, 0.40, 0.24)
const STEEL := Color(0.20, 0.21, 0.24)
const STEEL_LIGHT := Color(0.30, 0.31, 0.35)
const PANEL_INNER := Color(0.16, 0.17, 0.19)
const MACHINE_CARD := Color(0.44, 0.17, 0.15)
const MACHINE_CARD_LIGHT := Color(0.55, 0.23, 0.20)
const MACHINE_CARD_SHADE := Color(0.26, 0.11, 0.10)
const TEXT := Color(0.92, 0.89, 0.82)
const TAPE_HOLE := Color(0.20, 0.18, 0.13)
const BIO_ENERGY := Color(0.24, 0.75, 0.44)
const DANGER := Color(0.56, 0.23, 0.17)
const PAPER_PANEL := Color(0.86, 0.80, 0.67)
const PAPER_PANEL_SHADE := Color(0.74, 0.67, 0.49)
const FONT_SIZE_CARD_TITLE := 8
const FONT_SIZE_CARD_META := 6
const FONT_SIZE_CARD_VALUE := 9
const FONT_SIZE_VALUE := 12
const FONT_SIZE_STAT_VALUE := 12
const STAT_ICON_SIZE := 18.0
const STAT_ICON_GAP := 3.0
const CARD_VARIANTS := {
	"machine": {
		"card_class": "machine",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": ACCENT_DIM,
	},
	"tape_programmed": {
		"card_class": "medium",
		"face_fill": TAPE,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": null,
	},
	"tape_blank": {
		"card_class": "medium",
		"face_fill": Color(0.22, 0.23, 0.25),
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": null,
	},
	"power": {
		"card_class": "charge",
		"face_fill": TAPE,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.68, 0.60, 0.40),
	},
	"operator": {
		"card_class": "agent",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": null,
	},
	"location": {
		"card_class": "place",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.42, 0.38, 0.24),
	},
	"enemy": {
		"card_class": "threat",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.48, 0.20, 0.18),
	},
	"material": {
		"card_class": "material",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.55, 0.49, 0.31),
	},
	"equipment": {
		"card_class": "material",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.48, 0.41, 0.24),
	},
	"blueprint": {
		"card_class": "medium",
		"face_fill": TAPE,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": ACCENT_DIM,
	},
	"structure": {
		"card_class": "material",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": Color(0.55, 0.49, 0.31),
	},
	"mechanism": {
		"card_class": "machine",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": ACCENT_DIM,
	},
	"drone": {
		"card_class": "agent",
		"face_fill": null,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": null,
	},
}
const BLUEPRINT_MACHINE_TOKENS := {
	"BENCH": "bench",
	"ROUTE TABLE": "route",
	"CHARGE MACHINE": "charge",
	"JOURNAL": "journal",
	"TRASH": "trash",
}
const BLUEPRINT_MATERIAL_TOKENS := {
	"METAL": "metal",
	"SPRING": "spring",
	"BIOMASS": "biomass",
	"FIBER": "fiber",
	"HIDE": "hide",
	"BONE": "bone",
	"PAPER": "paper",
}
const BLUEPRINT_ENEMY_TOKENS := {
	"SURVEILLANCE DRONE": "surveillance_drone",
	"INFANTRY DRONE": "infantry_drone",
	"STALKER": "stalker",
	"GRIZZLY": "grizzly",
	"WOLF PACK": "wolf_pack",
	"WARDEN": "warden",
}
const BLUEPRINT_LOCATION_TOKENS := {
	"POND": "pond",
	"CRATER": "crater",
	"TOWER": "tower",
	"SURVEILLANCE ZONE": "surveillance_zone",
	"FACILITY": "facility",
	"BUNKER": "bunker",
	"CACHE": "cache",
	"FIELD": "field",
	"DUMP": "dump",
	"NEST": "nest",
	"RUIN": "ruin",
}
const BLUEPRINT_SPECIAL_TOKENS := {
	"OPERATOR": {"kind": "operator"},
	"PROGRAMMED TAPE": {"kind": "tape", "value": true},
	"BLANK TAPE": {"kind": "tape", "value": false},
	"SPRING CHARGE": {"kind": "material", "value": "power_unit"},
	"POWER UNIT": {"kind": "material", "value": "power_unit"},
	"SPIDER DRONE": {"kind": "drone", "value": "spider"},
	"BUTTERFLY DRONE": {"kind": "drone", "value": "butterfly"},
}

static var _spider_bot_art: Texture2D = null
static var _butterfly_bot_art: Texture2D = null
static var _spring_icon_art: Texture2D = null
static var _tape_device_art: Texture2D = null
static var _bench_machine_art: Texture2D = null
static var _trash_machine_art: Texture2D = null
static var _charge_machine_art: Texture2D = null
static var _journal_machine_art: Texture2D = null
static var _enemy_grizzly_art: Texture2D = null
static var _enemy_infantry_drone_art: Texture2D = null
static var _enemy_stalker_art: Texture2D = null
static var _enemy_surveillance_drone_art: Texture2D = null
static var _enemy_wolf_pack_art: Texture2D = null
static var _enemy_warden_art: Texture2D = null
static var _dog_unit_art: Texture2D = null
static var _material_hide_art: Texture2D = null
static var _material_biomass_art: Texture2D = null
static var _material_bone_art: Texture2D = null
static var _material_dry_rations_art: Texture2D = null
static var _material_medicine_art: Texture2D = null
static var _material_growth_medium_art: Texture2D = null
static var _material_algae_art: Texture2D = null
static var _material_bacteria_art: Texture2D = null
static var _material_mealworms_art: Texture2D = null
static var _material_bone_meal_art: Texture2D = null
static var _material_fiber_art: Texture2D = null
static var _material_paper_art: Texture2D = null
static var _material_metal_art: Texture2D = null
static var _material_mushrooms_art: Texture2D = null
static var _equipment_knife_art: Texture2D = null
static var _equipment_bow_art: Texture2D = null
static var _equipment_plate_mail_art: Texture2D = null
static var _equipment_hide_cloak_art: Texture2D = null
static var _equipment_tool_kit_art: Texture2D = null
static var _crafted_tank_art: Texture2D = null
static var _crafted_tool_chest_art: Texture2D = null
static var _crafted_brood_cage_art: Texture2D = null
static var _crafted_archive_shelf_art: Texture2D = null
static var _attack_stat_icon_art: Texture2D = null
static var _armor_stat_icon_art: Texture2D = null
static var _hp_stat_icon_art: Texture2D = null

static func load_svg_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var svg_text: String = FileAccess.get_file_as_string(path)
	if svg_text.is_empty():
		return null
	var image := Image.new()
	var err := image.load_svg_from_string(svg_text)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

static func load_texture_asset(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

static func draw_room_shell(canvas: Control, size: Vector2, wall_dark: Color, wall_mid: Color, wall_band: Color, floor: Color, floor_seam: Color) -> void:
	var wall_rect := Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.72))
	var floor_rect := Rect2(Vector2(0.0, wall_rect.end.y), Vector2(size.x, size.y - wall_rect.end.y))
	canvas.draw_rect(wall_rect, wall_dark)
	canvas.draw_rect(Rect2(Vector2(0.0, 96.0), Vector2(size.x, wall_rect.size.y - 96.0)), wall_mid)
	canvas.draw_rect(Rect2(Vector2(0.0, wall_rect.end.y - 36.0), Vector2(size.x, 36.0)), wall_band)
	canvas.draw_rect(floor_rect, floor)
	for seam_index in range(12):
		var seam_x := floor_rect.position.x + seam_index * (floor_rect.size.x / 11.0)
		canvas.draw_line(
			Vector2(seam_x, floor_rect.position.y + 8.0),
			Vector2(seam_x - 18.0, floor_rect.end.y),
			floor_seam,
			2.0
		)

static func draw_location_glyph(canvas: Control, rect: Rect2, location_type: String, image_seed: int, bunker_texture: Texture2D, cache_texture: Texture2D, pond_texture: Texture2D, crater_texture: Texture2D, tower_texture: Texture2D, surveillance_texture: Texture2D, facility_texture: Texture2D, field_texture: Texture2D, dump_texture: Texture2D, nest_texture: Texture2D, ruin_texture: Texture2D) -> void:
	var location_texture := _get_location_texture(location_type, bunker_texture, cache_texture, pond_texture, crater_texture, tower_texture, surveillance_texture, facility_texture, field_texture, dump_texture, nest_texture, ruin_texture)
	if _draw_texture_fit(canvas, location_texture, rect, 1.0):
		return
	_draw_art_label(canvas, rect, location_type)

static func _get_location_texture(location_type: String, bunker_texture: Texture2D, cache_texture: Texture2D, pond_texture: Texture2D, crater_texture: Texture2D, tower_texture: Texture2D, surveillance_texture: Texture2D, facility_texture: Texture2D, field_texture: Texture2D, dump_texture: Texture2D, nest_texture: Texture2D, ruin_texture: Texture2D) -> Texture2D:
	match location_type:
		"tower":
			return tower_texture
		"surveillance_zone":
			return surveillance_texture
		"cache":
			return cache_texture
		"bunker":
			return bunker_texture
		"pond":
			return pond_texture
		"crater":
			return crater_texture
		"facility":
			return facility_texture
		"field":
			return field_texture
		"dump":
			return dump_texture
		"nest":
			return nest_texture
		"ruin":
			return ruin_texture
		_:
			return null

static func _draw_art_label(canvas: Control, rect: Rect2, label: String, fill: Variant = null, border: Variant = null, font_size: int = FONT_SIZE_CARD_META, color: Color = STEEL_DARK) -> void:
	if fill != null:
		_draw_framed_panel(canvas, rect, 0.0, fill, border if border != null else PANEL_BORDER)
	_draw_text_token(canvas, rect, label, font_size, color)

static func _draw_text_token(canvas: Control, rect: Rect2, label: String, font_size: int = FONT_SIZE_CARD_META, color: Color = STEEL_DARK) -> void:
	var text := label.strip_edges().replace("_", " ").replace("-", " ").to_upper()
	if text.is_empty():
		return
	var font := ThemeDB.fallback_font
	var baseline := rect.position.y + (rect.size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	canvas.draw_string(font, Vector2(rect.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, color)

static func _draw_equipment_slot_row(canvas: Control, rect: Rect2, slots: Array) -> void:
	if rect.size.x <= 12.0 or rect.size.y <= 8.0:
		return
	var slot_count: int = 3
	var gap: float = 4.0
	var cell_side: float = floor(minf(rect.size.y, (rect.size.x - gap * float(slot_count - 1)) / float(slot_count)))
	if cell_side < 8.0:
		return
	var row_width: float = cell_side * float(slot_count) + gap * float(slot_count - 1)
	var start: Vector2 = Vector2(rect.position.x + (rect.size.x - row_width) * 0.5, rect.position.y + (rect.size.y - cell_side) * 0.5)
	for slot_index in range(slot_count):
		var cell_rect := Rect2(start + Vector2(float(slot_index) * (cell_side + gap), 0.0), Vector2.ONE * cell_side)
		canvas.draw_rect(cell_rect, Color(0.90, 0.85, 0.73, 0.92))
		canvas.draw_rect(cell_rect, PANEL_BORDER, false, 1.0)
		var slot_item_type := ""
		var slot_display_name := ""
		if slot_index < slots.size() and typeof(slots[slot_index]) == TYPE_DICTIONARY:
			var slot_data: Dictionary = slots[slot_index]
			slot_item_type = str(slot_data.get("item_type", ""))
			slot_display_name = str(slot_data.get("display_name", ""))
		if slot_item_type.is_empty():
			canvas.draw_rect(cell_rect.grow(-2.0), Color(0.63, 0.57, 0.43, 0.18))
			continue
		var item_label := slot_display_name if not slot_display_name.is_empty() else slot_item_type
		if not _draw_texture_fit(canvas, _get_equipment_texture(slot_item_type), cell_rect, 1.0):
			_draw_text_token(canvas, cell_rect, _get_equipment_slot_label(item_label), FONT_SIZE_CARD_META, STEEL_DARK)

static func _get_equipment_slot_label(item_name: String) -> String:
	var normalized := item_name.strip_edges().to_upper()
	if normalized.is_empty():
		return ""
	var words := normalized.split(" ", false)
	if words.size() >= 2:
		return "%s%s" % [words[0].substr(0, 1), words[1].substr(0, 1)]
	return normalized.substr(0, mini(normalized.length(), 2))

static func _get_machine_card_title(kind: String) -> String:
	match kind:
		"bench":
			return "BENCH"
		"route":
			return "ROUTE TABLE"
		"charge":
			return "CHARGE"
		"journal":
			return "JOURNAL"
		"trash":
			return "TRASH"
		_:
			return kind.replace("_", " ").to_upper()

static func _get_drone_card_title(slot: Dictionary) -> String:
	var explicit_type := str(slot.get("drone_type", ""))
	match explicit_type:
		"spider":
			return "SPIDER DRONE"
		"butterfly":
			return "BUTTERFLY"
		_:
			return explicit_type.replace("_", " ").to_upper() if not explicit_type.is_empty() else "DRONE"

static func _get_band_title_rect(face_rect: Rect2) -> Rect2:
	return Rect2(Vector2(face_rect.position.x + 8.0, face_rect.position.y + 1.0), Vector2(face_rect.size.x - 16.0, 10.0))

static func _draw_band_title(canvas: Control, face_rect: Rect2, label: String, color: Color) -> void:
	var title := _trim_card_label(label.to_upper(), 18)
	if title.is_empty():
		return
	_draw_card_text(canvas, _get_band_title_rect(face_rect), title, "title_center", color)

static func _get_stat_icon_texture(stat_name: String) -> Texture2D:
	match stat_name:
		"energy":
			if _spring_icon_art == null:
				_spring_icon_art = load_svg_texture("res://assets/cards/power_icon.svg")
			return _spring_icon_art
		"attack":
			if _attack_stat_icon_art == null:
				_attack_stat_icon_art = load_svg_texture("res://assets/cards/swordicon.svg")
			return _attack_stat_icon_art
		"armor":
			if _armor_stat_icon_art == null:
				_armor_stat_icon_art = load_svg_texture("res://assets/cards/shieldicon.svg")
			return _armor_stat_icon_art
		"hp":
			if _hp_stat_icon_art == null:
				_hp_stat_icon_art = load_svg_texture("res://assets/cards/hearticon.svg")
			return _hp_stat_icon_art
		_:
			return null

static func _draw_stat_icon_value(canvas: Control, rect: Rect2, stat_icon: String, value_text: String, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var font_size := FONT_SIZE_CARD_VALUE
	var icon_side := minf(rect.size.y - 1.0, 9.0)
	var gap := 2.0
	var text_width := font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var group_width := icon_side + gap + text_width
	var group_start_x := rect.position.x + (rect.size.x - group_width) * 0.5
	var icon_rect := Rect2(Vector2(group_start_x, rect.position.y + (rect.size.y - icon_side) * 0.5), Vector2(icon_side, icon_side))
	if not _draw_texture_fit(canvas, _get_stat_icon_texture(stat_icon), icon_rect):
		_draw_text_token(canvas, icon_rect, stat_icon, FONT_SIZE_CARD_META, color)
	var value_rect := Rect2(Vector2(icon_rect.end.x + gap, rect.position.y), Vector2(text_width + 2.0, rect.size.y))
	var baseline := value_rect.position.y + (value_rect.size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	canvas.draw_string(font, Vector2(value_rect.position.x, baseline), value_text, HORIZONTAL_ALIGNMENT_LEFT, value_rect.size.x, font_size, color)

static func _draw_stat_icon_pair_row(canvas: Control, rect: Rect2, left_icon: String, left_value: String, right_icon: String, right_value: String, color: Color) -> void:
	var half_width := rect.size.x * 0.5
	_draw_stat_icon_value(canvas, Rect2(rect.position, Vector2(half_width, rect.size.y)), left_icon, left_value, color)
	_draw_stat_icon_value(canvas, Rect2(Vector2(rect.position.x + half_width, rect.position.y), Vector2(half_width, rect.size.y)), right_icon, right_value, color)

static func _draw_stat_icon_single_row(canvas: Control, rect: Rect2, stat_icon: String, value_text: String, color: Color) -> void:
	_draw_stat_icon_value(canvas, rect, stat_icon, value_text, color)

static func _draw_operator_meta_row(canvas: Control, rect: Rect2, energy: int, hp: int, color: Color) -> void:
	var half_width := rect.size.x * 0.5
	_draw_stat_icon_value(canvas, Rect2(rect.position, Vector2(half_width, rect.size.y)), "energy", str(energy), color)
	_draw_stat_icon_value(canvas, Rect2(Vector2(rect.position.x + half_width, rect.position.y), Vector2(half_width, rect.size.y)), "hp", str(hp), color)

static func _draw_unit_stat_cell(canvas: Control, rect: Rect2, stat_icon: String, value_text: String, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var font_size := FONT_SIZE_STAT_VALUE
	var icon_side := STAT_ICON_SIZE
	var gap := STAT_ICON_GAP
	var text_width := font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var group_width := icon_side + gap + text_width
	var start_x := rect.position.x + (rect.size.x - group_width) * 0.5
	var icon_rect := Rect2(Vector2(start_x, rect.position.y + (rect.size.y - icon_side) * 0.5), Vector2(icon_side, icon_side))
	if not _draw_texture_fit(canvas, _get_stat_icon_texture(stat_icon), icon_rect):
		_draw_text_token(canvas, icon_rect, stat_icon, FONT_SIZE_CARD_META, color)
	var value_rect := Rect2(Vector2(icon_rect.end.x + gap, rect.position.y), Vector2(text_width + 1.0, rect.size.y))
	var baseline := value_rect.position.y + (value_rect.size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)
	canvas.draw_string(font, Vector2(value_rect.position.x, baseline), value_text, HORIZONTAL_ALIGNMENT_LEFT, value_rect.size.x, font_size, color)

static func _draw_operator_stat_grid(canvas: Control, rect: Rect2, operator_state: Dictionary, color: Color) -> void:
	var gap: float = 1.0
	var cell_width: float = floor((rect.size.x - gap) * 0.5)
	var cell_height: float = floor((rect.size.y - gap) * 0.5)
	var left_x: float = rect.position.x
	var right_x: float = rect.end.x - cell_width
	var top_y: float = rect.position.y
	var bottom_y: float = rect.end.y - cell_height
	var totals: Dictionary = Dictionary(operator_state.get("equipment_totals", {}))
	_draw_unit_stat_cell(canvas, Rect2(Vector2(left_x, top_y), Vector2(cell_width, cell_height)), "energy", str(int(operator_state.get("energy", 0))), color)
	_draw_unit_stat_cell(canvas, Rect2(Vector2(right_x, top_y), Vector2(cell_width, cell_height)), "hp", str(int(operator_state.get("hp", 0))), color)
	_draw_unit_stat_cell(canvas, Rect2(Vector2(left_x, bottom_y), Vector2(cell_width, cell_height)), "attack", str(int(totals.get("attack", 0))), color)
	_draw_unit_stat_cell(canvas, Rect2(Vector2(right_x, bottom_y), Vector2(cell_width, cell_height)), "armor", str(int(totals.get("armor", 0))), color)

static func _draw_drone_stat_strip(canvas: Control, rect: Rect2, power_charge: int, totals: Dictionary, color: Color) -> void:
	var gap: float = 4.0
	var cell_width: float = floor((rect.size.x - gap * 2.0) / 3.0)
	var row_width: float = cell_width * 3.0 + gap * 2.0
	var start_x: float = rect.position.x + (rect.size.x - row_width) * 0.5
	_draw_unit_stat_cell(canvas, Rect2(Vector2(start_x, rect.position.y), Vector2(cell_width, rect.size.y)), "energy", str(maxi(power_charge, 0)), color)
	_draw_unit_stat_cell(canvas, Rect2(Vector2(start_x + cell_width + gap, rect.position.y), Vector2(cell_width, rect.size.y)), "attack", str(int(totals.get("attack", 0))), color)
	_draw_unit_stat_cell(canvas, Rect2(Vector2(start_x + (cell_width + gap) * 2.0, rect.position.y), Vector2(cell_width, rect.size.y)), "armor", str(int(totals.get("armor", 0))), color)

static func _get_location_blueprint_token_label(location_type: String) -> String:
	match location_type:
		"surveillance_zone":
			return "SCAN"
		_:
			return location_type

static func _get_machine_token_label(kind: String) -> String:
	match kind:
		"bench":
			return "BENCH"
		"route":
			return "ROUTE"
		"charge":
			return "POWER"
		"journal":
			return "LOG"
		"trash":
			return "TRASH"
		_:
			return kind

static func _get_drone_token_label(drone_type: String) -> String:
	match drone_type:
		"spider":
			return "SPIDER"
		"butterfly":
			return "WING"
		_:
			return drone_type

static func _get_blueprint_token_text(token_name: String) -> String:
	var spec := _get_blueprint_token_spec(token_name)
	match str(spec.get("kind", "")):
		"operator":
			return "OP"
		"machine":
			return _get_machine_token_label(str(spec.get("value", "")))
		"material":
			return str(spec.get("value", ""))
		"tape":
			return "TAPE" if bool(spec.get("value", false)) else "BLANK"
		"power":
			return "PWR"
		"drone":
			return _get_drone_token_label(str(spec.get("value", "")))
		"enemy":
			return str(spec.get("value", ""))
		"location":
			return _get_location_blueprint_token_label(str(spec.get("value", "")))
		_:
			return token_name

static func _draw_poly_outline(canvas: Control, points: PackedVector2Array, color: Color, width: float) -> void:
	if points.size() < 2:
		return
	for index in range(points.size()):
		var a: Vector2 = points[index]
		var b: Vector2 = points[(index + 1) % points.size()]
		canvas.draw_line(a, b, color, width)

static func _fit_rect(rect: Rect2, inset: float = 0.0) -> Rect2:
	return rect.grow(-inset)

static func _draw_texture_fit(canvas: Control, texture: Texture2D, rect: Rect2, inset: float = 0.0) -> bool:
	if texture == null:
		return false
	var fit_rect := _fit_rect(rect, inset)
	var texture_size := texture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var scale := minf(fit_rect.size.x / texture_size.x, fit_rect.size.y / texture_size.y)
		var draw_size := texture_size * scale
		var draw_rect := Rect2(fit_rect.position + (fit_rect.size - draw_size) * 0.5, draw_size)
		canvas.draw_texture_rect(texture, draw_rect, false)
		return true
	canvas.draw_texture_rect(texture, fit_rect, false)
	return true

static func _draw_framed_panel(canvas: Control, rect: Rect2, inset: float, fill: Color, border: Color = PANEL_BORDER) -> Rect2:
	var panel_rect := _fit_rect(rect, inset)
	canvas.draw_rect(panel_rect, fill)
	canvas.draw_rect(panel_rect, border, false, 1.0)
	return panel_rect

static func _get_machine_texture(kind: String) -> Texture2D:
	match kind:
		"bench":
			if _bench_machine_art == null:
				_bench_machine_art = load_svg_texture("res://assets/cards/bench_fixed_v2.svg")
			return _bench_machine_art
		"journal":
			if _journal_machine_art == null:
				_journal_machine_art = load_svg_texture("res://assets/cards/journal.svg")
			return _journal_machine_art
		"trash":
			if _trash_machine_art == null:
				_trash_machine_art = load_svg_texture("res://assets/cards/trash_.svg")
			return _trash_machine_art
		"charge":
			if _charge_machine_art == null:
				_charge_machine_art = load_svg_texture("res://assets/cards/power.svg")
			return _charge_machine_art
		_:
			return null

static func _get_enemy_texture(enemy_type: String) -> Texture2D:
	match enemy_type:
		"grizzly":
			if _enemy_grizzly_art == null:
				_enemy_grizzly_art = load_svg_texture("res://assets/cards/grizzly.svg")
			return _enemy_grizzly_art
		"infantry_drone":
			if _enemy_infantry_drone_art == null:
				_enemy_infantry_drone_art = load_svg_texture("res://assets/cards/infantery_drone.svg")
			return _enemy_infantry_drone_art
		"stalker":
			if _enemy_stalker_art == null:
				_enemy_stalker_art = load_svg_texture("res://assets/cards/stalkerk.svg")
			return _enemy_stalker_art
		"surveillance_drone":
			if _enemy_surveillance_drone_art == null:
				_enemy_surveillance_drone_art = load_svg_texture("res://assets/cards/surveillance_drone.svg")
			return _enemy_surveillance_drone_art
		"wolf_pack":
			if _enemy_wolf_pack_art == null:
				_enemy_wolf_pack_art = load_svg_texture("res://assets/cards/woolfspack.svg")
			return _enemy_wolf_pack_art
		"warden":
			if _enemy_warden_art == null:
				_enemy_warden_art = load_svg_texture("res://assets/cards/warden.svg")
			return _enemy_warden_art
		_:
			return null

static func _get_dog_texture() -> Texture2D:
	if _dog_unit_art == null:
		_dog_unit_art = load_svg_texture("res://assets/cards/dog.svg")
	return _dog_unit_art

static func _get_material_texture(material_type: String) -> Texture2D:
	match material_type:
		"spring", "power_unit":
			if _spring_icon_art == null:
				_spring_icon_art = load_svg_texture("res://assets/cards/power_icon.svg")
			return _spring_icon_art
		"hide":
			if _material_hide_art == null:
				_material_hide_art = load_svg_texture("res://assets/cards/hide.svg")
			return _material_hide_art
		"biomass":
			if _material_biomass_art == null:
				_material_biomass_art = load_svg_texture("res://assets/cards/biomass-1.svg")
			return _material_biomass_art
		"bone":
			if _material_bone_art == null:
				_material_bone_art = load_svg_texture("res://assets/cards/bone.svg")
			return _material_bone_art
		"dry_rations":
			if _material_dry_rations_art == null:
				_material_dry_rations_art = load_svg_texture("res://assets/cards/drymeal.svg")
			return _material_dry_rations_art
		"algae":
			if _material_algae_art == null:
				_material_algae_art = load_svg_texture("res://assets/cards/algaes.svg")
			return _material_algae_art
		"fiber":
			if _material_fiber_art == null:
				_material_fiber_art = load_svg_texture("res://assets/cards/fiber.svg")
			return _material_fiber_art
		"medicine":
			if _material_medicine_art == null:
				_material_medicine_art = load_svg_texture("res://assets/cards/medicine.svg")
			return _material_medicine_art
		"growth_medium":
			if _material_growth_medium_art == null:
				_material_growth_medium_art = load_svg_texture("res://assets/cards/substrat.svg")
			return _material_growth_medium_art
		"bacteria":
			if _material_bacteria_art == null:
				_material_bacteria_art = load_svg_texture("res://assets/cards/bacteria.svg")
			return _material_bacteria_art
		"mealworms":
			if _material_mealworms_art == null:
				_material_mealworms_art = load_svg_texture("res://assets/cards/mealworms.svg")
			return _material_mealworms_art
		"bone_meal":
			if _material_bone_meal_art == null:
				_material_bone_meal_art = load_svg_texture("res://assets/cards/bone_meal.svg")
			return _material_bone_meal_art
		"paper":
			if _material_paper_art == null:
				_material_paper_art = load_svg_texture("res://assets/cards/paper.svg")
			return _material_paper_art
		"metal":
			if _material_metal_art == null:
				_material_metal_art = load_svg_texture("res://assets/cards/metal.svg")
			return _material_metal_art
		"mushrooms":
			if _material_mushrooms_art == null:
				_material_mushrooms_art = load_svg_texture("res://assets/cards/moushrooms.svg")
			return _material_mushrooms_art
		_:
			return null

static func _get_drone_texture(drone_type: String) -> Texture2D:
	match drone_type:
		"spider":
			if _spider_bot_art == null:
				_spider_bot_art = load_svg_texture("res://assets/cards/spider_optimized_trace.svg")
			return _spider_bot_art
		"butterfly":
			if _butterfly_bot_art == null:
				_butterfly_bot_art = load_svg_texture("res://assets/cards/butterfly_from_image_vectorized.svg")
			return _butterfly_bot_art
		_:
			return null

static func _get_equipment_texture(equipment_type: String) -> Texture2D:
	match equipment_type:
		"knife":
			if _equipment_knife_art == null:
				_equipment_knife_art = load_svg_texture("res://assets/cards/knife.svg")
			return _equipment_knife_art
		"bow":
			if _equipment_bow_art == null:
				_equipment_bow_art = load_svg_texture("res://assets/cards/bow.svg")
			return _equipment_bow_art
		"plate_mail":
			if _equipment_plate_mail_art == null:
				_equipment_plate_mail_art = load_svg_texture("res://assets/cards/platemail.svg")
			return _equipment_plate_mail_art
		"hide_cloak":
			if _equipment_hide_cloak_art == null:
				_equipment_hide_cloak_art = load_svg_texture("res://assets/cards/hide_cloak.svg")
			return _equipment_hide_cloak_art
		"tool_kit":
			if _equipment_tool_kit_art == null:
				_equipment_tool_kit_art = load_svg_texture("res://assets/cards/tools.svg")
			return _equipment_tool_kit_art
		_:
			return null

static func draw_machine_card(canvas: Control, rect: Rect2, kind: String, route_overlay: Callable = Callable()) -> void:
	var shell := _draw_card_variant(canvas, rect, "machine")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var machine_art_rect := _fit_rect(art_rect, 6.0)
	_draw_band_title(canvas, face_rect, _get_machine_card_title(kind), TEXT)
	match kind:
		"bench":
			_draw_programming_bench_art(canvas, machine_art_rect)
		"route":
			_draw_route_table_card_art(canvas, art_rect.grow(-3.0), route_overlay)
		"charge":
			_draw_charge_machine_art(canvas, machine_art_rect)
		"journal":
			_draw_journal_machine_art(canvas, machine_art_rect)
		"trash":
			_draw_trash_machine_art(canvas, machine_art_rect)

static func draw_trash_card(canvas: Control, rect: Rect2, active: bool) -> void:
	draw_machine_card(canvas, rect, "trash")
	if active:
		var shell := _draw_card_shell(canvas, rect, "machine", false, false)
		var info_rect: Rect2 = shell["info_rect"]
		var active_rect := Rect2(
			Vector2(info_rect.position.x + 10.0, info_rect.end.y - 5.0),
			Vector2(info_rect.size.x - 20.0, 3.0)
		)
		canvas.draw_rect(active_rect, Color(0.55, 0.22, 0.18))

static func draw_tape_card(canvas: Control, rect: Rect2, programmed: bool, label: String, selected: bool) -> void:
	var shell := _draw_card_variant(canvas, rect, "tape_programmed" if programmed else "tape_blank", selected)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var side_strip := Rect2(face_rect.position + Vector2(5.0, 8.0), Vector2(4.0, face_rect.size.y - 16.0))
	var suit_rect := _fit_rect(art_rect, 8.0)
	var band_label := "BLANK TAPE"
	canvas.draw_rect(side_strip, ACCENT if programmed else STEEL_LIGHT)
	if _tape_device_art == null:
		_tape_device_art = load_svg_texture("res://assets/cards/device_pixelperfect_fixed.svg")
	if not _draw_texture_fit(canvas, _tape_device_art, suit_rect):
		_draw_art_label(canvas, art_rect, "programmed tape" if programmed else "blank tape")
	if programmed and not label.is_empty():
		band_label = _trim_card_label(label, 18).to_upper()
	_draw_band_title(canvas, face_rect, band_label, STEEL_DARK)
	if not programmed:
		canvas.draw_line(
			Vector2(info_rect.position.x + 4.0, info_rect.position.y + 10.0),
			Vector2(info_rect.end.x - 4.0, info_rect.position.y + 10.0),
			Color(0.55, 0.57, 0.60),
			1.0
		)

static func draw_power_card(canvas: Control, rect: Rect2, charge: int, max_charge: int, selected: bool) -> void:
	var shell := _draw_card_variant(canvas, rect, "power", selected)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var fill_ratio := clampf(float(charge) / float(maxi(max_charge, 1)), 0.0, 1.0)
	var number_text := str(maxi(charge, 0))
	var suit_rect := _fit_rect(art_rect, 8.0)
	var meter_rect := Rect2(Vector2(info_rect.position.x, info_rect.end.y - 2.0), Vector2(info_rect.size.x, 3.0))
	var fill_rect := Rect2(meter_rect.position, Vector2(meter_rect.size.x * fill_ratio, meter_rect.size.y))
	_draw_band_title(canvas, face_rect, "POWER UNIT", STEEL_DARK)
	if not _draw_texture_fit(canvas, _get_material_texture("power_unit"), suit_rect):
		_draw_art_label(canvas, art_rect, "power unit")
	_draw_card_text(canvas, _get_info_slot(info_rect, "value"), number_text, "value_right", STEEL_DARK)
	if fill_rect.size.x > 0.0:
		canvas.draw_rect(fill_rect, ACCENT)
	if charge <= 0:
		_draw_disabled_hatch(canvas, face_rect)

static func draw_preview_tape(canvas: Control, rect: Rect2, visible_rows: int, active_row: int) -> void:
	_draw_preview_tape(canvas, rect, visible_rows, active_row)

static func draw_power_suit(canvas: Control, rect: Rect2, charged: bool, line_width: float = 1.5) -> void:
	_draw_power_suit(canvas, rect, charged, line_width)

static func draw_disabled_hatch(canvas: Control, rect: Rect2) -> void:
	_draw_disabled_hatch(canvas, rect)

static func draw_operator_card(canvas: Control, rect: Rect2, operator_state: Dictionary, operator_name: String, focus: String, photo: Texture2D) -> void:
	var shell := _draw_card_variant(canvas, rect, "operator")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var dossier_rect := _draw_framed_panel(canvas, art_rect, 8.0, TAPE, Color(0.58, 0.50, 0.30))
	_draw_texture_fit(canvas, photo, dossier_rect)
	_draw_equipment_slot_row(canvas, Rect2(Vector2(art_rect.position.x + 18.0, art_rect.end.y - 30.0), Vector2(art_rect.size.x - 36.0, 24.0)), Array(operator_state.get("equipment_slots", [])))
	var clip_rect := Rect2(Vector2(dossier_rect.end.x - 18.0, dossier_rect.position.y + 8.0), Vector2(8.0, 18.0))
	canvas.draw_rect(clip_rect, ACCENT_DIM)
	canvas.draw_rect(clip_rect.grow(-1.0), ACCENT)
	_draw_band_title(canvas, face_rect, operator_name, TAPE)
	_draw_operator_stat_grid(canvas, info_rect, operator_state, TAPE)

static func draw_dog_card(canvas: Control, rect: Rect2, dog_state: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "operator")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var portrait_rect := _draw_framed_panel(canvas, art_rect, 8.0, TAPE, Color(0.58, 0.50, 0.30))
	_draw_texture_fit(canvas, _get_dog_texture(), portrait_rect)
	_draw_equipment_slot_row(canvas, Rect2(Vector2(art_rect.position.x + 18.0, art_rect.end.y - 30.0), Vector2(art_rect.size.x - 36.0, 24.0)), Array(dog_state.get("equipment_slots", [])))
	_draw_band_title(canvas, face_rect, _trim_card_label(str(dog_state.get("display_name", "DOG")).to_upper(), 18), TAPE)
	_draw_operator_stat_grid(canvas, info_rect, dog_state, TAPE)

static func draw_location_card(canvas: Control, rect: Rect2, card_data: Dictionary, bunker_texture: Texture2D, cache_texture: Texture2D, pond_texture: Texture2D, crater_texture: Texture2D, tower_texture: Texture2D, surveillance_texture: Texture2D, facility_texture: Texture2D, field_texture: Texture2D, dump_texture: Texture2D, nest_texture: Texture2D, ruin_texture: Texture2D) -> void:
	var shell := _draw_card_variant(canvas, rect, "location")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var location_type := str(card_data.get("type", "site"))
	var type_label := location_type.replace("_", " ")
	var image_seed := int(card_data.get("image_seed", 0))
	var pos: Dictionary = card_data.get("position", {"x": 0, "y": 0})
	var coords := Vector2(int(pos.get("x", 0)), int(pos.get("y", 0)))
	draw_location_glyph(canvas, _fit_rect(art_rect, 4.0), location_type, image_seed, bunker_texture, cache_texture, pond_texture, crater_texture, tower_texture, surveillance_texture, facility_texture, field_texture, dump_texture, nest_texture, ruin_texture)
	_draw_band_title(canvas, face_rect, _trim_card_label(type_label.to_upper(), 18), STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "(%d,%d)" % [int(coords.x), int(coords.y)], "meta_center", Color(0.24, 0.26, 0.30))

static func draw_enemy_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "enemy")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var enemy_type := str(card_data.get("type", "hostile_creature"))
	var display_name := str(card_data.get("display_name", enemy_type.replace("_", " ")))
	var threat_level := int(card_data.get("threat_level", 1))
	var enemy_armor := int(card_data.get("armor", 0))
	var enemy_hp := int(card_data.get("hp", 1))
	var art_inset := 2.0 if enemy_type == "warden" else 8.0
	_draw_enemy_glyph(canvas, _fit_rect(art_rect, art_inset), enemy_type)
	_draw_band_title(canvas, face_rect, _trim_card_label(display_name.to_upper(), 18), TAPE)
	if enemy_armor > 0:
		_draw_unit_stat_cell(canvas, Rect2(Vector2(info_rect.position.x, info_rect.position.y + 8.0), Vector2(floor((info_rect.size.x - 8.0) / 3.0), 12.0)), "attack", str(threat_level), Color(0.93, 0.78, 0.54))
		_draw_unit_stat_cell(canvas, Rect2(Vector2(info_rect.position.x + floor((info_rect.size.x - 8.0) / 3.0) + 4.0, info_rect.position.y + 8.0), Vector2(floor((info_rect.size.x - 8.0) / 3.0), 12.0)), "hp", str(enemy_hp), Color(0.93, 0.78, 0.54))
		_draw_unit_stat_cell(canvas, Rect2(Vector2(info_rect.end.x - floor((info_rect.size.x - 8.0) / 3.0), info_rect.position.y + 8.0), Vector2(floor((info_rect.size.x - 8.0) / 3.0), 12.0)), "armor", str(enemy_armor), Color(0.93, 0.78, 0.54))
	else:
		_draw_stat_icon_pair_row(canvas, Rect2(Vector2(info_rect.position.x, info_rect.position.y + 10.0), Vector2(info_rect.size.x, 10.0)), "attack", str(threat_level), "hp", str(enemy_hp), Color(0.93, 0.78, 0.54))

static func draw_material_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "material")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var material_type := str(card_data.get("type", "metal"))
	var display_name := str(card_data.get("display_name", material_type.replace("_", " ").capitalize()))
	var quantity := maxi(int(card_data.get("quantity", 1)), 1)
	match material_type:
		"energy_bar":
			_draw_crafted_energy_bar_art(canvas, art_rect)
		_:
			_draw_material_glyph(canvas, _fit_rect(art_rect, 6.0), material_type)
	_draw_band_title(canvas, face_rect, _trim_card_label(display_name.to_upper(), 18), STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "qty_label"), "QTY", "meta_center", TAPE_SHADE)
	_draw_card_text(canvas, _get_info_slot(info_rect, "qty_value"), str(quantity), "value_right", STEEL_DARK)

static func draw_equipment_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "equipment")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var equipment_type := str(card_data.get("type", "equipment"))
	var display_name := str(card_data.get("display_name", equipment_type.replace("_", " ").capitalize()))
	_draw_framed_panel(canvas, art_rect, 8.0, Color(0.90, 0.84, 0.69))
	if not _draw_texture_fit(canvas, _get_equipment_texture(equipment_type), _fit_rect(art_rect, 6.0)):
		_draw_art_label(canvas, Rect2(Vector2(art_rect.position.x + 16.0, art_rect.position.y + 20.0), Vector2(art_rect.size.x - 32.0, 42.0)), _get_equipment_token_text(equipment_type), null, null, FONT_SIZE_CARD_TITLE + 2)
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x + 6.0, art_rect.end.y - 26.0), Vector2(art_rect.size.x - 12.0, 16.0)), _format_equipment_stat_summary(_get_equipment_stats(equipment_type)), "meta_center", TAPE_SHADE)
	_draw_band_title(canvas, face_rect, _trim_card_label(display_name.to_upper(), 18), STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "EQUIPMENT", "meta_center", TAPE_SHADE)

static func draw_blueprint_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "blueprint")
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	_draw_band_title(canvas, face_rect, "BLUEPRINT", STEEL_DARK)
	_draw_framed_panel(canvas, art_rect, 6.0, Color(0.90, 0.84, 0.69))
	var page_rect := _draw_framed_panel(canvas, art_rect, 8.0, Color(0.92, 0.87, 0.73))
	var fold_poly := PackedVector2Array([
		page_rect.position + Vector2(page_rect.size.x - 18.0, 0.0),
		page_rect.end + Vector2(0.0, -18.0),
		page_rect.end,
	])
	canvas.draw_colored_polygon(fold_poly, Color(0.82, 0.74, 0.57))
	_draw_poly_outline(canvas, fold_poly, PANEL_BORDER, 1.0)
	_draw_blueprint_formula(canvas, page_rect.grow(-6.0), Array(card_data.get("formula_parts", [])))

static func _draw_blueprint_formula(canvas: Control, rect: Rect2, formula_parts: Array) -> void:
	var tokens: Array = _parse_blueprint_formula_tokens(formula_parts)
	if tokens.is_empty():
		return
	var grid_size: int = 2 if tokens.size() <= 4 else 3
	var visible_count: int = mini(tokens.size(), grid_size * grid_size)
	var gap: float = 4.0 if grid_size == 2 else 3.0
	var cell_side: float = floor(minf(
		(rect.size.x - gap * float(grid_size - 1)) / float(grid_size),
		(rect.size.y - gap * float(grid_size - 1)) / float(grid_size)
	))
	if cell_side <= 8.0:
		return
	var grid_pixel_size: float = cell_side * float(grid_size) + gap * float(grid_size - 1)
	var grid_origin: Vector2 = rect.position + (rect.size - Vector2(grid_pixel_size, grid_pixel_size)) * 0.5
	for cell_index in range(grid_size * grid_size):
		var column: int = cell_index % grid_size
		var row: int = cell_index / grid_size
		var cell_rect: Rect2 = Rect2(
			grid_origin + Vector2(float(column) * (cell_side + gap), float(row) * (cell_side + gap)),
			Vector2.ONE * cell_side
		)
		if cell_index >= visible_count:
			canvas.draw_rect(cell_rect, Color(0.89, 0.83, 0.69, 0.18))
			canvas.draw_rect(cell_rect, Color(0.55, 0.49, 0.33, 0.35), false, 1.0)
			continue
		_draw_blueprint_formula_cell(canvas, cell_rect, Dictionary(tokens[cell_index]))

static func _parse_blueprint_formula_tokens(formula_parts: Array) -> Array:
	var tokens: Array = []
	for part_variant in formula_parts:
		var part := str(part_variant).strip_edges().to_upper()
		if part == "BLUEPRINT" or part.is_empty():
			continue
		var quantity := 1
		var token_name := part
		if token_name.contains(" X"):
			var pieces := token_name.split(" X")
			if pieces.size() == 2:
				token_name = str(pieces[0]).strip_edges()
				quantity = maxi(int(str(pieces[1]).to_int()), 1)
		tokens.append({
			"name": token_name,
			"quantity": quantity,
		})
	return tokens

static func _draw_blueprint_formula_cell(canvas: Control, cell_rect: Rect2, token: Dictionary) -> void:
	canvas.draw_rect(cell_rect, Color(0.90, 0.84, 0.70))
	canvas.draw_rect(cell_rect.grow(-1.0), Color(0.94, 0.89, 0.76))
	canvas.draw_rect(cell_rect, PANEL_BORDER, false, 1.0)
	var quantity := maxi(int(token.get("quantity", 1)), 1)
	var qty_height := clampf(cell_rect.size.y * 0.24, 10.0, 15.0)
	var qty_rect := Rect2(cell_rect.position + Vector2(3.0, 2.0), Vector2(cell_rect.size.x - 6.0, qty_height))
	var qty_font_size := mini(FONT_SIZE_CARD_VALUE + 1, maxi(FONT_SIZE_CARD_META + 1, int(round(cell_rect.size.y * 0.16))))
	_draw_text_token(canvas, qty_rect, "%dx" % quantity, qty_font_size, STEEL_DARK)
	var icon_inset := maxf(4.0, floor(cell_rect.size.x * 0.10))
	var icon_rect := Rect2(
		Vector2(cell_rect.position.x + icon_inset, cell_rect.position.y + qty_height + 2.0),
		Vector2(cell_rect.size.x - icon_inset * 2.0, cell_rect.size.y - qty_height - 6.0)
	)
	_draw_blueprint_token_icon(canvas, icon_rect, str(token.get("name", "")))

static func _draw_blueprint_token_icon(canvas: Control, rect: Rect2, token_name: String) -> void:
	var spec := _get_blueprint_token_spec(token_name)
	var kind := str(spec.get("kind", ""))
	match kind:
		"operator":
			_draw_text_token(canvas, rect, "OP", FONT_SIZE_CARD_META, STEEL_DARK)
			return
		"machine":
			_draw_text_token(canvas, rect, _get_machine_token_label(str(spec.get("value", ""))), FONT_SIZE_CARD_META, STEEL_DARK)
			return
		"material":
			_draw_material_glyph(canvas, rect, str(spec.get("value", "")))
			return
		"tape":
			_draw_text_token(canvas, rect, "TAPE" if bool(spec.get("value", false)) else "BLANK", FONT_SIZE_CARD_META, STEEL_DARK)
			return
		"power":
			_draw_text_token(canvas, rect, "PWR", FONT_SIZE_CARD_META, STEEL_DARK)
			return
		"drone":
			_draw_text_token(canvas, rect, _get_drone_token_label(str(spec.get("value", ""))), FONT_SIZE_CARD_META, STEEL_DARK)
			return
		"enemy":
			_draw_enemy_glyph(canvas, _fit_rect(rect, 2.0), str(spec.get("value", "")))
			return
		"location":
			_draw_text_token(canvas, rect, _get_location_blueprint_token_label(str(spec.get("value", ""))), FONT_SIZE_CARD_META, STEEL_DARK)
			return
	_draw_text_token(canvas, rect, _get_blueprint_token_text(token_name), FONT_SIZE_CARD_META, STEEL_DARK)

static func _get_blueprint_token_spec(token_name: String) -> Dictionary:
	if BLUEPRINT_SPECIAL_TOKENS.has(token_name):
		return Dictionary(BLUEPRINT_SPECIAL_TOKENS[token_name])
	if BLUEPRINT_MACHINE_TOKENS.has(token_name):
		return {"kind": "machine", "value": str(BLUEPRINT_MACHINE_TOKENS[token_name])}
	if BLUEPRINT_MATERIAL_TOKENS.has(token_name):
		return {"kind": "material", "value": str(BLUEPRINT_MATERIAL_TOKENS[token_name])}
	if BLUEPRINT_ENEMY_TOKENS.has(token_name):
		return {"kind": "enemy", "value": str(BLUEPRINT_ENEMY_TOKENS[token_name])}
	if BLUEPRINT_LOCATION_TOKENS.has(token_name):
		return {"kind": "location", "value": str(BLUEPRINT_LOCATION_TOKENS[token_name])}
	return {}

static func _draw_structure_like_card(canvas: Control, rect: Rect2, card_data: Dictionary, variant_name: String) -> void:
	var shell := _draw_card_variant(canvas, rect, variant_name)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var crafted_type := str(card_data.get("type", ""))
	var result_name := str(card_data.get("display_name", card_data.get("result", "Crafted Item"))).to_upper()
	var result_label := _trim_card_label(result_name, 16)
	var crafted_texture := _get_crafted_texture(crafted_type)
	if crafted_type == "brood_cage":
		_draw_brood_cage_art(canvas, art_rect, Dictionary(card_data.get("captive_enemy", {})))
	elif crafted_texture != null:
		_draw_texture_fit(canvas, crafted_texture, _fit_rect(art_rect, 6.0))
	elif result_name == "ENERGY BAR":
		_draw_crafted_energy_bar_art(canvas, art_rect)
	elif result_name == "MEDICINE":
		_draw_crafted_medicine_art(canvas, art_rect)
	else:
		_draw_crafted_generic_art(canvas, art_rect)
	_draw_band_title(canvas, face_rect, result_label, STEEL_DARK)
	var meta_text := ""
	if crafted_type in ["tool_chest", "archive_shelf"]:
		meta_text = "STORAGE %d" % Array(card_data.get("stored_cards", [])).size()
	elif crafted_type == "tank":
		meta_text = _get_tank_meta_text(card_data)
	elif crafted_type.contains("cage"):
		var captive_enemy: Dictionary = Dictionary(card_data.get("captive_enemy", {}))
		meta_text = "OCCUPIED" if not captive_enemy.is_empty() else "EMPTY CAGE"
	if not meta_text.is_empty():
		_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), meta_text, "meta_center", TAPE_SHADE)

static func draw_structure_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	_draw_structure_like_card(canvas, rect, card_data, "structure")

static func draw_mechanism_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	_draw_structure_like_card(canvas, rect, card_data, "mechanism")

static func _get_tank_slot_token(slot_name: String, slot_data: Dictionary) -> String:
	if slot_data.is_empty():
		return "---"
	match slot_name:
		"culture":
			match str(slot_data.get("type", "")):
				"algae":
					return "ALG"
				"bacteria":
					return "BAC"
				"mealworms":
					return "WRM"
		"feed":
			match str(slot_data.get("type", "")):
				"growth_medium":
					return "SUB"
				"biomass":
					return "BIO"
		"recipe":
			match str(slot_data.get("result", "")).to_upper():
				"FIBER":
					return "FIB"
				"MEDICINE":
					return "MED"
				"DRY RATIONS":
					return "RAT"
	return "???"

static func _get_tank_meta_text(card_data: Dictionary) -> String:
	var tank_slots := Dictionary(card_data.get("tank_slots", {}))
	var culture_token := _get_tank_slot_token("culture", Dictionary(tank_slots.get("culture", {})))
	var feed_token := _get_tank_slot_token("feed", Dictionary(tank_slots.get("feed", {})))
	var recipe_token := _get_tank_slot_token("recipe", Dictionary(tank_slots.get("recipe", {})))
	var status_token := "RUN" if not Dictionary(card_data.get("tank_batch", {})).is_empty() else "IDLE"
	return "%s %s %s %s" % [culture_token, feed_token, recipe_token, status_token]

static func draw_crafted_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	draw_structure_card(canvas, rect, card_data)

static func _draw_crafted_banner(canvas: Control, art_rect: Rect2) -> void:
	canvas.draw_rect(Rect2(Vector2(art_rect.position.x + 12.0, art_rect.position.y + 12.0), Vector2(art_rect.size.x - 24.0, 18.0)), ACCENT_DIM)

static func _draw_crafted_energy_bar_art(canvas: Control, art_rect: Rect2) -> void:
	var wrapper_rect := Rect2(Vector2(art_rect.position.x + 18.0, art_rect.position.y + 48.0), Vector2(art_rect.size.x - 36.0, 24.0))
	var bar_rect := Rect2(Vector2(wrapper_rect.position.x + 8.0, wrapper_rect.position.y + 6.0), Vector2(wrapper_rect.size.x - 16.0, 12.0))
	canvas.draw_rect(wrapper_rect, STEEL_DARK)
	canvas.draw_rect(wrapper_rect.grow(-1.0), Color(0.22, 0.19, 0.14))
	canvas.draw_rect(bar_rect, Color(0.70, 0.58, 0.33))
	canvas.draw_rect(bar_rect.grow(-2.0), TAPE)
	canvas.draw_line(Vector2(wrapper_rect.position.x + 14.0, wrapper_rect.end.y - 4.0), Vector2(wrapper_rect.end.x - 14.0, wrapper_rect.end.y - 4.0), ACCENT, 1.4)
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "FOOD", "title_center", TAPE)

static func _draw_crafted_medicine_art(canvas: Control, art_rect: Rect2) -> void:
	var bottle_rect := Rect2(Vector2(art_rect.position.x + art_rect.size.x * 0.5 - 14.0, art_rect.position.y + 44.0), Vector2(28.0, 36.0))
	var cap_rect := Rect2(Vector2(bottle_rect.position.x + 6.0, bottle_rect.position.y - 8.0), Vector2(16.0, 10.0))
	canvas.draw_rect(bottle_rect, Color(0.70, 0.62, 0.44))
	canvas.draw_rect(bottle_rect.grow(-2.0), TAPE)
	canvas.draw_rect(cap_rect, STEEL_DARK)
	canvas.draw_rect(cap_rect.grow(-1.0), STEEL)
	var cross_h := Rect2(Vector2(bottle_rect.position.x + 6.0, bottle_rect.position.y + 14.0), Vector2(16.0, 5.0))
	var cross_v := Rect2(Vector2(bottle_rect.position.x + 11.5, bottle_rect.position.y + 9.0), Vector2(5.0, 16.0))
	canvas.draw_rect(cross_h, DANGER)
	canvas.draw_rect(cross_v, DANGER)
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "AID", "title_center", TAPE)

static func _draw_material_dry_rations_art(canvas: Control, art_rect: Rect2) -> void:
	var pouch_rect := Rect2(Vector2(art_rect.position.x + 18.0, art_rect.position.y + 42.0), Vector2(art_rect.size.x - 36.0, 42.0))
	canvas.draw_rect(pouch_rect, Color(0.68, 0.58, 0.36))
	canvas.draw_rect(pouch_rect.grow(-2.0), Color(0.87, 0.81, 0.66))
	canvas.draw_rect(Rect2(pouch_rect.position, Vector2(pouch_rect.size.x, 12.0)), ACCENT_DIM)
	canvas.draw_rect(Rect2(Vector2(pouch_rect.position.x + 10.0, pouch_rect.position.y + 18.0), Vector2(pouch_rect.size.x - 20.0, 8.0)), STEEL_DARK)
	canvas.draw_rect(Rect2(Vector2(pouch_rect.position.x + 14.0, pouch_rect.position.y + 30.0), Vector2(pouch_rect.size.x - 28.0, 4.0)), ACCENT)
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "RATIONS", "title_center", TAPE)

static func _draw_material_growth_medium_art(canvas: Control, art_rect: Rect2) -> void:
	var tray_rect := Rect2(Vector2(art_rect.position.x + 18.0, art_rect.position.y + 48.0), Vector2(art_rect.size.x - 36.0, 26.0))
	canvas.draw_rect(tray_rect, STEEL_DARK)
	canvas.draw_rect(tray_rect.grow(-2.0), Color(0.32, 0.29, 0.17))
	canvas.draw_rect(Rect2(Vector2(tray_rect.position.x + 6.0, tray_rect.position.y + 8.0), Vector2(tray_rect.size.x - 12.0, 10.0)), Color(0.56, 0.49, 0.22))
	canvas.draw_circle(Vector2(tray_rect.position.x + 18.0, tray_rect.position.y + 13.0), 3.0, TAPE)
	canvas.draw_circle(Vector2(tray_rect.position.x + 34.0, tray_rect.position.y + 14.0), 2.0, TAPE)
	canvas.draw_circle(Vector2(tray_rect.end.x - 18.0, tray_rect.position.y + 13.0), 3.0, TAPE)
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "MEDIUM", "title_center", TAPE)

static func _draw_crafted_generic_art(canvas: Control, art_rect: Rect2) -> void:
	_draw_framed_panel(canvas, Rect2(Vector2(art_rect.position.x + 16.0, art_rect.position.y + 42.0), Vector2(art_rect.size.x - 32.0, art_rect.size.y - 58.0)), 0.0, Color(0.83, 0.76, 0.58))
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "MADE", "title_center", TAPE)

static func _draw_brood_cage_art(canvas: Control, art_rect: Rect2, captive_enemy: Dictionary) -> void:
	var art_target := Rect2(
		Vector2(art_rect.position.x + 1.0, art_rect.position.y + 2.0),
		Vector2(art_rect.size.x - 2.0, art_rect.size.y - 4.0)
	)
	var captive_type := str(captive_enemy.get("type", "")).strip_edges()
	if not captive_type.is_empty():
		var enemy_texture := _get_enemy_texture(captive_type)
		if enemy_texture != null:
			_draw_texture_fit(canvas, enemy_texture, art_target, 16.0)
	var cage_texture := _get_crafted_texture("brood_cage")
	if cage_texture != null:
		_draw_texture_fit(canvas, cage_texture, art_target)
	else:
		_draw_crafted_generic_art(canvas, art_rect)

static func _get_crafted_texture(crafted_type: String) -> Texture2D:
	match crafted_type:
		"tank":
			if _crafted_tank_art == null:
				_crafted_tank_art = load_svg_texture("res://assets/cards/tank.svg")
			return _crafted_tank_art
		"tool_chest":
			if _crafted_tool_chest_art == null:
				_crafted_tool_chest_art = load_svg_texture("res://assets/cards/tool_chest.svg")
			return _crafted_tool_chest_art
		"brood_cage":
			if _crafted_brood_cage_art == null:
				_crafted_brood_cage_art = load_svg_texture("res://assets/cards/brood_cage.svg")
			return _crafted_brood_cage_art
		"archive_shelf":
			if _crafted_archive_shelf_art == null:
				_crafted_archive_shelf_art = load_svg_texture("res://assets/cards/archive_shelf.svg")
			return _crafted_archive_shelf_art
		_:
			return null

static func _get_equipment_token_text(equipment_type: String) -> String:
	match equipment_type:
		"knife":
			return "KNF"
		"bow":
			return "BOW"
		"plate_mail":
			return "PLT"
		"hide_cloak":
			return "HIDE"
		"tool_kit":
			return "TOOLS"
		_:
			return equipment_type.replace("_", " ").to_upper()

static func _format_equipment_stat_summary(stats: Dictionary) -> String:
	var parts: Array[String] = []
	var attack := int(stats.get("attack", 0))
	var armor := int(stats.get("armor", 0))
	var stealth := int(stats.get("stealth", 0))
	var utility := int(stats.get("utility", 0))
	if attack != 0:
		parts.append("ATK %s" % _format_signed_stat(attack))
	if armor != 0:
		parts.append("ARM %s" % _format_signed_stat(armor))
	if stealth != 0:
		parts.append("STL %s" % _format_signed_stat(stealth))
	if utility != 0:
		parts.append("UTL %s" % _format_signed_stat(utility))
	return "  ".join(parts)

static func _format_signed_stat(value: int) -> String:
	if value >= 0:
		return "+%d" % value
	return str(value)

static func _get_equipment_stats(equipment_type: String) -> Dictionary:
	match equipment_type:
		"knife":
			return {"attack": 1, "armor": 0, "stealth": 0, "utility": 0}
		"bow":
			return {"attack": 3, "armor": -1, "stealth": 0, "utility": 0}
		"plate_mail":
			return {"attack": 0, "armor": 3, "stealth": -1, "utility": 0}
		"hide_cloak":
			return {"attack": 0, "armor": 0, "stealth": 3, "utility": 0}
		"tool_kit":
			return {"attack": 0, "armor": 0, "stealth": 0, "utility": 3}
		_:
			return {}

static func draw_table_drone_card(canvas: Control, rect: Rect2, slot: Dictionary, selected: bool, drag_ready: bool) -> void:
	var loaded_cartridge: Dictionary = slot.get("loaded_cartridge", {})
	var power_charge: int = int(slot.get("power_charge", 0))
	var power_card_count: int = int(slot.get("power_card_count", 0))
	var outside_status := str(slot.get("outside_status", "cabinet"))
	var available_in_workshop := bool(slot.get("available_in_workshop", false))
	var drone_type := str(slot.get("drone_type", ""))
	var tape_badge_rect: Rect2 = slot.get("tape_badge_rect", Rect2())
	var shell := _draw_card_variant(canvas, rect, "drone", selected, drag_ready)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	_draw_band_title(canvas, face_rect, _get_drone_card_title(slot), TAPE)
	if available_in_workshop:
		var fitted_art_rect := _fit_rect(art_rect, 4.0)
		var drone_texture := _get_drone_texture(drone_type)
		if drone_texture != null:
			_draw_texture_fit(canvas, drone_texture, fitted_art_rect)
		else:
			_draw_text_token(canvas, fitted_art_rect, _get_drone_token_label(drone_type), FONT_SIZE_CARD_META, TAPE)
		_draw_drone_tape_badge(canvas, tape_badge_rect, loaded_cartridge, selected)
	else:
		_draw_empty_drone_card_face(canvas, art_rect, outside_status)
	_draw_equipment_slot_row(canvas, Rect2(Vector2(art_rect.position.x + 18.0, art_rect.end.y - 30.0), Vector2(art_rect.size.x - 36.0, 24.0)), Array(slot.get("equipment_slots", [])))
	var drone_combat_totals: Dictionary = Dictionary(slot.get("equipment_totals", {}))
	_draw_drone_stat_strip(canvas, Rect2(Vector2(info_rect.position.x, info_rect.position.y + 1.0), Vector2(info_rect.size.x, info_rect.size.y - 2.0)), power_charge, drone_combat_totals, TAPE)
	var status_light := Rect2(Vector2(rect.end.x - 16.0, rect.position.y + 10.0), Vector2(6.0, 6.0))
	canvas.draw_circle(status_light.get_center(), 3.0, Color(0.46, 0.77, 0.46) if available_in_workshop else Color(0.76, 0.44, 0.24))

static func _draw_card_shell(canvas: Control, rect: Rect2, card_class: String, selected: bool, hovered: bool) -> Dictionary:
	var back_rect := Rect2(rect.position + Vector2(3.0, -3.0), rect.size)
	var face_rect := rect.grow(-3.0)
	var art_rect := Rect2(Vector2(face_rect.position.x + 12.0, face_rect.position.y + 18.0), Vector2(face_rect.size.x - 24.0, 86.0))
	var info_rect := Rect2(Vector2(face_rect.position.x + 12.0, face_rect.end.y - 40.0), Vector2(face_rect.size.x - 24.0, 24.0))
	var colors := _get_card_class_colors(card_class)
	canvas.draw_rect(back_rect, SHADOW)
	canvas.draw_rect(rect, colors["edge"])
	canvas.draw_rect(face_rect, colors["face"])
	canvas.draw_rect(Rect2(face_rect.position, Vector2(face_rect.size.x, 12.0)), colors["band"])
	canvas.draw_rect(back_rect, colors["shadow_border"], false, 1.0)
	canvas.draw_rect(rect, ACCENT if selected else PANEL_BORDER, false, 1.0)
	if hovered:
		canvas.draw_rect(rect.grow(4.0), Color(0.80, 0.66, 0.27, 0.14))
	return {
		"back_rect": back_rect,
		"face_rect": face_rect,
		"art_rect": art_rect,
		"info_rect": info_rect,
	}

static func _draw_card_template(canvas: Control, rect: Rect2, card_class: String, selected: bool, hovered: bool, face_fill: Variant = null, art_fill: Variant = null, art_border: Variant = null, info_rule_color: Variant = null) -> Dictionary:
	var shell := _draw_card_shell(canvas, rect, card_class, selected, hovered)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	if face_fill != null:
		canvas.draw_rect(face_rect, face_fill)
	if art_fill != null:
		canvas.draw_rect(art_rect, art_fill)
	if art_border != null:
		canvas.draw_rect(art_rect, art_border, false, 1.0)
	if info_rule_color != null:
		canvas.draw_line(Vector2(info_rect.position.x, info_rect.end.y - 2.0), Vector2(info_rect.end.x, info_rect.end.y - 2.0), info_rule_color, 2.0)
	return shell

static func _draw_card_variant(canvas: Control, rect: Rect2, variant_name: String, selected: bool = false, hovered: bool = false) -> Dictionary:
	var variant: Dictionary = CARD_VARIANTS.get(variant_name, CARD_VARIANTS["operator"])
	return _draw_card_template(
		canvas,
		rect,
		str(variant.get("card_class", "agent")),
		selected,
		hovered,
		variant.get("face_fill", null),
		variant.get("art_fill", null),
		variant.get("art_border", null),
		variant.get("info_rule_color", null)
	)

static func _get_card_class_colors(card_class: String) -> Dictionary:
	match card_class:
		"machine":
			return {"edge": MACHINE_CARD_SHADE, "face": MACHINE_CARD, "band": MACHINE_CARD_LIGHT, "shadow_border": Color(0.45, 0.25, 0.22)}
		"agent":
			return {"edge": STEEL_DARK, "face": Color(0.14, 0.15, 0.18), "band": Color(0.19, 0.20, 0.24), "shadow_border": Color(0.22, 0.23, 0.26)}
		"medium":
			return {"edge": STEEL, "face": TAPE, "band": Color(0.89, 0.84, 0.69), "shadow_border": Color(0.42, 0.36, 0.24)}
		"charge":
			return {"edge": TAPE_SHADE, "face": TAPE, "band": Color(0.90, 0.83, 0.63), "shadow_border": Color(0.45, 0.38, 0.22)}
		"place":
			return {"edge": Color(0.27, 0.31, 0.38), "face": Color(0.68, 0.72, 0.78), "band": Color(0.80, 0.84, 0.88), "shadow_border": Color(0.32, 0.36, 0.42)}
		"material":
			return {"edge": Color(0.35, 0.30, 0.20), "face": Color(0.78, 0.73, 0.61), "band": Color(0.88, 0.83, 0.70), "shadow_border": Color(0.40, 0.34, 0.22)}
		"threat":
			return {"edge": Color(0.27, 0.10, 0.10), "face": Color(0.46, 0.16, 0.15), "band": Color(0.58, 0.22, 0.20), "shadow_border": Color(0.32, 0.12, 0.11)}
		_:
			return {"edge": STEEL_DARK, "face": PANEL_INNER, "band": STEEL, "shadow_border": PANEL_BORDER}

static func _draw_programming_bench_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("bench"), rect):
		return
	_draw_art_label(canvas, rect, "bench")

static func _draw_route_table_card_art(canvas: Control, rect: Rect2, route_overlay: Callable) -> void:
	var outer_size := minf(rect.size.x - 2.0, rect.size.y - 2.0)
	var display_rect := Rect2(rect.position + (rect.size - Vector2(outer_size, outer_size)) * 0.5, Vector2(outer_size, outer_size))
	canvas.draw_rect(display_rect, PAPER_PANEL)
	canvas.draw_rect(display_rect.grow(-2.0), Color(0.89, 0.84, 0.71))
	canvas.draw_rect(display_rect, PANEL_BORDER, false, 1.0)
	if route_overlay.is_valid():
		route_overlay.call(display_rect)

static func _draw_journal_machine_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("journal"), rect):
		return
	_draw_art_label(canvas, rect, "journal")

static func _draw_trash_machine_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("trash"), rect):
		return
	_draw_art_label(canvas, rect, "trash")

static func _draw_charge_machine_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("charge"), rect):
		return
	_draw_art_label(canvas, rect, "power")

static func _draw_preview_tape(canvas: Control, rect: Rect2, visible_rows: int, active_row: int) -> void:
	canvas.draw_rect(rect, TAPE_SHADE)
	canvas.draw_rect(rect.grow(-2.0), TAPE)
	var rows: int = maxi(visible_rows, 10)
	var row_width: float = (rect.size.x - 16.0) / float(rows)
	for row in range(rows):
		var row_rect := Rect2(Vector2(rect.position.x + 8.0 + row * row_width, rect.position.y + 3.0), Vector2(row_width - 2.0, rect.size.y - 6.0))
		canvas.draw_rect(row_rect, Color(1.0, 1.0, 1.0, 0.04))
		canvas.draw_rect(row_rect, Color(0.42, 0.36, 0.24, 0.22), false, 1.0)
		for bit in range(5):
			var hole_center := Vector2(row_rect.position.x + row_rect.size.x * 0.5, row_rect.position.y + 5.0 + bit * ((row_rect.size.y - 10.0) / 4.0))
			canvas.draw_circle(hole_center, 1.7, TAPE_HOLE if row <= active_row else Color(0.35, 0.30, 0.20, 0.25))
	if visible_rows > 0:
		var highlight_x: float = rect.position.x + 8.0 + float(mini(active_row, rows - 1)) * row_width
		var highlight_rect := Rect2(Vector2(highlight_x, rect.position.y + 1.0), Vector2(row_width - 2.0, rect.size.y - 2.0))
		canvas.draw_rect(highlight_rect, Color(0.85, 0.68, 0.28, 0.18))
		canvas.draw_rect(highlight_rect, ACCENT, false, 1.0)

static func _draw_enemy_glyph(canvas: Control, rect: Rect2, enemy_type: String) -> void:
	if _draw_texture_fit(canvas, _get_enemy_texture(enemy_type), rect):
		return
	_draw_text_token(canvas, rect, enemy_type, FONT_SIZE_CARD_META, STEEL_DARK)

static func _draw_material_glyph(canvas: Control, rect: Rect2, material_type: String) -> void:
	if _draw_texture_fit(canvas, _get_material_texture(material_type), rect):
		return
	_draw_text_token(canvas, rect, material_type, FONT_SIZE_CARD_META, STEEL_DARK)

static func _draw_empty_drone_card_face(canvas: Control, window_rect: Rect2, outside_status: String) -> void:
	canvas.draw_rect(window_rect.grow(-10.0), Color(0.10, 0.11, 0.12))

static func _draw_drone_tape_badge(canvas: Control, rect: Rect2, loaded_cartridge: Dictionary, is_selected: bool) -> void:
	if loaded_cartridge.is_empty():
		return
	var tag_rect := rect
	var back_poly := PackedVector2Array([
		tag_rect.position + Vector2(3.0, -2.0),
		tag_rect.position + Vector2(tag_rect.size.x - 3.0, -2.0),
		tag_rect.end + Vector2(0.0, -2.0),
		tag_rect.position + Vector2(7.0, tag_rect.size.y - 2.0),
		tag_rect.position + Vector2(0.0, tag_rect.size.y * 0.5),
	])
	var front_poly := PackedVector2Array([
		tag_rect.position + Vector2(0.0, 0.0),
		tag_rect.position + Vector2(tag_rect.size.x - 4.0, 0.0),
		tag_rect.end + Vector2(-4.0, 0.0),
		tag_rect.position + Vector2(8.0, tag_rect.size.y),
		tag_rect.position + Vector2(0.0, tag_rect.size.y * 0.5),
	])
	canvas.draw_colored_polygon(back_poly, Color(0.22, 0.18, 0.12, 0.65))
	canvas.draw_colored_polygon(front_poly, TAPE)
	_draw_poly_outline(canvas, front_poly, ACCENT if is_selected else PANEL_BORDER, 1.0)
	canvas.draw_rect(Rect2(tag_rect.position + Vector2(4.0, 2.0), Vector2(3.0, tag_rect.size.y - 4.0)), ACCENT)
	var short_label := _trim_card_label(str(loaded_cartridge.get("label", "")), 6).to_upper()
	_draw_card_text(canvas, Rect2(Vector2(tag_rect.position.x + 12.0, tag_rect.position.y + 2.0), Vector2(tag_rect.size.x - 16.0, tag_rect.size.y - 4.0)), short_label, "tag_left", STEEL_DARK)

static func _draw_drone_power_badge(canvas: Control, rect: Rect2, power_charge: int, has_power: bool) -> void:
	if not has_power and power_charge <= 0:
		return
	var value_text := str(maxi(power_charge, 0))
	var suit_rect := Rect2(rect.position + Vector2(0.0, 4.0), Vector2(14.0, 8.0))
	_draw_power_suit(canvas, suit_rect, power_charge > 0, 1.0)
	_draw_card_text(canvas, Rect2(Vector2(rect.position.x + 12.0, rect.position.y + 1.0), Vector2(rect.size.x - 12.0, rect.size.y - 2.0)), value_text, "badge_value_right", TAPE)

static func _draw_spider_drone_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_drone_texture("spider"), rect):
		return
	_draw_text_token(canvas, rect, "spider", FONT_SIZE_CARD_META, STEEL_DARK)

static func _draw_butterfly_drone_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_drone_texture("butterfly"), rect):
		return
	_draw_text_token(canvas, rect, "butterfly", FONT_SIZE_CARD_META, STEEL_DARK)

static func _draw_power_suit(canvas: Control, rect: Rect2, charged: bool, line_width: float = 1.5) -> void:
	if _draw_texture_fit(canvas, _get_material_texture("spring"), rect):
		return
	_draw_text_token(canvas, rect, "power", FONT_SIZE_CARD_META, ACCENT if charged else STEEL_LIGHT)

static func _draw_disabled_hatch(canvas: Control, rect: Rect2) -> void:
	var x := rect.position.x - rect.size.y
	while x < rect.end.x:
		canvas.draw_line(Vector2(x, rect.position.y), Vector2(x + rect.size.y, rect.end.y), Color(0.0, 0.0, 0.0, 0.18), 1.0)
		x += 6.0

static func _get_text_style(style_name: String) -> Dictionary:
	match style_name:
		"title_center":
			return {"font_size": FONT_SIZE_CARD_TITLE, "alignment": HORIZONTAL_ALIGNMENT_CENTER, "tracking_color": TEXT}
		"meta_center":
			return {"font_size": FONT_SIZE_CARD_META, "alignment": HORIZONTAL_ALIGNMENT_CENTER, "tracking_color": TAPE_SHADE}
		"value_right":
			return {"font_size": FONT_SIZE_VALUE, "alignment": HORIZONTAL_ALIGNMENT_RIGHT, "tracking_color": STEEL_DARK}
		"badge_value_right":
			return {"font_size": FONT_SIZE_CARD_VALUE, "alignment": HORIZONTAL_ALIGNMENT_RIGHT, "tracking_color": TAPE}
		"tag_left":
			return {"font_size": FONT_SIZE_CARD_TITLE, "alignment": HORIZONTAL_ALIGNMENT_LEFT, "tracking_color": STEEL_DARK}
		_:
			return {"font_size": FONT_SIZE_CARD_TITLE, "alignment": HORIZONTAL_ALIGNMENT_LEFT, "tracking_color": TEXT}

static func _get_info_slot(info_rect: Rect2, slot_name: String) -> Rect2:
	match slot_name:
		"title":
			return Rect2(Vector2(info_rect.position.x, info_rect.position.y + 1.0), Vector2(info_rect.size.x, 9.0))
		"meta":
			return Rect2(Vector2(info_rect.position.x, info_rect.position.y + 11.0), Vector2(info_rect.size.x, 8.0))
		"foot":
			return Rect2(Vector2(info_rect.position.x, info_rect.position.y + 18.0), Vector2(info_rect.size.x, 6.0))
		"value":
			return Rect2(Vector2(info_rect.position.x, info_rect.position.y + 1.0), Vector2(info_rect.size.x, 14.0))
		"qty_label":
			return Rect2(Vector2(info_rect.position.x, info_rect.position.y + 11.0), Vector2(info_rect.size.x * 0.58, 8.0))
		"qty_value":
			return Rect2(Vector2(info_rect.position.x + info_rect.size.x * 0.42, info_rect.position.y + 8.0), Vector2(info_rect.size.x * 0.58, 12.0))
		_:
			return info_rect

static func _get_text_baseline(rect: Rect2, font_size: int) -> float:
	var font := ThemeDB.fallback_font
	return rect.position.y + (rect.size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)

static func _draw_card_text(canvas: Control, rect: Rect2, text: String, style_name: String, color_override: Variant = null) -> void:
	var style := _get_text_style(style_name)
	var font_size := int(style["font_size"])
	var alignment: HorizontalAlignment = style["alignment"]
	var color: Color = color_override if color_override != null else Color(style["tracking_color"])
	var baseline := _get_text_baseline(rect, font_size)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, baseline), text, alignment, rect.size.x, font_size, color)

static func _trim_card_label(label: String, max_length: int) -> String:
	var trimmed := label.strip_edges()
	if trimmed.length() <= max_length:
		return trimmed
	return trimmed.substr(0, max_length)

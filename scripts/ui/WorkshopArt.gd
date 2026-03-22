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
	"blueprint": {
		"card_class": "medium",
		"face_fill": TAPE,
		"art_fill": PAPER_PANEL,
		"art_border": PANEL_BORDER,
		"info_rule_color": ACCENT_DIM,
	},
	"crafted": {
		"card_class": "medium",
		"face_fill": TAPE,
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
	"SPRING CHARGE": {"kind": "power"},
	"POWER UNIT": {"kind": "power"},
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
static var _material_hide_art: Texture2D = null
static var _material_biomass_art: Texture2D = null
static var _material_bone_art: Texture2D = null
static var _material_paper_art: Texture2D = null
static var _material_metal_art: Texture2D = null

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
	var horizon_y := rect.position.y + rect.size.y - 12.0
	if location_type not in ["pond", "crater"]:
		canvas.draw_line(Vector2(rect.position.x + 4.0, horizon_y), Vector2(rect.end.x - 4.0, horizon_y), Color(0.45, 0.40, 0.26), 1.6)
	match location_type:
		"tower":
			_draw_location_tower(canvas, rect, horizon_y, false, tower_texture)
		"surveillance_zone":
			_draw_location_tower(canvas, rect, horizon_y, true, surveillance_texture)
		"cache":
			_draw_location_bunker(canvas, rect, horizon_y, true, cache_texture)
		"bunker":
			_draw_location_bunker(canvas, rect, horizon_y, false, bunker_texture)
		"pond":
			_draw_location_basin(canvas, rect, horizon_y, true, pond_texture)
		"crater":
			_draw_location_basin(canvas, rect, horizon_y, false, crater_texture)
		"facility", "dump", "field":
			_draw_location_facility(canvas, rect, horizon_y, location_type, facility_texture, field_texture, dump_texture)
		"nest":
			_draw_location_nest(canvas, rect, horizon_y, nest_texture)
		"ruin":
			_draw_location_ruin(canvas, rect, horizon_y, ruin_texture)
		_:
			_draw_location_ruin(canvas, rect, horizon_y, ruin_texture)

static func _draw_location_tower(canvas: Control, rect: Rect2, horizon_y: float, surveillance: bool, tower_texture: Texture2D) -> void:
	if _draw_texture_fit(canvas, tower_texture, rect, 1.0):
		return
	var outline := Color(0.10, 0.10, 0.11)
	var accent := Color(0.76, 0.66, 0.38)
	var ref_size: Vector2 = Vector2(320.0, 420.0)
	var fit_scale: float = min(rect.size.x / ref_size.x, rect.size.y / ref_size.y) * 0.90
	var fit_size: Vector2 = ref_size * fit_scale
	var fit_origin: Vector2 = rect.get_center() - fit_size * 0.5 + Vector2(0.0, rect.size.y * 0.04)
	var p := func(x: float, y: float) -> Vector2:
		return fit_origin + Vector2(x, y) * fit_scale
	var mast_x := 160.0
	var ground_y := 356.0
	var mast_top_y := 92.0
	var base_poly := PackedVector2Array([
		p.call(112.0, ground_y),
		p.call(135.0, 292.0),
		p.call(185.0, 292.0),
		p.call(208.0, ground_y),
	])
	canvas.draw_colored_polygon(base_poly, Color(0.18, 0.18, 0.20))
	_draw_poly_outline(canvas, base_poly, outline, 2.0)
	canvas.draw_line(p.call(mast_x, ground_y), p.call(mast_x, mast_top_y), outline, 4.0)
	canvas.draw_line(p.call(mast_x, 138.0), p.call(126.0, 238.0), outline, 2.0)
	canvas.draw_line(p.call(mast_x, 138.0), p.call(194.0, 238.0), outline, 2.0)
	canvas.draw_line(p.call(140.0, 184.0), p.call(180.0, 184.0), outline, 2.2)
	canvas.draw_line(p.call(136.0, 228.0), p.call(184.0, 228.0), outline, 2.2)
	canvas.draw_line(p.call(mast_x, mast_top_y), p.call(mast_x, 64.0), outline, 2.0)
	if surveillance:
		var dish_center: Vector2 = p.call(mast_x, 104.0)
		canvas.draw_arc(dish_center, 26.0 * fit_scale, PI * 0.12, PI * 0.88, 18, outline, 2.6)
		canvas.draw_line(dish_center, p.call(mast_x, 126.0), outline, 1.8)
		canvas.draw_arc(dish_center + Vector2(0.0, 2.0 * fit_scale), 18.0 * fit_scale, PI * 0.16, PI * 0.84, 14, accent, 1.6)
	else:
		canvas.draw_line(p.call(146.0, 78.0), p.call(174.0, 78.0), outline, 2.4)
		canvas.draw_line(p.call(152.0, 66.0), p.call(168.0, 66.0), outline, 2.0)
	var beacon_rect: Rect2 = Rect2(p.call(148.0, 48.0), Vector2(24.0, 10.0) * fit_scale)
	canvas.draw_rect(beacon_rect, accent)
	canvas.draw_rect(beacon_rect, outline, false, 1.4)

static func _draw_location_bunker(canvas: Control, rect: Rect2, horizon_y: float, cache_like: bool, bunker_texture: Texture2D) -> void:
	var fit_rect := Rect2(rect.position + Vector2(2.0, 4.0), rect.size - Vector2(4.0, 8.0))
	if not _draw_texture_fit(canvas, bunker_texture, fit_rect):
		var outline := Color(0.10, 0.10, 0.11)
		var body_rect := Rect2(Vector2(rect.get_center().x - 18.0, horizon_y - 18.0), Vector2(36.0, 16.0))
		var fill := TAPE if cache_like else Color(0.58, 0.53, 0.45)
		if not cache_like:
			var berm := PackedVector2Array([
				Vector2(body_rect.position.x - 10.0, horizon_y),
				Vector2(body_rect.position.x - 3.0, body_rect.position.y + 6.0),
				Vector2(body_rect.end.x + 3.0, body_rect.position.y + 6.0),
				Vector2(body_rect.end.x + 10.0, horizon_y),
			])
			canvas.draw_colored_polygon(berm, Color(0.54, 0.46, 0.32))
			_draw_poly_outline(canvas, berm, outline, 1.2)
		canvas.draw_rect(body_rect, fill)
		canvas.draw_rect(body_rect, outline, false, 2.0)
		var door_rect := Rect2(Vector2(body_rect.get_center().x - 6.0, body_rect.position.y + 3.0), Vector2(12.0, 10.0))
		canvas.draw_rect(door_rect, outline)
	if cache_like:
		var outline_tint := Color(0.10, 0.10, 0.11, 0.55)
		var accent := Color(0.84, 0.78, 0.60, 0.14)
		canvas.draw_rect(fit_rect, accent)
		canvas.draw_rect(fit_rect, outline_tint, false, 1.4)

static func _draw_location_basin(canvas: Control, rect: Rect2, horizon_y: float, wet: bool, basin_texture: Texture2D) -> void:
	var fit_rect := Rect2(rect.position + Vector2(2.0, 6.0), rect.size - Vector2(4.0, 12.0))
	if _draw_texture_fit(canvas, basin_texture, fit_rect):
		return
	if not wet:
		var center := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.62)
		var outer_rx := 28.0
		var outer_ry := 13.0
		var inner_rx := 21.0
		var inner_ry := 9.0
		var outline := Color(0.10, 0.10, 0.11)
		var rim_color := Color(0.58, 0.49, 0.35)
		var basin_color := Color(0.36, 0.29, 0.20)
		canvas.draw_ellipse(center, outer_rx, outer_ry, rim_color)
		canvas.draw_arc(center, outer_rx, 0.0, TAU, 36, outline, 2.0)
		canvas.draw_ellipse(center + Vector2(0.0, 1.0), inner_rx, inner_ry, basin_color)
		canvas.draw_arc(center + Vector2(0.0, 1.0), inner_rx, 0.0, TAU, 32, outline, 1.8)
		var crack_center := center + Vector2(-2.0, 1.0)
		canvas.draw_line(crack_center + Vector2(-5.0, 0.0), crack_center + Vector2(3.0, 2.0), outline, 1.2)
		canvas.draw_line(crack_center + Vector2(1.0, 1.0), crack_center + Vector2(-2.0, 5.0), outline, 1.0)
		canvas.draw_line(crack_center + Vector2(2.0, 1.0), crack_center + Vector2(6.0, -2.0), outline, 1.0)
	else:
		var center := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.62)
		var outer_rx := 28.0
		var outer_ry := 13.0
		var inner_rx := 21.0
		var inner_ry := 9.0
		var outline := Color(0.10, 0.10, 0.11)
		var rim_color := Color(0.66, 0.57, 0.30)
		var basin_color := Color(0.30, 0.40, 0.34)
		canvas.draw_ellipse(center, outer_rx, outer_ry, rim_color)
		canvas.draw_arc(center, outer_rx, 0.0, TAU, 36, outline, 2.0)
		canvas.draw_ellipse(center + Vector2(0.0, 1.0), inner_rx, inner_ry, basin_color)
		canvas.draw_arc(center + Vector2(0.0, 1.0), inner_rx, 0.0, TAU, 32, outline, 1.8)

static func _draw_location_facility(canvas: Control, rect: Rect2, horizon_y: float, location_type: String, facility_texture: Texture2D = null, field_texture: Texture2D = null, dump_texture: Texture2D = null) -> void:
	if location_type == "facility" and _draw_texture_fit(canvas, facility_texture, rect, 1.0):
		return
	if location_type == "field" and _draw_texture_fit(canvas, field_texture, rect, 1.0):
		return
	if location_type == "dump" and _draw_texture_fit(canvas, dump_texture, rect, 1.0):
		return
	var outline := Color(0.10, 0.10, 0.11)
	var base_rect := Rect2(Vector2(rect.get_center().x - 20.0, horizon_y - 18.0), Vector2(40.0, 16.0))
	if location_type == "field":
		for furrow in range(4):
			var y := horizon_y - 3.0 - furrow * 4.0
			canvas.draw_line(Vector2(base_rect.position.x + 4.0, y), Vector2(base_rect.end.x - 4.0, y), Color(0.73, 0.63, 0.36), 1.8)
		return
	canvas.draw_rect(base_rect, Color(0.26, 0.27, 0.30))
	canvas.draw_rect(base_rect, outline, false, 2.0)
	var roof_rect := Rect2(Vector2(base_rect.position.x - 3.0, base_rect.position.y - 4.0), Vector2(base_rect.size.x + 6.0, 4.0))
	canvas.draw_rect(roof_rect, outline)
	if location_type == "facility":
		for stack in range(2):
			var stack_x := base_rect.position.x + 8.0 + float(stack) * 20.0
			canvas.draw_rect(Rect2(Vector2(stack_x, base_rect.position.y - 12.0), Vector2(4.0, 12.0)), outline)
		for window_index in range(3):
			var window_rect := Rect2(Vector2(base_rect.position.x + 6.0 + window_index * 11.0, base_rect.position.y + 5.0), Vector2(6.0, 6.0))
			canvas.draw_rect(window_rect, TAPE_SHADE)
	elif location_type == "dump":
		for pile in range(3):
			canvas.draw_circle(Vector2(base_rect.position.x + 10.0 + pile * 10.0, horizon_y - 4.0), 4.0 + float(pile), TAPE_SHADE)
		var crate_rect := Rect2(Vector2(base_rect.position.x + 26.0, horizon_y - 12.0), Vector2(10.0, 8.0))
		canvas.draw_rect(crate_rect, Color(0.42, 0.36, 0.23))
		canvas.draw_rect(crate_rect, outline, false, 1.4)

static func _draw_location_nest(canvas: Control, rect: Rect2, horizon_y: float, nest_texture: Texture2D = null) -> void:
	if _draw_texture_fit(canvas, nest_texture, rect, 1.0):
		return
	var center := Vector2(rect.get_center().x, horizon_y - 10.0)
	var mound := PackedVector2Array([
		Vector2(center.x - 24.0, horizon_y),
		Vector2(center.x - 16.0, horizon_y - 14.0),
		Vector2(center.x + 16.0, horizon_y - 14.0),
		Vector2(center.x + 24.0, horizon_y),
	])
	canvas.draw_colored_polygon(mound, TAPE_SHADE)
	_draw_poly_outline(canvas, mound, Color(0.10, 0.10, 0.11), 1.6)
	for hole in range(3):
		var hole_rect := Rect2(Vector2(center.x - 16.0 + hole * 12.0, horizon_y - 10.0), Vector2(8.0, 6.0))
		canvas.draw_rect(hole_rect, STEEL_DARK)
	for spike in range(4):
		var spike_x := center.x - 15.0 + spike * 10.0
		canvas.draw_line(Vector2(spike_x, horizon_y - 14.0), Vector2(spike_x, horizon_y - 23.0), Color(0.10, 0.10, 0.11), 1.4)

static func _draw_location_ruin(canvas: Control, rect: Rect2, horizon_y: float, ruin_texture: Texture2D = null) -> void:
	if _draw_texture_fit(canvas, ruin_texture, rect, 1.0):
		return
	var outline := Color(0.10, 0.10, 0.11)
	var body := PackedVector2Array([
		Vector2(rect.get_center().x - 22.0, horizon_y),
		Vector2(rect.get_center().x - 22.0, horizon_y - 18.0),
		Vector2(rect.get_center().x - 9.0, horizon_y - 26.0),
		Vector2(rect.get_center().x + 1.0, horizon_y - 18.0),
		Vector2(rect.get_center().x + 10.0, horizon_y - 24.0),
		Vector2(rect.get_center().x + 22.0, horizon_y - 24.0),
		Vector2(rect.get_center().x + 22.0, horizon_y),
	])
	canvas.draw_colored_polygon(body, Color(0.57, 0.52, 0.43))
	_draw_poly_outline(canvas, body, outline, 1.8)
	var door_rect := Rect2(Vector2(rect.get_center().x - 7.0, horizon_y - 12.0), Vector2(14.0, 12.0))
	canvas.draw_rect(door_rect, outline)

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

static func _draw_machine_panel(canvas: Control, rect: Rect2, outer_fill: Color, inner_fill: Variant = null, border: Color = STEEL_LIGHT, inner_inset: float = 2.0) -> Rect2:
	canvas.draw_rect(rect, outer_fill)
	if inner_fill != null:
		canvas.draw_rect(rect.grow(-inner_inset), inner_fill)
	canvas.draw_rect(rect, border, false, 1.0)
	return rect.grow(-inner_inset)

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
		_:
			return null

static func _get_material_texture(material_type: String) -> Texture2D:
	match material_type:
		"spring":
			if _spring_icon_art == null:
				_spring_icon_art = load_svg_texture("res://assets/cards/spring_icon.svg")
			return _spring_icon_art
		"hide":
			if _material_hide_art == null:
				_material_hide_art = load_svg_texture("res://assets/cards/hide.svg")
			return _material_hide_art
		"biomass":
			if _material_biomass_art == null:
				_material_biomass_art = load_svg_texture("res://assets/cards/meat.svg")
			return _material_biomass_art
		"bone":
			if _material_bone_art == null:
				_material_bone_art = load_svg_texture("res://assets/cards/bone.svg")
			return _material_bone_art
		"paper":
			if _material_paper_art == null:
				_material_paper_art = load_svg_texture("res://assets/cards/paper.svg")
			return _material_paper_art
		"metal":
			if _material_metal_art == null:
				_material_metal_art = load_svg_texture("res://assets/cards/metal.svg")
			return _material_metal_art
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

static func draw_machine_card(canvas: Control, rect: Rect2, kind: String, route_overlay: Callable = Callable()) -> void:
	var shell := _draw_card_variant(canvas, rect, "machine")
	var art_rect: Rect2 = shell["art_rect"]
	var machine_art_rect := _fit_rect(art_rect, 6.0)
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
	var label_rect := _get_info_slot(info_rect, "title")
	canvas.draw_rect(side_strip, ACCENT if programmed else STEEL_LIGHT)
	if _tape_device_art == null:
		_tape_device_art = load_svg_texture("res://assets/cards/device_pixelperfect_fixed.svg")
	if not _draw_texture_fit(canvas, _tape_device_art, suit_rect):
		_draw_tape_suit(canvas, suit_rect, programmed)
	if programmed and not label.is_empty():
		var short_label := _trim_card_label(label, 10).to_upper()
		_draw_card_text(canvas, label_rect, short_label, "title_center", STEEL_DARK)
	elif not programmed:
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
	_draw_power_suit(canvas, suit_rect, charge > 0)
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
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var dossier_rect := _draw_framed_panel(canvas, art_rect, 8.0, TAPE, Color(0.58, 0.50, 0.30))
	_draw_texture_fit(canvas, photo, dossier_rect)
	var clip_rect := Rect2(Vector2(dossier_rect.end.x - 18.0, dossier_rect.position.y + 8.0), Vector2(8.0, 18.0))
	canvas.draw_rect(clip_rect, ACCENT_DIM)
	canvas.draw_rect(clip_rect.grow(-1.0), ACCENT)
	_draw_card_text(canvas, _get_info_slot(info_rect, "title"), operator_name, "title_center", TEXT)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "EN %d  HP %d" % [int(operator_state.get("energy", 0)), int(operator_state.get("hp", 0))], "title_center", TAPE)
	_draw_card_text(canvas, _get_info_slot(info_rect, "foot"), focus, "meta_center", TAPE_SHADE)

static func draw_location_card(canvas: Control, rect: Rect2, card_data: Dictionary, bunker_texture: Texture2D, cache_texture: Texture2D, pond_texture: Texture2D, crater_texture: Texture2D, tower_texture: Texture2D, surveillance_texture: Texture2D, facility_texture: Texture2D, field_texture: Texture2D, dump_texture: Texture2D, nest_texture: Texture2D, ruin_texture: Texture2D) -> void:
	var shell := _draw_card_variant(canvas, rect, "location")
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var location_type := str(card_data.get("type", "site"))
	var type_label := location_type.replace("_", " ")
	var image_seed := int(card_data.get("image_seed", 0))
	var pos: Dictionary = card_data.get("position", {"x": 0, "y": 0})
	var coords := Vector2(int(pos.get("x", 0)), int(pos.get("y", 0)))
	draw_location_glyph(canvas, _fit_rect(art_rect, 4.0), location_type, image_seed, bunker_texture, cache_texture, pond_texture, crater_texture, tower_texture, surveillance_texture, facility_texture, field_texture, dump_texture, nest_texture, ruin_texture)
	_draw_card_text(canvas, _get_info_slot(info_rect, "title"), _trim_card_label(type_label.to_upper(), 16), "title_center", STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "(%d,%d)" % [int(coords.x), int(coords.y)], "meta_center", Color(0.24, 0.26, 0.30))

static func draw_enemy_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "enemy")
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var enemy_type := str(card_data.get("type", "hostile_creature"))
	var display_name := str(card_data.get("display_name", enemy_type.replace("_", " ")))
	var threat_level := int(card_data.get("threat_level", 1))
	var enemy_hp := int(card_data.get("hp", 1))
	_draw_enemy_glyph(canvas, _fit_rect(art_rect, 8.0), enemy_type)
	_draw_card_text(canvas, _get_info_slot(info_rect, "title"), _trim_card_label(display_name.to_upper(), 16), "title_center", TAPE)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "ATK %d  HP %d" % [threat_level, enemy_hp], "meta_center", Color(0.93, 0.78, 0.54))

static func draw_material_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "material")
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var material_type := str(card_data.get("type", "metal"))
	var quantity := maxi(int(card_data.get("quantity", 1)), 1)
	_draw_material_glyph(canvas, _fit_rect(art_rect, 6.0), material_type)
	_draw_card_text(canvas, _get_info_slot(info_rect, "title"), _trim_card_label(material_type.replace("_", " ").to_upper(), 16), "title_center", STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "qty_label"), "QTY", "meta_center", TAPE_SHADE)
	_draw_card_text(canvas, _get_info_slot(info_rect, "qty_value"), str(quantity), "value_right", STEEL_DARK)

static func draw_blueprint_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "blueprint")
	var art_rect: Rect2 = shell["art_rect"]
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
	var tokens: Array = []
	for part_variant in formula_parts:
		var part := str(part_variant).strip_edges().to_upper()
		if part == "BLUEPRINT" or part.is_empty():
			continue
		tokens.append(part)
	if tokens.is_empty():
		return
	var plus_gap := 5.0
	var qty_width := 16.0
	var icon_side := minf(rect.size.y - 4.0, 18.0)
	if icon_side <= 0.0:
		return
	var plus_width := 6.0
	var token_width := qty_width + 4.0 + icon_side
	var total_width := float(tokens.size()) * token_width
	if tokens.size() > 1:
		total_width += float(tokens.size() - 1) * (plus_width + plus_gap * 2.0)
	if total_width > rect.size.x:
		icon_side = maxf(12.0, minf(icon_side, (rect.size.x - float(tokens.size()) * (qty_width + 4.0) - float(tokens.size() - 1) * (plus_width + plus_gap * 2.0)) / float(tokens.size())))
		token_width = qty_width + 4.0 + icon_side
		total_width = float(tokens.size()) * token_width
		if tokens.size() > 1:
			total_width += float(tokens.size() - 1) * (plus_width + plus_gap * 2.0)
	var start_x := rect.position.x + (rect.size.x - total_width) * 0.5
	var baseline_y := rect.position.y + rect.size.y * 0.5
	for token_index in range(tokens.size()):
		var quantity := 1
		var token_name := str(tokens[token_index])
		if token_name.contains(" X"):
			var pieces := token_name.split(" X")
			if pieces.size() == 2:
				token_name = str(pieces[0]).strip_edges()
				quantity = maxi(int(str(pieces[1]).to_int()), 1)
		var token_x := start_x
		for prev_index in range(token_index):
			token_x += token_width
			if prev_index < token_index:
				token_x += plus_gap + plus_width + plus_gap
		var qty_rect := Rect2(Vector2(token_x, baseline_y - 7.0), Vector2(qty_width, 14.0))
		_draw_card_text(canvas, qty_rect, "%dx" % quantity, "value_right", STEEL_DARK)
		var icon_rect := Rect2(Vector2(token_x + qty_width + 4.0, baseline_y - icon_side * 0.5), Vector2(icon_side, icon_side))
		_draw_blueprint_token_icon(canvas, icon_rect, token_name)
		if token_index < tokens.size() - 1:
			var plus_x := token_x + token_width + plus_gap
			_draw_card_text(canvas, Rect2(Vector2(plus_x, baseline_y - 7.0), Vector2(plus_width, 14.0)), "+", "title_center", TAPE_SHADE)

static func _draw_blueprint_token_icon(canvas: Control, rect: Rect2, token_name: String) -> void:
	var spec := _get_blueprint_token_spec(token_name)
	var kind := str(spec.get("kind", ""))
	match kind:
		"operator":
			_draw_blueprint_operator_icon(canvas, rect)
			return
		"machine":
			_draw_blueprint_machine_icon(canvas, rect, str(spec.get("value", "")))
			return
		"material":
			_draw_material_glyph(canvas, rect, str(spec.get("value", "")))
			return
		"tape":
			_draw_blueprint_tape_icon(canvas, rect, bool(spec.get("value", false)))
			return
		"power":
			_draw_power_suit(canvas, _fit_rect(rect, 8.0), true, 2.0)
			return
		"drone":
			var drone_type := str(spec.get("value", ""))
			if drone_type == "spider":
				_draw_spider_drone_art(canvas, _fit_rect(rect, 2.0))
			elif drone_type == "butterfly":
				_draw_butterfly_drone_art(canvas, _fit_rect(rect, 2.0))
			return
		"enemy":
			_draw_enemy_glyph(canvas, _fit_rect(rect, 2.0), str(spec.get("value", "")))
			return
		"location":
			_draw_blueprint_location_icon(canvas, rect, str(spec.get("value", "")))
			return
	_draw_framed_panel(canvas, rect, 8.0, STEEL)

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

static func _draw_blueprint_location_icon(canvas: Control, rect: Rect2, location_type: String) -> void:
	match location_type:
		"pond":
			_draw_location_basin(canvas, rect, rect.end.y - 8.0, true, null)
		"crater":
			_draw_location_basin(canvas, rect, rect.end.y - 8.0, false, null)
		"tower":
			_draw_location_tower(canvas, rect, rect.end.y - 8.0, false, null)
		"surveillance_zone":
			_draw_location_tower(canvas, rect, rect.end.y - 8.0, true, null)
		"facility", "field", "dump":
			_draw_location_facility(canvas, rect, rect.end.y - 8.0, location_type, null, null, null)
		"bunker":
			_draw_location_bunker(canvas, rect, rect.end.y - 8.0, false, null)
		"cache":
			_draw_location_bunker(canvas, rect, rect.end.y - 8.0, true, null)
		"nest":
			_draw_location_nest(canvas, rect, rect.end.y - 8.0, null)
		"ruin":
			_draw_location_ruin(canvas, rect, rect.end.y - 8.0, null)
		_:
			_draw_framed_panel(canvas, rect, 8.0, STEEL)

static func _draw_blueprint_operator_icon(canvas: Control, rect: Rect2) -> void:
	var head_center := rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.34)
	canvas.draw_circle(head_center, 7.0, STEEL_DARK)
	var bust := PackedVector2Array([
		rect.position + Vector2(rect.size.x * 0.28, rect.size.y * 0.92),
		rect.position + Vector2(rect.size.x * 0.36, rect.size.y * 0.66),
		rect.position + Vector2(rect.size.x * 0.64, rect.size.y * 0.66),
		rect.position + Vector2(rect.size.x * 0.72, rect.size.y * 0.92),
	])
	canvas.draw_colored_polygon(bust, STEEL_DARK)
	_draw_poly_outline(canvas, bust, PANEL_BORDER, 1.0)

static func _draw_blueprint_machine_icon(canvas: Control, rect: Rect2, kind: String) -> void:
	var inset := rect.grow(-8.0)
	match kind:
		"bench":
			canvas.draw_rect(Rect2(Vector2(inset.position.x + 6.0, inset.position.y + 8.0), Vector2(inset.size.x - 12.0, 8.0)), STEEL)
			canvas.draw_rect(Rect2(Vector2(inset.position.x + 14.0, inset.position.y + 4.0), Vector2(inset.size.x - 28.0, 6.0)), TAPE)
			canvas.draw_line(Vector2(inset.position.x + 12.0, inset.end.y - 6.0), Vector2(inset.position.x + 16.0, inset.position.y + 16.0), PANEL_BORDER, 1.4)
			canvas.draw_line(Vector2(inset.end.x - 12.0, inset.end.y - 6.0), Vector2(inset.end.x - 16.0, inset.position.y + 16.0), PANEL_BORDER, 1.4)
		"route":
			canvas.draw_rect(inset, STEEL_DARK)
			canvas.draw_rect(inset.grow(-2.0), PANEL_INNER)
			for dot_y in range(3):
				for dot_x in range(3):
					canvas.draw_circle(inset.position + Vector2(10.0 + float(dot_x) * 12.0, 10.0 + float(dot_y) * 10.0), 1.2, TAPE_SHADE)
			canvas.draw_circle(inset.get_center(), 2.4, ACCENT)
		"charge":
			canvas.draw_rect(inset, STEEL)
			canvas.draw_rect(inset.grow(-2.0), STEEL_DARK)
			_draw_power_suit(canvas, inset.grow(-8.0), true, 2.0)
		"journal":
			canvas.draw_rect(inset, TAPE)
			canvas.draw_rect(inset.grow(-2.0), Color(0.91, 0.85, 0.72))
			canvas.draw_line(Vector2(inset.position.x + 6.0, inset.position.y + 10.0), Vector2(inset.position.x + 6.0, inset.end.y - 6.0), PANEL_BORDER, 1.6)
			for line_index in range(3):
				var line_y := inset.position.y + 10.0 + float(line_index) * 8.0
				canvas.draw_line(Vector2(inset.position.x + 12.0, line_y), Vector2(inset.end.x - 6.0, line_y), TAPE_SHADE, 1.2)
		"trash":
			var bin_rect := Rect2(Vector2(inset.position.x + 10.0, inset.position.y + 10.0), Vector2(inset.size.x - 20.0, inset.size.y - 16.0))
			var lid_rect := Rect2(Vector2(bin_rect.position.x - 2.0, bin_rect.position.y - 6.0), Vector2(bin_rect.size.x + 4.0, 5.0))
			canvas.draw_rect(bin_rect, STEEL_DARK)
			canvas.draw_rect(bin_rect.grow(-2.0), STEEL)
			canvas.draw_rect(lid_rect, STEEL_DARK)
			canvas.draw_rect(Rect2(Vector2(bin_rect.position.x + bin_rect.size.x * 0.5 - 4.0, lid_rect.position.y - 3.0), Vector2(8.0, 2.0)), STEEL_DARK)

static func _draw_blueprint_tape_icon(canvas: Control, rect: Rect2, programmed: bool) -> void:
	if _tape_device_art == null:
		_tape_device_art = load_svg_texture("res://assets/cards/device_pixelperfect_fixed.svg")
	if not _draw_texture_fit(canvas, _tape_device_art, rect, 6.0):
		_draw_framed_panel(canvas, rect, 10.0, STEEL)
	if programmed:
		for hole_index in range(3):
			canvas.draw_circle(rect.position + Vector2(12.0 + float(hole_index) * 10.0, rect.end.y - 12.0), 1.4, TAPE_HOLE)

static func draw_crafted_card(canvas: Control, rect: Rect2, card_data: Dictionary) -> void:
	var shell := _draw_card_variant(canvas, rect, "crafted")
	var art_rect: Rect2 = shell["art_rect"]
	var info_rect: Rect2 = shell["info_rect"]
	var result_name := str(card_data.get("result", "Crafted Item")).to_upper()
	var result_label := _trim_card_label(result_name, 16)
	_draw_framed_panel(canvas, art_rect, 8.0, Color(0.90, 0.84, 0.69))
	_draw_crafted_banner(canvas, art_rect)
	if result_name == "ENERGY BAR":
		_draw_crafted_energy_bar_art(canvas, art_rect)
	elif result_name == "MEDICINE":
		_draw_crafted_medicine_art(canvas, art_rect)
	else:
		_draw_crafted_generic_art(canvas, art_rect)
	_draw_card_text(canvas, _get_info_slot(info_rect, "title"), result_label, "title_center", STEEL_DARK)
	_draw_card_text(canvas, _get_info_slot(info_rect, "meta"), "CRAFTED", "meta_center", TAPE_SHADE)

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

static func _draw_crafted_generic_art(canvas: Control, art_rect: Rect2) -> void:
	_draw_framed_panel(canvas, Rect2(Vector2(art_rect.position.x + 16.0, art_rect.position.y + 42.0), Vector2(art_rect.size.x - 32.0, art_rect.size.y - 58.0)), 0.0, Color(0.83, 0.76, 0.58))
	_draw_card_text(canvas, Rect2(Vector2(art_rect.position.x, art_rect.position.y + 16.0), Vector2(art_rect.size.x, 10.0)), "MADE", "title_center", TAPE)

static func draw_table_drone_card(canvas: Control, rect: Rect2, slot: Dictionary, selected: bool, drag_ready: bool) -> void:
	var loaded_cartridge: Dictionary = slot.get("loaded_cartridge", {})
	var power_charge: int = int(slot.get("power_charge", 0))
	var power_card_count: int = int(slot.get("power_card_count", 0))
	var outside_status := str(slot.get("outside_status", "cabinet"))
	var available_in_workshop := bool(slot.get("available_in_workshop", false))
	var tape_badge_rect: Rect2 = slot.get("tape_badge_rect", Rect2())
	var shell := _draw_card_variant(canvas, rect, "drone", selected, drag_ready)
	var face_rect: Rect2 = shell["face_rect"]
	var art_rect: Rect2 = shell["art_rect"]
	if available_in_workshop:
		if int(slot.get("index", 0)) == 0:
			_draw_spider_drone_art(canvas, _fit_rect(art_rect, 4.0))
		else:
			_draw_butterfly_drone_art(canvas, _fit_rect(art_rect, 4.0))
		_draw_drone_tape_badge(canvas, tape_badge_rect, loaded_cartridge, selected)
		_draw_drone_power_badge(canvas, Rect2(Vector2(face_rect.end.x - 46.0, face_rect.end.y - 28.0), Vector2(34.0, 16.0)), power_charge, power_card_count > 0)
	else:
		_draw_empty_drone_card_face(canvas, art_rect, outside_status)
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
	var body_rect := Rect2(Vector2(rect.position.x + 8.0, rect.position.y + 12.0), Vector2(rect.size.x - 16.0, 30.0))
	var tape_rect := Rect2(Vector2(body_rect.position.x + 12.0, body_rect.position.y + 9.0), Vector2(body_rect.size.x - 24.0, 12.0))
	var left_roller := Rect2(Vector2(tape_rect.position.x - 10.0, tape_rect.position.y - 4.0), Vector2(6.0, tape_rect.size.y + 8.0))
	var right_roller := Rect2(Vector2(tape_rect.end.x + 4.0, tape_rect.position.y - 4.0), Vector2(6.0, tape_rect.size.y + 8.0))
	var punch_rect := Rect2(Vector2(tape_rect.get_center().x - 7.0, tape_rect.position.y - 10.0), Vector2(14.0, 28.0))
	var deck_rect := Rect2(Vector2(body_rect.position.x + 8.0, body_rect.end.y + 10.0), Vector2(body_rect.size.x - 16.0, 10.0))
	_draw_machine_panel(canvas, body_rect, Color(0.14, 0.15, 0.18), null, PANEL_BORDER, 0.0)
	canvas.draw_rect(Rect2(Vector2(body_rect.position.x + 12.0, body_rect.position.y + 8.0), Vector2(body_rect.size.x - 24.0, 3.0)), ACCENT_DIM)
	_draw_machine_panel(canvas, left_roller, STEEL_DARK, STEEL)
	_draw_machine_panel(canvas, right_roller, STEEL_DARK, STEEL)
	_draw_preview_tape(canvas, tape_rect, 6, 1)
	_draw_machine_panel(canvas, punch_rect, Color(0.61, 0.54, 0.40), Color(0.71, 0.65, 0.49), PANEL_BORDER)
	_draw_machine_panel(canvas, deck_rect, Color(0.12, 0.13, 0.15), null, PANEL_BORDER, 0.0)
	var key_origin := deck_rect.position + Vector2(16.0, 3.0)
	for column in range(4):
		var key_center := key_origin + Vector2(column * 13.0, 2.0)
		canvas.draw_circle(key_center, 1.6, STEEL_DARK)
		canvas.draw_circle(key_center, 1.0, Color(0.17, 0.18, 0.20))

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
	var cover_rect := rect.grow(-10.0)
	canvas.draw_rect(cover_rect, TAPE)
	canvas.draw_rect(cover_rect, PANEL_BORDER, false, 1.0)

static func _draw_trash_machine_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("trash"), rect):
		return
	var inner_rect := rect.grow(-4.0)
	var bin_color := Color(0.28, 0.29, 0.31)
	var body_rect := Rect2(Vector2(inner_rect.position.x + 16.0, inner_rect.position.y + 16.0), Vector2(inner_rect.size.x - 32.0, 36.0))
	var lid_rect := Rect2(Vector2(body_rect.position.x - 5.0, body_rect.position.y - 8.0), Vector2(body_rect.size.x + 10.0, 8.0))
	var slot_rect := Rect2(Vector2(body_rect.position.x + 12.0, body_rect.position.y - 2.0), Vector2(body_rect.size.x - 24.0, 2.0))
	var paper_rect := Rect2(Vector2(inner_rect.position.x + inner_rect.size.x * 0.5 - 10.0, inner_rect.position.y + 8.0), Vector2(20.0, 14.0))
	_draw_machine_panel(canvas, lid_rect, bin_color, Color(0.20, 0.21, 0.23))
	_draw_machine_panel(canvas, body_rect, bin_color, Color(0.18, 0.19, 0.20))
	canvas.draw_rect(slot_rect, Color(0.09, 0.10, 0.12))
	canvas.draw_rect(paper_rect, TAPE)
	canvas.draw_rect(paper_rect, Color(0.60, 0.52, 0.31), false, 1.0)
	canvas.draw_line(paper_rect.position + Vector2(4.0, 4.0), paper_rect.end - Vector2(4.0, 4.0), Color(0.46, 0.16, 0.13), 1.2)
	canvas.draw_line(Vector2(body_rect.position.x + 12.0, body_rect.position.y + 4.0), Vector2(body_rect.position.x + 8.0, body_rect.end.y - 6.0), STEEL_LIGHT, 1.0)
	canvas.draw_line(Vector2(body_rect.end.x - 12.0, body_rect.position.y + 4.0), Vector2(body_rect.end.x - 8.0, body_rect.end.y - 6.0), STEEL_LIGHT, 1.0)

static func _draw_charge_machine_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_machine_texture("charge"), rect):
		return
	var inner_rect := rect.grow(-4.0)
	var drum_rect := Rect2(Vector2(inner_rect.position.x + 12.0, inner_rect.position.y + 16.0), Vector2(inner_rect.size.x - 24.0, 28.0))
	var tray_rect := Rect2(Vector2(inner_rect.position.x + 16.0, inner_rect.end.y - 28.0), Vector2(inner_rect.size.x - 32.0, 14.0))
	var crank_center := Vector2(drum_rect.end.x - 12.0, drum_rect.get_center().y)
	_draw_machine_panel(canvas, drum_rect, Color(0.24, 0.25, 0.28), Color(0.17, 0.18, 0.20))
	_draw_power_suit(canvas, Rect2(drum_rect.position + Vector2(10.0, 8.0), Vector2(drum_rect.size.x - 32.0, 10.0)), true, 1.3)
	canvas.draw_line(crank_center + Vector2(-8.0, 0.0), crank_center + Vector2(3.0, 0.0), TAPE, 1.5)
	canvas.draw_line(crank_center + Vector2(3.0, 0.0), crank_center + Vector2(8.0, -6.0), TAPE, 1.5)
	canvas.draw_circle(crank_center + Vector2(8.0, -6.0), 2.0, TAPE)
	_draw_machine_panel(canvas, tray_rect, TAPE, null, TAPE_SHADE, 0.0)
	canvas.draw_rect(Rect2(tray_rect.position + Vector2(10.0, 3.0), Vector2(tray_rect.size.x - 20.0, 8.0)), Color(0.88, 0.82, 0.66))

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

static func _draw_tape_suit(canvas: Control, rect: Rect2, programmed: bool) -> void:
	var strip_rect := Rect2(rect.position + Vector2(0.0, 2.0), Vector2(rect.size.x, rect.size.y - 4.0))
	canvas.draw_rect(strip_rect, TAPE_SHADE if programmed else Color(0.70, 0.70, 0.72))
	canvas.draw_rect(strip_rect, Color(0.56, 0.48, 0.28), false, 1.0)
	for hole_index in range(5):
		var hole_center := Vector2(strip_rect.position.x + 5.0 + float(hole_index) * ((strip_rect.size.x - 10.0) / 4.0), strip_rect.position.y + strip_rect.size.y * 0.5)
		canvas.draw_circle(hole_center, 0.9, TAPE_HOLE if programmed else STEEL_LIGHT)

static func _draw_enemy_glyph(canvas: Control, rect: Rect2, enemy_type: String) -> void:
	if _draw_texture_fit(canvas, _get_enemy_texture(enemy_type), rect):
		return
	match enemy_type:
		"swarm":
			for point in [Vector2(24, 18), Vector2(42, 28), Vector2(32, 42), Vector2(54, 46)]:
				canvas.draw_circle(rect.position + point, 4.0, TAPE)
		"raider":
			var triangle := PackedVector2Array([rect.position + Vector2(rect.size.x * 0.5, 16.0), rect.position + Vector2(24.0, rect.size.y - 18.0), rect.position + Vector2(rect.size.x - 24.0, rect.size.y - 18.0)])
			canvas.draw_colored_polygon(triangle, TAPE)
			_draw_poly_outline(canvas, triangle, STEEL_DARK, 1.0)
		_:
			var body := rect.get_center()
			canvas.draw_circle(body + Vector2(0.0, -6.0), 8.0, TAPE)
			canvas.draw_line(body + Vector2(-10.0, 6.0), body + Vector2(10.0, 6.0), TAPE, 2.0)

static func _draw_material_glyph(canvas: Control, rect: Rect2, material_type: String) -> void:
	if _draw_texture_fit(canvas, _get_material_texture(material_type), rect):
		return
	_draw_framed_panel(canvas, rect, 12.0, STEEL)

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

static func _draw_drone_silhouette(canvas: Control, rect: Rect2) -> void:
	var chassis_rect := Rect2(Vector2(rect.position.x + rect.size.x * 0.5 - 19.0, rect.position.y + 36.0), Vector2(38.0, 18.0))
	var chassis_top := Rect2(Vector2(chassis_rect.position.x + 4.0, chassis_rect.position.y + 2.0), Vector2(chassis_rect.size.x - 8.0, 4.0))
	var optic_pod := Rect2(Vector2(chassis_rect.position.x + 6.0, chassis_rect.position.y + 2.0), Vector2(11.0, 11.0))
	var service_hatch := Rect2(Vector2(chassis_rect.end.x - 12.0, chassis_rect.position.y + 4.0), Vector2(8.0, 8.0))
	var spring_gauge := Rect2(Vector2(chassis_rect.position.x + 20.0, chassis_rect.position.y + 4.0), Vector2(9.0, 4.0))
	var belly_plate := Rect2(Vector2(chassis_rect.position.x + 10.0, chassis_rect.end.y - 2.0), Vector2(chassis_rect.size.x - 20.0, 3.0))
	canvas.draw_rect(chassis_rect, STEEL_DARK)
	canvas.draw_rect(chassis_rect.grow(-2.0), Color(0.17, 0.18, 0.20))
	canvas.draw_rect(chassis_top, STEEL_LIGHT)
	canvas.draw_rect(optic_pod, STEEL)
	canvas.draw_rect(service_hatch, Color(0.15, 0.15, 0.17))
	canvas.draw_rect(spring_gauge, Color(0.10, 0.10, 0.11))
	canvas.draw_rect(Rect2(spring_gauge.position + Vector2(1.0, 1.0), Vector2(5.0, spring_gauge.size.y - 2.0)), ACCENT_DIM)
	canvas.draw_rect(belly_plate, ACCENT_DIM)
	canvas.draw_rect(chassis_rect, PANEL_BORDER, false, 2.0)
	canvas.draw_rect(optic_pod, PANEL_BORDER, false, 1.0)
	canvas.draw_rect(service_hatch, PANEL_BORDER, false, 1.0)
	var sensor_center := optic_pod.position + optic_pod.size * 0.5
	canvas.draw_circle(sensor_center, 4.0, STEEL_DARK)
	canvas.draw_circle(sensor_center, 2.7, STEEL)
	canvas.draw_circle(sensor_center, 1.3, TEXT)
	canvas.draw_circle(sensor_center + Vector2(-0.6, -0.6), 0.7, ACCENT)
	for bolt in [chassis_rect.position + Vector2(6.0, chassis_rect.size.y - 5.0), chassis_rect.position + Vector2(chassis_rect.size.x - 6.0, chassis_rect.size.y - 5.0)]:
		canvas.draw_circle(bolt, 1.3, STEEL_LIGHT)
	var key_center := Vector2(chassis_rect.position.x + chassis_rect.size.x * 0.5 + 6.0, chassis_rect.position.y - 2.0)
	canvas.draw_line(key_center + Vector2(-2.2, 0.0), key_center + Vector2(-2.2, -7.0), STEEL_DARK, 2.0)
	canvas.draw_line(key_center + Vector2(2.2, 0.0), key_center + Vector2(2.2, -7.0), STEEL_DARK, 2.0)
	canvas.draw_arc(key_center + Vector2(-2.2, -8.5), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	canvas.draw_arc(key_center + Vector2(2.2, -8.5), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	var left_anchors := [Vector2(0.0, 3.0), Vector2(0.0, 7.0), Vector2(0.0, 11.0), Vector2(0.0, 15.0)]
	var right_anchors := [Vector2(chassis_rect.size.x, 3.0), Vector2(chassis_rect.size.x, 7.0), Vector2(chassis_rect.size.x, 11.0), Vector2(chassis_rect.size.x, 15.0)]
	var left_knees := [Vector2(-8.0, -1.0), Vector2(-12.0, 2.0), Vector2(-13.0, 7.0), Vector2(-10.0, 12.0)]
	var right_knees := [Vector2(8.0, -1.0), Vector2(12.0, 2.0), Vector2(13.0, 7.0), Vector2(10.0, 12.0)]
	for leg_index in range(4):
		var left_anchor: Vector2 = chassis_rect.position + left_anchors[leg_index]
		var right_anchor: Vector2 = chassis_rect.position + right_anchors[leg_index]
		_draw_spider_leg(canvas, left_anchor, left_knees[leg_index], true)
		_draw_spider_leg(canvas, right_anchor, right_knees[leg_index], false)

static func _draw_spider_drone_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_drone_texture("spider"), rect):
		return
	_draw_drone_silhouette(canvas, rect)

static func _draw_spider_leg(canvas: Control, anchor: Vector2, knee_offset: Vector2, is_left: bool) -> void:
	var knee := anchor + knee_offset
	var shin := knee + Vector2(-10.0 if is_left else 10.0, 8.0)
	var foot := shin + Vector2(-5.0 if is_left else 5.0, 12.0)
	_draw_leg_segment(canvas, anchor, knee, shin, foot)

static func _draw_butterfly_drone(canvas: Control, rect: Rect2) -> void:
	var body_center := rect.position + Vector2(rect.size.x * 0.5, 42.0)
	var head_center := body_center + Vector2(0.0, -18.0)
	var thorax_rect := Rect2(Vector2(body_center.x - 6.0, body_center.y - 10.0), Vector2(12.0, 18.0))
	var spring_rect := Rect2(Vector2(body_center.x - 3.5, body_center.y - 2.0), Vector2(7.0, 34.0))
	var key_axle_rect := Rect2(Vector2(body_center.x - 2.0, body_center.y - 4.0), Vector2(4.0, 14.0))
	var key_bar_y := body_center.y + 3.0
	var lower_tail := PackedVector2Array([body_center + Vector2(-5.0, 28.0), body_center + Vector2(0.0, 36.0), body_center + Vector2(5.0, 28.0), body_center + Vector2(0.0, 20.0)])
	canvas.draw_circle(head_center, 4.0, STEEL_DARK)
	canvas.draw_rect(thorax_rect, STEEL_DARK)
	canvas.draw_rect(thorax_rect.grow(-1.0), ACCENT_DIM)
	canvas.draw_rect(spring_rect, STEEL_DARK)
	canvas.draw_rect(spring_rect.grow(-1.0), TAPE)
	canvas.draw_rect(key_axle_rect, STEEL_DARK)
	canvas.draw_line(Vector2(body_center.x - 8.0, key_bar_y), Vector2(body_center.x + 8.0, key_bar_y), STEEL_DARK, 2.0)
	canvas.draw_arc(Vector2(body_center.x - 8.0, key_bar_y - 3.0), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	canvas.draw_arc(Vector2(body_center.x + 8.0, key_bar_y - 3.0), 3.0, 0.0, TAU, 12, STEEL_DARK, 1.8)
	canvas.draw_circle(Vector2(body_center.x, key_bar_y), 2.0, STEEL_LIGHT)
	canvas.draw_line(spring_rect.position + Vector2(0.0, 4.0), spring_rect.position + Vector2(spring_rect.size.x, 4.0), PANEL_BORDER, 1.0)
	canvas.draw_line(spring_rect.position + Vector2(0.0, 10.0), spring_rect.position + Vector2(spring_rect.size.x, 10.0), PANEL_BORDER, 1.0)
	canvas.draw_line(spring_rect.position + Vector2(0.0, 16.0), spring_rect.position + Vector2(spring_rect.size.x, 16.0), PANEL_BORDER, 1.0)
	canvas.draw_colored_polygon(lower_tail, STEEL_DARK)
	var upper_left := PackedVector2Array([body_center + Vector2(-5.0, -10.0), body_center + Vector2(-24.0, -26.0), body_center + Vector2(-39.0, -20.0), body_center + Vector2(-33.0, -3.0), body_center + Vector2(-12.0, -1.0), body_center + Vector2(-6.0, -4.0)])
	var upper_right := PackedVector2Array([body_center + Vector2(5.0, -10.0), body_center + Vector2(24.0, -26.0), body_center + Vector2(39.0, -20.0), body_center + Vector2(33.0, -3.0), body_center + Vector2(12.0, -1.0), body_center + Vector2(6.0, -4.0)])
	var lower_left := PackedVector2Array([body_center + Vector2(-4.0, 6.0), body_center + Vector2(-16.0, 13.0), body_center + Vector2(-26.0, 24.0), body_center + Vector2(-24.0, 37.0), body_center + Vector2(-13.0, 44.0), body_center + Vector2(-5.0, 34.0), body_center + Vector2(-2.0, 18.0)])
	var lower_right := PackedVector2Array([body_center + Vector2(4.0, 6.0), body_center + Vector2(16.0, 13.0), body_center + Vector2(26.0, 24.0), body_center + Vector2(24.0, 37.0), body_center + Vector2(13.0, 44.0), body_center + Vector2(5.0, 34.0), body_center + Vector2(2.0, 18.0)])
	_draw_butterfly_wing(canvas, upper_left, 4)
	_draw_butterfly_wing(canvas, upper_right, 4)
	_draw_butterfly_wing(canvas, lower_left, 5)
	_draw_butterfly_wing(canvas, lower_right, 5)
	canvas.draw_line(head_center + Vector2(-1.0, -2.0), head_center + Vector2(-7.0, -10.0), ACCENT_DIM, 1.4)
	canvas.draw_line(head_center + Vector2(1.0, -2.0), head_center + Vector2(7.0, -10.0), ACCENT_DIM, 1.4)
	canvas.draw_arc(head_center + Vector2(-7.0, -12.0), 2.5, 0.0, TAU, 10, STEEL_DARK, 1.1)
	canvas.draw_arc(head_center + Vector2(7.0, -12.0), 2.5, 0.0, TAU, 10, STEEL_DARK, 1.1)

static func _draw_butterfly_drone_art(canvas: Control, rect: Rect2) -> void:
	if _draw_texture_fit(canvas, _get_drone_texture("butterfly"), rect):
		return
	_draw_butterfly_drone(canvas, rect)

static func _draw_butterfly_wing(canvas: Control, points: PackedVector2Array, rib_count: int) -> void:
	canvas.draw_colored_polygon(points, TAPE)
	for point_index in range(points.size()):
		var next_index: int = (point_index + 1) % points.size()
		canvas.draw_line(points[point_index], points[next_index], STEEL_DARK, 2.4)
	var root := points[points.size() - 1]
	var tip := points[0]
	canvas.draw_line(root, tip, Color(0.58, 0.52, 0.37), 1.1)
	for rib_index in range(1, mini(rib_count + 1, points.size() - 1)):
		canvas.draw_line(root, points[rib_index], Color(0.58, 0.52, 0.37), 1.0)

static func _draw_leg_segment(canvas: Control, anchor: Vector2, joint_a: Vector2, joint_b: Vector2, foot: Vector2) -> void:
	canvas.draw_line(anchor, joint_a, STEEL_DARK, 4.0)
	canvas.draw_line(joint_a, joint_b, STEEL_DARK, 4.0)
	canvas.draw_line(joint_b, foot, STEEL_DARK, 4.0)
	canvas.draw_line(anchor, joint_a, ACCENT_DIM, 1.8)
	canvas.draw_line(joint_a, joint_b, ACCENT_DIM, 1.8)
	canvas.draw_line(joint_b, foot, ACCENT_DIM, 1.8)
	for point in [anchor, joint_a, joint_b]:
		canvas.draw_circle(point, 2.2, STEEL_DARK)
		canvas.draw_circle(point, 1.1, STEEL_LIGHT)

static func _draw_power_suit(canvas: Control, rect: Rect2, charged: bool, line_width: float = 1.5) -> void:
	if _draw_texture_fit(canvas, _get_material_texture("spring"), rect):
		return
	var color := ACCENT if charged else STEEL_LIGHT
	var left := rect.position.x + 1.0
	var right := rect.end.x - 1.0
	var cy := rect.get_center().y
	var amp := rect.size.y * 0.32
	var pts := PackedVector2Array()
	for step in range(9):
		var t := float(step) / 8.0
		var x := lerpf(left + 2.0, right - 2.0, t)
		var y := cy
		if step > 0 and step < 8:
			y += amp if step % 2 == 0 else -amp
		pts.append(Vector2(x, y))
	canvas.draw_line(Vector2(left, cy), pts[0], color, line_width)
	for i in range(pts.size() - 1):
		canvas.draw_line(pts[i], pts[i + 1], color, line_width)
	canvas.draw_line(pts[-1], Vector2(right, cy), color, line_width)

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

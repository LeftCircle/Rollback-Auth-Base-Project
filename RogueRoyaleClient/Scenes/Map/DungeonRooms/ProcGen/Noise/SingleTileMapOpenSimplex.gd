@tool
extends TileMapResource
class_name SingleTileMapOpenSimplex

@export var lancunarity = 1 setget set_lancunarity # (float, 0, 10)
@export var octaves = 1 setget set_octaves # (int, 0, 10)
@export var period = 1 setget set_period # (float, 0, 64)
@export var thresholds: Array : set = set_tile_thresholds
@export var persistence = 0.5 setget set_persistence # (float, 0, 1)

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var noise = OpenSimplexNoise.new()
var tile_threshold_dict : Dictionary

func _ready():
	pass

func _build_tile_threshold_dict():
	tile_threshold_dict.clear()
	for i in range(floor_tiles.size()):
		tile_threshold_dict[floor_tiles[i]] = thresholds[i]

func fill_area_with_funcref() -> void:
	var fill_area_funcref = funcref(self, "_fill_area")
	#var args = [x_range, y_range, tiles, thresholds]
	FunctionQueue.queue_funcref(fill_area_funcref)

func place_tiles() -> void:
	_build_tile_threshold_dict()
	var noise_funcref = funcref(self, "_set_cells_if_noise_allows")
	set_cells_in_r2(room_outline.room_aabb_tiles, noise_funcref)
	tile_map.update_bitmask_region()

func _set_cells_if_noise_allows(x : int, y : int) -> void:
	var noise_value = noise.get_noise_2d(x, y)
	for tile in floor_tiles:
		if tile_threshold_dict[tile][0] < noise_value and noise_value <= tile_threshold_dict[tile][1]:
			tile_map.set_cell(x, y, tile)

func reset_noise():
	randomize()
	noise.seed = randi()

func _redraw_if_in_editor():
	randomize()
	if Engine.editor_hint:
		emit_signal("resource_updated")

################################################################################
######### All of the setters
################################################################################
func set_lancunarity(_lancunarity : float) -> void:
	lancunarity = _lancunarity
	_reset_noise()
	_redraw_if_in_editor()

func set_octaves(_octaves : int) -> void:
	octaves = _octaves
	_reset_noise()
	_redraw_if_in_editor()

func set_period(_period) -> void:
	period = _period
	_reset_noise()
	_redraw_if_in_editor()

func set_persistence(per) -> void:
	persistence = per
	_reset_noise()
	_redraw_if_in_editor()

func set_tile_thresholds(_thresholds : Array) -> void:
	for threshold in _thresholds:
		if threshold == null:
			continue
		assert(typeof(threshold) == TYPE_VECTOR2) #,"threshold must be Vector2")
		assert(threshold.x <= threshold.y) #,"first value must be less than second value")
		assert(threshold.x >= -1 and threshold.x <= 1) #,"Values must be between -1 and 1")
		assert(threshold.y >= -1 and threshold.y <= 1) #,"Values must be between -1 and 1")
	thresholds = _thresholds

func _reset_noise():
	noise.lacunarity = lancunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence

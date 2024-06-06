extends TileMap
class_name VoronoiTileMap

signal tiles_spawned()

enum CORNER_TYPES{UpRight, UpLeft, DownRight, DownLeft, NONE}

const LARGE_SHIFT = 0.3
const SMALL_SHIFT = 0.05
const TILE_SIZE = 64

const CORNER_VECTOR_PAIRS = {
	CORNER_TYPES.UpRight : [Vector2(0, 1), Vector2.RIGHT],
	CORNER_TYPES.UpLeft : [Vector2(0, 1), Vector2.LEFT],
	CORNER_TYPES.DownRight : [Vector2(0, -1), Vector2.RIGHT],
	CORNER_TYPES.DownLeft : [Vector2(0, -1), Vector2.LEFT]
}

const vec_to_tile_id = {
	Vector2(-1, -1) : 1,
	Vector2(0, -1) : 2,
	Vector2(1, -1) : 3,
	Vector2(-1, 0) : 4,
	Vector2(0, 0) : 5,
	Vector2(1, 0) : 6,
	Vector2(-1, 1) : 7,
	Vector2(0, 1) : 8,
	Vector2(1, 1) : 9
}

# We need a map to the tile_id and the color of the tile
@export var tile_id_to_color: Dictionary = {}
@export var voronoi_tile_scene: PackedScene

# {cell : corner_type}
var corner_cells = {}
# {cell, voronoi_tile}
var voronoi_tiles = {}

var debug_physics_steps = 0
var cell_size = 64 # Not sure where cell size used to come from - maybe from TileMap in 3.5?

func _ready():
	randomize()
#	find_corner_tile_cells()
#	spawn_voronoi_tiles()

#func _physics_process(delta):
#	debug_physics_steps += 1
#	if debug_physics_steps == 10:
#		find_corner_tile_cells()
#		spawn_voronoi_tiles()
#	elif debug_physics_steps >= 20:
#		var debug = true

func spawn_voronoi_tiles():
	find_corner_tile_cells()
	_spawn_voronoi_tiles()
	emit_signal("tiles_spawned")

func _spawn_voronoi_tiles():
	for cell in corner_cells.keys():
		var corner_type = corner_cells[cell]
		var tile_id = get_cell_source_id(0, cell)
		var tile_color = tile_id_to_color[tile_id]
		# We have to confirm that a voronoi tile hasn't already been spawned at this cell. If it has, update it to the appropriate corner type
		if cell in voronoi_tiles:
			_update_tile_corner_type_and_add_neighbors(cell, corner_type)
		else:
			_create_new_tile_and_add_neighbors(cell, corner_type, tile_color)
	_update_voronoi_seeds()
	update_all_neighbor_colors_and_points()

func _update_tile_corner_type_and_add_neighbors(cell : Vector2, corner_type : int) -> void:
	var voronoi_tile = voronoi_tiles[cell]
	voronoi_tile.set_corner_type(corner_type)
	_track_voronoi_tile_and_add_neighbors(cell, voronoi_tile)

func _create_new_tile_and_add_neighbors(cell : Vector2, corner_type : int, tile_color : Color) -> void:
	var new_tile = _add_voronoi_tile(cell, corner_type, tile_color)
	_track_voronoi_tile_and_add_neighbors(cell, new_tile)

func _track_voronoi_tile_and_add_neighbors(cell : Vector2, new_tile : VoronoiTile):
	voronoi_tiles[cell] = new_tile
	_add_neighbor_tiles_to(cell)

func find_corner_tile_cells() -> void:
	_find_corner_tile_cells_brute_force()

# Spawns a voronoi tile at the location of the cell and sets the color of the tile to the tile_color
# then checks the corner_type and updates the voronoi tile with the neighbor colors
func _add_voronoi_tile(cell : Vector2, corner_type : int, tile_color : Color) -> VoronoiTile:
	var voronoi_tile = voronoi_tile_scene.instantiate()
	voronoi_tile.init(cell * cell_size, tile_color, corner_type)
	voronoi_tiles[cell] = voronoi_tile
	add_child(voronoi_tile)
	return voronoi_tile

func _add_neighbor_tiles_to(cell : Vector2) -> void:
	# Adds a voronoi tile to the surrounding 8 cells if one does not already exist
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var neighbor_cell = cell + Vector2(i, j)
			_add_new_tile_if_no_tile_at_cell(neighbor_cell)

func _add_new_tile_if_no_tile_at_cell(cell : Vector2) -> void:
	if not cell in voronoi_tiles:
		var neighbor_tile_id = get_cell_source_id(0, cell)
		if neighbor_tile_id != -1 and tile_id_to_color.has(neighbor_tile_id):
			var neighbor_tile_color = tile_id_to_color[neighbor_tile_id]
			var neighbor_tile = _add_voronoi_tile(cell, CORNER_TYPES.NONE, neighbor_tile_color)
			voronoi_tiles[cell] = neighbor_tile

func update_all_neighbor_colors_and_points():
	for cell in voronoi_tiles.keys():
		var voronoi_tile = voronoi_tiles[cell]
		_update_voronoi_neighbor_colors_and_points(voronoi_tile, cell)

# Looks at the 8 tiles around the cell and updates the voronoi tile with the neighbor colors
func _update_voronoi_neighbor_colors_and_points(voronoi_tile : VoronoiTile, cell : Vector2) -> void:
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var neighbor_cell = cell + Vector2(i, j)
			var neighbor_voronoi_id = vec_to_tile_id[Vector2(i, j)]
			_update_neighbor_data_to_match_tilemap(voronoi_tile, neighbor_cell, neighbor_voronoi_id)

func _update_neighbor_data_to_match_tilemap(center_tile : VoronoiTile, neighbor_cell : Vector2, neighbor_voronoi_id : int) -> void:
	if neighbor_cell in voronoi_tiles:
		var neighbor_voronoi_tile = voronoi_tiles[neighbor_cell]
		center_tile.set_neighbor_color(neighbor_voronoi_id, neighbor_voronoi_tile.color)
		center_tile.set_neighbor_random_point(neighbor_voronoi_id, neighbor_voronoi_tile.random_point)
	else:
		center_tile.set_neighbor_color(neighbor_voronoi_id, center_tile.color)

func _find_corner_tile_cells_brute_force() -> void:
	var used_cells = []
	#for tile_id in tile_id_to_color.keys():
	used_cells.append_array(get_used_cells(0))
	for cell in used_cells:
		var corner_type = _get_tile_corner_type(cell)
		if corner_type != CORNER_TYPES.NONE:
			corner_cells[cell] = corner_type

func _get_tile_corner_type(cell : Vector2) -> int:
	# Look at the top/right, top/left, bottom/right, bottom/left
	var tile_id = get_cell_source_id(0, cell)
	for corner_type in CORNER_VECTOR_PAIRS.keys():
		var vector_pair = CORNER_VECTOR_PAIRS[corner_type]
		var neighbor_0 = get_cell_source_id(0, cell + vector_pair[0])
		var neighbor_1 = get_cell_source_id(0, cell + vector_pair[1])
		var is_valid = tile_id_to_color.has(neighbor_0) and tile_id_to_color.has(neighbor_1)
		if is_valid and neighbor_0 != -1 and neighbor_1 != -1:
			if neighbor_0 != tile_id and neighbor_1 != tile_id:
				return corner_type
	return CORNER_TYPES.NONE

func _update_voronoi_seeds() -> void:
	for cell in corner_cells.keys():
		cell = Vector2(cell)
		var voronoi : VoronoiTile = voronoi_tiles[cell]
		if voronoi.corner_type == CORNER_TYPES.UpRight:
			var away_direction = Vector2(-1, -1)
			displace_seed(voronoi, away_direction)
			_displace_voronoi_if_exists(cell + Vector2(-1, 0), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(0, -1), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(1, 0), Vector2(-1, 1))
			_displace_voronoi_if_exists(cell + Vector2(0, 1), Vector2(1, -1))
		elif voronoi.corner_type == CORNER_TYPES.UpLeft:
			var away_direction = Vector2(1, -1)
			displace_seed(voronoi, away_direction)
			_displace_voronoi_if_exists(cell + Vector2(1, 0), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(0, -1), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(-1, 0), Vector2(1, 1))
			_displace_voronoi_if_exists(cell + Vector2(0, 1), Vector2(-1, -1))
		elif voronoi.corner_type == CORNER_TYPES.DownRight:
			var away_direction = Vector2(-1, 1)
			displace_seed(voronoi, away_direction)
			_displace_voronoi_if_exists(cell + Vector2(-1, 0), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(0, 1), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(1, 0), Vector2(-1, -1))
			_displace_voronoi_if_exists(cell + Vector2(0, -1), Vector2(1, 1))
		elif voronoi.corner_type == CORNER_TYPES.DownLeft:
			var away_direction = Vector2(1, 1)
			displace_seed(voronoi, away_direction)
			_displace_voronoi_if_exists(cell + Vector2(1, 0), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(0, 1), away_direction, true)
			_displace_voronoi_if_exists(cell + Vector2(-1, 0), Vector2(1, -1))
			_displace_voronoi_if_exists(cell + Vector2(0, -1), Vector2(-1, 1))

func _displace_voronoi_if_exists(cell : Vector2, direction : Vector2, small_shift = false) -> void:
	if cell in voronoi_tiles:
		var voronoi = voronoi_tiles[cell] as VoronoiTile
		displace_seed(voronoi, direction, small_shift)

func displace_seed(voronoi_tile : VoronoiTile, direction : Vector2, small_shift = false) -> void:
	var displacement = direction * SMALL_SHIFT if small_shift else direction * LARGE_SHIFT
	displacement += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	var displacement_direction = displacement.normalized()
	displacement = displacement_direction * min(displacement.length(), 0.4)
	voronoi_tile.set_random_point(voronoi_tile.random_point + displacement)

# looks at the top, left, right, and bottom cell, then returns the voronoi tile
# if it exists, otherwise an empty array
func _get_four_immediate_neighbors(cell : Vector2) -> Array:
	var neighbors = []
	if cell + Vector2(0, 1) in voronoi_tiles:
		neighbors.append(voronoi_tiles[cell + Vector2(0, 1)])
	if cell + Vector2(1, 0) in voronoi_tiles:
		neighbors.append(voronoi_tiles[cell + Vector2(1, 0)])
	if cell + Vector2(0, -1) in voronoi_tiles:
		neighbors.append(voronoi_tiles[cell + Vector2(0, -1)])
	if cell + Vector2(-1, 0) in voronoi_tiles:
		neighbors.append(voronoi_tiles[cell + Vector2(-1, 0)])
	return neighbors

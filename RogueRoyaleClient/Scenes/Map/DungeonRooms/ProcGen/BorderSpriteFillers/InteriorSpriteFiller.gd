@tool
extends Node


@export var sprite_scene_paths : Array = [] : set = set_sprite_paths
@export var chance_to_fill_cell = 0.5 # (float, 0, 1)
@export var sprite_filler_paths: Array = [] : set = set_sprite_filler

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var half_tile_size = TILE_SIZE / 2
var fourth_tile_size = half_tile_size / 2
var surrounded_cell_id = Vector2(6, 1)
var tile_map : TileMap
var rng = RandomNumberGenerator.new()
var filler_z_index

@onready var sprite_container = $Sprites
var use_fillers = false

func _ready():
	if not sprite_filler_paths.is_empty():
		use_fillers = true
		filler_z_index = load(sprite_scene_paths[0]).instantiate().z_index - 1
		print(filler_z_index)
	rng.randomize()
	tile_map = get_parent() as TileMap
	_fill_interior()

func _fill_interior():
	var used_cells = tile_map.get_used_cells(0)
	var n_sprites = sprite_scene_paths.size()
	var n_fillers = sprite_filler_paths.size()
	for cell in used_cells:
		if tile_map.get_cell_autotile_coord(cell.x, cell.y) == surrounded_cell_id:
			if rng.randf() <= chance_to_fill_cell:
				var sprite = load(sprite_scene_paths[rng.randi() % n_sprites]).instantiate()
				position_sprite(sprite, cell)
				sprite_container.add_child(sprite)
			elif use_fillers:
				var sprite = load(sprite_filler_paths[randi() % n_fillers]).instantiate()
				position_sprite(sprite, cell)
				sprite.z_index = filler_z_index
				sprite_container.add_child(sprite)

func position_sprite(sprite : Sprite2D, cell : Vector2) -> void:
	sprite.position = tile_map.map_to_local(cell) + tile_map.position
	sprite.position.x += random_normalized_shift()
	sprite.position.y += random_normalized_shift()

func random_normalized_shift():
	var shift = rng.randfn() * half_tile_size - fourth_tile_size
	return shift

################################################################################
######### All of the setters
################################################################################
func set_sprite_paths(sprite_array : Array) -> void:
	sprite_scene_paths = sprite_array

func set_sprite_filler(sprite_array : Array) -> void:
	sprite_filler_paths = sprite_array

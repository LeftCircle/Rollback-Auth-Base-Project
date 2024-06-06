@tool
extends Node

@export var sprite_scene_paths : Array = [] : set = set_sprite_paths

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var half_tile_size = int(round(float(TILE_SIZE) / 2.0))
var fourth_tile_size = int(round(float(half_tile_size) / 2.0))
var surrounded_cell_id = Vector2(6, 1)
var to_shift_right = [
	Vector2(0, 2),
	Vector2(1, 1),
	Vector2(1, 2),
	Vector2(1, 3),
	Vector2(1, 4),
	Vector2(3, 0),
	Vector2(3, 2),
	Vector2(4, 0),
	Vector2(4, 1),
	Vector2(4, 2),
	Vector2(5, 2),
	Vector2(7, 0),
	Vector2(7, 1),
	Vector2(7, 2)
]
var right_shift = Vector2(int(TILE_SIZE / 2), 0)

var to_shift_down = [
	Vector2(5, 2),
	Vector2(0, 2)
]
var down_shift = Vector2(0, -int(TILE_SIZE / 2))

var sprite_nodes : Array
var border_tilemap : TileMap
var n_sprites : int
@onready var sprite_container : Node2D = $Sprites

func set_sprite_paths(sprite_paths : Array) -> void:
	sprite_scene_paths = sprite_paths

func _ready():
	border_tilemap = get_parent() as TileMap
	_add_sprites_to_scene()

func _add_sprites_to_scene():
	randomize()
	n_sprites = len(sprite_scene_paths)
	for cell in border_tilemap.get_used_cells(0):
		var cell_autotile_coord = border_tilemap.get_cell_autotile_coord(cell.x, cell.y)
		if cell_autotile_coord == surrounded_cell_id:
			continue
		var random_path = sprite_scene_paths[randi() % n_sprites]
		var random_scene = load(random_path)
		var sprite = random_scene.instantiate()
		sprite.position = border_tilemap.map_to_local(cell) + border_tilemap.position
		# This shift is a bit of a hack for tree sprites with the shape of 
		# the collision hitboxes
		if cell_autotile_coord in to_shift_right:
			sprite.position += right_shift
		if cell_autotile_coord in to_shift_down:
			sprite.position += down_shift
		sprite_container.add_child(sprite)

func _random_shift(sprite : Sprite2D) -> void:
	var random_x = randi() % half_tile_size - fourth_tile_size
	var random_y = randi() % half_tile_size - fourth_tile_size
	sprite.position += Vector2(random_x, random_y)

func _clear_nodes():
	$Sprites.queue_free()
	var new_sprite_container = Node2D.new()
	new_sprite_container.name = "Sprites"
	add_child(new_sprite_container, true)
	sprite_container = new_sprite_container




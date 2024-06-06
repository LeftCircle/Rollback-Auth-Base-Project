extends Node

@export var door_border_scene: PackedScene

var spring : GrammarSpring
var all_nodes : Array
var half_walkable_width = 5
var spring_line = LineSegment.new()
var spring_line_tiles = LineSegment.new()
var tile_map : TileMap

func init(g_spring : GrammarSpring, g_nodes : Array, tilemap : TileMap) -> void:
	spring = g_spring
	all_nodes = g_nodes
	tile_map = tilemap

func _ready():
	spring_line.init(spring.g_node_a.global_position, spring.g_node_b.global_position)
	spring_line_tiles.init(spring.g_node_a.pos_tiles, spring.g_node_b.pos_tiles)
	_spawn_doors_at_intersections()

func _spawn_doors_at_intersections() -> void:
	var a_intersection = _get_intersection_point(spring.g_node_a)
	var b_intersection = _get_intersection_point(spring.g_node_b)
	if a_intersection == null:
		_get_intersection_point(spring.g_node_a)
	if b_intersection == null:
		_get_intersection_point(spring.g_node_b)
	spring.door_a = door_border_scene.instantiate()
	spring.door_b = door_border_scene.instantiate()
	spring.g_node_a.room_scene.spawn_door(spring.door_a, a_intersection)
	spring.g_node_b.room_scene.spawn_door(spring.door_b, b_intersection)
	queue_free()

func _get_intersection_point(node):
	for line_segment in node.room_scene.room_rect2_extended.line_segments:
		var intersection = line_segment.get_intersection(spring_line)
		if not intersection == null:
			return intersection

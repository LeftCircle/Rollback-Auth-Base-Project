extends Sprite2D
class_name VoronoiTile

@export var randomize_point: bool = false
@export var color: Color
@export var random_point: Vector2 = Vector2(0.5, 0.5)

var corner_type : int = -1

func _ready():
	if randomize_point:
		random_point.x = randf()
		random_point.y = randf()
	material.set("shader_parameter/color", color)
	material.set("shader_parameter/random_point", random_point)
	for i in range(1, 10):
		set_neighbor_color(i, color)
	var debug = true

func init(pos : Vector2, new_color : Color, new_corner_type : int) -> void:
	color = new_color
	position = pos
	corner_type = new_corner_type

# This function exists for debugging purposes only
func set_corner_type(c_type : int) -> void:
	corner_type = c_type
	material.set("shader_parameter/is_corner_tyle", 1)

func set_random_point(new_pos : Vector2) -> void:
	random_point = new_pos
	material.set("shader_parameter/random_point", new_pos)
#	for i in range(10):
#		set_neighbor_random_point(i, random_point)

# Neighbor id is 1 for tl, 2 for t, 3 for tr, 4 for left, 5 for self, 6 for right, 7 for bl, 8 for b, 9 for br
func set_neighbor_random_point(neighbor_id : int, new_pos : Vector2) -> void:
	# Since the position is in tile space, we have to add the vector to the top left tile
	if neighbor_id == 1:
		material.set("shader_parameter/random_bottom_left", new_pos + Vector2(-1, -1))
	elif neighbor_id == 2:
		material.set("shader_parameter/random_bottom", new_pos + Vector2(0, -1))
	elif neighbor_id == 3:
		material.set("shader_parameter/random_bottom_right", new_pos + Vector2(1, -1))
	elif neighbor_id == 4:
		material.set("shader_parameter/random_left", new_pos + Vector2(-1, 0))
	elif neighbor_id == 5:
		pass
	elif neighbor_id == 6:
		material.set("shader_parameter/random_right", new_pos + Vector2(1, 0))
	elif neighbor_id == 7:
		material.set("shader_parameter/random_top_left", new_pos + Vector2(-1, 1))
	elif neighbor_id == 8:
		material.set("shader_parameter/random_top", new_pos + Vector2(0, 1))
	elif neighbor_id == 9:
		material.set("shader_parameter/random_top_right", new_pos + Vector2(1, 1))

func set_neighbor_color(neighbor_id : int, new_col : Color) -> void:
	# Since the position is in tile space, we have to add the vector to the top left tile
	if neighbor_id == 1:
		material.set("shader_parameter/bl_color", new_col)
	elif neighbor_id == 2:
		material.set("shader_parameter/b_color", new_col)
	elif neighbor_id == 3:
		material.set("shader_parameter/br_color", new_col)
	elif neighbor_id == 4:
		material.set("shader_parameter/l_color", new_col)
	elif neighbor_id == 5:
		pass
	elif neighbor_id == 6:
		material.set("shader_parameter/r_color", new_col)
	elif neighbor_id == 7:
		material.set("shader_parameter/tl_color", new_col)
	elif neighbor_id == 8:
		material.set("shader_parameter/t_color", new_col)
	elif neighbor_id == 9:
		material.set("shader_parameter/tr_color", new_col)

func get_neighbor_random_point(neighbor_id : int) -> Vector2:
	if neighbor_id == 1:
		return material.get("shader_parameter/random_bottom_left")
	elif neighbor_id == 2:
		return material.get("shader_parameter/random_bottom")
	elif neighbor_id == 3:
		return material.get("shader_parameter/random_bottom_right")
	elif neighbor_id == 4:
		return material.get("shader_parameter/random_left")
	elif neighbor_id == 5:
		return random_point
	elif neighbor_id == 6:
		return material.get("shader_parameter/random_right")
	elif neighbor_id == 7:
		return material.get("shader_parameter/random_top_left")
	elif neighbor_id == 8:
		return material.get("shader_parameter/random_top")
	elif neighbor_id == 9:
		return material.get("shader_parameter/random_top_right")
	else:
		assert(false) #,"Invalid neighbor id: " + str(neighbor_id))
		return Vector2.INF

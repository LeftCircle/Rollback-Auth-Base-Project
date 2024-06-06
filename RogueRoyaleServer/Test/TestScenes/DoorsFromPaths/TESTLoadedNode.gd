extends LoadedNode

#@export var room_scene_path # (String, FILE)

func _init():
	state = LOADED

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_pos_to_grid_and_state_to_saved()
	room_scene = load(room_scene_path).instantiate()
	set_node_size(room_scene.border_rect2.size)
	var border_shift = Vector2.ONE * room_scene.border_size_tiles * ProjectSettings.get_setting("global/TILE_SIZE")
	room_scene.set_position_snapped(node_info.node_rect2.position + border_shift)
	room_scene.build_room_rect2aabb()
	get_parent().call_deferred("add_child", room_scene)
	room_scene.build_room_rect2aabb()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

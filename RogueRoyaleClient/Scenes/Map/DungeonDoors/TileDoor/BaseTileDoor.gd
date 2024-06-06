#tool
extends C_BaseDoor
class_name BaseTileDoor

@export var is_horizontal: bool = true
@export var n_tiles = 3 # (int, 0, 10)

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var connected_doors = []


@onready var door_pillar = $TestTopDoor

func _netcode_init():
	netcode.init(self, "TDR", TileDoorData.new(), TileDoorCompresser.new())

func _ready():
	add_to_group("Doors")

func _add_extra_blocks():
	var offset = _get_offset()
	for i in range(n_tiles - 1):
		var new_door = door_pillar.duplicate()
		new_door.position += offset * (i + 1)
		add_child(new_door)

func _get_offset():
	if is_horizontal:
		return Vector2(TILE_SIZE, 0)
	else:
		return Vector2(0, TILE_SIZE)

func close():
	is_open = false
	for door in get_children():
		door.close()

func open():
	is_open = true
	for door in get_children():
		door.open()

func get_center():
	var offset = _get_offset()
	var center = offset * n_tiles / 2.0
	return global_position + center
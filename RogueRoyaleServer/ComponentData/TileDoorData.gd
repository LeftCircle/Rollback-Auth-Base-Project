extends DoorData
class_name TileDoorData

var n_tiles : int
var is_horizontal : bool

func set_data_with_obj(other_obj):
	n_tiles = other_obj.n_tiles
	is_horizontal = other_obj.is_horizontal
	is_open = other_obj.is_open
	global_position = other_obj.global_position
	connected_doors = other_obj.connected_doors.duplicate(true)

func set_obj_with_data(other_obj):
	other_obj.n_tiles = n_tiles
	other_obj.is_horizontal = is_horizontal
	other_obj.is_open = is_open
	other_obj.global_position = global_position
	other_obj.connected_doors = connected_doors.duplicate(true)

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(n_tiles, other_obj.n_tiles) == true) and
	(ModularDataComparer.compare_values(is_horizontal, other_obj.is_horizontal) == true) and
	(ModularDataComparer.compare_values(is_open, other_obj.is_open) == true) and
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true)
	)

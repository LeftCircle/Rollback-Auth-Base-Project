@tool
extends TileMap

@export var tile_map_resource: Resource : set = set_resource_to_load

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var cell_size = 64 # Not sure where cell size used to come from - maybe from TileMap in 3.5?

var tile_size_multiplier

func _ready():
	tile_map_resource.connect("resource_updated",Callable(self,"_on_resource_updated"))
	place_tiles_with_resource()

func _on_resource_updated():
	place_tiles_with_resource()

func place_tiles_with_resource():
	self.clear()
	tile_size_multiplier = int(TILE_SIZE / cell_size.x)
	var room_outline = get_room_outline_from_tree() as RoomOutline
	tile_map_resource.init(self, room_outline, tile_size_multiplier)
	tile_map_resource.place_tiles()

func get_room_outline_from_tree():
	var max_searches = 20
	var parent = get_parent()
	for _i in range(max_searches):
		if parent.get_class() == "RoomOutline":
			return parent
		else:
			parent = parent.get_parent()
	assert(false) #,"failed to find RoomOutline")

################################################################################
######## SETTERS
################################################################################
func set_resource_to_load(resource : Resource) -> void:
	tile_map_resource = resource.duplicate(true)


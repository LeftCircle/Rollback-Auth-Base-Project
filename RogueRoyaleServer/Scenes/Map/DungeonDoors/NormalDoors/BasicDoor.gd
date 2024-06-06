extends TileMap

var door_top_id = 1#tile_set.find_tile_by_name("door_top")

# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	z_index = 999
	assert(get_parent().get_class() == "DoorBorder") #,"The parent of this door MUST be a DoorBorder class")
	#_draw_door()

func draw_door():
	var door_side = get_parent().door_side
	var width = get_parent().door_width
	# Draw the door on the bottom for the top
	# right for the left, left for the right, and top for the bottom
	if door_side == "top":
		# Door is drawn at rect2.position, so draw at origin
		for i in range(width):
			set_cell(0, Vector2i(i, 0), door_top_id, Vector2i.ZERO)
	elif door_side == "bottom":
		# draw at rect2.end
		for i in range(width):
			set_cell(0, Vector2i(i, 0), door_top_id, Vector2i.ZERO)
	elif door_side == "left":
		for i in range(width):
			set_cell(0, Vector2i(0, i), door_top_id, Vector2i.ZERO)
	else:
		for i in range(width):
			set_cell(0, Vector2i(0, i), door_top_id, Vector2i.ZERO)

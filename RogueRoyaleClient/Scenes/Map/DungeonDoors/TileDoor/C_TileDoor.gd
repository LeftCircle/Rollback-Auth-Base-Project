extends BaseTileDoor
class_name C_TileDoor

func _ready():
	super._ready()
	door_pillar.set_is_open(is_open)
	_on_first_update()

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	var state_data = netcode.decompress(frame, bit_packer) as TileDoorData
	#if not first_update:
	#	_on_first_update(state_data)
	#	first_update = true
	receive_open_status(state_data.is_open)
	state_data.set_obj_with_data(self)

func _on_first_update():
	#n_tiles = state_data.n_tiles
	#global_position = state_data.global_position
	#is_horizontal = state_data.is_horizontal
	_add_extra_blocks()

func receive_open_status(open_status : bool) -> void:
	if open_status == true and not is_open:
		open()
		#print("OPEN")
	elif open_status == false and is_open:
		close()
		#print("CLOSE")
	else:
		pass
		#print("OTHER")

func get_connected_doors():
	var door_scenes = []
	var n_loops = connected_doors.size() / 2
	for i in range(0, n_loops, 2):
		var door_class_id = connected_doors[i]
		var door_instance_id = connected_doors[i + 1]
		if ObjectsInScene.has(door_class_id, door_instance_id):
			var door_scene = ObjectsInScene.find_and_return_object(door_class_id, door_instance_id)
			door_scenes.append(door_scene)
		else:
			assert(false) #,"we need some failsafe if the door isn't loaded in yet")
	return door_scenes

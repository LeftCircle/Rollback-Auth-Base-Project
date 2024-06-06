extends Resource
class_name BaseSyncedResource

enum RES_TYPE {SFX, VFX}

@export_file var res_path # (String, FILE)
@export var resource_id: String : set = set_resource_id
@export var type: RES_TYPE

# Set via the ObjectCrationRegistry (done this way for fast client/server iterations)
var res

func _init_resource():
	# Override this to set the resource_id and anything else
	pass

func set_resource_id(new_id : String):
	resource_id = new_id.left(3)

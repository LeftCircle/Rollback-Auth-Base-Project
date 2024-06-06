extends NetcodeBase
class_name FrameLatencyTrackerNetcode

var is_from_server = true

func _init():
	class_instance_id = 0

func _on_ready():
	# All class instance id's of this will be 0, since we are sending only one
	# of these to each player
	class_instance_id = 0


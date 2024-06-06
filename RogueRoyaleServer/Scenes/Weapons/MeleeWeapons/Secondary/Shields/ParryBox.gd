extends Area2D
class_name ParryBox

var entity
#var history = PastBoxHistory.new()

@onready var shape = $ParryBoxShape

func _ready():
	add_to_group("ParryBox")
	add_to_group("Rollback")

#func _physics_process(delta):
#	# We can get off by one errors here. When enabling/disabling the hurtbox, we must take care to
#	# properly enable/disable past hurtboxes so that it occurs on the same frame
#	history.add_data(CommandFrame.frame, shape)
#
#func get_history_for_frame(frame : int):
#	return history.retrieve_data(frame)

#func _physics_process(delta):
#	var parry_box = get_child(0)
#	if parry_box.disabled == false:
#		print("Parry box is active")

# Past hurtboxes should extend something else since they do not need a history
# or we add histories as a component to hurtboxes?
extends Area2D
class_name PastHurtbox

#signal hit_by(hitbox)

var base_hurtbox
var entity

func _init():
	#set_physics_process(false)
	pass

func _ready():
#	assert(entity_is_set == true) #,"entity must be set by hand for past hurtbox")
	add_to_group("Hurtbox")
	pass

func duplicate_hurtbox_shape(old_hurtbox) -> void:
	var shape = old_hurtbox.get_hurtbox_shape()
	var new_shape = shape.duplicate(true)
	#new_shape.set_deferred("disabled", true)
	add_child(new_shape)

func enable_hurtbox():
	get_child(0).set_deferred("disabled", false)

func is_disabled() -> bool:
	return get_child(0).is_disabled()

func disable_hurtbox():
	get_child(0).set_deferred("disabled", true)

#func _on_PastHurtbox_area_entered(area):
#	Logging.log_line("Past hurtbox area entered on frame " + str(CommandFrame.frame))
#	print("Past hurtbox area entered on frame " + str(CommandFrame.frame))
func _exit_tree():
	Logging.log_line("Hurtbox is exiting tree on frame " + str(CommandFrame.frame))


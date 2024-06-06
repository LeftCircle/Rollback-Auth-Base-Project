extends Knockback
class_name S_Knockback

func _ready() -> void:
	super._ready()
	Logging.log_line("Knockback %s ready on frame %s" % [self.to_string(), CommandFrame.frame])

#func execute(frame : int, entity) -> bool:
#	var knockback_occuring = super.execute(frame, entity)
#	# The netcode data is already set in the parent execute function
#	#print("Sending knockback netcode ", netcode)
#	netcode.send_to_clients()
#	return knockback_occuring
#
#func set_state_data():
#	pass

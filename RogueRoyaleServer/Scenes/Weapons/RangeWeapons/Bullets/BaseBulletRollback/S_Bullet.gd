extends Bullet
class_name S_Bullet

#func _ready():
#	netcode.state_data.set_data_with_obj(self)
#	netcode.state_data.to_despawn = false
#
#func send_data(despawn : bool = false) -> void:
#	netcode.state_data.set_data_with_obj(self)
#	netcode.state_data.to_despawn = despawn
#	netcode.send_data()

func hit_by_melee(event : CombatEvent):
	event.entity_received_event.on_projectile_hit_by_melee(event)
	call_deferred("queue_free()")

func _exit_tree():
	velocity = Vector2.ZERO
	global_position = Vector2.ZERO
	#send_data(true)

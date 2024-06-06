extends NetcodeBase
class_name LocalBulletNetcode

# The local bullet is only sent to the local player.
var player_id = null
var player_id_to_send_to = null

func _init():
	# Bullets don't send data every frame
	#set_physics_process(false)
	pass

func _on_ready():
	player_id = entity.entity.player_id
	super._on_ready()
	send_data()
	print("sending data for bullet ", class_instance_id)

func send_data():
#	#var compressed_data = compressed_class_instance.duplicate(true)
#	print("Compressed class isntance = ", compressed_class_instance)
#	compressed_data += state_compresser.compress(state_data)
#	WorldState.add_compressed_data_to_player_id(player_id_to_send_to, class_id, compressed_data)
	pass

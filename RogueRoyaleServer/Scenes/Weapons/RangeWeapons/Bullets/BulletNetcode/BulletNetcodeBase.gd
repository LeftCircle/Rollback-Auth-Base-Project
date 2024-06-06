extends NetcodeBase
class_name BulletNetcodeBase
# The entity for this class is the bullet itself

###############################################################################
#
#                          READ ME!!!!
# Bullets are funky. Bullets spawned by players don't actually require any netcode
# since they are handled by the guns, which contain all of the info needed for
# rollback. But the netcode component is still needed for locating the bullet
# scene (maybe???).
# It might be needed in the future in case certain weapons have dynamic bullets,
# Then players need to know what bullets other players are firing.
#
# Netcode is 100% required for mob bullets though
################################################################################

const DO_NOT_SEND = -1

var is_from_player = false
var player_id = null
var player_id_to_send_to = DO_NOT_SEND

func _init():
	# Bullets don't send data every frame
	#set_physics_process(false)
	pass

#func _on_ready():
#	is_from_player = entity.entity.is_in_group("Players")
#	if is_from_player:
#		player_id = entity.entity.player_id
#	super._on_ready()
#	#send_data()
#	#print("sending data for bullet ", class_instance_id)
#
#func send_data():
##	assert(false) #," needs to be rewritten for mobs.")
##	if player_id_to_send_to == DO_NOT_SEND:
##		return
##	var compressed_data = compressed_class_instance.duplicate(true)
##	print("Compressed class isntance = ", compressed_class_instance)
##	compressed_data += state_compresser.compress(state_data)
##	if is_from_player:
##		WorldState.add_compressed_data_to_player_id(player_id_to_send_to, class_id, compressed_data)
##	else:
##		WorldState.add_compressed_data(class_id, compressed_data)
#	pass

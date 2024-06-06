extends Node
# Local Animation System

# The local animation system is responsible for advancing all rollback animation players
# It also resets all local animations back to their previous frame on rollback

var step_time = CommandFrame.frame_length_sec


func _ready() -> void:
	RollbackSystem.rollback_frame.connect(_on_rollback)

func execute(frame : int) -> void:
	#var rollback_animation_players = get_tree().get_nodes_in_group("RollbackAnimationPlayers")
	#for rollback_player in rollback_animation_players:
		#rollback_player.rollback_advance(frame, step_time)
	#var local_trees = get_tree().get_nodes_in_group("LocalRollbackAnimationTree")
	#for rollback_tree in local_trees:
		#rollback_tree.execute(frame)
	pass

func _on_rollback(frame : int) -> void:
	var rollback_animation_players = get_tree().get_nodes_in_group("RollbackAnimationPlayers")
	for rollback_player in rollback_animation_players:
		rollback_player._on_rollback(frame)


#var rollback_animation_players : Array[RollbackAnimationPlayer] = []
#var index_to_entity = {}
#var entity_to_index = {}
#func register(entity, animation_player : RollbackAnimationPlayer) -> void:
#	rollback_animation_players.append(animation_player)
#
#func unregister_animation_player(id : String, instance : int, animation_player : RollbackAnimationPlayer) -> void:
#	# Take the last animation player and place it in the position of this animation player
#	var index_of_entity : int = index_to_entity[id][instance]
#	var last_index : int = rollback_animation_players.size() - 1
#	var entity_of_last_element = index_to_entity[last_index]
#
#	var last_anim_player : RollbackAnimationPlayer = rollback_animation_players.pop_back()
#	rollback_animation_players[index_of_entity] = last_anim_player
#
#	entity_to_index[entity_of_last_element] = index_of_entity
#	index_to_entity[index_of_entity] = entity_of_last_element
#
#	entity_to_index.erase(entity)
#	index_to_entity.erase(last_index)

#func has_entity(id : String, instance : int) -> bool:
#	if entity_to_index.has(id):
#		return entity_to_index[id].has(instance)
#	else:
#		return false

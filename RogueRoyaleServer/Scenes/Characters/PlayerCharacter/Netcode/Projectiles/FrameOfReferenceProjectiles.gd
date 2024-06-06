extends Area2D
class_name FrameOfReferenceProjectileSpawner

var close_players = {}
var entity
var original_bullet
var shooter_frames_ahead : int

@onready var bullet_container = $BulletContainer

func init(new_entity) -> void:
	entity = new_entity

func _on_bullet_fired(bullet):
	original_bullet = bullet
	var frame_of_ref_bullet = _instance_new_bullet(bullet)
	_send_to_other_clients(frame_of_ref_bullet)

func _instance_new_bullet(bullet):
	shooter_frames_ahead = ClientWorldStateMap.get_n_frames_ahead(entity.player_id)
	# Start by just spawning a new projectile
	var new_bullet = ObjectCreationRegistry.duplicate_object_with_netcode_data(bullet)
	new_bullet.global_position = bullet.global_position
	new_bullet.weapon_data = bullet.weapon_data
	new_bullet.entity = bullet.entity
	for _i in range(shooter_frames_ahead):
		new_bullet.advance(CommandFrame.frame_length_sec)
	return new_bullet

func _send_to_other_clients(new_bullet):
	for player_char in close_players.keys():
		var player_bullet = ObjectCreationRegistry.duplicate_object_with_netcode_data(new_bullet)
		#_predict_bullet_position(player_char, player_bullet)
		_set_extra_bullet_data(player_bullet, player_char, new_bullet)
		_frame_of_reference_shift(player_bullet, player_char)
		_set_new_combat_event_parser(player_bullet, player_char)
		player_bullet.scale = Vector2(2.0, 2.0)
		bullet_container.add_child(player_bullet)


#func _predict_bullet_position(player_char : ServerPlayerCharacter, player_bullet) -> void:
#	#var pred_frames = ClientWorldStateMap.get_n_predicted_frames(player_char.player_id)
#	var pred_frames = shooter_predicted_frames
#	for i in range(pred_frames):
#		player_bullet.advance(CommandFrame.frame_length_sec)

func _set_extra_bullet_data(player_bullet, player_char : ServerPlayerCharacter, new_bullet) -> void:
	player_bullet.global_position = new_bullet.global_position
	player_bullet.netcode.player_id_to_send_to = player_char.player_id
	player_bullet.weapon_data = new_bullet.weapon_data
	player_bullet.entity = new_bullet.entity

func _set_new_combat_event_parser(player_bullet, player_char : ServerPlayerCharacter) -> void:
	var new_combat_event_parser = FrameOfRefProjectileCombatEventParser.new()
	new_combat_event_parser.init(original_bullet, entity, player_char)
	player_bullet.combat_event_parser = new_combat_event_parser
	original_bullet.frame_of_ref_projectiles.append(player_bullet)

func _frame_of_reference_shift(player_bullet, other_player : ServerPlayerCharacter) -> void:
	# Get the vector from the lag comp hitbox to the player character
	var client_predicted_frames = ClientWorldStateMap.get_n_predicted_frames(other_player.player_id)
	print("Client predicted frames = ", client_predicted_frames)
	for i in range(client_predicted_frames):
		player_bullet.advance(CommandFrame.frame_length_sec)
	# Now find the vector from the past hitbox to the bullet. Send the player
	# character this data and mark the bullet as FOR
	var past_hurtbox = other_player.lag_comp_hurtbox_spawner.get_past_hurtbox_for(entity)
	var hbox_to_bullet = player_bullet.position - past_hurtbox.global_position
	player_bullet.hbox_to_spawn = hbox_to_bullet
	print("hbox to bullet = ", hbox_to_bullet)

func _on_FrameOfReferenceProjectileSpawner_body_entered(body):
	if body.is_in_group("Players") and body != entity:
		close_players[body] = null

func _on_FrameOfReferenceProjectileSpawner_body_exited(body):
	if close_players.has(body):
		close_players.erase(body)

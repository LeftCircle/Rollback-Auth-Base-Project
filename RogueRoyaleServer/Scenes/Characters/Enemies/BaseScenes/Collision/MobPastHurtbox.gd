extends PastHurtbox
class_name MobPastHurtbox

var player_that_can_hit : ServerPlayerCharacter

func init_mob_past_hurtbox(player_char, mob, hurtbox_to_dup : BaseHurtbox) -> void:
	duplicate_hurtbox_shape(hurtbox_to_dup)
	player_that_can_hit = player_char
	entity = mob
	base_hurtbox = hurtbox_to_dup
	#set_physics_process(true)

func _ready():
	Logging.log_line("Past hurtbox readied on frame " + str(CommandFrame.frame))
	set_collision_layer_value(3, true)
	set_collision_layer_value(0, false)
	set_collision_mask_value(0, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	connect("area_entered",Callable(self,"_on_PastHurtbox_area_entered"))
	assert(entity != null)
	#connect("hit_by",Callable(entity,"_on_hurtbox_hit"))

func _physics_process(delta):
	if not is_instance_valid(player_that_can_hit):
		queue_free()
	else:
		var client_frame = ClientWorldStateMap.get_world_state_frame(player_that_can_hit.player_id, CommandFrame.frame)
		Logging.log_line("Trying to get buffered history for frame " + str(client_frame))
		var past_pos = entity.position_history.retrieve(client_frame)
		if past_pos == PositionHistory.INVALID_POS:
			disable_hurtbox()
		else:
			if is_disabled():
				enable_hurtbox()
			global_position = past_pos
			Logging.log_line("Setting past hurtbox position to " + str(past_pos) + " for client frame " + str(client_frame))

#func _on_PastHurtbox_area_entered(area):
#	if area.is_in_group("Hitbox"):
#		if area.entity == player_that_can_hit:
#			emit_signal("hit_by", area)

extends PastHurtbox
class_name PlayerPastHurtbox

signal past_hurtbox_hit(entity, weapond_data, damage)

var player_that_can_hit : ServerPlayerCharacter

func init_player_past_hurtbox(player_entity, player_that_hits, hurtbox_to_dup : BaseHurtbox) -> void:
	duplicate_hurtbox_shape(hurtbox_to_dup)
	entity = player_entity
	player_that_can_hit = player_that_hits
	base_hurtbox = hurtbox_to_dup

func _ready():
	Logging.log_line("Past hurtbox readied on frame " + str(CommandFrame.frame))
	set_collision_layer_value(2, true)
	set_collision_layer_value(0, false)
	set_collision_mask_value(0, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)
	assert(entity != null)
	connect("past_hurtbox_hit",Callable(entity,"_on_hurtbox_hit_by"))

func _physics_process(delta):
	if not is_instance_valid(player_that_can_hit) or not is_instance_valid(base_hurtbox):
		queue_free()
	else:
		var client_frame = ClientWorldStateMap.get_world_state_frame(player_that_can_hit.player_id)
		Logging.log_line("Trying to get buffered history for frame " + str(client_frame))
		var past_data = base_hurtbox.get_history_for_frame(client_frame)
		if past_data != PastBoxHistory.NO_DATA_FOR_FRAME:
			global_position = past_data.global_position
		else:
			Logging.log_line("No past hurtbox data for client frame " + str(client_frame))
		#else:
		#	print("Invalid pos")
		set_if_disabled()
	Logging.log_line(str(entity.player_id) + " lag comp position = " + str(global_position))

# Client hitboxes are enabled/disabled immediately to respect the player getting the dodge off first
func set_if_disabled():
	if base_hurtbox.collision_shape.is_disabled() == true:
		disable_hurtbox()
	else:
		enable_hurtbox()

func on_hurtbox_hit_by(entity, weapon_data : WeaponData, damage : int) -> void:
	if entity == player_that_can_hit:
		print("Past hurtbox hit on frame ", CommandFrame.frame)
		emit_signal("past_hurtbox_hit", entity, weapon_data, damage)

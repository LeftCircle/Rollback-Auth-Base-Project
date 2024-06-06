#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends AnimationTree
class_name BaseWeaponRollbackAnimationTree

var action_to_end_result = {
	"attack_primary" : WeaponData.ATTACK_END.COMBO_PRIMARY,
	"attack_secondary" : WeaponData.ATTACK_END.COMBO_SECONDARY,
	"fire_ranged_weapon" : WeaponData.ATTACK_END.COMBO_RANGED,
	"special_1" : WeaponData.ATTACK_END.SPECIAL_1,
	"special_2" : WeaponData.ATTACK_END.SPECIAL_2,
	"dash" : WeaponData.ATTACK_END.DASH,
	"health_flask" : WeaponData.ATTACK_END.HEAL,
	"dodge" : WeaponData.ATTACK_END.DODGE
}

var finisher_action_to_end_result = {
	"attack_primary" : WeaponData.ATTACK_END.PRIMARY,
	"attack_secondary" : WeaponData.ATTACK_END.SECONDARY,
	"fire_ranged_weapon" : WeaponData.ATTACK_END.RANGED,
	"special_1" : WeaponData.ATTACK_END.SPECIAL_1,
	"special_2" : WeaponData.ATTACK_END.SPECIAL_2,
	"dash" : WeaponData.ATTACK_END.DASH,
	"health_flask" : WeaponData.ATTACK_END.HEAL,
	"dodge" : WeaponData.ATTACK_END.DODGE
}
var attack_sequence_to_animation = {}

var weapon
var weapon_data
var input_queue : InputQueueComponent

var step_time = CommandFrame.frame_length_sec
#var history = RollbackAnimationTreeHistory.new()

@onready var state_machine_playback = get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var animation_player = get_node(anim_player)

func _ready() -> void:
	set_process_callback(AnimationTree.ANIMATION_PROCESS_MANUAL)

func init(new_weapon) -> void:
	weapon = new_weapon
	weapon_data = new_weapon.weapon_data
	input_queue = weapon.entity.input_queue

func advance_state(frame : int) -> void:
	#############################
	var debug = true
	var current_node = state_machine_playback.get_current_node()
	var is_playing = state_machine_playback.is_playing()
	# I bet the travel path involves reset, and so reset is clearing the angle
	# Although we should have already stepped through reset to get to the current node?
	# Unless starting it also causes a reset?
	var path = state_machine_playback.get_travel_path()
	#############################
	rollback_advance(frame)
	var current_animation_position = state_machine_playback.get_current_play_position()
	weapon_data.animation_frame = int(round(current_animation_position / CommandFrame.frame_length_sec))

func rollback_advance(frame : int, time : float = step_time) -> void:
	super.advance(time)

func check_for_attack_end():
	var state_machine_len = state_machine_playback.get_current_length()
	var state_machine_pos = state_machine_playback.get_current_play_position()
	return !weapon_data.is_looping and is_equal_approx(state_machine_len, state_machine_pos)

func reset_data(frame : int, soft_reset = false) -> void:
	if soft_reset:
		weapon_data.soft_reset()
	else:
		weapon_data.reset()
		var input_queue_component = weapon.entity.get_component("InputQueue")
		input_queue_component.reset(frame)

func reset_state_machine():
	if state_machine_playback.is_playing():
		_start_animation("RESET")
		set("parameters/Seek/seek_position", 0.0)

func _on_animation_start() -> void:
	#reset_advance_conditions()
	weapon_data.animation_frame = 0

func _start_animation(node_name : String, seek_position : float = 0.0) -> void:
	weapon_data.animation_frame = int(round(seek_position / step_time))
	state_machine_playback.stop()
	state_machine_playback.start("RESET")
	super.advance(step_time)
	state_machine_playback.start(node_name)
	super.advance(0)
	super.advance(seek_position)

func _set_attack_direction(weapon_data : WeaponData, direction : Vector2) -> void:
	weapon_data.attack_direction = direction
	weapon.set_attack_direction(direction)
	_set_blend_positions(weapon_data)

func _set_blend_positions(weapon_data : WeaponData) -> void:
	var animation = attack_sequence_to_animation[weapon_data.attack_sequence]
	set("parameters/" + animation + "/blend_position", weapon_data.attack_direction)

func _set_end_animation_result(end_case = WeaponData.ATTACK_END.END, is_finisher = false) -> void:
	if !input_queue.queued_input_is(weapon_data.input_to_check) and input_queue.is_input_queued():
		_end_case_with_input(is_finisher)
	else:
		weapon_data.attack_end = end_case

func _end_case_with_input(is_finisher : bool) -> void:
	# Send the queued input to the respective weapon for processing
	if not is_finisher:
		weapon_data.attack_end = action_to_end_result[input_queue.int_to_string[input_queue.data_container.input]]
	else:
		weapon_data.attack_end = finisher_action_to_end_result[input_queue.int_to_string[input_queue.data_container.input]]

func end_execution(frame : int) -> void:
	reset_state_machine()
	reset_data(frame, true)

func _init_sequence_to_animation_map():
	attack_sequence_to_animation[0] = "Anticipation"
	for i in range(1, weapon_data.max_sequence):
		attack_sequence_to_animation[i] = "Attack_" + str(i)
	attack_sequence_to_animation[weapon_data.max_sequence] = "Finisher"
	attack_sequence_to_animation[weapon_data.max_sequence + 1] = "Charging"
	attack_sequence_to_animation[weapon_data.max_sequence + 2] = "ChargeAttack"
	attack_sequence_to_animation[weapon_data.max_sequence + 3] = "Combo"

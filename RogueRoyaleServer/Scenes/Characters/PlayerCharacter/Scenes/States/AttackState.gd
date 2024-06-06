extends BasePlayerState
class_name PlayerAttackState

enum WEAPON_SLOT{PRIMARY, SECONDARY}
@export var weapon_slot: WEAPON_SLOT = WEAPON_SLOT.PRIMARY

var weapon
var check_state
var input_queue_copy_data = InputQueueData.new()

func _ready():
	if weapon_slot == WEAPON_SLOT.PRIMARY:
		check_state = PlayerStateManager.ATTACK_PRIMARY
		state_enum = PlayerStateManager.ATTACK_PRIMARY
	else:
		check_state = PlayerStateManager.ATTACK_SECONDARY
		state_enum = PlayerStateManager.ATTACK_SECONDARY
	set_physics_process(false)

func init(new_entity) -> void:
	entity = new_entity

func physics_process(frame : int, input_actions : InputActions, args = {}):
	var new_state = check_for_state_change(input_actions)
	if new_state != check_state and new_state != PlayerStateManager.NULL:
		state_machine.switch_state(frame, new_state, input_actions, args)
		return
	var weapon_result = weapon.execute(frame, input_actions)
	_handle_weapon_result(frame, weapon_result, input_actions)
	# if weapon_result != WeaponData.ATTACK_END.NONE:
	# 	_on_execution_finished(frame)

# Doing this with an if check instead of signals for simplicity
func _handle_weapon_result(frame : int, weapon_result : int, input_actions : InputActions):
	if weapon_result == WeaponData.ATTACK_END.NONE:
		return
	elif weapon_result == WeaponData.ATTACK_END.END:
		_on_execution_finished(frame)
	elif weapon_result == WeaponData.ATTACK_END.COMBO_PRIMARY or weapon_result == WeaponData.ATTACK_END.COMBO_SECONDARY:
		_on_melee_weapon_combo(frame, input_actions)
	elif weapon_result == WeaponData.ATTACK_END.PRIMARY or weapon_result == WeaponData.ATTACK_END.SECONDARY:
		_on_melee_switch(frame, input_actions)
	else:
		assert(false) #,"Not yet sure what the logic should be for other cases yet")

func _on_melee_weapon_combo(frame : int, input_actions : InputActions):
	Logging.log_line("Combo is beginning!!")
	var state = PlayerStateManager.ATTACK_PRIMARY if weapon_slot == WEAPON_SLOT.SECONDARY else PlayerStateManager.ATTACK_SECONDARY
	var combo_weapon = entity.primary_weapon if weapon_slot == WEAPON_SLOT.SECONDARY else entity.secondary_weapon
	var entity_input_queue_data = entity.get_input_queue_data()
	input_queue_copy_data.set_data_with_obj(entity_input_queue_data)
	state_machine.set_current_state(frame, state)
	entity_input_queue_data.set_data_with_obj(input_queue_copy_data)
	combo_weapon.start_anticipation_for_combo(frame, input_actions)
	combo_weapon.execute(frame, input_actions)

func _on_melee_switch(frame : int, input_actions : InputActions):
	var state = PlayerStateManager.ATTACK_PRIMARY if weapon_slot == WEAPON_SLOT.SECONDARY else PlayerStateManager.ATTACK_SECONDARY
	var entity_input_queue_data = entity.get_input_queue_data()
	input_queue_copy_data.set_data_with_obj(entity_input_queue_data)
	state_machine.set_current_state(frame, state)
	entity_input_queue_data.set_data_with_obj(input_queue_copy_data)
	var other_weapon = entity.primary_weapon if weapon_slot == WEAPON_SLOT.SECONDARY else entity.secondary_weapon
	other_weapon.start_anticipation(frame, input_actions)
	other_weapon.execute(frame, input_actions)

func exit(frame : int):
	weapon.end_execution(frame)

func set_primary_weapon(with_weapon):
	if with_weapon != weapon:
		weapon = with_weapon
		weapon.connect("execution_finished",Callable(self,"_on_execution_finished"))

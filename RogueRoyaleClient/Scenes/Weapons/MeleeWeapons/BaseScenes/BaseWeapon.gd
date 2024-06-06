extends C_MeleeNetcodeBase
class_name BaseWeapon

# The base weapon class should match on the client and the server

signal execution_finished(frame)

var stamina : BaseStamina
var is_primary = false
var move : Move
var end_execution_frame

@onready var weapon_data = $WeaponData
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $RollbackAnimationTree

func _netcode_init():
	netcode.init(self, "MLW", MeleeWeaponData.new(), MeleeWeaponCompresser.new())

func init(new_entity, new_stamina : BaseStamina, new_move : Move, _is_primary : bool) -> void:
	set_entity(new_entity)
	stamina = new_stamina
	move = new_move
	process_priority = entity.process_priority + 1
	is_primary = _is_primary
	_weapon_data_init(new_entity)
	animation_tree.init(self)

func _weapon_data_init(new_entity):
	weapon_data.input_to_check = "attack_primary" if is_primary else "attack_secondary"
	weapon_data.entity = new_entity

func _ready():
	super._ready()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_MANUAL
	add_to_group("Weapon")
	self.connect("area_entered",Callable(self,"_on_area_entered"))

func execute(_frame : int, _input_actions : InputActions):
	assert(false) #,"execution not yet implemented for " + self.to_string())

func end_execution(frame : int):
	# TO DO -> this animation tree end execution should probably either be in
	# all end executions for weapons, or attached via a signal
	animation_tree.end_execution(frame)
	weapon_data.is_executing = false
	weapon_data.is_in_parry = false
	end_execution_frame = frame

func physics_process(frame : int, input_actions : InputActions):
	if not weapon_data.is_executing:
		set_attack_direction(input_actions.get_looking_vector())

func set_entity(new_entity) -> void:
	entity = new_entity

func set_attack_direction(direction : Vector2):
	rotation = direction.angle()

func start_anticipation(frame : int, input_actions : InputActions) -> void:
	animation_tree.advance_to_anticipation(frame, input_actions, 0)

func start_anticipation_for_combo(frame : int, input_actions : InputActions) -> void:
	animation_tree.advance_to_anticipation(frame, input_actions, 0, true)

func get_combo_sequence():
	return weapon_data.get_combo_sequence()

func get_attack_animation() -> String:
	return animation_tree.attack_sequence_to_animation[weapon_data.attack_sequence]

func get_current_animation_tree_node() -> String:
	return animation_tree.state_machine_playback.get_current_node()

func activate_hitbox() -> void:
	$Hitbox.disabled = false

func _on_area_entered(area):
	combat_event_parser.on_area_entered(area, weapon_data)

func on_successful_hit(hit_entity) -> void:
	pass

func on_parry(_frame : int):
	weapon_data.is_in_parry = true
	Logging.log_line("Parry predicted on frame " + str(CommandFrame.frame))

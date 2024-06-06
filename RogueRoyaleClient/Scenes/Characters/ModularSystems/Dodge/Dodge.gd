extends ClientNetcodeModule
class_name Dodge

signal finished(frame)

@export var move_module_path: NodePath
@export var animation_path: NodePath
@export var stamina_path: NodePath
@export var stamina_cost: int = 2

var is_executing = false : set = set_is_executing
var animation_frame : int = 0

@onready var move = get_node(move_module_path)# as Move
@onready var animations = get_node(animation_path) as AnimationPlayer
@onready var stamina = get_node(stamina_path) as BaseStamina

func set_is_executing(with_val):
	is_executing = with_val

func _netcode_init():
	netcode.init(self, "DGE", DodgeData.new(), DodgeCompresser.new())

func execute(frame : int, entity, input_actions : InputActions) -> bool:
	if not is_executing:
		if not stamina.execute(frame, stamina_cost):
			animation_frame = 0
			return false
		else:
			is_executing = true
	var input_vector = input_actions.get_input_vector()
	animations.play_rollback("Roll")
	animations.advance(CommandFrame.frame_length_sec)
	move.execute(frame, entity, input_vector)
	animation_frame += 1
	return true

func _on_animation_finished(anim : String):
	if anim == "Roll":
		is_executing = false
		animation_frame = 0
		emit_signal("finished", CommandFrame.execution_frame)

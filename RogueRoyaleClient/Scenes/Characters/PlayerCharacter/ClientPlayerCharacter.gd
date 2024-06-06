extends ClientBaseCharacter
class_name ClientPlayerCharacter

var input_sender = InputHistoryCompresser.new()
var is_debug_test_character = ProjectSettings.get_setting("global/spawn_test_characters")

@onready var health_gui = $PlayerGUI/CanvasLayer/OverwatchHealth
@onready var ammo_gui = $PlayerGUI/CanvasLayer/Ammo
@onready var camera_smoother = $CameraSmoother
@onready var gui = $PlayerGUI

func _ready():
	super._ready()
	_connect_signals()
	add_to_group("LocalPlayer")

func _kinematic_entity_physics_process(delta):
#	node_interp.ready_next_frame(global_position)
#	camera_smoother.ready_next_frame(global_position)
	pass

func _track_inputs(frame : int) -> void:
	if is_debug_test_character:
		inputs.random_input()
	else:
		inputs.track_inputs(self)

func connect_health_to_gui(health : ClientHealth) -> void:
	gui.connect_health(health)

func _connect_signals():
	#health.connect("health_changed",Callable(health_gui,"_on_health_changed"))
	#ammo.connect("ammo_changed",Callable(ammo_gui,"_on_ammo_changed"))
	#ammo.emit_ammo_changed_signal()
	pass


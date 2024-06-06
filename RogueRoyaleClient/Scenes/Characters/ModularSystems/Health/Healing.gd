extends ClientNetcodeModule
class_name BaseHealing

signal healing_finished(frame)

@export var max_uses = 1 # (float, 0, 10)
@export var healing_amount = 50 # (float, 0, 1000)
@export var health_component_path: NodePath

var health_module

@onready var uses_left = max_uses
@onready var health_component = get_node(health_component_path)
@onready var heal_timer = $HealTimer

func _netcode_init():
	netcode.init(self, "HEL", HealingData.new(), HealingCompresser.new())

func _ready():
	heal_timer.connect("timeout",Callable(self,"_on_heal_timer_timeout"))

func execute(frame : int) -> bool:
	if uses_left > 0:
		_on_use(frame)
		return true
	else:
		return false

func _on_use(frame : int):
	heal_timer.advance(frame)

func _on_heal_timer_timeout(frame : int) -> void:
	uses_left -= 1
	health_module.heal(healing_amount)
	end_execution()
	emit_signal("healing_finished", CommandFrame.execution_frame)

func refill():
	# refill a health flask
	uses_left += 1
	uses_left = min(max_uses, uses_left)

func increase_max_uses():
	max_uses += 1
	refill()

# This function should be called if healing is disrupted
func end_execution():
	heal_timer.stop()

extends Sprite2D
class_name HealingFlask

@export var max_uses = 1 # (float, 0, 10)
@export var healing_amount = 50 # (float, 0, 1000)

var entity
var health_module

@onready var uses_left = max_uses

func _ready():
	_update_shader()

func execute(health_module_to_heal):
	health_module = health_module_to_heal
	if uses_left > 0:
		_on_use()
	pass

func _on_use():
	assert(uses_left > 0)
	uses_left -= 1
	_update_shader()
	health_module.heal(healing_amount)

func refill():
	# refill a health flask
	uses_left += 1
	uses_left = min(max_uses, uses_left)
	_update_shader()

func increase_max_uses():
	max_uses += 1
	refill()

func _update_shader():
	self.material.set("shader_parameter/max_flasks", max_uses)
	self.material.set("shader_parameter/current_flasks", uses_left)

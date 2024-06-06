extends BaseWeapon
class_name StarterShield

@export var radius = 32 # (float, 0, 64)
@export var stamina_cost: int = 1

enum {RAISING_SHIELD, HOLDING_SHIELD, N_ENUM}

@export var radius_adjust_amount: int = 0

var state = RAISING_SHIELD
var just_raised = false
var current_inputs : InputActions

@onready var block_box_shape = $BlockBox/BlockBoxShape
@onready var block_box = $BlockBox
@onready var starting_radius = radius
@onready var parry_box_shape = $ParryBox/ParryBoxShape
@onready var parry_box = $ParryBox

func _netcode_init():
	netcode.init(self, "SHD", MeleeWeaponData.new(), MeleeWeaponCompresser.new())

func _ready():
	shape = $Hitbox
	_disable_all_collision_boxes()
	add_to_group("SecondaryWeapons")
	super._ready()

func set_entity(new_entity) -> void:
	entity = new_entity
	block_box.entity = new_entity
	parry_box.entity = new_entity

func execute(frame : int, input_actions : InputActions):
	animation_tree.execute(frame, input_actions)
	_set_radius_from_radius_adjust()
	_set_position_from_radius()

func set_attack_direction(direction : Vector2):
	#attack_direction = direction
	rotation = direction.angle()
	rotation_degrees -= 90
	_set_position_from_radius()

func _set_position_from_radius():
	position.x = radius * cos(rotation + PI / 2)
	position.y = radius * sin(rotation + PI / 2)


func _adjust_radius(amount : int) -> void:
	radius = starting_radius + amount

func _set_radius_from_radius_adjust() -> void:
	radius = starting_radius + radius_adjust_amount

func _disable_all_collision_boxes():
	block_box_shape.disabled = true
	shape.disabled = true
	parry_box_shape.disabled = true

func physics_process(frame : int, input_actions : InputActions):
	super.physics_process(frame, input_actions)

func on_parry(frame : int):
	# the shield cannot be parried?
	pass

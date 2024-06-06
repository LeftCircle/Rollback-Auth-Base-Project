extends C_RangeNetcodeBase
class_name BaseRangedWeapon

signal fired(bullet)

@export var ammo = 1 # (int, 0, 100)
@export var has_charge_shot: bool = false
@export var is_automatic: bool = false
@export var primary_ammunition: PackedScene
@export var radius = 10 # (float, 0, 100)

var aiming_direction = Vector2.ZERO
var is_holstered = true
var ammo_obj : AmmoBase
var fired_this_frame = false

@onready var move = get_node("%Move")
@onready var bullet_container = $BulletContainer
@onready var weapon_data = $WeaponData

func _netcode_init():
	netcode.init(self, "RNG", BaseRangeWeaponData.new(), BaseRangeWeaponCompresser.new())

func init(frame : int, new_entity, new_ammo_obj) -> void:
	entity = new_entity
	ammo_obj = new_ammo_obj
	ammo_obj.set_max_and_current(frame, ammo, ammo)

func _ready():
	add_to_group("Weapon")
	set_physics_process(false)

func set_entity(new_entity) -> void:
	entity = new_entity

func execute(frame : int, input_actions : InputActions) -> void:
	fired_this_frame = false
	var direction = input_actions.get_looking_vector()
	move.execute(frame, entity, input_actions.get_input_vector(), 0.75)
	aim_weapon(direction)
	is_holstered = false
	aiming_direction = direction
	if input_actions.is_action_just_pressed("fire_ranged_weapon"):
		Logging.log_line("fire ranged weapon pressed")
		fire(frame)

func aim_weapon(direction : Vector2) -> void:
	rotation = direction.angle()
	position.x = cos(rotation) * radius
	position.y = sin(rotation) * radius

func fire(frame = CommandFrame.frame):
	# Check enitity ammo attribute. If there is ammo, fire and execute ammo attribute. Otherwise,
	# do not fire
	if ammo_obj.execute(frame):
		_on_ammo_to_fire(frame)
	else:
		_on_no_ammo()

func _on_ammo_to_fire(frame = CommandFrame.frame):
	var new_bullet = primary_ammunition.instantiate()
	_init_bullet(new_bullet, frame)
	bullet_container.add_child(new_bullet)
	fired_this_frame = true
	emit_signal("fired", new_bullet)

func _init_bullet(new_bullet, frame) -> void:
	# To be overridden by the server/client specific codes.
	pass

func _on_no_ammo():
	pass

func holster():
	is_holstered = true

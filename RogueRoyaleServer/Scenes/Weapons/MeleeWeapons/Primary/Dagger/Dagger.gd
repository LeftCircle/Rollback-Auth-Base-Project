extends BaseWeapon
class_name BaseDagger

@onready var tether = $Tether

func _netcode_init():
	netcode.init(self, "DGR", MeleeWeaponData.new(), MeleeWeaponCompresser.new())

func _ready():
	shape = $Hitbox
	shape.disabled = true
	add_to_group("PrimaryWeapons")
	super._ready()

func execute_tree(frame : int, input_actions : InputActions, weapon_data : WeaponData):
	animation_tree.execute(frame, input_actions)

func physics_process(frame : int, input_actions : InputActions) -> void:
	super.physics_process(frame, input_actions)

func end_execution(frame : int):
	super.end_execution(frame)
	_disable_all_collision_boxes()

func _disable_all_collision_boxes():
	shape.disabled = true

func debug_is_anim_playing():
	print("true")

func on_successful_hit(hit_entity) -> void:
	#tether.execute(hit_entity)
	pass

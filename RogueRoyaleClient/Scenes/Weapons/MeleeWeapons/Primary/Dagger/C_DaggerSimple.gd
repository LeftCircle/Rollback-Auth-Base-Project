extends ClientDagger
class_name DaggerSimple

@onready var pivot : Pivot2D = $NodeInterpolater/Pivot2D
@onready var player_sprite = $NodeInterpolater/Pivot2D2/PlayerSprite
@onready var dagger_sprite = $NodeInterpolater/Pivot2D/DaggerSprite

func _netcode_init():
	netcode.init(self, "DGR", MeleeWeaponData.new(), MeleeWeaponCompresser.new())

func get_pivot():
	return pivot

func set_attack_direction(direction : Vector2) -> void:
	super.set_attack_direction(direction)
	#pivot.rotate_radians(direction.rotated(PI / 2.0).angle())
	pivot.rotate_degrees(rad_to_deg(direction.rotated(PI / 2.0).angle()))

func execute(frame : int, input_actions : InputActions) -> int:
	show()
	entity.show_player_sprite(false)
	var return_value = super.execute(frame, input_actions)
	return return_value

func end_execution(frame : int) -> void:
	super.end_execution(frame)
	hide()
	entity.show_player_sprite(true)

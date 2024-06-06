extends BaseRangedWeapon
class_name ClientRangedWeapon

@onready var weapon_sprite = $NodeInterpolater/WeaponSprite
@onready var node_interpolater = $NodeInterpolater as NodeInterpolater

func _ready():
	super._ready()
	weapon_sprite.visible = false

func execute(frame : int, input_actions : InputActions) -> void:
	if is_holstered:
		node_interpolater.ready_next_frame(global_position)
	super.execute(frame, input_actions)
	weapon_sprite.visible = true
	node_interpolater.ready_next_frame(global_position)


func _init_bullet(new_bullet, frame) -> void:
	# To be overridden by the server/client specific codes.
	new_bullet.fire(entity, weapon_data, aiming_direction, global_position, frame)
	new_bullet.local = true
	if frame != CommandFrame.frame:
		Logging.log_line("BULLET SPAWNED DURING ROLLBACK")
		_on_bullet_spawned_during_rollback(new_bullet, frame)

func _on_bullet_spawned_during_rollback(new_bullet, frame : int):
	var frames_to_sim = CommandFrame.frame_difference(CommandFrame.frame, frame)
	if frames_to_sim > 0:
		for i in range(frames_to_sim):
			new_bullet.advance(CommandFrame.frame_length_sec)

func draw() -> void:
	weapon_sprite.visible = true

func holster():
	weapon_sprite.visible = false
	super.holster()

func _on_rollback(frame) -> void:
	for bullet in bullet_container.get_children():
		bullet.on_rollback(frame)
	pass

func physics_process():
	node_interpolater.ready_next_frame(global_position)

# let the bullets know a reset. Respawn bullets if need be and update their positions
func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not is_lag_comp:
		for bullet in bullet_container.get_children():
			bullet.on_rollback(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		hist.set_obj_with_data(self)
		aim_weapon(aiming_direction)
		if fired_this_frame:
			print("Fired this reset frame!")
			if not is_lag_comp:
				_on_ammo_to_fire(frame)
		if not is_holstered:
			weapon_sprite.visible = true
		#node_interpolater.ready_next_frame(global_position)

func save_history(frame : int) -> void:
	history.add_data(frame, self)

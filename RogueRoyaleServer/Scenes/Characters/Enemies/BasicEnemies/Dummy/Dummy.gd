extends BaseEnemy
class_name Dummy

enum STATES{IDLE, RUN, ATTACK, N_STATES}

var state_data = EnemyState.new()

#var state : int = STATES.IDLE
var attack_cooldown_frames = 60
var attack_cooldown = 0
var can_attack = false
var run_frames = 240
var current_run_frames = 0

@onready var lagcomp_hurtbox_spawner = $LagCompHurtboxSpawner
@onready var hurtbox = $EnemyHurtbox
@onready var animations = $AnimationPlayer
@onready var hitbox = $EnemyHitbox
@onready var move : S_Move = get_node("%Move")

func _netcode_init():
	netcode.init(self, "DMY", state_data, DummyCompresser.new())

func _kinematic_entity_physics_process(delta):
	if state == STATES.IDLE:
		_random_input_vector()
		_on_idle()
	elif state == STATES.RUN:
		_on_run()
	elif state == STATES.ATTACK:
		_on_attack()
	position_history.add_position_for_frame(CommandFrame.frame, global_position)
	animations.advance_animations()
	_update_cooldowns()
	state_data.set_data_with_obj(self)

func _update_cooldowns():
	if can_attack == false:
		attack_cooldown += 1
		if attack_cooldown >= attack_cooldown_frames:
			attack_cooldown = 0
			can_attack = true
			state = STATES.ATTACK

func _random_input_vector():
	var x_addition = randf() - 0.5
	var y_addition = randf() - 0.5
	input_vector.x += x_addition
	input_vector.y += y_addition
	input_vector = input_vector.normalized()

func _on_idle():
	move.execute(CommandFrame.frame, self, Vector2.ZERO)
	if randf() < (1.0 / 60.0):
		state = STATES.RUN
		current_run_frames = 0

func _on_run():
	move.execute(CommandFrame.frame, self, input_vector)
	current_run_frames += 1
	if current_run_frames > run_frames:
		state = STATES.IDLE

func _on_attack():
	if can_attack:
		animations.animate("Attack")

#func _on_hurtbox_hit(hitbox : BaseHitbox) -> void:
#	Logging.log_line("Enemy dummy hit on frame " + str(CommandFrame.frame))
#	print("Enemy dummy hit on frame " + str(CommandFrame.frame))

func on_hurtbox_hit_by(frame : int, event : CombatEvent, damage : int):
	# To be overriden by child classes
	print("Hurtbox hit not yet implemented for " + self.to_string())
	#assert(false)

func _on_attack_finished():
	can_attack = false
	state = STATES.IDLE
	animations.animate("Idle")

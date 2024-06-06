extends KinematicEntity
class_name Dummy

enum STATES{IDLE, RUN, ATTACK, N_STATES}

var netcode = NetcodeBaseReference.new()
var dummy_history = BaseEnemyHistory.new()
var state_data = DummyState.new()
var component_map = NetcodeModuleMap.new()

@onready var hurtbox = $EnemyHurtbox
@onready var hitbox = $EnemyHitbox
@onready var animations = $AnimationPlayer

func _init():
	netcode.init(self, "DMY", state_data, DummyCompresser.new())

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	var server_state = netcode.state_compresser.decompress(frame, bit_packer)
	dummy_history.add_data(frame, server_state)
	#components.decompress_components(frame, server_state.modular_abilties_this_frame, bit_packer)

func _kinematic_entity_physics_process(delta):
	var buffered_frame = WorldState.buffered_frame
	Logging.log_line("Showing enemy for frame " + str(buffered_frame))
	var buffered_state = dummy_history.retrieve_data(buffered_frame)
	if buffered_state != BaseModularHistory.NO_DATA_FOR_FRAME:
		buffered_state.set_obj_with_data(self)
		components.reset_components_to_frame(buffered_frame)
		if buffered_state.state == STATES.IDLE:
			_on_idle()
		elif buffered_state.state == STATES.ATTACK:
			_on_attack()
		Logging.log_line("Position is " + str(position) + " For buffered frame " + str(buffered_frame))
	animations.advance_animations()

func _on_idle():
	animations.animate("Idle")

func _on_attack():
	animations.animate("Attack")

func _on_hurtbox_hit(damage_amount : int) -> void:
	damage(damage_amount)

func damage(damage_amount: int):
	$AnimationPlayer.play("damage")
	#cur_health = cur_health - damage_amount
	#print("New health = ", cur_health)
	#$HealthBar.value = (cur_health / max_health) * 100
	checkDeath()

func checkDeath():
#	if(cur_health <= 0):
#		on_death()
	pass

func move_enemy(new_position):
	global_position = new_position

func set_health(new_health):
#	if new_health < cur_health:
#		damage(new_health)
#	elif new_health > cur_health:
#		# Heal!
#		pass
	pass

func on_death():
#	if not death_triggered:
#		death_triggered = true
#		#get_node("CollisionPolygon2D").set_deferred("disabled", true)
#		# Play death animation then queue free after death animation
#		$HealthBar.hide()
#		# Adding a timer before disabling the hitbox to account for synchronization issues
#		hitbox.set_deferred("disabled", true)
#		#await get_tree().create_timer(0.15).timeout
#		queue_free()
	pass

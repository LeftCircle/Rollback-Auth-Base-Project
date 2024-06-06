extends ClientNetcodeModule
class_name BaseHealth

signal health_reached_zero

enum {HEALTH, ARMOR, SHIELD}
@export var armor_reduction_amount = 5 # (int, 0, 50)
@export var health_segments = 6 # (int, 0, 100)
@export var armor_segments = 1 # (int, 0, 100)
@export var shield_segments = 1 # (int, 0, 100)
@export var shield_regen_heal_amount = 1 # (int, 0, 100)

var segment_value = ProjectSettings.get_setting("global/health_segment_value")

var current_health : int
var current_armor : int
var current_shields : int

var regenerating_shield = false

@onready var shield_regen_start_timer = $shield_regen_start_timer
@onready var shield_regen_heal_timer = $shield_regen_heal_timer


func _netcode_init():
	netcode.init(self, "HLT", HealthData.new(), HealthCompresser.new())
	add_to_group("Health")

func _ready():
	current_health = health_segments * segment_value
	current_armor = armor_segments * segment_value
	current_shields = shield_segments * segment_value
	shield_regen_start_timer.connect("timeout",Callable(self,"_on_shield_regen_start_timer_timeout"))
	shield_regen_heal_timer.connect("timeout",Callable(self,"_on_shield_heal_timer_timeout"))

func physics_process(frame : int):
	shield_regen_start_timer.advance(frame)
	shield_regen_heal_timer.advance(frame)

func damage(frame : int, amount : int) -> void:
	Logging.log_line("Player has been damaged for " + str(amount))
	amount = _damage_shields(amount)
	if amount > 0:
		amount = _damage_armor(amount)
	current_health = max(0, current_health - amount)
	_check_for_death()
	reset_shield_regen()

func heal(frame : int, amount : int) -> void:
	# armor -> health -> shield
	amount = _heal_health(amount)
	if amount > 0:
		amount = _heal_armor(amount)
		if amount > 0:
			_heal_shields(amount)
			# This is where we could add overshields on extra health

func set_health(frame : int, amount : int) -> void:
	var max_health = (health_segments + armor_segments + shield_segments) * segment_value
	amount = clamp(amount, 0, max_health)
	var current_health = _get_current_health()
	var health_difference = abs(max_health - current_health)
	if amount <= current_health:
		heal(frame, health_difference)
	else:
		damage(frame, health_difference)

func full_heal(frame : int):
	heal(frame, (health_segments + armor_segments + shield_segments) * segment_value)

func _get_current_health():
	return current_health + current_armor + current_shields

func _damage_shields(amount) -> int:
	if current_shields > 0:
		if amount > current_shields:
			amount -= current_shields
			current_shields = 0
		else:
			current_shields -= amount
			return 0
	return amount

func _damage_armor(amount) -> int:
	if current_armor > 0:
		amount -= armor_reduction_amount
		amount = max(amount, 1)
		if amount > current_armor:
			amount -= current_armor
			current_armor = 0
		else:
			current_armor -= amount
			return 0
	return amount

func _heal_health(amount) -> int:
	var max_health = health_segments * segment_value
	if current_health < max_health:
		current_health += amount
		if current_health < max_health:
			return 0
		else:
			var overheal = current_health - max_health
			current_health = max_health
			return overheal
	else:
		return amount

func _heal_armor(amount) -> int:
	var max_health = armor_segments * segment_value
	if current_armor < max_health:
		current_armor += amount
		if current_armor < max_health:
			return 0
		else:
			var overheal = current_armor - max_health
			current_armor = max_health
			return overheal
	else:
		return amount

func _heal_shields(amount) -> int:
	var max_health = shield_segments * segment_value
	if current_shields < max_health:
		current_shields += amount
		if current_shields < max_health:
			return 0
		else:
			var overheal = current_shields - max_health
			current_shields = max_health
			return overheal
	else:
		return amount

func _get_segments_for_health_type(health_type : int) -> int:
	if health_type == HEALTH:
		return health_segments
	elif health_type == ARMOR:
		return armor_segments
	elif health_type == SHIELD:
		return shield_segments
	return -1

func _get_current_health_for_health_type(health_type : int) -> int:
	if health_type == HEALTH:
		return current_health
	elif health_type == ARMOR:
		return current_armor
	elif health_type == SHIELD:
		return current_shields
	return -1

func get_percent(health_type : int) -> float:
	if health_type == HEALTH:
		return float(current_health) / float(health_segments * segment_value)
	elif health_type == ARMOR:
		return float(current_armor) / float(armor_segments * segment_value)
	elif health_type == SHIELD:
		return float(current_shields) / float(shield_segments * segment_value)
	return -1.0

func _check_for_death():
	if current_health <= 0:
		emit_signal("health_reached_zero")
		print("HEALTH REACHED ZERO")

func _on_attack():
	reset_shield_regen()

func _on_shield_regen_start_timer_timeout(frame : int):
	if shield_segments > 0:
		if current_shields != shield_segments * segment_value:
			shield_regen_heal_timer.start()
	shield_regen_start_timer.stop()

func _on_shield_heal_timer_timeout(frame : int):
	#print("HEALED!")
	if shield_segments > 0:
		if current_shields < shield_segments * segment_value:
			_heal_shields(shield_regen_heal_amount)
			shield_regen_heal_timer.start()
	else:
		shield_regen_heal_timer.stop()

func reset_shield_regen():
	shield_regen_start_timer.reset()
	shield_regen_heal_timer.stop()


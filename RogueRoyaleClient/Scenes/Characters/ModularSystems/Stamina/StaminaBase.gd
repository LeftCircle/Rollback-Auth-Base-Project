extends BaseNetcodeModule2D
class_name BaseStamina

@export var stamina = 5 # (int, 0, 20)
@export var stamina_node: PackedScene
@export var stamina_to_refill_on_timeout = 1 # (int, 0, 5)

var stamina_nodes = []

@onready var current_stamina = stamina
@onready var stamina_refill_delay_timer = $StaminaRefillDelay
@onready var stamina_refill_speed_timer = $StaminaRefillSpeed

func _netcode_init():
	netcode.init(self, "STM", StaminaData.new(), StaminaCompresser.new())
	add_to_group("Stamina")

func _ready():
	stamina_refill_delay_timer.connect("timeout",Callable(self,"_on_refill_delay_timeout"))
	stamina_refill_speed_timer.connect("timeout",Callable(self,"_on_refill_speed_timeout"))
	_spawn_stamina_nodes()

func _spawn_stamina_nodes():
	for i in range(stamina):
		var new_node = stamina_node.instantiate()
		new_node.name = "StaminaNode_" + str(i)
		add_child(new_node)
		stamina_nodes.push_front(new_node)

func physics_process(frame : int):
	stamina_refill_delay_timer.advance(frame)
	stamina_refill_speed_timer.advance(frame)
	Logging.log_line("Stamina refill delay timer :")
	stamina_refill_delay_timer.log_timer()
	Logging.log_line("Stamina refill speed timer :")
	stamina_refill_speed_timer.log_timer()

func execute(frame : int, n_stamina : int, to_reset_timers = true) -> bool:
	var has_stamina = _use_stamina(n_stamina)
	if to_reset_timers:
		reset_timers(frame)
	return has_stamina

func _use_stamina(n_stamina : int) -> bool:
	Logging.log_line("Trying to use " + str(n_stamina) + " Current stamina = " + str(current_stamina))
	if current_stamina >= n_stamina:
		for i in range(n_stamina):
			var stamina_node = stamina_nodes[current_stamina - 1 - i]
			#if not stamina_node.is_empty:
			stamina_node.use_stamina()
		current_stamina -= n_stamina
		#print("Used stamina. Current is now ", current_stamina)
		return true
	else:
		# TO DO -> client animation for not enough stamina, (Maybe add self stun??)
		return false

func get_stamina() -> int:
	return current_stamina

func reset_timers(frame : int):
	stamina_refill_delay_timer.reset()
	stamina_refill_speed_timer.reset()
	stamina_refill_speed_timer.stop()

func reset_and_stop_timers(frame : int) -> void:
	stamina_refill_delay_timer.reset()
	stamina_refill_speed_timer.reset()
	stamina_refill_delay_timer.stop()
	stamina_refill_speed_timer.stop()

func _on_refill_delay_timeout(frame : int):
	refill_x_stamina(frame, stamina_to_refill_on_timeout)
	#print("Stamina refilled on frame %s. Stopping delay timer and resetting speed timer" % [frame])
	stamina_refill_delay_timer.stop()
	stamina_refill_speed_timer.reset()

func refill_x_stamina(frame : int, n_stamina_to_refill : int) -> void:
	var n_refilled = 0
	for stamina in stamina_nodes:
		if n_refilled == n_stamina_to_refill:
			break
		if stamina.is_empty:
			stamina.refill()
			current_stamina += 1
			n_refilled += 1
			#stamina_refill_speed_timer.reset()
			#print("Stamina is refilled. Current is now ", current_stamina)
	if n_refilled == 0:
		stamina_refill_speed_timer.stop()
	else:
		stamina_refill_speed_timer.reset()

func _on_refill_speed_timeout(frame : int):
	refill_x_stamina(frame, stamina_to_refill_on_timeout)

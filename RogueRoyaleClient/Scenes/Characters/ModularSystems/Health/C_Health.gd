extends BaseHealth
class_name ClientHealth

signal health_changed(health_data)

var health_data = HealthData.new()

func _init_history():
	history = HealthHistory.new()

func _ready():
	#._ready()
	if is_instance_valid(entity):
		connect_to_entity(entity)
	_on_health_changed()

func damage(frame : int, amount : int) -> void:
	super.damage(frame, amount)
	_on_health_changed()

func heal(frame, amount : int) -> void:
	super.heal(frame, amount)
	_on_health_changed()

func _on_health_changed() -> void:
	health_data.set_data_with_obj(self)
	emit_signal("health_changed", health_data)

func physics_process(frame : int) -> void:
#	super.physics_process(frame)
#	history.add_data(frame, self)
	pass

func reset_to_frame(frame : int) -> void:
	var hist = history.retrieve_data(frame)
	if not hist == BaseModularHistory.NO_DATA_FOR_FRAME:
		hist.set_obj_with_data(self)
	_on_health_changed()

func connect_to_entity(connected_entity) -> void:
	# Connect to the gui
	super.connect_to_entity(connected_entity)
	connected_entity.connect_health_to_gui(self)

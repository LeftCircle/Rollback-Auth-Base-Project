#################################################
######   ALL THE SAME EXCEPT EXTENDS        #####
#################################################
extends BaseNetcodeModule
class_name StateSystemState

func _ready():
	add_to_group("StateSystem")

func _data_container_init() -> void:
	data_container = StateSystemData.new()

func _netcode_init() -> void:
	netcode.init(self, "SSS", data_container, StateSystemCompresser.new())

func set_state(frame : int, state : int) -> void:
	data_container.state = state

func set_queued_state(frame : int, queued_state : int) -> void:
	data_container.queued_state = queued_state

func set_queued_unregister(frame : int, queued_unregister : int) -> void:
	data_container.queued_unregister = queued_unregister

extends RefCounted
class_name PositionHistory

const INVALID_POS = Vector2.INF

var history_size = 60
var history = PackedVector2Array([])
var entity

func _init():
	history.resize(history_size)
	for i in range(history_size):
		history.set(i, Vector2.INF)

func init(new_entity) -> void:
	entity = new_entity
	entity.connect("physics_process_ended",Callable(self,"_on_entity_physics_process_finished"))

func _on_entity_physics_process_finished():
	add_position_for_frame(CommandFrame.frame, entity.global_position)

func add_position_for_frame(frame : int, pos : Vector2) -> void:
	history.set(frame % history_size, pos)

func retrieve(frame : int) -> Vector2:
	return history[frame % history_size]

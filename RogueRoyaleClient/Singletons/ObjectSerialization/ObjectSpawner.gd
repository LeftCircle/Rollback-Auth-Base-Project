extends RefCounted
class_name LagCompObjectSpawner

const array_size = 180
# If this is too slow, consider using signals!
var objects_to_spawn = {}
var parent_node
var mutex = Mutex.new()

func init_lag_comp_spawner(p_node) -> void:
	parent_node = p_node

func queue_spawn(frame : int, obj):
	mutex.lock()
	if frame in objects_to_spawn.keys():
		objects_to_spawn[frame].append(obj)
	else:
		objects_to_spawn[frame] = [obj]
	mutex.unlock()

func spawn_for_frame(frame : int) -> void:
	mutex.lock()
	var frames = objects_to_spawn.keys()
	for spawn_frame in frames:
		if CommandFrame.is_fame_greater_than(frame, spawn_frame) or frame == spawn_frame:
			for obj in objects_to_spawn[spawn_frame]:
				parent_node.add_child(obj)
			objects_to_spawn.erase(spawn_frame)
	mutex.unlock()

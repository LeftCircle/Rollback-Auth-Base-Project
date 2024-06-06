extends Node
class_name IterationSpeedManager

# Must match PlayerSyncController on the server
enum {FAST, SLOW, NORMAL, DOUBLE_FAST, HALF_SPEED}

const CHANGE_ITERATIONS_FOR_X_FRAMES = 2

var NORMAL_ITERATIONS = int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
var FAST_ITERATIONS = NORMAL_ITERATIONS + 5
var SLOW_ITERATIONS = NORMAL_ITERATIONS - 5
var DOUBLE_FAST_ITERATIONS = 2 * NORMAL_ITERATIONS
var DOUBLE_SLOW_ITERATIONS = NORMAL_ITERATIONS / 2

var iterations = NORMAL
var frames_since_normal = 0
var speed_to_change_to = NORMAL
var n_slow_frames : int


#func _physics_process(_delta):
func execute():
	if Engine.physics_ticks_per_second != NORMAL_ITERATIONS:
		frames_since_normal += 1
	if Engine.physics_ticks_per_second == SLOW_ITERATIONS:
		if frames_since_normal >= n_slow_frames:
			change_iteration_speed(NORMAL)
			Server.send_normal_iterations()
	else:
		if frames_since_normal >= CHANGE_ITERATIONS_FOR_X_FRAMES:
			change_iteration_speed(NORMAL)
	Logging.log_line("Frames since normal = " + str(frames_since_normal))


#func change_iteration_speed(speed : int) -> void:
#	mutex.lock()
#	speed_to_change_to = speed
#	mutex.unlock()

func receive_iteration_packet(data : Array) -> void:
	var new_speed = data[0]
	if new_speed != SLOW:
		change_iteration_speed(new_speed)
	elif new_speed == SLOW:
		change_iteration_speed(new_speed)
		var slow_comp_frames = data.slice(1, 4)#3)
		n_slow_frames = BaseCompression.decompress_frame_from_3_bytes(slow_comp_frames) - 1
		print("n slow frames = ", n_slow_frames)

func change_iteration_speed(speed : int) -> void:
	iterations = speed
	Logging.log_line("Changing iteration speed to " + str(speed))
	if speed == FAST:
		Engine.physics_ticks_per_second = FAST_ITERATIONS
		Engine.time_scale = float(FAST_ITERATIONS) / float(NORMAL_ITERATIONS)
		#print("fast iterations")
	elif speed == SLOW:
		Engine.physics_ticks_per_second = SLOW_ITERATIONS
		Engine.time_scale = float(SLOW_ITERATIONS) / float(NORMAL_ITERATIONS)
		#print("slow iterations!")
	elif speed == NORMAL:
		Engine.physics_ticks_per_second = NORMAL_ITERATIONS
		Engine.time_scale = 1.0
		#print("Normal iterations")
	elif speed == DOUBLE_FAST:
		Engine.physics_ticks_per_second = DOUBLE_FAST_ITERATIONS
		Engine.time_scale = 2.0
		#print("double fast iterations")
	elif speed == HALF_SPEED:
		Engine.physics_ticks_per_second = DOUBLE_SLOW_ITERATIONS
		Engine.time_scale = 0.5
		print("Double slow iterations")
	else:
		assert(false) #," No speed of " + str(speed))
	frames_since_normal = 0

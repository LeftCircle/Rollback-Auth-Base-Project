extends CommandTimer
class_name RollbackTimer

var history = RollbackTimerHistory.new()
var logging_enabled = false

func set_logging(to_enable):
	logging_enabled = to_enable
	history.logging_enabled = to_enable

func advance(frame : int):
	assert(false) #,"rollback timers must use rollback_advance")

#func reset():
#	assert(false) #,"rollback timers must use rollback_reset")
#
#func start():
#	assert(false) #," Rollback timers must use rollback_start")
#
#func stop():
#	assert(false) #,"RollbackTimers must use rollback_stop")

func _physics_process(delta):
	rollback_advance(CommandFrame.frame)

func rollback_advance(frame : int):
	super.advance(frame)
	history.add_data(frame, self)

func rollback_reset(frame : int) -> void:
	pass

func rollback(frame : int) -> void:
	history.rollback_the_timer(frame, self)

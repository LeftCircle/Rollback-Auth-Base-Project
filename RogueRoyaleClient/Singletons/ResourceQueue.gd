extends Node
# This script avoids the 70ms idle time with a thread by not closing the
# thread until the scene exits the tree, which it never should until the game
# is closed

#signal finished_loading(res)

var thread
var mutex
var sem

var queue = []
var pending = {}
var exit_thread : bool = false

func _lock(_caller):
	mutex.lock()

func _unlock(_caller):
	mutex.unlock()

func _post(_caller):
	sem.post()

func _wait(_caller):
	sem.wait()

func _init():
	mutex = Mutex.new()
	sem = Semaphore.new()
	thread = Thread.new()
	thread.start(Callable(self,"thread_func").bind(0))

# Main function that starts the thread
func queue_resource(path, p_in_front = false):
	_lock("queue_resource")
	if path in pending:
		_unlock("queue_resource")
		return
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		_unlock("queue_resource")
		return
	else:
		var res = ResourceLoader.load_threaded_request(path)
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		# Post triggers the thread to start
		_post("queue_resource")
		_unlock("queue_resource")
		return

func thread_func(_u):
	while true:
		if _time_for_exit():
			break
		thread_process()

func _time_for_exit() -> bool:
	# Protect with Mutex.
	_lock("_time_for_exit")
	var should_exit = exit_thread
	_unlock("_time_for_exit")
	return should_exit

func thread_process():
	# We hang at this wait until a _post() occurs from queue_resource
	_wait("thread_process")
	_lock("process")
	while queue.size() > 0:
		var res = queue[0]
		# Ensures we do not block the main thread during polling
		_unlock("process_poll")
		var ret = res.poll()
		_lock("process_check_queue")
		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				pending[res.get_meta("path")] = res.get_resource()
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			queue.erase(res)
	_unlock("process")

func get_resource(path):
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)

			res = _wait_for_resource(res, path)
			pending.erase(path)
			_unlock("return")
			return res
		else:
			var res = pending[path]
			pending.erase(path)
			_unlock("return")
			return res
	else:
		_unlock("return")
		return ResourceLoader.load(path)

func _wait_for_resource(res, path):
	_unlock("wait_for_resource")
	while true:
		RenderingServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_resource")
		if queue.size() == 0 || queue[0] != res:
			return pending[path]
		_unlock("wait_for_resource")

func cancel_resource(path):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")


func get_progress(path):
	_lock("get_progress")
	var ret = -1
	if path in pending:
		if pending[path] is ResourceLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	_unlock("get_progress")
	return ret

func is_ready(path):
	var ret
	_lock("is_ready")
	if path in pending:
		ret = !(pending[path] is ResourceLoader)
	else:
		ret = false
	_unlock("is_ready")
	return ret

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	_lock("_exit_tree")
	exit_thread = true # Protect with Mutex.
	_post("_exit_tree")
	_unlock("_exit_tree")

	# Wait until it exits.
	thread.wait_to_finish()
	print("Resource queue thread stopped")

extends Node
class_name WorldStateFunctionQueue

# Just like the function queue except no results

# This script avoids the 70ms idle time with a thread by not closing the
# thread until the scene exits the tree, which it never should until the game
# is closed

# TODO - allow the same function to be called by tagging each call with
# a unique identifier

var thread
var mutex
var sem
# {FuncRef : [args], ... }
var func_ref_arguments = {}
var func_ref_queue = []
var exit_thread : bool = false
#var n_queued_functions = 0

signal finished_computations

func _init():
	mutex = Mutex.new() as Mutex
	sem = Semaphore.new() as Semaphore
	thread = Thread.new() as Thread
	thread.start(Callable(self,"thread_func").bind(0))

func _lock(_caller):
	#print("Locked by " + _caller)
	mutex.lock()

func _unlock(_caller):
	#print("unlocked by " + _caller)
	mutex.unlock()

func _post(_caller):
	sem.post()

func _wait(_caller):
	sem.wait()

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

func queue_funcref(func_ref : FuncRef, args : Array = []) -> void:
	_lock("queue_funcref")
	#n_queued_functions += 1
	__queue_thread_to_run(func_ref, args)
	_post("queue_funcref")
	_unlock("queue_funcref")

func queue_dict_of_funcrefs(func_ref_dict : Dictionary) -> void:
	_lock("queue_dict_of_funcrefs")
	#n_queued_functions += func_ref_dict.size()
	for func_ref in func_ref_dict.keys():
		__queue_thread_to_run(func_ref, func_ref_dict[func_ref])
	_post("queue_dict_of_funcrefs")
	_unlock("queue_dict_of_funcrefs")

func __queue_thread_to_run(func_ref : FuncRef, args : Array) -> void:
	# NOTE - ALREADY IN A LOCKED THREAD
	if not func_ref in func_ref_queue:
		func_ref_queue.append(func_ref)
		func_ref_arguments[func_ref] = args

func thread_process():
	_wait("thread_process")
	_lock("thread_process")
	while func_ref_queue.size() > 0:
		_execute_func_refs()
	call_deferred("emit_signal", "finished_computations")
	_unlock("thread_process")

func _execute_func_refs():
	var func_ref = func_ref_queue[0] as FuncRef
	var args = func_ref_arguments[func_ref] as Array
	_unlock("_execute_func_refs")
	var results = func_ref.call_funcv(args)
	_lock("_execute_func_refs")
	func_ref_queue.erase(func_ref)
	func_ref_arguments.erase(func_ref)

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	_lock("_exit_tree")
	exit_thread = true # Protect with Mutex.
	_post("_exit_tree")
	_unlock("_exit_tree")

	# Wait until it exits.
	thread.wait_to_finish()
	print("Function queue thread stopped")

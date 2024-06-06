#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends Node
# This script avoids the 70ms idle time with a thread by not closing the
# thread until the scene exits the tree, which it never should until the game
# is closed

# TODO - allow the same function to be called by tagging each call with
# a unique identifier

signal finished_computations

const FUNC_IS_VOID = null

var thread
var mutex
var sem
# {FuncRef : [args], ... }
var func_ref_arguments = {}
var func_ref_queue = []
var func_ref_results = {}
var exit_thread : bool = false
#var n_queued_functions = 0

#signal finished_computations

func _init():
	mutex = Mutex.new()
	sem = Semaphore.new()
	thread = Thread.new()
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
			print("STOPPING THE THREAD!")
			break
		thread_process()

func _time_for_exit() -> bool:
	# Protect with Mutex.
	_lock("_time_for_exit")
	var should_exit = exit_thread
	_unlock("_time_for_exit")
	return should_exit

func queue_funcref(func_ref : Callable, args : Array = []) -> void:
	_lock("queue_funcref")
	#n_queued_functions += 1
	if func_ref in func_ref_results:
		print("Function already in results")
		_unlock("queue_funcref")
	else:
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

func __queue_thread_to_run(func_ref : Callable, args : Array) -> void:
	# NOTE - ALREADY IN A LOCKED THREAD
	if not func_ref in func_ref_queue and not func_ref_results.has(func_ref):
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
	#print("func_ref_queue size during computation = ", func_ref_queue.size())
	var func_ref = func_ref_queue[0]
	var args = func_ref_arguments[func_ref]
	_unlock("_execute_func_refs")
	var results
	if args.size() == 0 or args[0] == FUNC_IS_VOID:
		results = func_ref.call_func()
	else:
		results = func_ref.call_funcv(args)
	_lock("_execute_func_refs")
	if not args[0] == FUNC_IS_VOID:
		func_ref_results[func_ref] = results
	func_ref_queue.erase(func_ref)
	func_ref_arguments.erase(func_ref)

func is_finished(func_ref : Callable) -> bool:
	_lock("is_finished")
	if func_ref_results.has(func_ref):
		_unlock("is_finished")
		return true
	_unlock("is_finished")
	return false

func get_results_or_null(func_ref : Callable):
	var results = null
	_lock("get_results")
	print("results are being gotten")
	if func_ref_results.has(func_ref):
		results = func_ref_results[func_ref]
		func_ref_results.erase(func_ref)
	_unlock("get_results")
	return results

func clear_results():
	_lock("clear_results")
	func_ref_results.clear()
	_unlock("clear_results")

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	_lock("_exit_tree")
	exit_thread = true # Protect with Mutex.
	_post("_exit_tree")
	_unlock("_exit_tree")

	# Wait until it exits.
	thread.wait_to_finish()

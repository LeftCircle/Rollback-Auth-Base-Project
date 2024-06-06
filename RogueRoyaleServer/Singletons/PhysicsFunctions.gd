extends Node
# If spawning several physics objects, or setting paramaters on physics objects
# that will interact, they should all be
# spawned/set on the same physics frame in order for their interactions to be
# deterministic (or as close as floating points will allow)

var physics_funcrefs : Array[Callable]
var physics_func_args : Array

func _init():
	set_physics_process(false)

func _physics_process(_delta):
	var n_funcs = physics_funcrefs.size()
	for i in range(n_funcs):
		if physics_funcrefs[i].is_valid():
			physics_funcrefs[i].callv(physics_func_args[i])
	physics_funcrefs.clear()
	physics_func_args.clear()
	set_physics_process(false)

func execute_func(ref : Callable, args : Array) -> void:
	physics_funcrefs.append(ref)
	physics_func_args.append(args)
	set_physics_process(true)

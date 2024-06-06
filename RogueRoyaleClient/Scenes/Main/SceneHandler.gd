extends Node
class_name SceneHandler
# The SceneHandler is resposnible for directing the code down different paths.
# The default action of the scene handler is to do nothing. If this is the case,
# Then the login screen should appear. Once the authentication token is verified
# after login, the Lobby (as of 6/9/21) will then be entered, and the Map will
# be started from the lobby.
const MAX_LOAD_MSEC = 5

@export var reset_wait_time_before_load : int = 1
@export var test : bool = false : set = set_test
@export var client_test_scene : String : set = set_client_test_scene
@export var lobby: PackedScene
#export var map: PackedScene

var parent_node_to_add_child_to
var wait_frames_before_load = 1
var loader
var scene_name


func set_test(is_test : bool) -> void:
	test = is_test

func set_client_test_scene(test_path : String):
	client_test_scene = test_path

func _ready():
	if test:
		print("running tests")
		_run_test()

# The game is started once the authentication results have been returned
func enter_lobby():
	if not test:
		print("Verification successful. Starting the game")
		$LoginScreen.queue_free()
		add_child(lobby.instantiate())
		#instance_scene(lobby_path, "Lobby", self)
		#Server.sync_to_server_time()

# Called from the Server once all players have readied up
#func load_map(data : Dictionary):
#	var map_scene = map.instantiate()
#	map_scene.init(data)
#	map_scene.name = "Map"
#	add_child(map_scene)

func instance_scene(path : String, _scene_name : String, _parent_node) -> void:
	parent_node_to_add_child_to = _parent_node
	loader = ResourceLoader.load_threaded_request(path)
	scene_name = _scene_name
	if loader == null:
		assert(false) #,"Loader was null. Failed to instance")
		return
	set_process(true)

	# Start your "loading..." animation.
	#get_node("animation").play("loading")

func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return
	# Wait for frames to let the "loading" animation show up.
	if wait_frames_before_load > 0:
		wait_frames_before_load -= 1
		return
	_load_scene()

func _load_scene() -> void:
	var t = Time.get_ticks_msec()
	while Time.get_ticks_msec() < t + MAX_LOAD_MSEC:
		var err = loader.poll()
		# Finished loading.
		if err == ERR_FILE_EOF:
			_add_child_scene()
			loader = null
			wait_frames_before_load = reset_wait_time_before_load
			break
		elif err == OK:
			# Could be used to update a loading bar
			#update_progress()
			pass
		# Error during loading.
		else:
			loader = null
			break

func _add_child_scene() -> void:
	var scene = loader.get_resource().instantiate()
	scene.name = scene_name
	parent_node_to_add_child_to.add_child(scene, true)


#func update_progress():
#	var progress = float(loader.get_stage()) / loader.get_stage_count()
#	# Update your progress bar?
#	get_node("progress").set_progress(progress)
#
#	# ...or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()
#
#	# Call this on a paused animation. Use "true" as the second argument to
#	# force the animation to update.
#	get_node("animation").seek(progress * length, true)


func on_connection():
	pass
#	Server.get_test_name() #TODO test function

func _run_test() -> void:
	Gateway.connect_to_server("asdf", "asdfasdf", false)
	$LoginScreen.queue_free()
	print("Loading up the test director")
	var TestDirector = load("res://03_Tests/TestDirector.tscn").instantiate()
	TestDirector.set_name("TestDirector")
	add_child(TestDirector, true)
	if not client_test_scene == null:
		TestDirector.instance_test_scene(client_test_scene)

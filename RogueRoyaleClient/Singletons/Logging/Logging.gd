extends Node

# A way to print output to a text file instead of printing to console
@export var use_log_b: bool = false
@export var logging_enabled: bool = false
@export var server_logging_enabled: bool = false
var log_name : String = "user://CLIENT.log"
var log_file : FileAccess
var run_time : String
var n_server_sends = 0
var n_server_receives = 0
var log_b_file = "user://CLIENT_B.log"


func _ready():
	if use_log_b:
		log_name = log_b_file
	if ProjectSettings.get_setting("global/spawn_test_characters") and not use_log_b:
		logging_enabled = false
	if is_logging_enabled():
		_create_log_file()

func is_logging_enabled() -> bool:
	return logging_enabled

func log_server_send(info : String) -> void:
	if server_logging_enabled:
		info = "send " + str(n_server_sends) + " | " + info
		n_server_sends += 1
		_store_line(info)

func log_server_receive(info : String) -> void:
	if server_logging_enabled:
		info = "receive " + str(n_server_receives) + " | " + info
		n_server_receives += 1
		_store_line(info)

func _store_line(info : String) -> void:
	info = str(CommandFrame.frame) + " | " + info
	log_file.store_line(info)

func log_line(info : String) -> void:
	if logging_enabled:
		_store_line(info)

func log_object_vars(obj) -> void:
	if logging_enabled:
		var properties = obj.get_script().get_script_property_list()
		for property in properties:
			var obj_var = obj.get(property.name)
			if typeof(obj_var) == TYPE_OBJECT:
				log_object_vars(obj_var)
			Logging.log_line(property.name + " = " + str(obj.get(property.name)))

func log_rollback(info : String) -> void:
	if logging_enabled:
		var text = "ROLLBACK " + info
		log_line(text)

func _create_log_file():
	log_file = FileAccess.open(log_name, FileAccess.WRITE)

func log_dict_as_json(dict : Dictionary) -> void:
	if logging_enabled:
		log_file.log_line(JSON.new().stringify(dict))

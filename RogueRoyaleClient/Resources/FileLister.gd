@tool
extends Resource
class_name FileLister

@export_dir var folder_path : set = set_folder_path
@export var file_ending: String : get = get_file_ending, set = set_file_ending
@export var with_sub_folders: bool = false : set = set_with_sub_folders
@export var list_folders : bool = false

var all_file_paths : PackedStringArray = []
var all_folder_paths : PackedStringArray = []
var all_file_names : PackedStringArray = []
var searching = with_sub_folders
var folder
var all_folder_names : PackedStringArray = []
var loaded = false

func set_folder_path(_path : String) -> void:
		folder_path = _path

func set_file_ending(ending : String) -> void:
	file_ending = ending

func get_file_ending():
	return file_ending

func set_create_list_of_folders(to_list : bool) -> void:
	list_folders = to_list

func set_with_sub_folders(_with_sub : bool) -> void:
	with_sub_folders = _with_sub

func get_with_subfolders():
	return with_sub_folders

func _ready():
	load_resources()

func clear():
	all_file_paths.clear()
	all_folder_paths.clear()
	all_folder_names.clear()
	all_file_names.clear()
	loaded = false

func get_file_paths():
	return all_file_paths.duplicate()

func get_folder_names():
	return all_folder_names.duplicate()

func get_folder_paths():
	return all_folder_paths.duplicate()

func load_resources() -> void:
	if folder_path != "":
		all_file_paths.clear()
		all_folder_names.clear()
		all_folder_paths.clear()
		all_file_names.clear()
		var exists = DirAccess.dir_exists_absolute(folder_path)
		assert(exists, "Directory must exist")
		_loop_through_folder()
	loaded = true

func _loop_through_folder() -> void:
	var folders = DirAccess.get_directories_at(folder_path)
	if with_sub_folders:
		add_folders_to_array(folder_path, folders)
		_add_files_from_subfolders(folder_path)
	else:
		var files = DirAccess.get_files_at(folder_path)
		add_files_to_array(folder_path, files)
		add_folders_to_array(folder_path, folders)

func _add_files_from_subfolders(dir_path : String) -> void:
	var files = DirAccess.get_files_at(dir_path)
	add_files_to_array(dir_path, files)
	var sub_directories = DirAccess.get_directories_at(dir_path)
	add_folders_to_array(dir_path, sub_directories)
	for sub_dir in sub_directories:
		_add_files_from_subfolders(dir_path + "/" + sub_dir)

func add_files_to_array(dir_path : String, files : PackedStringArray) -> void:
	for file in files:
		if file.ends_with(file_ending):
			all_file_paths.append(dir_path + "/" + file)
			all_file_names.append(file)

func add_folders_to_array(dir_path : String, files : PackedStringArray) -> void:
	for file in files:
		all_folder_paths.append(dir_path + "/" + file)
		all_folder_names.append(file)

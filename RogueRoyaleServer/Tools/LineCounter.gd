extends Node

@export var file_array : Array[String] = []

var dev_counter = ""
var file_lister = FileLister.new()


func _ready():
	var all_file_paths = []
	for path in file_array:
		file_lister.clear()
		file_lister.with_sub_folders = true
		file_lister.set_folder_path(path)
		file_lister.set_file_ending(".gd")
		file_lister.load_resources()
		all_file_paths += Array(file_lister.get_file_paths())
	print("Found %s files" % [all_file_paths.size()])
		
	run_dev_line_counter(all_file_paths)

func run_dev_line_counter(all_paths : Array):
	var script_counter = 0
	var func_counter = 0
	var line_counter = 0
	var comment_counter = 0
	for i in all_paths:
		if ".gd" in i:
			script_counter += 1
			var file = FileAccess.open(i,FileAccess.READ)
			while !file.eof_reached():
				var line = file.get_line()
				line_counter+=1
				if "#" in line:
					comment_counter +=1
				if "func " in line:
					func_counter += 1
			file.close()
	dev_counter = "Total Scripts: " + str(script_counter)
	dev_counter += "\nTotal Functions: " + str(func_counter)
	dev_counter += "\nTotal Comments: " + str(comment_counter)
	dev_counter += "\nTotal lines of code: " + str(line_counter)
	dev_counter += "\nAverage lines per script: " + str(int(round(float(line_counter) / float(script_counter))))
	print(dev_counter)
	var debug = true


extends Node2D

@export var file_lister: Resource

var id_to_path = {}
@onready var pchar = load("res://Scenes/Characters/PlayerCharacter/PlayerCharacter.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
#func _ready():
#	file_lister as FileLister
#	print("Test Enemy scene loaded")
#	pass # Replace with function body.
#	var new_enemy = EnemyDummy
#	file_lister.load_resources()
#	var paths = file_lister.get_file_paths()
#	for path in paths:
#		var scene = load(path).instantiate()
#		var class_id = scene.get("class_id")
#		if class_id != null:
#			var num_id = id_to_int(class_id)
#			if num_id in id_to_path.keys():
#				assert(false) #,"This class_id already exists: " + str(class_id))
#			else:
#				id_to_path[num_id] = path
#	print(id_to_int("ZZZ"))

func id_to_int(id : String):
	id = id.to_upper()
	var ascii_A = ord("A")
	var a = ord(id[0]) - ascii_A
	var b = ord(id[1]) - ascii_A
	var c = ord(id[2]) - ascii_A
	var first_cantor = cantor(a, b)
	return cantor(first_cantor, c)

func cantor(a : int, b : int) -> int:
	return (a + b) * (a + b + 1) / 2 + b

# See https://en.wikipedia.org/wiki/Pairing_function#Inverting_the_Cantor_pairing_function
func reverse_cantor(cantor_number : int):
	var w = int((sqrt(8 * cantor_number + 1) - 1) / 2)
	var t = w * (w + 1) / 2
	var y = cantor_number - t
	var x = w - y
	return [x, y]
	
	
	

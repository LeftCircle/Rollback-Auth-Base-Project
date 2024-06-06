extends Node2D

@export var straight_path_scene: PackedScene

@onready var node_a = $LoadedNode
@onready var node_b = $LoadedNode2

func _ready():
	$Spring.connect_nodes($LoadedNode, $LoadedNode2)
	call_deferred("_add_paths")

func _physics_process(delta):
	update()


func _draw():
	draw_circle(node_a.global_position, 100, Color.RED)
	draw_circle(node_b.global_position, 100, Color.GREEN)

func _add_paths():
	var new_path = straight_path_scene.instantiate()
	new_path.init($Spring, [$LoadedNode, $LoadedNode2], TileMap.new())
	$Spring.add_child(new_path)

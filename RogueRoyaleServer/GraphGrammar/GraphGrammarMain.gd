extends Camera2D

@export var rule_maker: Resource : set = set_rule_maker
@export var rule_viewer: Resource : set = set_rule_viewer
@export var start_maker: Resource : set = set_start_maker
@export var start_viewer: Resource : set = set_start_viewer
@export var graph_builder: Resource : set = set_graph_builder
@export var grammar_rule_save: Script
@export var node_info: Resource
@export var door_info: Resource

@onready var vbox_container = $VBoxContainer
@onready var active_scene_container = $ActiveScene

func set_rule_maker(res : Resource) -> void:
	rule_maker = res

func set_rule_viewer(res : Resource) -> void:
	rule_viewer = res

func set_start_maker(res : Resource) -> void:
	start_maker = res

func set_start_viewer(res : Resource) -> void:
	start_viewer = res

func set_graph_builder(res : Resource) -> void:
	graph_builder = res

func _ready():
	pass

func zoom_camera():
	if Input.is_action_just_released("zoom_out"):
		zoom.x += 1
		zoom.y += 1
	if Input.is_action_just_released('zoom_in') and zoom.x > 1 and zoom.y > 1:
		zoom.x -= 1
		zoom.y -= 1

func _physics_process(_delta):
	zoom_camera()

func _input(event):
	if event.as_text() == "Escape":
		vbox_container.show()
		for node in active_scene_container.get_children():
			node.call_deferred("queue_free")

func _on_BuildStart_pressed():
	vbox_container.hide()
	active_scene_container.add_child(start_maker.instantiate())

func _on_ViewStart_pressed():
	vbox_container.hide()
	active_scene_container.add_child(start_viewer.instantiate())

func _on_BuildRule_pressed():
	vbox_container.hide()
	active_scene_container.add_child(rule_maker.instantiate())

func _on_ViewRule_pressed():
	vbox_container.hide()
	active_scene_container.add_child(rule_viewer.instantiate())

func _on_BuildGraph_pressed():
	vbox_container.hide()
	active_scene_container.add_child(graph_builder.instantiate())

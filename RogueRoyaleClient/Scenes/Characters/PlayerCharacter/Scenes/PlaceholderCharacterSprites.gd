extends Node2D
class_name PlayerSprites

var visible_node
var previous_global_pos : Vector2 = Vector2.ZERO
var next_global_pos : Vector2 = Vector2.ZERO


@onready var Run = $Run
@onready var Idle = $Idle
@onready var Attack = $Attack
@onready var Spell = $Spell
@onready var Death = $Death
@onready var Hurt = $Hurt
@onready var Roll = $Roll

func _ready():
	visible_node = Idle
	Idle.show()
	Run.hide()
	Attack.hide()
	Spell.hide()
	Death.hide()
	Hurt.hide()
	Roll.hide()

#func set_next_global_position(new_pos : Vector2) -> void:
#	previous_global_pos = next_global_pos
#	next_global_pos = new_pos

func physics_process(input_actions : InputActions) -> void:
	var looking_vec = input_actions.get_looking_vector()
	if looking_vec.x < 0:
		scale.x = -1
	else:
		scale.x = 1

func set_direction(looking_vec : Vector2) -> void:
	if looking_vec.x < 0:
		scale.x = -1
	else:
		scale.x = 1

func show_sprite_node(node):
	if not node == visible_node:
		visible_node.hide()
		node.show()
		visible_node = node

func show_sprite(node_str : String) -> void:
	if node_str == "Run":
		show_sprite_node(Run)
	elif node_str == "Idle":
		show_sprite_node(Idle)
	elif node_str == "Attack":
		show_sprite_node(Attack)
	elif node_str == "Spell":
		show_sprite_node(Spell)
	elif node_str == "Death":
		show_sprite_node(Death)
	elif node_str == "Hurt":
		show_sprite_node(Hurt)
	elif node_str == "Roll":
		show_sprite_node(Roll)

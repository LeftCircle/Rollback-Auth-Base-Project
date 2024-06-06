extends Area2D
class_name BlockBox

var entity

func _ready():
	add_to_group("BlockBox")
	add_to_group("Rollback")

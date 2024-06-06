@tool
extends Sprite2D

func _ready():
	randomize()
	self.frame = randi() % 7 + 10

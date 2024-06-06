@tool
extends Sprite2D

func _ready():
	randomize()
	if randi() % 2 == 1:
		self.frame = randi() % 5 + 1
	else:
		self.frame = randi() % 3 + 7

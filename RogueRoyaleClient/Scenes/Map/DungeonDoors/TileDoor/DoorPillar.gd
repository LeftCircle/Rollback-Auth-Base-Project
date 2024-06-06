extends StaticBody2D

@export var is_open: bool = true

@onready var animation = $AnimationPlayer

func _ready():
	open_or_close()

func set_is_open(new_is_open : bool) -> void:
	is_open = new_is_open
	open_or_close()

func open_or_close():
	if is_open:
		open()
	else:
		close()

func open():
	animation.play_backwards("Close")

func close():
	animation.play("Close")

extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func zoom_camera():
#	if Input.is_action_just_released("zoom_in"):
#		$Camera2D.zoom.x += 0.25
#		$Camera2D.zoom.y += 0.25
#		print('Zoom in occured')
#	if Input.is_action_just_released('zoom_out') and $Camera2D.zoom.x > 1 and $Camera2D.zoom.y > 1:
#		$Camera2D.zoom.x -= 0.25
#		$Camera2D.zoom.y -= 0.25
#		print('Zoom out occured')

func zoom_camera():
	if Input.is_action_just_released("zoom_out"):
		zoom.x += 5
		zoom.y += 5
	if Input.is_action_just_released('zoom_in') and zoom.x > 1 and zoom.y > 1:
		zoom.x -= 5
		zoom.y -= 5


func _physics_process(_delta):
	zoom_camera()

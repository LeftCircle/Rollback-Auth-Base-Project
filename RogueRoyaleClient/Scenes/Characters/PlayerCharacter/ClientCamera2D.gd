extends Camera2D


func zoom_camera():
	if Input.is_action_just_released("zoom_out"):
		zoom.x += 0.1
		zoom.y += 0.1
	if Input.is_action_just_released('zoom_in') and zoom.x > 1 and zoom.y > 1:
		zoom.x -= 0.1
		zoom.y -= 0.1



func _physics_process(_delta):
	zoom_camera()

extends Area2D

var collision_occured = false

func _on_area_entered(area):
	collision_occured = true

extends Node2D
class_name RoomDoorController

var doors_closed = false

func close_doors():
	if doors_closed == false:
		doors_closed = true
		for child in get_children():
			if child.is_in_group("Doors"):
				child.close()

func open_doors():
	if doors_closed == true:
		doors_closed = false
		for child in get_children():
			if child.is_in_group("Doors"):
				child.open()

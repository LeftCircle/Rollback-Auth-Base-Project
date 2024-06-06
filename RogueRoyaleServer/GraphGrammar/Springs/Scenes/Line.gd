extends Line2D

var node_a
var node_b

func _init():
	width = 2

func _process(_delta):
	points = [node_a.global_position, node_b.global_position]


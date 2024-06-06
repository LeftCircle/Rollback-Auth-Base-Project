@tool
extends Resource
class_name RandomWalker

enum {UP, DOWN, LEFT, RIGHT}
var steps_taken = 0
var viable_directions = []
var walker_position
var x_limits
var y_limits
var step_map = {
	UP : Vector2(0, 1),
	DOWN : Vector2(0, -1),
	LEFT : Vector2(-1, 0),
	RIGHT : Vector2(1, 0)
}

func init(pos : Vector2, _x_limits : Vector2, _y_limits : Vector2):
	walker_position = pos
	x_limits = _x_limits
	y_limits = _y_limits

func take_step() -> Vector2:
	get_viable_directions()
	var direction = viable_directions[Map.map_rng.randi() % viable_directions.size()]
	walker_position += step_map[direction]
	return walker_position

func get_viable_directions() -> void:
	viable_directions.clear()
	if walker_position.x > x_limits[0]:
		viable_directions.append(LEFT)
	if walker_position.x < x_limits[1]:
		viable_directions.append(RIGHT)
	if walker_position.y > y_limits[0]:
		viable_directions.append(DOWN)
	if walker_position.y < y_limits[1]:
		viable_directions.append(UP)


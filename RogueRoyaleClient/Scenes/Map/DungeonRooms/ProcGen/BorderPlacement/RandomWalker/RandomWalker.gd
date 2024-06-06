@tool
extends Resource
class_name RandomWalker

enum {UP, DOWN, LEFT, RIGHT}
var steps_taken = 0
var viable_directions = []
var walker_position
var rect2_to_fill : Rect2
var step_map = {
	UP : Vector2(0, 1),
	DOWN : Vector2(0, -1),
	LEFT : Vector2(-1, 0),
	RIGHT : Vector2(1, 0)
}

func init(pos : Vector2, _rect2_to_fill : Rect2):
	randomize()
	walker_position = pos
	rect2_to_fill = _rect2_to_fill

func take_step() -> Vector2:
	get_viable_directions()
	var direction = viable_directions[WorldState.map_rng.randi() % viable_directions.size()]
	walker_position += step_map[direction]
	return walker_position

func get_viable_directions() -> void:
	viable_directions.clear()
	if walker_position.x > rect2_to_fill.position.x:
		viable_directions.append(LEFT)
	if walker_position.x < rect2_to_fill.end.x:
		viable_directions.append(RIGHT)
	if walker_position.y > rect2_to_fill.position.y:
		viable_directions.append(DOWN)
	if walker_position.y < rect2_to_fill.end.y:
		viable_directions.append(UP)


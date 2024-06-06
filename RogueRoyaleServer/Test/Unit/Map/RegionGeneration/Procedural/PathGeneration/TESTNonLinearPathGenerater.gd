extends GutTest
# This will take an isolated instance of the pathing system and run a few simple tests without rooms
# This is a bit annoying though since the path builder takes a navigation map to see if points are valid

var TILE_SIZE = ProjectSettings.get_setting("global/TILE_SIZE")
var test_path = [Vector2.ZERO, Vector2(10, 0) * TILE_SIZE]
var path_builder = NonLinearRegionPathBuilder.new()


func _init_path_builder() -> void:
	pass

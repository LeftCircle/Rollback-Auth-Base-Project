@tool
extends RegionFromGrammar
class_name TestRegionFromGrammar

func _on_all_rules_applied():
	_deactivate_nodes_and_springs()
	_spawn_rooms()
	path_between_room_generator.init(get_region_rect2_tiles(), get_rect2_tiles_from_rooms(), region_filler_tilemap, get_rect2_tiles_from_rooms(), get_rooms())
	path_between_room_generator.region = self
	region_built = true
	emit_signal("region_generation_complete")

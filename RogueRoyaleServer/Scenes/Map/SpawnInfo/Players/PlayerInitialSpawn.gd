extends Resource
class_name PlayerSpawnResource
# Goal : Determine the spawn location of a player based on the map.
# {player_id, spawn_location}
var spawned_players = {}
# Take the region node as an argument, then get the center of the largest room and
# Set this to the spawn point.
func region_spawn_point(region, player_id : int) -> Vector2:
	if spawned_players.has(player_id):
		return spawned_players[player_id]
	var spawn_room = get_spawn_room(region)
	var center = spawn_room.room_rect2.position + spawn_room.room_rect2.size / 2
	spawned_players[player_id] = center
	return center

# Debug spawn selection until logic is actually determined.
func get_spawn_room(region):
	var spawn_room = region.get_spawn_room()
	if not is_instance_valid(spawn_room):
		return region.get_rooms()[0]
	return spawn_room

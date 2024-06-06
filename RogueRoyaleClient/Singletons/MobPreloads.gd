extends Node

# This will preload the instances of each mob so that they can be easily accessed
# In order to avoid adding mobs here all the time, we could also load the mobs
# from a json and autoload each mob?


var enemy_ids = {
}

func _ready():
	pass

# Returns an instance of the preloaded enemy based on the enemy id
func instance_enemy_by_type(enemy_type : String):
	return enemy_ids[enemy_type].instantiate()

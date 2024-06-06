extends Node2D
class_name NetcodeNode2D
# Like a Node2D, but comes with netcode functions!

var netcode = NetcodeBaseEntity.new()

func _init():
	_netcode_init()

func _netcode_init():
	assert(false) #,"To be overwritten")

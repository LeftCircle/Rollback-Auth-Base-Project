extends Node
class_name FXManager

var fx_manager_data = FXManagerData.new()
var netcode = NetcodeForFXManager.new()
var execution_frame : int = 0
var player_id

func _init():
	netcode.init(self, "FXM", fx_manager_data, FXManagerCompresser.new())

func _ready():
	#add_child(netcode)
	# TO DO -> this is awful
	player_id = get_parent().player_id
	#assert(player_id != 0) #," debug. This is an awful way to set player id")

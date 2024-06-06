extends BaseHitboxRollback
class_name MeleeNetcodeBase

var netcode = NetcodeForModules.new()
var component_data = ComponentData.new()
var frame : int = 0

func _init():
	_netcode_init()

func _netcode_init():
	assert(false) #,"Child classes must override _netcode_init()")

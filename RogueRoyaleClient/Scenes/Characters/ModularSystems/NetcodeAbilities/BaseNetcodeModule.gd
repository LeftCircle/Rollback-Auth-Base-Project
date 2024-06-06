extends BaseNodeComponent
class_name BaseNetcodeModule

var netcode = NetcodeForModules.new()

func _init():
	super._init()
	_netcode_init()

func _netcode_init():
	assert(false) #,"Child classes must override _netcode_init()")

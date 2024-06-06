extends Node2D
class_name RangeNetcodeBase

var netcode = NetcodeForModules.new()
var component_data = ComponentData.new()
var frame : int = 0
var is_entity = false
var data_container
var entity

func _init():
	_netcode_init()

func _netcode_init():
	assert(false, "Child classes must override _netcode_init()")

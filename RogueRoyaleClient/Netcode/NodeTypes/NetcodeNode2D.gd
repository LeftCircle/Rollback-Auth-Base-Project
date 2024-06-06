extends Node2D
class_name NetcodeNode2D
# Like a Node2D, but comes with netcode functions!

var netcode = NetcodeBaseReference.new()
var frame : int
var is_entity = true

func _init():
	_netcode_init()

func _netcode_init():
	assert(false) #,"To be overwritten")

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
	assert(false, "Is this even used?")
	var server_data = netcode.state_compresser.decompress(frame, bit_packer)
	server_data.set_obj_with_data(self)
	#assert(false) #,"To be overwritten")

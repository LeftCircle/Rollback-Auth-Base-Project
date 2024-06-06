extends RefCounted
class_name BaseLagCompComponent

var history
var netcode

func _init():
	_netcode_init()
	_init_history()

func _netcode_init():
	pass

func _init_history():
	#assert(false) #,"Must be overwritten!")
	pass

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	var server_hist = netcode.state_compresser.decompress(bit_packer)
	server_hist.frame = frame
	history.add_data(server_hist)

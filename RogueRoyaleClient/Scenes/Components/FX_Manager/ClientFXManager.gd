extends FXManager
class_name ClientFXManager

func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	print("FX manager decompression")
	netcode.state_compresser.decompress(bit_packer)
	Logging.log_line("Parry fx received on frame " + str(frame))

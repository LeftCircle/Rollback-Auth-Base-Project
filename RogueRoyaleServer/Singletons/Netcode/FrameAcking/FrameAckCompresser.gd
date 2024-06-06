extends RefCounted
class_name FrameAckCompresser

static func compress_acked_frames_to_bytes(bit_packer : OutputMemoryBitStream, acked_frames : Array):
	var n_acked_frames = acked_frames.size()
	bit_packer.variable_compress(n_acked_frames)
	for i in range(n_acked_frames):
		bit_packer.compress_frame(acked_frames[i])


static func decompress_acked_frames(bit_packer : OutputMemoryBitStream) -> Array:
	var acked_frames = []
	var n_acked_frames = bit_packer.variable_decompress(TYPE_INT)
	for i in range(n_acked_frames):
		acked_frames.append(bit_packer.decompress_frame())
	return acked_frames
#
#static func get_acked_frames_from_compressed_ack(n_acks : int, compressed_acks : Array) -> Array:
#	var frames = []
#	for i in range(n_acks):
#		var c_frame_start = (3 * i)
#		var c_frame_end = 2 + (3 * i + 1) - 1
#		var comp_frame_data = compressed_acks.slice(c_frame_start, c_frame_end)
#		frames.append(BaseCompression.decompress_frame_from_3_bytes(comp_frame_data))
#	return frames

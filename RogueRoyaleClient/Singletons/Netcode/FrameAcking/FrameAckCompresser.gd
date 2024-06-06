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
	for _i in range(n_acked_frames):
		acked_frames.append(bit_packer.decompress_frame())
	return acked_frames

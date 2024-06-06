extends RefCounted
class_name PingDataCompresser

static func compress(ping_data : PingData) -> Array:
	var c_frame = BaseCompression.compress_frame_into_3_bytes(ping_data.frame)
	var c_frac = BaseCompression.compress_float_into_x_bits(ping_data.frame_fraction, 4, false, 4)
	return c_frame + c_frac

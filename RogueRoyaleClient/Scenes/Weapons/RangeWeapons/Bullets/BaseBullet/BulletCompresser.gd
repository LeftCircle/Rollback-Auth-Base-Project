extends BaseModuleCompresser
class_name BulletCompresser

var global_position : Vector2
var velocity : Vector2
var despawn : bool = false

func _init_server_data():
	server_data = BulletData.new()

#func compress(module_data : BulletData) -> Array:
##	var hbox_to_spawn_bits = BaseCompression.variable_compress(module_data.hbox_to_spawn, true)
##	var vel_bits = BaseCompression.variable_compress(module_data.velocity, true)
##	var despawn_bits = BaseCompression.compress_bool(module_data.to_despawn)
##	return hbox_to_spawn_bits + vel_bits + despawn_bits
#
#func decompress(bit_reader) -> BulletData:
#	server_data.hbox_to_spawn = BaseCompression.variable_decompress(bit_reader, TYPE_VECTOR2, true)
#	server_data.velocity = BaseCompression.variable_decompress(bit_reader, TYPE_VECTOR2, true)
#	server_data.to_despawn = bit_reader.get_bool()
#	return server_data

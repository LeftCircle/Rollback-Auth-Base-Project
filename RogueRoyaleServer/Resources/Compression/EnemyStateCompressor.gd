extends BaseCompression
class_name EnemyStateCompression

const n_state_bits = 1

var bitfield = {
	"health" : 1 << 0,
	"position" : 1 << 1,
	"velocity" : 1 << 2,
	"state" : 1 << 3
}

var n_bitfield_bits

func init_compresser():
	pass

func _init():
	n_bitfield_bits = bitfield.size()


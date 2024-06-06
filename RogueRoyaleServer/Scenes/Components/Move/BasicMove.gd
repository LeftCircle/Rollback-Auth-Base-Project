extends BaseNetcodeModule
class_name BasicMove

var velocity = Vector2.ZERO
var delta = CommandFrame.frame_length_sec

func _netcode_init():
	netcode.init(self, "BMV", MoveData.new(), MoveCompression.new())

func execute(entity, velocity) -> void:
	entity.global_position += velocity * delta

extends ClientNetcodeModule
class_name Knockback

const NO_DIRECTION = Vector2.INF

func _netcode_init():
	add_to_group("Knockback")
	data_container = KnockbackData.new()
	netcode.init(self, "KBK", data_container, KnockbackCompresser.new())

func _ready():
	netcode.state_data = data_container

func connect_to_entity(connected_entity):
	super.connect_to_entity(connected_entity)
	KnockBackSystem.register_entity(connected_entity)

func disconnect_from_entity() -> void:
	KnockBackSystem.unregister_entity(entity)
	super.disconnect_from_entity()

func set_data(direction : Vector2, speed : int, decay : int) -> void:
	data_container.knockback_direction = direction
	data_container.knockback_speed = speed
	data_container.knockback_decay = decay

extends BaseNetcodeModule
class_name Knockback

const NO_DIRECTION = Vector2.INF

func _netcode_init():
	add_to_group("Knockback")
	data_container = KnockbackData.new()
	netcode.init(self, "KBK", data_container, KnockbackCompresser.new())

func _ready():
	netcode.state_data = data_container

func add_owner(new_entity) -> void:
	super.add_owner(new_entity)
	entity.add_to_group("KnockbackEntity")

func set_data(direction : Vector2, speed : int, decay : int) -> void:
	data_container.knockback_direction = direction
	data_container.knockback_speed = speed
	data_container.knockback_decay = decay

extends Sprite2D
class_name OverwatchHealth

@export var visible_numbers: bool = false

@onready var current_health_label = $CurrentHealthLabel
@onready var max_health_label = $MaxHealthLabel

var segment_value = ProjectSettings.get_setting("global/health_segment_value")

# Need to get the number of segments of each health type
func init(health_segments : int, armor_segments : int, shield_segments : int) -> void:
	self.material.set("shader_parameter/health_segments", health_segments)
	self.material.set("shader_parameter/armor_segments", armor_segments)
	self.material.set("shader_parameter/shield_segments", shield_segments)

func _ready():
	current_health_label.visible = visible_numbers
	max_health_label.visible = visible_numbers

func _on_health_changed(health_data : HealthData) -> void:
	self.material.set("shader_parameter/health_segments", health_data.health_segments)
	self.material.set("shader_parameter/armor_segments", health_data.armor_segments)
	self.material.set("shader_parameter/shield_segments", health_data.shield_segments)
	var health_percent = _get_percent(health_data.current_health, health_data.health_segments)
	var armor_percent = _get_percent(health_data.current_armor, health_data.armor_segments)
	var shield_percent = _get_percent(health_data.current_shields, health_data.shield_segments)
	self.material.set("shader_parameter/health_percent", health_percent)
	self.material.set("shader_parameter/armor_percent", armor_percent)
	self.material.set("shader_parameter/shield_percent", shield_percent)
	max_health_label.text = str(_get_max_health(health_data))
	current_health_label.text = str(_get_current_health_total(health_data))

func _get_percent(current_health : int, health_segments : int) -> float:
	return float(current_health) / float(health_segments * segment_value)

func _get_max_health(health_data : HealthData) -> int:
	return (health_data.health_segments + health_data.armor_segments + health_data.shield_segments) * segment_value

func _get_current_health_total(health_data : HealthData) -> int:
	return health_data.current_armor + health_data.current_health + health_data.current_shields

extends Control
class_name PlayerGUI

@onready var health_gui = $CanvasLayer/OverwatchHealth
@onready var ammo_gui = $CanvasLayer/Ammo


func connect_health(health_component : ClientHealth) -> void:
	health_component.connect("health_changed", health_gui._on_health_changed)





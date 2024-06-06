extends Sprite2D
class_name AmmoGUI

func init(max_ammo : int, current_ammo : int) -> void:
	_on_ammo_changed(max_ammo, current_ammo)

func _on_ammo_changed(max_ammo : int, current_ammo : int) -> void:
	self.material.set("shader_parameter/max_ammo", max_ammo)
	self.material.set("shader_parameter/current_ammo", current_ammo)


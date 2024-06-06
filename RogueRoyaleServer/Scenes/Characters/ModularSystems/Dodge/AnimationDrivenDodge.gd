extends BaseNetcodeModule
class_name AnimationDrivenDodge

func _netcode_init() -> void:
	data_container = DodgeData.new()
	netcode.init(self, "ADD", data_container, DodgeCompresser.new())
	add_to_group("Dodge")

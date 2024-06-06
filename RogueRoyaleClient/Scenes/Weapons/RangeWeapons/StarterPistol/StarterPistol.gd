extends ClientRangedWeapon
class_name StarterPistol

func _netcode_init():
	netcode.init(self, "PST", BaseRangeWeaponData.new(), BaseRangeWeaponCompresser.new())

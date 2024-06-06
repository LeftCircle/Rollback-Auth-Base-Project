extends Node
class_name BaseEntityNetcodeSceneToTest

var netcode = NetcodeBaseEntity.new()

func _init():
	netcode.init(self, "BET", BaseEntityNetcodeTestData.new(), BaseEntityNetcodeTestCompresser.new())

func send_data():
	WorldState.add_netcode_to_compress(netcode)

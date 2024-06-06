extends SpawnedRoomOutline

func _netcode_init():
	netcode.init(self, "PLT", RoomOutlineData.new(), RoomOutlineCompresser.new())


extends RoomOutline


func _netcode_init():
	netcode.init(self, "FST", RoomOutlineData.new(), RoomOutlineCompresser.new())

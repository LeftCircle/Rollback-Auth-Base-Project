@tool
extends RoomOutline

func _netcode_init():
	netcode.init(self, "FFS", RoomOutlineData.new(), RoomOutlineCompresser.new())

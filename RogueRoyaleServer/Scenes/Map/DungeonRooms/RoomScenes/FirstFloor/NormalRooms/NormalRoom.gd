@tool
extends RoomOutline

func _netcode_init():
	netcode.init(self, "NRM", RoomOutlineData.new(), RoomOutlineCompresser.new())

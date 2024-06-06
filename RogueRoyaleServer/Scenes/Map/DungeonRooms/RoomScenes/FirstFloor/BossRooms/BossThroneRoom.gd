@tool
extends RoomOutline

func _netcode_init():
	netcode.init(self, "BTR", RoomOutlineData.new(), RoomOutlineCompresser.new())

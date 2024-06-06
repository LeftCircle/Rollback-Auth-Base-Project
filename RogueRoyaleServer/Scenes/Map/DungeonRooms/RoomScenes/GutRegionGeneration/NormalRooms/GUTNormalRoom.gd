@tool
extends RoomOutline
class_name GUTNormalRoom

func _netcode_init():
	netcode.init(self, "GNR", RoomOutlineData.new(), RoomOutlineCompresser.new())


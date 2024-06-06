@tool
extends RoomOutline
class_name GUTNormalRoom

func _netcode_init():
	netcode.init(self, "GNR", RoomOutlineData.new(), RoomOutlineCompresser.new())

func _ready():
	super._ready()
	$RoomTiles/VoronoiTileMap.spawn_voronoi_tiles()
	$BorderTiles/WallTiles.spawn_voronoi_tiles()

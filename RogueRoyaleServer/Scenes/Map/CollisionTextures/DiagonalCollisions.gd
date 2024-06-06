extends TileMap
class_name RegionFillerTilemap

func place_edge_tiles(region : RegionFromGrammar):
	var region_rect_tiles = region.get_region_rect2_tiles()
	region_rect_tiles = region_rect_tiles.grow(region.n_tiles_to_grow_region)
	for x in range(region_rect_tiles.position.x, region_rect_tiles.end.x):
		region.region_filler_tilemap.set_cell(0, Vector2i(x, region_rect_tiles.position.y), 1, Vector2i.ZERO)
		region.region_filler_tilemap.set_cell(0, Vector2i(x, region_rect_tiles.end.y), 1, Vector2i.ZERO)
	for y in range(region_rect_tiles.position.y, region_rect_tiles.end.y):
		region.region_filler_tilemap.set_cell(0, Vector2i(region_rect_tiles.position.x, y), 1, Vector2i.ZERO)
		region.region_filler_tilemap.set_cell(0, Vector2i(region_rect_tiles.end.x, y), 1, Vector2i.ZERO)

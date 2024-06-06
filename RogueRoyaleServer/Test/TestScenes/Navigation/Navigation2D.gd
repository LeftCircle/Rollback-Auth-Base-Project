extends Navigation2D

@onready var nav_poly_inst = $NavigationRegion2D
var occured = false

func _ready():
	nav_poly_inst.navpoly = NavigationPolygon.new()
	_set_start_points()
	_coutout_polygon()
	nav_poly_inst.navpoly.make_polygons_from_outlines()
	nav_poly_inst.enabled = false
	nav_poly_inst.enabled = true
	var poly_filler = PolygonFiller.new()
	await get_tree().create_timer(1).timeout
	poly_filler.init($DiagonalCollisions, self, nav_poly_inst.navpoly)
	poly_filler.fill_nav2D_world_to_tiles(0)

func _input(event):
	if event.as_text() == "Escape" and not occured:
		_set_start_points()
		_coutout_polygon()
		nav_poly_inst.navpoly.make_polygons_from_outlines()
		occured = true

func _set_start_points():
	var points = PackedVector2Array([Vector2(2 * 64, 2 * 64), Vector2(5 * 64, 2 * 64),
								Vector2(5 * 64, 5 * 64), Vector2(2 * 64, 5 * 64)])
	nav_poly_inst.navpoly.add_outline(points)

func _coutout_polygon():
	var points = PackedVector2Array([Vector2(3 * 64, 3 * 64), Vector2(4, 3) * 64,
								Vector2(4, 4) * 64, Vector2(3, 4) * 64])
	nav_poly_inst.navpoly.add_outline(points)


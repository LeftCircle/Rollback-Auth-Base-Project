extends GutTestRogue

@export var rollback_anim_player: PackedScene
var anim_player
var has_ready_run = false

func _ready():
	print(rollback_anim_player.to_string())

func test_load():
	assert_true(anim_player != null)

extends GutTestRogue

var latency_hud_path = "res://Scenes/Characters/PlayerCharacter/HUD/LatencyTracker/LatencyTrackerHUD.tscn"

func test_init():
	var latency_hud = load(latency_hud_path).instantiate()
	assert_true(is_instance_valid(latency_hud))
	latency_hud.free()

func test_new_remote_latency() -> void:
	var latency_hud = load(latency_hud_path).instantiate()
	ObjectCreationRegistry.add_child(latency_hud)
	var test_id = 12345
	var test_frames = 1
	latency_hud._on_remote_frames_ahead_update(test_id, test_frames)
	assert_true(_has_latency_label_for_id(latency_hud, test_id))
	latency_hud.queue_free()

func _has_latency_label_for_id(latency_hud : LatencyTrackerHUD, player_id : int) -> bool:
	var label_name = str(player_id) + "FrameLatency"
	var node_path = "VBoxContainer/" + label_name
	return latency_hud.has_node(node_path)

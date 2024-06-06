extends RefCounted
class_name SceneFreer


static func queue_scenes_free(scenes: Array) -> void:
	for scene in scenes:
		scene.queue_free()

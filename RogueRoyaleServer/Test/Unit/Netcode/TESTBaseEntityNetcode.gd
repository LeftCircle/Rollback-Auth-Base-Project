extends GutTest

var test_scene_path = "res://Test/Unit/Netcode/BaseEntityNetcodeScene/BaseEntityNetcodeScene.tscn"

func test_base_entity_netcode_assigns_instance_id():
	ObjectCreationRegistry.serialize_class_id(test_scene_path)
	var first_scene = _instance_test_scene()
	var second_scene = _instance_test_scene()
	assert_true(first_scene.netcode.class_instance_id == 0 and second_scene.netcode.class_instance_id == 1)
	first_scene.queue_free()
	second_scene.queue_free()

func _instance_test_scene():
	var scene = load(test_scene_path).instantiate()
	ObjectCreationRegistry.add_child(scene)
	return scene

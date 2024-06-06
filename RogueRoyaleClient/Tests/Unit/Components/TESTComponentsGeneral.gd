extends GutTestRogue


func test_components_other_than_health_are_not_lag_comp() -> void:
	var player : ClientPlayerCharacter = await init_player_character(randi_range(0, 1000000))
	_test_if_components_are_lag_comp(player)
	var template : PlayerTemplate = await init_player_template(randi_range(0, 1000000))
	_test_if_components_are_lag_comp(template)
	

func _test_if_components_are_lag_comp(entity) -> void:
	for component in entity.get_components():
		if component.netcode.class_id == "HLT":
			assert_true(component.is_lag_comp)
		else:
			assert_false(component.is_lag_comp)

func test_client_predicted_component_instance_id_is_neg_one() -> void:
	# This is to prevent the first instance of a component from stopping the first
	# server received component from being tracked in ObjectsInScene when queued free. 
	var knockback : C_Knockback = await instance_scene_by_id("KBK")
	assert_eq(knockback.netcode.class_instance_id, -1)

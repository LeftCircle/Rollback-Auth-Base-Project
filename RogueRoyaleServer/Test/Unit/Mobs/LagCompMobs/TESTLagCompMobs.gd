extends GutTest

var dummy_mob_path = "res://Scenes/Characters/Enemies/BasicEnemies/Dummy/S_EnemyDummy.tscn"


func test_dummy_spawns() -> void:
	var dummy_mob = TestFunctions.instance_scene(dummy_mob_path)
	await get_tree().process_frame
	assert_true(is_instance_valid(dummy_mob))
	TestFunctions.queue_scenes_free([dummy_mob])


func test_lag_comp_hurtbox_spawns() -> void:
	var dummy_mob = TestFunctions.instance_scene(dummy_mob_path)
	var character = TestFunctions.init_player_character()
	Server.on_player_verified(character.player_id)
	var dummy_position = Vector2.ZERO
	var character_position = Vector2(0, 100)
	dummy_mob.global_position = dummy_position
	character.global_position = character_position
	await get_tree().process_frame

	var past_hurtbox = dummy_mob.lagcomp_hurtbox_spawner.get_past_hurtbox_for(character)

	assert_true(dummy_mob.hurtbox.collision_shape.disabled)
	assert_true(is_instance_valid(past_hurtbox))
	TestFunctions.queue_scenes_free([dummy_mob, character])



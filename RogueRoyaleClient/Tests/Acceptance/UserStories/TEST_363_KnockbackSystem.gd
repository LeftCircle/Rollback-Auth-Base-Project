extends GutTestRogue

# AC 2:
# If an entity gets hit twice, only one knockback component is generated instead of two.
# Simply replace the old knockback component with the new data
func test_only_one_knockback_component_after_two_hits() -> void:
	# Create a character then two knockback components.
	# Add one knockback component to the character, then the other
	# assert that the character only has one knockback component, and that the
	# direction and velocity have been updated.
	var character = await init_player_character()
	var knockback1 : C_Knockback = await instance_scene_by_id("KBK")
	var knockback2 : C_Knockback = await instance_scene_by_id("KBK")
	knockback1.data_container.knockback_direction = Vector2(1, 0)
	knockback1.data_container.knockback_speed = 100
	knockback1.data_container.knockback_decay = 10
	knockback2.data_container.knockback_direction = Vector2(0, 1)
	knockback2.data_container.knockback_speed = 300
	knockback2.data_container.knockback_decay = 10
	character.add_component(0, knockback1)
	character.add_component(0, knockback2)
	var knockback_component = character.get_component("Knockback")
	assert_eq(knockback_component, knockback1)
	assert_true(knockback1.data_container.matches(knockback2.data_container))
	assert_false(PredictedCreationSystem.has_component(0, knockback2))
	assert_true(PredictedCreationSystem.has_component(0, knockback1))


func test_adding_a_component_maps_component_id_to_component() -> void:
	# Create a character and a knockback component.
	# Add the knockback component to the character, then assert that the character has the knockback component
	var character = await init_player_character()
	var knockback : C_Knockback = await instance_scene_by_id("KBK")
	character.add_component(0, knockback)
	var has_class_id = character.components.class_id_to_component.has(knockback.netcode.class_id)
	assert_true(has_class_id)
	if has_class_id:
		assert_eq(character.components.class_id_to_component[knockback.netcode.class_id], knockback)

func test_removing_a_component_removes_class_id_to_component_mapping() -> void:
	# Create a character and a knockback component.
	# Add the knockback component to the character, then remove it
	# assert that the character no longer has the knockback component
	var character = await init_player_character()
	var knockback : C_Knockback = await instance_scene_by_id("KBK")
	character.add_component(0, knockback)
	character.remove_component(knockback)
	var has_class_id = character.components.class_id_to_component.has(knockback.netcode.class_id)
	assert_false(has_class_id)
	character.add_component(0, knockback)
	assert_true(character.components.class_id_to_component.has(knockback.netcode.class_id))
	character.remove_and_immediately_delete_component(knockback)
	assert_false(character.components.class_id_to_component.has(knockback.netcode.class_id))

func test_adding_a_second_component_tracks_the_existing_component_as_updated() -> void:
	# already implemented but no test atm
	pass


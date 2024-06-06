extends GutTestRogue

# Miss Prediction Smoothing - Attack Prediction

#1. Clients locally predict hit detection
#2. If client_a hits client_b, client_a locally predicts the hit effect on client_b
#4. When a client predicts being hit, they generate a client side hit component
#
#    a. When the server frame for the hit comes, the client side hit component is queued free
#
#5. Predicted components lifetimes are tracked just like regular server components. 
# Called when the node enters the scene tree for the first time.

# AC 1/2/4 of User Story 731
func test_client_detects_hurtbox_hit() -> void:
	var hurt_character = TestFunctions.init_player_character(randi_range(0, 100000))
	var hit_character = TestFunctions.init_player_character(randi_range(0, 100000))

	hurt_character.global_position = Vector2(0, 0)
	hit_character.global_position = Vector2(1000, 0)
	await get_tree().physics_frame

	var primary_weapon = hit_character.get_primary_weapon()
	
	primary_weapon.global_position = hurt_character.global_position
	primary_weapon.activate_hitbox()
	await get_tree().physics_frame
	
	var hitter_has_hit = hit_character.combat_events.has_event(CombatEvent.HURTBOX_HIT, primary_weapon)
	var hurt_has_hit = hurt_character.combat_events.has_event(CombatEvent.HURTBOX_HIT, primary_weapon)
	# Check for collisions!
	assert_true(hitter_has_hit, "The hitting character should predict a hit event.")
	assert_false(hurt_has_hit, "The hurt character should not have the combat event.")
	
	# Now we have to advance the combat events such that combat events are handled.
	hurt_character.combat_events.update(0)
	hit_character.combat_events.update(0)
	
	# Confirm that the knockback component is locally predicted. 
	var knockback_component = hurt_character.get_component("Knockback")
	var has_knockback = not knockback_component is NullComponent
	assert_true(has_knockback, "Knockback component should be valid.")
	KnockBackSystem.execute(0)
	if has_knockback:
		# The component is "Predicted" because the server version of this component won't match
		assert_true(PredictedCreationSystem.has_component(0, knockback_component))

func _position_hurt_and_hit_character(hurt_character : ClientPlayerCharacter, hit_character : ClientPlayerCharacter, hurt_position : Vector2, hit_position : Vector2) -> void:
	hurt_character.global_position = hurt_position
	hit_character.global_position = hit_position
	await get_tree().physics_frame

# 5. Predicted components lifetimes are tracked just like regular server components.
func test_client_created_components_enter_deferred_delete_system() -> void:
	# Create a predicted component, then queue it for deletion. Assert that the component
	# is in the deferred delete system. 
	var random_frame = random_frame()
	var character = await init_player_character()
	var knockback : C_Knockback = await instance_scene_by_id("KBK")
	knockback.netcode.is_from_server = false
	character.add_component(random_frame, knockback)
	character.remove_component(knockback)
	assert_true(ComponentFreeSystem.has_deferred_delete(knockback))

func test_immediate_delete_removes_component_from_PredictedCreationSystem() -> void:
	#assert_true(false, "Not implemented and may not have to be")
	pass

# AC 5 from US 731
func test_component_creation_misspredict():
	var test_id = randi() % 10000
	var frame = TestFunctions.random_frame()
	# Create a character and attach a component to it on a given frame. Then 
	# run the component update checker to see if the component was received 
	# from the server, and confirm that the component is deleted and removed from the character
	var character = TestFunctions.init_player_character(test_id)
	await get_tree().process_frame
	var knockback_component = add_knockback_to_character(frame, character)
	KnockBackSystem.execute(frame)
	assert_false(ComponentUpdateTracker.is_component_updated(frame, knockback_component))
	PredictedCreationSystem._on_server_update(frame)
	ComponentFreeSystem.execute()
	assert_true(knockback_component.is_queued_for_deletion())
	assert_false(character.has_component_group("Knockback"))
	assert_false(KnockBackSystem.has_entity(character))
	character.queue_free()
	await get_tree().process_frame

func add_knockback_to_character(frame : int, character) -> Knockback:
	var knockback_component = TestFunctions.instance_scene_by_id("KBK") as Knockback
	knockback_component.data_container.knockback_speed = 100
	character.add_component(frame, knockback_component)
	return knockback_component

# AC 5 from US 731
func test_component_is_removed_if_misspredict_before_creation():
	var test_id = randi() % 10000
	var frame = TestFunctions.random_frame()
	# Create a character and attach a component to it on a given frame. Then 
	# run the component update checker to see if the component was received 
	# from the server, and confirm that the component is deleted and removed from the character
	var character = TestFunctions.init_player_character(test_id)
	await get_tree().process_frame
	var knockback_component = add_knockback_to_character(frame, character)
	assert_true(character.has_component_group("Knockback"))
	assert_eq(knockback_component.component_data.creation_frame, frame)

	MissPredictFrameTracker.frame_init(frame)
	MissPredictFrameTracker.add_reset_frame(CommandFrame.get_previous_frame(frame))
	RollbackSystem.execute(frame)
	ComponentFreeSystem.execute()

	assert_true(knockback_component.is_queued_for_deletion())
	assert_false(character.has_component_group("Knockback"))

	character.queue_free()
	await character.tree_exited

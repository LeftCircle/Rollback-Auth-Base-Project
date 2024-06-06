extends GutTestRogue

func test_stamina_refills():
	var character = TestFunctions.init_player_character()
	await get_tree().process_frame
	var stamina = character.get_component("Stamina")
	# use one stamina then wait x frames for refill
	stamina.execute(0, 1)
	assert_eq(stamina.current_stamina, stamina.stamina - 1)
	var wait_delay_frames = stamina.stamina_refill_delay_timer.wait_frames
	var speed_frames = stamina.stamina_refill_speed_timer.wait_frames
	for i in range(wait_delay_frames + speed_frames):
		#SystemController._physics_process(0)
		TimerSystem.execute(0)
	assert_eq(stamina.current_stamina, stamina.stamina)
	character.queue_free()
	await get_tree().process_frame

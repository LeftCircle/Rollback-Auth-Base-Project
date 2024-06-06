extends GutTestRogue


func test_component_array_init() -> void:
	var test_component = ComponentArray.new()
	assert_eq(test_component.components.size(), EntityManager.MAX_ENTITIES)
	assert_eq(test_component.next_component_index, 0)
	assert(test_component.signature == 0)

func test_component_array_add_component() -> void:
	var test_component = ComponentArray.new()
	var entity_manager = EntityManager.new()
	var entity = entity_manager.create_entity()
	var knockback_data = KnockbackData.new()
	test_component.add_data(entity, knockback_data)
	assert_eq(test_component.next_component_index, 1)
	assert_eq(test_component.get_data(entity), knockback_data)

func test_component_array_remove_component() -> void:
	var test_array = ComponentArray.new()
	var entity_manager = EntityManager.new()
	var entity_a = entity_manager.create_entity()
	var entity_b = entity_manager.create_entity()
	var entity_c = entity_manager.create_entity()
	var knockback_data_a = KnockbackData.new()
	var knockback_data_b = KnockbackData.new()
	var knockback_data_c = KnockbackData.new()

	test_array.add_data(entity_a, knockback_data_a)
	test_array.add_data(entity_b, knockback_data_b)
	test_array.add_data(entity_c, knockback_data_c)
	assert_eq(test_array.components[0], knockback_data_a)
	assert_eq(test_array.components[1], knockback_data_b)
	assert_eq(test_array.components[2], knockback_data_c)

	test_array.remove_data(entity_b)
	# Confirm that everything is in memory as expected
	assert_eq(test_array.components[0], knockback_data_a)
	assert_eq(test_array.components[1], knockback_data_c)
	assert_eq(test_array.next_component_index, 2)

func test_entity_destroyed() -> void:
	var test_array = ComponentArray.new()
	var entity_manager = EntityManager.new()
	var entity_a = entity_manager.create_entity()
	var entity_b = entity_manager.create_entity()
	
	var knockback_a = KnockbackData.new()

	test_array.add_data(entity_a, knockback_a)
	test_array.entity_destroyed(entity_a)
	test_array.entity_destroyed(entity_b)
	assert_eq(test_array.next_component_index, 0)
	assert_false(test_array.has_entity(entity_a))
	assert_false(test_array.has_entity(entity_b))

func test_create_component_array_of_given_type() -> void:
	# Given knockback data, create a component array of that type
	#var test_array = ComponentArray.new()
	#test_array.init(KnockbackData)
	#for i in range(0, EntityManager.MAX_ENTITIES):
		#assert_eq(test_array.components[i].knockback_speed, 0)
	
	# Not currently implemented
	pass

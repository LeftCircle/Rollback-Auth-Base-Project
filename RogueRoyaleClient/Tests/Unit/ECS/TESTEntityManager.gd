extends GutTestRogue



func test_entity_manager_has_arrays_of_ids_and_signatures() -> void:
	var entity_manager = EntityManager.new()
	assert_eq(entity_manager.available_ids.size(), EntityManager.MAX_ENTITIES)
	assert_eq(entity_manager.signatures.size(), 0)
	assert_eq(entity_manager.n_living_entities, 0)

func test_entity_manager_create_entity() -> void:
	var entity_manager = EntityManager.new()
	var entity = entity_manager.create_entity()
	assert_eq(entity, EntityManager.MAX_ENTITIES - 1)
	assert_eq(entity_manager.available_ids[entity_manager._last_id_index], EntityManager.MAX_ENTITIES - 2)
	assert_eq(entity_manager.available_ids.size(), EntityManager.MAX_ENTITIES - 1)
	assert_eq(entity_manager.signatures.size(), 1)
	assert_eq(entity_manager.n_living_entities, 1)
	assert_true(entity_manager.signatures.has(entity))
	if entity_manager.signatures.has(entity):
		assert_eq(entity_manager.signatures[entity], 0)

func test_entity_manager_destroy_entity() -> void:
	var entity_manager = EntityManager.new()
	var entity = entity_manager.create_entity()
	var second_entity = entity_manager.create_entity()
	var third_entity = entity_manager.create_entity()
	entity_manager.destroy_entity(second_entity)
	assert_eq(entity_manager.available_ids[entity_manager._last_id_index], second_entity)
	assert_eq(entity_manager.available_ids.size(), EntityManager.MAX_ENTITIES - 2)
	assert_eq(entity_manager.signatures.size(), 2)
	assert_false(entity_manager.signatures.has(second_entity))
	assert_eq(entity_manager.n_living_entities, 2)

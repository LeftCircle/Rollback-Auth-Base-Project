extends RefCounted
class_name EntityManager

const MAX_ENTITIES = 10000

var n_living_entities : int = 0
var available_ids : PackedInt64Array = PackedInt64Array()
var signatures : Dictionary = {}
var _last_id_index : int = MAX_ENTITIES - 1

func _init():
    available_ids.resize(MAX_ENTITIES)
    for i in range(MAX_ENTITIES):
        available_ids.set(i, i)

func create_entity() -> int:
    assert(n_living_entities < MAX_ENTITIES, "Too many entities in existence.")
    var id = available_ids[_last_id_index]
    available_ids.resize(_last_id_index)
    _last_id_index -= 1
    n_living_entities += 1
    signatures[id] = 0
    return id

func destroy_entity(entity : int) -> void:
    assert(entity < MAX_ENTITIES, "Entity out of range.")
    available_ids.push_back(entity)
    _last_id_index += 1
    n_living_entities -= 1
    signatures.erase(entity)
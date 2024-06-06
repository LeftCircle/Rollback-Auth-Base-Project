extends Area2D
class_name BaseHitboxRollback

var entity
# The CollisionShape3D
var shape
var combat_event_parser = HitboxCombatEventParserRollback.new()
var is_entity = false

func _ready():
	add_to_group("Hitbox")
	add_to_group("Rollback")
	combat_event_parser.init(self)

func set_combat_event_parser(new_event_parser) -> void:
	combat_event_parser = new_event_parser
	new_event_parser.init(self)

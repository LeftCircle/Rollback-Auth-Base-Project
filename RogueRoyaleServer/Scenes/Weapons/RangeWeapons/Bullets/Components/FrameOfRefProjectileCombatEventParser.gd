extends RefCounted
class_name FrameOfRefProjectileCombatEventParser
# Frame of reference projectiles can only collide with the weapons of the
# target character. It collides with the _weapons_ not past combat boxes

const groups_to_ignore = ["BaseHurtbox", "Hurtbox", "PastCombatBox"]

# This is the area of the origianl projectile hitbox that does the hitting
var colliding_area
var entity : ServerPlayerCharacter
var target_player : ServerPlayerCharacter

func init(original_projectile, new_entity : ServerPlayerCharacter, new_target_player : ServerPlayerCharacter) -> void:
	colliding_area = original_projectile
	entity = new_entity
	target_player = new_target_player

func on_area_entered(area, weapon_data):
	if "entity" in area and area.entity != entity and area.entity == target_player:
		for group in groups_to_ignore:
			if area.is_in_group(group):
				return
			var event_type : int
			var combat_event = CombatEvent.new()
			if area.is_in_group("Hitbox"):
				event_type = _get_event_type_on_Hitbox_hit(area, weapon_data)
			elif area.is_in_group("BlockBox"):
				print("Past blockbox hit")
				event_type = CombatEvent.BLOCK_BOX_HIT
			elif area.is_in_group("ParryBox"):
				print("Past parrybox hit")
				event_type = CombatEvent.SHIELD_PARRY_BOX_HIT
			else:
				return
			combat_event.init(colliding_area, entity, area.entity, event_type)
			combat_event.weapon_data = weapon_data
			entity.combat_events.queue_event(combat_event)
	else:
		print("Collision area has no entity attribute. Nothing to be done " + area.to_string())

func _get_event_type_on_Hitbox_hit(area, weapon_data) -> int:
	if weapon_data.is_ranged == false:
		return CombatEvent.MELEE_HITBOX_HIT
	return CombatEvent.RANGE_HITBOX_HIT

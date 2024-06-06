#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends RefCounted
class_name CombatEventQueue
# Looks through all of the combat events that occured on frame, then updates the player state
# based off of the events that occured.

var entity
var buffer_size : int = 64
var buffer : Array = []
# Head is the oldest -> where data is read from
var head : int = 0
# Tail is the newest -> where data is written to. DATA DOES NOT YET EXIST AT THE TAIL
var tail : int = 0
var old_head : int = 0
var update_frame : int = 0
#var mutex = Mutex.new()

func init(new_entity) -> void:
	entity = new_entity
	#entity.connect("physics_process_started",Callable(self,"_on_entity_physics_process_started"))

func _init(new_size = buffer_size):
	buffer_size = new_size
	for _i in range(buffer_size):
		buffer.append(null)

# func _ready():
# 	# Collisions are gathered at the start of the frame, so this executes _before_ any player
# 	# physics process
# 	process_priority = ProjectSettings.get_setting("global/COMBAT_EVENT_PROCESS_PRIORITY")

func queue_event(event : CombatEvent) -> void:
	#mutex.lock()
	assert((tail + 1) % buffer_size != head)
	buffer[tail] = event
	tail = (tail + 1) % buffer_size
	#mutex.unlock()

func update(frame : int):
	update_frame = frame
	#mutex.lock()
	old_head = head
	while head != tail:
		var event = buffer[head]
		if event.type == CombatEvent.HURTBOX_HIT:
			if event.weapon_data.is_ranged:
				_on_hurtbox_hit_by_ranged(event)
			else:
				_on_hurtbox_hit(event)
		if event.type == CombatEvent.MELEE_HITBOX_HIT:
			if event.weapon_data.is_ranged:
				_on_melee_hitbox_hit_by_ranged(event)
			else:
				_on_melee_hitbox_hit(event)
		elif event.type == CombatEvent.RANGE_HITBOX_HIT:
			if event.weapon_data.is_ranged:
				_on_range_hitbox_hit_by_ranged(event)
			else:
				_on_range_hitbox_hit(event)
		elif event.type == CombatEvent.SHIELD_PARRY_BOX_HIT:
			if event.weapon_data.is_ranged:
				_on_range_hitbox_hit_parry_box(event)
			else:
				print("Parry hit not yet coded")
		elif event.type == CombatEvent.BLOCK_BOX_HIT:
			if event.weapon_data.is_ranged:
				_on_range_hitbox_hit_block_box(event)
			else:
				print("Pblock box hit not yet coded")
		head = (head + 1) % buffer_size
	#mutex.unlock()

func _on_hurtbox_hit(event : CombatEvent) -> void:
	var other_entity = event.entity_received_event
	var event_result = _check_client_hutbox_hit_event_priority(event)
	if event_result == CombatEvent.HURTBOX_HIT:
		var other_entity_event = _check_remote_hurtbox_hit_event_priority(event)
		if other_entity_event == CombatEvent.MELEE_HITBOX_HIT:
			event_result = CombatEvent.NONE
	if event_result == CombatEvent.HURTBOX_HIT:
		print("Hurtbox hit occurs")
		#emit_signal("new_current_event", event)
		entity.on_attack_hit_entity(update_frame, event)

func _check_client_hutbox_hit_event_priority(event : CombatEvent) -> int:
	var other_entity = event.entity_received_event
	if has_event_against(CombatEvent.SHIELD_PARRY_BOX_HIT, event.object_did_event, other_entity):
		return CombatEvent.SHIELD_PARRY_BOX_HIT
	elif has_event_against(CombatEvent.MELEE_HITBOX_HIT, event.object_did_event, other_entity):
		return CombatEvent.MELEE_HITBOX_HIT
	elif has_event_against(CombatEvent.BLOCK_BOX_HIT, event.object_did_event, other_entity):
		return CombatEvent.BLOCK_BOX_HIT
	return CombatEvent.HURTBOX_HIT

func _check_remote_hurtbox_hit_event_priority(event) -> int:
	var other_entity = event.entity_received_event
	if other_entity_has_event_against_client(CombatEvent.MELEE_HITBOX_HIT, other_entity, false):
		return CombatEvent.MELEE_HITBOX_HIT
	elif other_entity_has_event_against_client(CombatEvent.HURTBOX_HIT, other_entity, false):
		# We could either do a parry or both clients get hit
		return CombatEvent.MELEE_HITBOX_HIT
	return CombatEvent.NONE

func _on_hurtbox_hit_by_ranged(event : CombatEvent) -> void:
	var other_entity = event.entity_received_event
	if has_event(CombatEvent.SHIELD_PARRY_BOX_HIT, event.object_did_event):
		# TO DO -> early exit by setting tail to head and executing the shield parry response
		print("SHIELD Parry ranged occurs")
		return
	elif has_event(CombatEvent.MELEE_HITBOX_HIT, event.object_did_event):
		print("Range hit melee hitbox")
		return
	elif has_event_against(CombatEvent.BLOCK_BOX_HIT, event.object_did_event, other_entity):
		# Set a flag when hitting the other entity to see if they were shielding. When the entity
		# is hit, they can check to see how much damage they blocked
		pass
	else:
		print("Hurtbox hit by range occurs")
		entity.on_range_attack_hit_entity(event)

func _on_melee_hitbox_hit_by_ranged(event : CombatEvent) -> void:
	# It is fun to always hit projectiles if possible
	# For this interaction, the projectile hits a melee hitbox
	event.object_did_event.hit_by_melee(event)

func _on_melee_hitbox_hit(event : CombatEvent):
	var event_result = _check_client_melee_hit_event_priority(event)
	if event_result == CombatEvent.MELEE_HITBOX_HIT:
		entity.on_melee_hitbox_hit(event)

func _check_client_melee_hit_event_priority(event) -> int:
	var other_entity = event.entity_received_event
	if has_event_against(CombatEvent.SHIELD_PARRY_BOX_HIT, event.object_did_event, other_entity):
		return CombatEvent.NONE
	elif has_event_against(CombatEvent.BLOCK_BOX_HIT, event.object_did_event, other_entity):
		return CombatEvent.NONE
	return CombatEvent.MELEE_HITBOX_HIT

func _on_range_hitbox_hit_by_ranged(event) -> void:
	# do nothing!
	pass

func _on_range_hitbox_hit(event : CombatEvent) -> void:
	# This is handled by the bullet hitting the hitbox, not the hitbox hitting
	# the bullet
	pass
#	var other_entity = event.entity_received_event
#	event.object_did_event.hit_by_melee(event)
#	if has_event(CombatEvent.SHIELD_PARRY_BOX_HIT, event.object_did_event):
#		print("SHIELD Parry occurs")
#	else:
#		# Deflect the projectile
#		# Hit occurs!
#		print("Ranged weapon deflection occurs")

func _on_range_hitbox_hit_parry_box(event : CombatEvent) -> void:
	# Same as hitting a hitbox
	event.object_did_event.hit_by_melee(event)

func _on_range_hitbox_hit_block_box(event : CombatEvent) -> void:
	event.object_did_event.queue_free()

# TO DO -> This could be accomplished faster by creating a binary map for all of the events
# that occur this frame, then checking the binary map. Create a binary map from the enums, then
# check against it
func has_event(event_type : int, with_object) -> bool:
	var walker = old_head
	while walker != tail:
		var c_event = buffer[walker]
		if c_event.type == event_type and c_event.object_did_event == with_object:
			return true
		walker = (walker + 1) % buffer_size
	return false

func has_event_against(event_type : int, with_object, check_entity) -> bool:
	var walker = old_head
	while walker != tail:
		var c_event = buffer[walker]
		if c_event.type == event_type and c_event.entity_received_event == check_entity and c_event.object_did_event == with_object:
			return true
		walker = (walker + 1) % buffer_size
	return false

func has_event_against_with_any_obj(event_type : int, check_entity, is_ranged : bool) -> bool:
	var walker = old_head
	while walker != tail:
		var c_event = buffer[walker]
		if c_event.type == event_type and c_event.entity_received_event == check_entity and c_event.weapon_data.is_ranged == is_ranged:
			return true
		walker = (walker + 1) % buffer_size
	return false

func other_entity_has_event_against_client(event_type : int, other_entity, is_ranged : bool) -> bool:
	var other_event_queue = other_entity.combat_events
	if other_event_queue.has_event_against_with_any_obj(event_type, entity, is_ranged):
		return true
	return false

func has_event_type_for_object(event_type : int, with_object) -> bool:
	var walker = old_head
	while walker != tail:
		var c_event = buffer[walker]
		if c_event.type == event_type and c_event.object_did_event == with_object:
			return true
		walker = (walker + 1) % buffer_size
	return false

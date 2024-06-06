extends Node
# Handles the updating and then processing of each characters combat events

# entity : CombatEventQueue
var event_queues = {}
#var updated_events = {}

func _ready():
	process_priority = ProjectSettings.get_setting("global/COMBAT_EVENT_PROCESS_PRIORITY")

func _physics_process(delta):
	assert(false) #,"must clear current events")
	_set_current_events()

func register(new_entity : Node) -> void:
	event_queues[new_entity] = CombatEventQueue.new()
	#updated_events[new_entity] = CombatEventProcesser.new()
	new_entity.connect("child_exiting_tree",Callable(self,"_on_entity_queue_free"))

func _on_entity_queue_free(entity) -> void:
	if event_queues.has(entity):
		event_queues.erase(entity)

func _set_current_events():
	for entity in event_queues.keys():
		var event_queue = event_queues[entity]
		event_queue.update()

func _on_new_current_event(event : CombatEvent) -> void:
	# We have to sort the events so that a player knows all of the things that
	# occured to it this frame. So if an enemy hits the player, the player know
	# that their hurtbox was hit
	pass

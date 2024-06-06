extends Area2D
class_name LagCompHurtboxSpawner

@export var for_player: bool = false
@export var entity_path: NodePath
@export var hurtbox_path: NodePath

var player_to_hurtbox = {}
#var position_history : PositionHistory

@onready var entity = get_node(entity_path)
@onready var hurtbox_to_copy = get_node(hurtbox_path)
@onready var collision = $CollisionShape2D

#func init(new_position_history : PositionHistory):
#	position_history = new_position_history

func _ready():
	#process_priority = entity.process_priority + 1
	pass

func _physics_process(delta):
	for body in player_to_hurtbox.keys():
		if is_instance_valid(body):
			if not overlaps_body(body):
				player_to_hurtbox[body].queue_free()
				player_to_hurtbox.erase(body)

func _build_past_hurtbox(player_node):
	#var client_frame = ClientWorldStateMap.get_world_state_frame(player_node.player_id, CommandFrame.frame)
	if not for_player:
		var past_hurtbox = MobPastHurtbox.new()
		past_hurtbox.name = "PastHurtbox"
		past_hurtbox.init_mob_past_hurtbox(player_node, entity, hurtbox_to_copy)
		entity.call_deferred("add_child", past_hurtbox)
		return past_hurtbox
	else:
		var past_hurtbox = PlayerPastHurtbox.new()
		past_hurtbox.name = "PastHurtbox"
		past_hurtbox.init_player_past_hurtbox(entity, player_node, hurtbox_to_copy)
		entity.call_deferred("add_child", past_hurtbox)
		return past_hurtbox

func _on_LagCompHurtboxSpawner_body_entered(body):
	if body.is_in_group("Players") and not body in player_to_hurtbox.keys() and body != entity:
		var past_hurtbox = _build_past_hurtbox(body)
		player_to_hurtbox[body] = past_hurtbox
		print("Area3D entered lagcomp spawner ", body.to_string())

func get_past_hurtbox_for(player_obj):
	if player_to_hurtbox.has(player_obj):
		return player_to_hurtbox[player_obj]
	else:
		return hurtbox_to_copy

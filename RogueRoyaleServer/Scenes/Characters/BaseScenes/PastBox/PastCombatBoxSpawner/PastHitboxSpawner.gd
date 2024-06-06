extends Area2D
class_name PastCombatBoxSpawner

@export var entity_path: NodePath

var hitbox_to_past_hitbox = {}

@onready var entity = get_node(entity_path)
@onready var collision = $CollisionShape2D

func _ready():
	add_to_group("Spawner")

# Looks for all other hitboxes in the area
func _on_LagCompHurtboxSpawner_area_entered(area):
	if _is_combat_box(area) and area.entity != entity and not area in hitbox_to_past_hitbox:
		print("Past combat box added! " + str(CommandFrame.frame))
		var past_box = PastCombatBox.new()
		past_box.init_past_box(entity, area)
		hitbox_to_past_hitbox[area] = past_box
		past_box.name = "PastCombatBox"
		past_box.connect("queueing_free_past_box_for_area",Callable(self,"_on_past_box_exiting_tree"))
		#area.entity.call_deferred("add_child", past_box)
		ObjectCreationRegistry.call_deferred("add_child", past_box)

func _is_combat_box(area) -> bool:
	if area.is_in_group("PastCombatBox") or area.is_in_group("Projectile"):
		return false
	for combat_type in CombatBoxTypes.get_box_types():
		if area.is_in_group(combat_type):
			return true
	return false

func _on_past_box_exiting_tree(area) -> void:
	if hitbox_to_past_hitbox.has(area):
		hitbox_to_past_hitbox.erase(area)

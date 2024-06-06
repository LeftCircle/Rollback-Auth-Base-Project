extends Area2D


var SPEED = 900
var damage
var direction = Vector2()
# A check to see if the client shot this, or if this comes from a player on the server
var from_client = true
var player_id : int

func _ready():
	#damage = Combat.get_skill_damage("Fireball", player_id)
	pass

func _physics_process(delta):
	move_local_x(SPEED * delta)

func _on_Fireball_area_entered(area : Area2D) -> void:
	print("Class of object hit = ", area.get_class())
	print("Name of hit object = ", area.get_name())
	var deal_damage = area.get_node_or_null("Hitbox") != null
	var allow_queue_free = true
	if area.get_name() == str(player_id):
		allow_queue_free = false
		deal_damage = false
	if deal_damage:
		area.damage(damage, player_id)
	if allow_queue_free:
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
		print("Not yet queueing the fireball free")

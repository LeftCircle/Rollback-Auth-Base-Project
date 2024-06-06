extends BaseHitboxRollback
class_name Bullet

@export var speed = 850 # (float, 0, 1000)

#var netcode = BulletNetcodeBase.new()
var velocity
var weapon_data# : WeaponData
var to_despawn : bool = false

func _netcode_init():
	netcode.init(self, "BLT", BulletData.new(), BulletCompresser.new())

func _ready():
	add_to_group("Projectile")
	#add_child(netcode)
	self.connect("area_entered",Callable(self,"_on_area_entered"))
	self.connect("body_entered",Callable(self,"_on_body_entered"))

func fire(shot_by, gun_weapon_data : WeaponData, direction : Vector2, global_pos : Vector2, frame : int = CommandFrame.frame):
	global_position = global_pos
	rotation = direction.angle()
	velocity = direction.normalized() * speed
	entity = shot_by
	weapon_data = gun_weapon_data
	combat_event_parser.init(self)

func _physics_process(delta):
	advance(delta)

func advance(delta):
	global_position += velocity * delta

func _on_area_entered(area):
	if area.is_in_group("Spawner"):
		return
	elif "entity" in area:
		if area.entity == entity:
			return
		print("Bullet entered area for entity " + area.to_string())
		combat_event_parser.on_area_entered(area, weapon_data)
		print("queueing bullet free")
		call_deferred("queue_free")
	else:
		print("queueing bullet free because it hit something unimportant " + area.to_string())
		call_deferred("queue_free")

func _on_body_entered(body) -> void:
	if "entity" in body:
		print("Bullet entered body " + body.to_string())
		if body.entity != entity:
			call_deferred("queue_free")
	else:
		call_deferred("queue_free")



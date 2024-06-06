extends BaseHitbox
class_name LocalBullet
# This bullet gets sent to local clients. It is the standard bullet that
# hits lag comp hurtboxes

@export var speed = 850 # (float, 0, 1000)

var netcode = BulletNetcodeBase.new()
# The parent object is always the character or mob that uses the gun
var velocity
var weapon_data# : WeaponData
var entity_to_hit

func _init():
	netcode.init(self, "BLT", BulletData.new(), BulletCompresser.new())

func _ready():
	assert(false) #,"not sure where this is used")
	#add_child(netcode)
	add_to_group("Weapons")
	self.connect("area_entered",Callable(self,"_on_area_entered"))
	self.connect("body_entered",Callable(self,"_on_body_entered"))

func fire(shot_by, gun_weapon_data : WeaponData, direction : Vector2, global_pos : Vector2, frame : int = CommandFrame.frame):
	global_position = global_pos
	velocity = direction.normalized() * speed
	entity = shot_by
	weapon_data = gun_weapon_data

func _physics_process(delta):
	advance(delta)

func advance(delta):
	global_position += velocity * delta

func _on_area_entered(area):
	print("Bullet entered area " + area.to_string())
	on_area_entered(area, weapon_data)
	if "entity" in area:
		if area.entity != entity:
			print("queueing bullet free")
			call_deferred("queue_free")
	else:
		print("queueing bullet free")
		call_deferred("queue_free")

func _on_body_entered(body) -> void:
	print("Bullet entered body " + body.to_string())
	if "entity" in body:
		if body.entity != entity:
			call_deferred("queue_free")
	else:
		call_deferred("queue_free")

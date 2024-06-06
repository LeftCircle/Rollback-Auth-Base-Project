extends Bullet
class_name ClientBullet

var fired_frame : int
var local = false

func _ready():
	if local:
		$Sprite2D.modulate = Color.RED

func get_object():
	return self

func decompress(frame : int, bit_packer : OutputMemoryBitStream):
#	var server_data = netcode.decompress(bit_packer) as BulletData
#	if server_data.to_despawn:
#		queue_free()
#	else:
#		server_data.set_obj_with_data(self)
#		set_pos_based_on_client()
	pass

func set_pos_based_on_client():
	var this_client = ObjectCreationRegistry.get_this_client()
	var spawn_pos = this_client.global_position + hbox_to_spawn
	global_position = spawn_pos

func _on_area_entered(area):
	print("Bullet entered area " + area.to_string())
	if local:
		print("Local collision frame = " + str(CommandFrame.frame))
	else:
		print("Remote collision frame = " + str(CommandFrame.frame))
	if "entity" in area:
		if area.entity != entity:
			queue_free()
	else:
		queue_free()
#	on_area_entered(area, weapon_data)
#	if "entity" in area:
#		if area.entity != entity:
#			queue_free()
#	else:
#		queue_free()

func _on_body_entered(body) -> void:
	print("Bullet entered body " + body.to_string())
	if local:
		print("Local collision frame = " + str(CommandFrame.frame))
	else:
		print("Remote collision frame = " + str(CommandFrame.frame))
	if "entity" in body:
		if body.entity != entity:
			queue_free()
	else:
		queue_free()

############## Rollback code ###############################
func fire(shot_by, gun_weapon_data : WeaponData, direction : Vector2, global_pos : Vector2, frame : int = CommandFrame.frame):
	super.fire(shot_by, gun_weapon_data, direction, global_pos, frame)
	fired_frame = frame

func on_rollback(frame) -> void:
	if CommandFrame.command_frame_greater_than_previous(fired_frame, frame):
		queue_free()

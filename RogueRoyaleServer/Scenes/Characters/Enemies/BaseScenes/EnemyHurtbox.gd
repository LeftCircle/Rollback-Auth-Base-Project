extends BaseHurtbox
class_name EnemyHurtbox

func _on_BaseHurtbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		print("Hurtbox entered by ", area)
		emit_signal("hurtbox_hit", area, 10)

func get_hurtbox_duplicate():
	var dup = self.duplicate(true)
	dup.show()
	return dup

extends BaseHurtbox
class_name EnemyHurtbox


func _on_BaseHurtbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		print(area)
		emit_signal("hurtbox_hit", area, 10)
		Logging.log_line("Enemy hurtbox hit on frame " + str(CommandFrame.frame))

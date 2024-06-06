extends BaseModuleData
class_name KnockbackData

var knockback_direction : Vector2
var knockback_speed : int
var knockback_decay : int

func set_data_with_obj(other_obj): 
	knockback_direction = other_obj.knockback_direction
	knockback_speed = other_obj.knockback_speed
	knockback_decay = other_obj.knockback_decay
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.knockback_direction = knockback_direction
	other_obj.knockback_speed = knockback_speed
	other_obj.knockback_decay = knockback_decay
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(knockback_direction, other_obj.knockback_direction) == true) and
	(ModularDataComparer.compare_values(knockback_speed, other_obj.knockback_speed) == true) and
	(ModularDataComparer.compare_values(knockback_decay, other_obj.knockback_decay) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)

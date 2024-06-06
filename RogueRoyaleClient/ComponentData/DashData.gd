extends BaseModuleData
class_name DashModuleData

var dash_speed : int = 0
var dash_frames : int = 0
var stamina_cost = 1
var current_dash_frames = 0
var dash_direction : Vector2
var is_dashing = false

func set_data_with_obj(other_obj): 
	dash_speed = other_obj.dash_speed
	dash_frames = other_obj.dash_frames
	stamina_cost = other_obj.stamina_cost
	current_dash_frames = other_obj.current_dash_frames
	dash_direction = other_obj.dash_direction
	is_dashing = other_obj.is_dashing
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.dash_speed = dash_speed
	other_obj.dash_frames = dash_frames
	other_obj.stamina_cost = stamina_cost
	other_obj.current_dash_frames = current_dash_frames
	other_obj.dash_direction = dash_direction
	other_obj.is_dashing = is_dashing
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(dash_speed, other_obj.dash_speed) == true) and
	(ModularDataComparer.compare_values(dash_frames, other_obj.dash_frames) == true) and
	(ModularDataComparer.compare_values(stamina_cost, other_obj.stamina_cost) == true) and
	(ModularDataComparer.compare_values(current_dash_frames, other_obj.current_dash_frames) == true) and
	(ModularDataComparer.compare_values(dash_direction, other_obj.dash_direction) == true) and
	(ModularDataComparer.compare_values(is_dashing, other_obj.is_dashing) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)

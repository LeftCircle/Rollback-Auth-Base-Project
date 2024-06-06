extends BaseModuleData
class_name AmmoData

var max_ammo : int
var current_ammo : int

func set_data_with_obj(other_obj): 
	max_ammo = other_obj.max_ammo
	current_ammo = other_obj.current_ammo
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.max_ammo = max_ammo
	other_obj.current_ammo = current_ammo
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(max_ammo, other_obj.max_ammo) == true) and
	(ModularDataComparer.compare_values(current_ammo, other_obj.current_ammo) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)

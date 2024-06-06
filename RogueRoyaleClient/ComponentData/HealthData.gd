extends BaseModuleData
class_name HealthData

var health_segments = 6
var armor_segments = 1
var shield_segments = 1
var current_health : int
var current_armor : int
var current_shields : int
var regenerating_shield = false
var shield_regen_start_timer = TimerData.new()
var shield_regen_heal_timer = TimerData.new()

func set_data_with_obj(other_obj): 
	health_segments = other_obj.health_segments
	armor_segments = other_obj.armor_segments
	shield_segments = other_obj.shield_segments
	current_health = other_obj.current_health
	current_armor = other_obj.current_armor
	current_shields = other_obj.current_shields
	regenerating_shield = other_obj.regenerating_shield
	shield_regen_start_timer.current_frames = other_obj.shield_regen_start_timer.current_frames
	shield_regen_start_timer.wait_frames = other_obj.shield_regen_start_timer.wait_frames
	shield_regen_start_timer.is_running = other_obj.shield_regen_start_timer.is_running
	shield_regen_start_timer.autostart = other_obj.shield_regen_start_timer.autostart
	shield_regen_heal_timer.current_frames = other_obj.shield_regen_heal_timer.current_frames
	shield_regen_heal_timer.wait_frames = other_obj.shield_regen_heal_timer.wait_frames
	shield_regen_heal_timer.is_running = other_obj.shield_regen_heal_timer.is_running
	shield_regen_heal_timer.autostart = other_obj.shield_regen_heal_timer.autostart
	frame = other_obj.frame

func set_obj_with_data(other_obj): 
	other_obj.health_segments = health_segments
	other_obj.armor_segments = armor_segments
	other_obj.shield_segments = shield_segments
	other_obj.current_health = current_health
	other_obj.current_armor = current_armor
	other_obj.current_shields = current_shields
	other_obj.regenerating_shield = regenerating_shield
	other_obj.shield_regen_start_timer.current_frames = shield_regen_start_timer.current_frames
	other_obj.shield_regen_start_timer.wait_frames = shield_regen_start_timer.wait_frames
	other_obj.shield_regen_start_timer.is_running = shield_regen_start_timer.is_running
	other_obj.shield_regen_start_timer.autostart = shield_regen_start_timer.autostart
	other_obj.shield_regen_heal_timer.current_frames = shield_regen_heal_timer.current_frames
	other_obj.shield_regen_heal_timer.wait_frames = shield_regen_heal_timer.wait_frames
	other_obj.shield_regen_heal_timer.is_running = shield_regen_heal_timer.is_running
	other_obj.shield_regen_heal_timer.autostart = shield_regen_heal_timer.autostart
	other_obj.frame = frame

func matches(other_obj) -> bool: 
	return (
	(ModularDataComparer.compare_values(health_segments, other_obj.health_segments) == true) and
	(ModularDataComparer.compare_values(armor_segments, other_obj.armor_segments) == true) and
	(ModularDataComparer.compare_values(shield_segments, other_obj.shield_segments) == true) and
	(ModularDataComparer.compare_values(current_health, other_obj.current_health) == true) and
	(ModularDataComparer.compare_values(current_armor, other_obj.current_armor) == true) and
	(ModularDataComparer.compare_values(current_shields, other_obj.current_shields) == true) and
	(ModularDataComparer.compare_values(regenerating_shield, other_obj.regenerating_shield) == true) and
	(ModularDataComparer.compare_values(shield_regen_start_timer.current_frames, other_obj.shield_regen_start_timer.current_frames) == true) and
	(ModularDataComparer.compare_values(shield_regen_start_timer.wait_frames, other_obj.shield_regen_start_timer.wait_frames) == true) and
	(ModularDataComparer.compare_values(shield_regen_start_timer.is_running, other_obj.shield_regen_start_timer.is_running) == true) and
	(ModularDataComparer.compare_values(shield_regen_start_timer.autostart, other_obj.shield_regen_start_timer.autostart) == true) and
	(ModularDataComparer.compare_values(shield_regen_heal_timer.current_frames, other_obj.shield_regen_heal_timer.current_frames) == true) and
	(ModularDataComparer.compare_values(shield_regen_heal_timer.wait_frames, other_obj.shield_regen_heal_timer.wait_frames) == true) and
	(ModularDataComparer.compare_values(shield_regen_heal_timer.is_running, other_obj.shield_regen_heal_timer.is_running) == true) and
	(ModularDataComparer.compare_values(shield_regen_heal_timer.autostart, other_obj.shield_regen_heal_timer.autostart) == true) and
	(ModularDataComparer.compare_values(frame, other_obj.frame) == true)
	)

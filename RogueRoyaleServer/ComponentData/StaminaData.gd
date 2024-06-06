extends RefCounted
class_name StaminaData

var stamina : int
var current_stamina : int
var stamina_refill_delay_timer = TimerData.new()
var stamina_refill_speed_timer = TimerData.new()

func set_data_with_obj(other_obj):
	stamina = other_obj.stamina
	current_stamina = other_obj.current_stamina
	stamina_refill_delay_timer.current_frames = other_obj.stamina_refill_delay_timer.current_frames
	stamina_refill_delay_timer.wait_frames = other_obj.stamina_refill_delay_timer.wait_frames
	stamina_refill_delay_timer.is_running = other_obj.stamina_refill_delay_timer.is_running
	stamina_refill_delay_timer.autostart = other_obj.stamina_refill_delay_timer.autostart
	stamina_refill_speed_timer.current_frames = other_obj.stamina_refill_speed_timer.current_frames
	stamina_refill_speed_timer.wait_frames = other_obj.stamina_refill_speed_timer.wait_frames
	stamina_refill_speed_timer.is_running = other_obj.stamina_refill_speed_timer.is_running
	stamina_refill_speed_timer.autostart = other_obj.stamina_refill_speed_timer.autostart

func set_obj_with_data(other_obj):
	other_obj.stamina = stamina
	other_obj.current_stamina = current_stamina
	other_obj.stamina_refill_delay_timer.current_frames = stamina_refill_delay_timer.current_frames
	other_obj.stamina_refill_delay_timer.wait_frames = stamina_refill_delay_timer.wait_frames
	other_obj.stamina_refill_delay_timer.is_running = stamina_refill_delay_timer.is_running
	other_obj.stamina_refill_delay_timer.autostart = stamina_refill_delay_timer.autostart
	other_obj.stamina_refill_speed_timer.current_frames = stamina_refill_speed_timer.current_frames
	other_obj.stamina_refill_speed_timer.wait_frames = stamina_refill_speed_timer.wait_frames
	other_obj.stamina_refill_speed_timer.is_running = stamina_refill_speed_timer.is_running
	other_obj.stamina_refill_speed_timer.autostart = stamina_refill_speed_timer.autostart

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(stamina, other_obj.stamina) == true) and
	(ModularDataComparer.compare_values(current_stamina, other_obj.current_stamina) == true) and
	(ModularDataComparer.compare_values(stamina_refill_delay_timer.current_frames, other_obj.stamina_refill_delay_timer.current_frames) == true) and
	(ModularDataComparer.compare_values(stamina_refill_delay_timer.wait_frames, other_obj.stamina_refill_delay_timer.wait_frames) == true) and
	(ModularDataComparer.compare_values(stamina_refill_delay_timer.is_running, other_obj.stamina_refill_delay_timer.is_running) == true) and
	(ModularDataComparer.compare_values(stamina_refill_delay_timer.autostart, other_obj.stamina_refill_delay_timer.autostart) == true) and
	(ModularDataComparer.compare_values(stamina_refill_speed_timer.current_frames, other_obj.stamina_refill_speed_timer.current_frames) == true) and
	(ModularDataComparer.compare_values(stamina_refill_speed_timer.wait_frames, other_obj.stamina_refill_speed_timer.wait_frames) == true) and
	(ModularDataComparer.compare_values(stamina_refill_speed_timer.is_running, other_obj.stamina_refill_speed_timer.is_running) == true) and
	(ModularDataComparer.compare_values(stamina_refill_speed_timer.autostart, other_obj.stamina_refill_speed_timer.autostart) == true)
	)

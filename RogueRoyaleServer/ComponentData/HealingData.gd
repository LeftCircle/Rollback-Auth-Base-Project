extends RefCounted
class_name HealingData

var max_uses = 1
var uses_left = max_uses
var heal_timer = TimerData.new()

func set_data_with_obj(other_obj):
	max_uses = other_obj.max_uses
	uses_left = other_obj.uses_left
	heal_timer.current_frames = other_obj.heal_timer.current_frames
	heal_timer.wait_frames = other_obj.heal_timer.wait_frames
	heal_timer.is_running = other_obj.heal_timer.is_running
	heal_timer.autostart = other_obj.heal_timer.autostart

func set_obj_with_data(other_obj):
	other_obj.max_uses = max_uses
	other_obj.uses_left = uses_left
	other_obj.heal_timer.current_frames = heal_timer.current_frames
	other_obj.heal_timer.wait_frames = heal_timer.wait_frames
	other_obj.heal_timer.is_running = heal_timer.is_running
	other_obj.heal_timer.autostart = heal_timer.autostart

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(max_uses, other_obj.max_uses) == true) and
	(ModularDataComparer.compare_values(uses_left, other_obj.uses_left) == true) and
	(ModularDataComparer.compare_values(heal_timer.current_frames, other_obj.heal_timer.current_frames) == true) and
	(ModularDataComparer.compare_values(heal_timer.wait_frames, other_obj.heal_timer.wait_frames) == true) and
	(ModularDataComparer.compare_values(heal_timer.is_running, other_obj.heal_timer.is_running) == true) and
	(ModularDataComparer.compare_values(heal_timer.autostart, other_obj.heal_timer.autostart) == true)
	)

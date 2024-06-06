extends RefCounted
class_name DamageCalculator

var player_class_stats : ClassStats

func get_damage(weapon_data : WeaponData) -> int:
	var stat_val = player_class_stats.stats[weapon_data.class_type]
	return int(round(weapon_data.base_damage + weapon_data.base_damage * (stat_val * 0.15)))

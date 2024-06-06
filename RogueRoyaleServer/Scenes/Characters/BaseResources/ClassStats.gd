extends RefCounted
class_name ClassStats

var stats = {
	"dps" : 1,
	"tank" : 1,
	"support" : 1
}

func standard_increase(stat_type : String) -> void:
	assert(stat_type in stats.keys())
	for key in stats.keys():
		if key != stat_type:
			stats[key] -= 1
		else:
			stats[key] += 2

extends BaseModularHistory
class_name KnockbackHistory

#func _init():
#	for i in range(size):
#		history.append(KnockbackData.new())

func _new_data_container():
	return KnockbackData.new()

extends BaseModularHistory
class_name BaseEnemyHistory

#func _init():
#	for i in range(size):
#		history.append(EnemyState.new())

func _new_data_container():
	return EnemyState.new()

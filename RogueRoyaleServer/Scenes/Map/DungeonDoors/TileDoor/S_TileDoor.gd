extends BaseTileDoor
class_name S_TileDoor

func _ready():
	_add_extra_blocks()

func close():
	super.close()
	send_data_during_game()

func open():
	super.open()
	send_data_during_game()


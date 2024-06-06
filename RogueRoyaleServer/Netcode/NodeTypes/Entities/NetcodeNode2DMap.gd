extends NetcodeNode2D
class_name NetcodeNode2DMap

func prep_data_to_send():
	netcode.state_data.set_data_with_obj(self)
	MapClientSpawner.add_netcode_to_compress(netcode)

func send_data_during_game():
	netcode.state_data.set_data_with_obj(self)
	PlayerStateSync.add_netcode_to_compress(netcode)

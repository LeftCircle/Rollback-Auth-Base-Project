extends FXManager
class_name ServerFXManager

var netcode_sent_to_player_sync = false

func add_fx(fx_res : Resource) -> void:
	fx_manager_data.fx_resources.append(fx_res)
	if not netcode_sent_to_player_sync:
		PlayerStateSync.add_player_netcode_to_compress(netcode, [player_id])

func reset(fx_data : FXManagerData) -> void:
	fx_data.fx_resources.clear()
	netcode_sent_to_player_sync = false

extends GutTest
class_name PlayerCompressionTest

var player_netcode = CharacterNetcodeBase.new()
var player_state_comp = PlayerStateCompresser.new()
var dash_comp = DashModuleCompression.new()
var range_comp = BaseRangeWeaponCompresser.new()
var shield_comp = StarterShieldCompresser.new()
var shield_data = StarterShieldData.new()

var player_state = ServerPlayerStateOnClient.new()
var dash_data = DashModuleData.new()

@onready var player_char = load("res://Scenes/Characters/PlayerCharacter/ServerPlayerCharacter.tscn").instantiate()



#func test_gut() -> void:
#
#	assert_true(true)
#	_pack_netcode_with_data()
#	var bit_stream = OutputMemoryBitStream.new()
#	player_netcode.write_compressed_data_to_stream(bit_stream)
#	var array_to_send = bit_stream.get_array_to_send()
#	bit_stream.init_read(array_to_send)
#	var t_player_state = player_state_comp.decompress(0, bit_stream)
#	assert_true(t_player_state.matches(player_state))
#	#player_netcode.free()
##	player_state_comp.free()
##	dash_comp.free()
##	range_comp.free()
##	shield_comp.free()
##	shield_data.free()
##	player_state.free()
##	dash_data.free()
#	player_char.free()
#
#func _pack_netcode_with_data():
#	player_netcode.class_instance_id = 0
#	player_state.modular_abilties_this_frame = 3
#	player_state.state = PlayerStateManager.RANGE_WEAPON
#	player_state.position = Vector2(-192, 256)
#	player_netcode.init(self, "CHR", player_state, PlayerStateCompresser.new())
#
#
#	var dash_netcode = NetcodeForModules.new()
#
#	dash_data.dash_speed = 746
#	dash_data.dash_frames = 10
#	dash_data.current_dash_frames = 3
#	dash_data.dash_direction = Vector2(-1, 0)
#	dash_data.is_dashing = false
#	dash_netcode.init(self, "DSH", dash_data, DashModuleCompression.new())
#
#	var range_weapon_netcode = NetcodeForModules.new()
#	var range_weapon_data = BaseRangeWeaponData.new()
#	range_weapon_data.aiming_direction = Vector2(1, 0)
#	range_weapon_data.is_holstered = false
#	range_weapon_data.fired_this_frame = false
#	range_weapon_netcode.init(self, "PST", range_weapon_data, BaseRangeWeaponCompresser.new())
#
#	var shield_netcode = NetcodeForModules.new()
#
#	shield_data.attack_sequence = 1
#	shield_data.is_executing = false
#	shield_data.attack_direction = Vector2.ZERO
#	shield_data.animation_frame = 0
#	shield_data.is_in_parry = false
#	shield_netcode.init(self, "SHD", shield_data, StarterShieldCompresser.new())
#
##	player_netcode._receive_modular_netcode_data(dash_netcode)
##	player_netcode._receive_modular_netcode_data(range_weapon_netcode)
##	player_netcode._receive_modular_netcode_data(shield_netcode)
#	#player_netcode.reset()
#	player_netcode.compress()
#

extends BaseCharacter
class_name ClientBaseCharacter

signal rollback(frame)
signal misspredict_occured

const NO_FRAME = INF

var debug_to_log = true

var netcode = NetcodeFromSpawner.new()

var frame_to_reset_to = NO_FRAME

@onready var local_animation_tree : LocalRollbackAnimationTree = $LocalRollbackAnimationTree
@onready var node_interp = $NodeInterpolater
@onready var player_sprite = $NodeInterpolater/Sprite2D

func _init():
	_netcode_init()

func _netcode_init():
	netcode.state_data = PlayerState.new()
	netcode.state_compresser = PlayerStateCompresser.new()
	netcode.entity = self

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	self.connect("misspredict_occured",Callable(node_interp,"on_misspredict"))

#func silent_reset_state(_frame : int, to_player_state : PlayerState) -> void:
#	health.set_health(to_player_state.health)
#	ammo.set_max_and_current(to_player_state.max_ammo, to_player_state.current_ammo)

func add_component(frame : int, component) -> void:
	if component.is_in_group("Weapon"):
		add_weapon(frame, component, false)
	super.add_component(frame, component)
	if not component.is_connected("frame_to_reset_to",Callable(self,"_on_reset_frame_received")):
		component.connect("frame_to_reset_to",Callable(self,"_on_reset_frame_received"))
	Logging.log_line("Adding component %s to player %s. Is from server = %s" % [component.to_string(), self.to_string(), component.netcode.is_from_server])

func remove_component(component) -> bool:
	var has_component_to_remove = super.remove_component(component)
	if has_component_to_remove:
		component.disconnect("frame_to_reset_to",Callable(self,"_on_reset_frame_received"))
	Logging.log_line("Removing component %s to player %s. Is from server = %s" % [component.to_string(), self.to_string(), component.netcode.is_from_server])
	return has_component_to_remove

func remove_and_immediately_delete_component(component) -> bool:
	var has_component_to_remove = super.remove_and_immediately_delete_component(component)
	if has_component_to_remove:
		component.disconnect("frame_to_reset_to",Callable(self,"_on_reset_frame_received"))
	return has_component_to_remove

# The player may need a decompression function for creation/destruction?
func decompress(frame : int, bit_packer : OutputMemoryBitStream) -> void:
	pass

func _get_frame_to_reset_to() -> int:
	var reset_frame = frame_to_reset_to
	frame_to_reset_to = NO_FRAME
	return reset_frame

func show_player_sprite(to_show : bool) -> void:
	player_sprite.visible = to_show

func _on_reset_frame_received(frame : int) -> void:
	if frame_to_reset_to == NO_FRAME:
		frame_to_reset_to = frame
		add_to_group("MissPredicted")
	else:
		if CommandFrame.command_frame_greater_than_previous(frame_to_reset_to, frame):
			frame_to_reset_to = frame
			add_to_group("MissPredicted")
	emit_signal("misspredict_occured")

func _set_state_from_physical_hit_effect(frame : int, weapon_data : WeaponData, dir_to_entity : Vector2) -> void:
	if weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.STUN:
		print("Stun state not yet implemented for " + self.to_string())
	elif weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.KNOCKBACK:
		var new_knockback = C_Knockback.new()
		new_knockback.set_data(-dir_to_entity, weapon_data.knockback_speed, weapon_data.knockback_decay)
		Logging.log_line("Knockback added on frame %s with speed %s" % [frame, new_knockback.data_container.knockback_speed])
		add_component(frame, new_knockback)

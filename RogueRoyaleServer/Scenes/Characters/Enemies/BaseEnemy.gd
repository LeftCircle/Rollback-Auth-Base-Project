extends KinematicEntity
class_name BaseEnemy

signal mob_death(mob)
var netcode = MobNetcodeBase.new()

func _netcode_init():
	netcode.init(self, "BEN", DummyState.new(), DummyCompresser.new())

func _init():
	_netcode_init()

func _ready():
	add_to_group("Enemy")
	var new_name = str(self.get_instance_id())
	self.set_name(new_name)

func _on_death():
	emit_signal("mob_death", self)

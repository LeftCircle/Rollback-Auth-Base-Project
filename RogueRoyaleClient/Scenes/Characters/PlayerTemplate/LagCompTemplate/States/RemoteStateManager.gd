extends RemoteStateMachine
class_name RemotePlayerStateManager

enum {IDLE, RUN, DASH, ROLL, ATTACK_PRIMARY, ATTACK_SECONDARY, RANGE_WEAPON, HEALING_FLASK,
	KNOCKBACK, NULL}

func _ready():
	state_group_name = "RemoteState"

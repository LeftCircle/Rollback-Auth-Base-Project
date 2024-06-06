extends RefCounted
class_name PlayerStateComparer

# Silent missmatch types do not require rollbacks, but isntead
# set the variable to be updated directly
enum MISSMATCH_TYPE{NONE, SILENT, ROLLBACK}

static func compare_states(player_state_a : PlayerState, player_state_b : PlayerState, is_template = false) -> int:
	# Start with rollback missmatches. These allow for an early out
	if player_state_a.state != player_state_b.state:
		Logging.log_line("state missmatch")
		return MISSMATCH_TYPE.ROLLBACK
	if not vectors_match(player_state_a.position, player_state_b.position, 2):
		Logging.log_line("position missmatch")
		return MISSMATCH_TYPE.ROLLBACK
	if not vectors_match(player_state_a.velocity, player_state_b.velocity, 2):
		Logging.log_line("velocity missmatch")
		return MISSMATCH_TYPE.ROLLBACK
	if player_state_a.current_stamina != player_state_b.current_stamina:
		Logging.log_line("current stamina missmatch")
		return MISSMATCH_TYPE.ROLLBACK
	if player_state_a.current_ammo != player_state_b.current_ammo:
		Logging.log_line("current ammo missmatch")
		return MISSMATCH_TYPE.ROLLBACK

	# Template variations
	if not vectors_match(player_state_a.looking_vector, player_state_b.looking_vector, 0.25):
		if is_template:
			return MISSMATCH_TYPE.SILENT
		else:
			Logging.log_line("looking vector missmatch")
			return MISSMATCH_TYPE.ROLLBACK

	# Now the silent missmatches
	if player_state_a.max_stamina != player_state_b.max_stamina:
		return MISSMATCH_TYPE.SILENT
	if player_state_a.max_ammo != player_state_b.max_ammo:
		return MISSMATCH_TYPE.SILENT
	if player_state_a.health != player_state_b.health:
		return MISSMATCH_TYPE.SILENT
	return MISSMATCH_TYPE.NONE

static func vectors_match(vector1, vector2, threshold = 0.1) -> bool:
	var matches =  (vector1 - vector2).length_squared() < threshold
	if matches:
		return true
	else:
		Logging.log_line("Vectors do not match. length squared = " + str((vector1 - vector2).length_squared()))
		return false

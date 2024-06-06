extends Node2D
class_name Tether

func execute(entity):
	var input_vec = entity.global_position.direction_to(global_position)
	entity.move.execute(CommandFrame.frame, entity, input_vec)

	# The tether could actually be a state on the character itself. The character
	# has to move toward the tether point via a damped spring each frame until
	# the character is no longer tethered. The character is tethered to the last
	# hit weapon, which sets the tether point to track and the length of time to
	# track the tether

	# The tether point on the weapon should be set by the attack direction and
	# not rotate with the weapon - Except it would be cool if the shield acted
	# as a hook when thrown and then pushed people away with a normal hit...

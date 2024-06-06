extends BaseStaminaNode
class_name ClientStaminaNode

@onready var animations = $AnimationPlayer

func use_stamina():
	super.use_stamina()
	if is_inside_tree():
		animations.play("Use")

func refill():
	super.refill()
	if is_inside_tree():
		animations.play("Fill")

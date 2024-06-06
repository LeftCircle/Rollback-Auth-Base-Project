extends Node2D


@onready var state_machine_playback : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _ready():
	state_machine_playback.start("Null")
	$AnimationTree.advance(1.0 / 60.0)
	$AnimationPlayer.play("Test")

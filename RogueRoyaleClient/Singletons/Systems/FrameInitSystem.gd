extends Node
# FrameInitSystem

func execute(frame : int = CommandFrame.frame):
	var entities = get_tree().get_nodes_in_group("FrameInit")
	for entity in entities:
		entity.frame_init(frame)


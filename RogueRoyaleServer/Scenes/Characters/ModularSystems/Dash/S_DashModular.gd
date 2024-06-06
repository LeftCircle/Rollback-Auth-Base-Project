extends DashModular
class_name S_DashModular

func execute(frame, entity, input_actions: InputActions):
	super.execute(frame, entity, input_actions)
	#netcode.set_state_data(self)
	netcode.send_to_clients()


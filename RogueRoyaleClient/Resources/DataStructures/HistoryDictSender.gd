extends Resource
class_name HistoryDictSender

# This class will receive a dictionary of history data, then send a buffer
# of the data history

var data_to_add = []
var history_0 : Array = []
var history_1 : Array = []
var history_2 : Array = []
var history_3 : Array = []
var history_extra_buffer : Array = []
var unreliable_history_array : Array
var current_action = ActionFromClient.new()

func add_data(dict : Dictionary) -> void:
	data_to_add.append(dict)

func send_data_and_swap_buffers(send_function : FuncRef):
	if not data_to_add.is_empty():
		history_0 = data_to_add.duplicate(true)
		unreliable_history_array = history_0 + history_1 + history_2 + history_3
		send_function.call_func(unreliable_history_array)
		data_to_add.clear()
		__swap_history_buffers()

func __swap_history_buffers():
	history_3 = history_2
	history_2 = history_1
	history_1 = history_0
	history_0 = history_extra_buffer
	history_extra_buffer = history_3
	history_0.clear()

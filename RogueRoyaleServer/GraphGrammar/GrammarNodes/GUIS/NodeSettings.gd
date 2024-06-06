extends MarginContainer

var room_folders_res = FileLister.new()

@onready var replaceable_checkbox = $VBoxContainer/ReplaceableCheckbox
@onready var node_number = $VBoxContainer/NodeNumber
@onready var room_type = $VBoxContainer/RoomTypes
@onready var delete_checkbox = $VBoxContainer/DeleteChecbox
@onready var delete_button = $VBoxContainer/DeleteButton
@onready var is_starting_checkbox = $VBoxContainer/StartingNodeCheckbox
@onready var is_ending_checkbox = $VBoxContainer/EndingNodeCheckbox

func _init():
	room_folders_res.file_ending = ".tscn"
	room_folders_res.list_folders = true
	room_folders_res.folder_path = "res://Scenes/Map/DungeonRooms/RoomScenes/FirstFloor/"

func get_room_folders():
	return room_folders_res

func _ready():
	room_folders_res.load_resources()
	for name in get_room_folders().all_folder_names:
		room_type.add_item(name)

func _on_DeleteChecbox_pressed():
	if delete_checkbox.pressed:
		delete_button.visible = true
	else:
		delete_button.visible = false

func update_data(node_info : GrammarNodeInfo):
	if is_instance_valid(node_number):
		node_number.text = str(node_info.node_number)
		is_starting_checkbox.button_pressed = node_info.is_starting_node
		is_ending_checkbox.button_pressed = node_info.is_ending_node

func set_node_info_data(node_info : GrammarNodeInfo) -> void:
	node_info.replaceable = replaceable_checkbox.pressed
	node_info.is_starting_node = is_starting_checkbox.pressed
	node_info.is_ending_node = is_ending_checkbox.pressed
	node_info.room_type = room_type.get_item_text(room_type.selected)
	node_info.node_number = int(node_number.text)


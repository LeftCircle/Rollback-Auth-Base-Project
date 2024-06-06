extends RigidBody2D
class_name GrammarNode

signal starting_node_updated(node)
signal ending_node_updated(node)

enum {SELECTED, SITTING, SAVED, LOADED, DRAGGING}
const GRID_SIZE = 16
const MAX_CONNECTIONS = 8

@export var starting_node_color: Color = Color.GREEN
@export var ending_node_color: Color = Color.RED

var node_info = GrammarNodeInfo.new()
var state = SITTING
var springs = []
var side_length = 24
var set_disabled = false
var first_frame = true
var size = Vector2.ONE * side_length * 2


var node_settings : MarginContainer
var number_label : Label
var collision_box : CollisionShape2D
var selected_button : Button
@onready var button_stylebox = StyleBoxFlat.new()
#onready var number_label = $NumberLabel
#onready var collision_box = $NodeCollisionBox
#onready var selected_button = $SelectedButton

signal g_node_queue_free

#func init(number : int, pos : Vector2, type : String, replaceable : bool):
#	assert(false) #,"Checking to see if we ever reach here")
#	position = pos
#	set_node_number(number)
#	node_info.room_type = type
#	node_info.replaceable = replaceable

func _ready():
	_set_defaults()
	_reset_collision_box()
	set_starting_rule_node(node_info.is_starting_node)
	set_ending_rule_node(node_info.is_ending_node)
	if state == SAVED:
		_on_saved()
	elif state == LOADED:
		_on_loaded()
	else:
		_on_node_editing()
	collision_box.disabled = true
	#collision_box.shape.custom_solver_bias = 0.5

func _physics_process(_delta):
	if first_frame and not set_disabled:
		collision_box.disabled = false
		first_frame = false
	_quarter_force()
	#update()
	if state == SITTING:
		_while_sitting()
	elif state == SELECTED:
		_while_selected()
	elif state == DRAGGING:
		_while_dragging()
	elif state == SAVED:
		_while_saved()
	elif state == LOADED:
		_while_sitting()

func set_starting_rule_node(is_starting_rule_node : bool):
	node_info.is_starting_node = is_starting_rule_node
	if is_instance_valid(node_settings):
		node_settings.is_starting_checkbox.button_pressed = is_starting_rule_node
	if is_starting_rule_node:
		color_selected_button(starting_node_color)
	else:
		color_selected_button(Color.WHITE)
	update_node_settings()

func set_ending_rule_node(is_ending_rule_node : bool):
	node_info.is_ending_node = is_ending_rule_node
	if is_ending_rule_node:
		color_selected_button(ending_node_color)
	else:
		color_selected_button(Color.WHITE)
	update_node_settings()

func set_node_size(new_size : Vector2) -> void:
	side_length = max(new_size.x, new_size.y) / 2
	size = new_size
	_reset_collision_box()
	for spring in springs:
		if is_instance_valid(spring):
			spring.size_spring()

func _reset_collision_box():
	if is_instance_valid(collision_box):
		collision_box.shape.set_deferred("radius", side_length * 1.5)#1.325)

func set_node_number(new_number : int):
	node_info.node_number = new_number
	if not get_node_or_null("NumberLabel") == null:
		$NumberLabel.text = str(new_number)
	for spring in springs:
		spring.set_connected_node_number(self)

func _set_defaults() -> void:
	if get_node_or_null("NodeCollisionBox") == null:
		collision_box = CollisionShape2D.new()
		add_child(collision_box)
	else:
		collision_box = get_node_or_null("NodeCollisionBox")
	if get_node_or_null("NumberLabel") == null:
		number_label = Label.new()
		add_child(number_label)
	else:
		number_label = get_node_or_null("NumberLabel")
	if get_node_or_null("SelectedButton") == null:
		selected_button = Button.new()
		add_child(selected_button)
	else:
		selected_button = get_node_or_null("SelectedButton")
	button_stylebox.set_corner_radius_all(15)
	collision_box.shape = CircleShape2D.new()
	if size == Vector2.ZERO:
		set_node_size(Vector2(GRID_SIZE, GRID_SIZE) * 3)

func _on_saved():
	assert(false) #,"Checking to see if we ever reach here")
	set_process(false)
	set_physics_process(false)
	set_deferred("mode", FREEZE_MODE_STATIC)
	selected_button.text = node_info.room_type
	number_label.text = str(node_info.node_number)
	node_settings.call_deferred("queue_free")
	call_deferred("queue_collision_box_free")
	#set_deferred("position", node_info.position.snapped(Vector2(64, 64)))

func queue_collision_box_free():
	collision_box.shape.set_deferred("size", Vector2.ZERO)
	collision_box.call_deferred("queue_free")
	#call_deferred("_queue_collision_free_defferred")

func _queue_collision_free_defferred():
	collision_box.call_deferred("queue_free")

func _on_loaded():
	set_process(true)
	set_physics_process(true)
	#mode = MODE_CHARACTER
	if not is_instance_valid(selected_button):
		_set_defaults()
	selected_button.text = node_info.room_type
	number_label.text = str(node_info.node_number)

func _on_node_editing():
	node_settings = $NodeSettings
	_connect_signals()
	node_settings.node_number.text = str(node_info.node_number)
	number_label.text = str(node_info.node_number)
	selected_button.text = node_settings.room_type.get_item_text(0)
	node_info.room_type = selected_button.text

func _connect_signals():
	node_settings.replaceable_checkbox.connect("pressed",Callable(self,"_on_replaceable_checkbox_toggled"))
	node_settings.room_type.connect("item_selected",Callable(self,"_on_room_type_item_selected"))
	node_settings.node_number.connect("text_changed",Callable(self,"_on_node_number_text_changed"))
	node_settings.delete_button.connect("pressed",Callable(self,"_on_delete_button_pressed"))
	node_settings.is_starting_checkbox.connect("pressed",Callable(self,"_on_is_starting_checkbox_pressed"))
	node_settings.is_ending_checkbox.connect("pressed",Callable(self,"_on_is_ending_checkbox_pressed"))

func _unhandled_input(event):
	if not state == LOADED and not state == SAVED:
		if event is InputEventMouseButton:
			deselect_node()

func _quarter_force():
	#apply_central_force(-applied_force / 4)
	pass

func _while_sitting():
	for spring in springs:
		if is_instance_valid(spring):
			var force = spring.get_force(self)
			apply_central_force(force)

func _while_selected():
	pass

func _while_saved():
	set_deferred("mode", FREEZE_MODE_STATIC)
	if is_instance_valid(collision_box):
		call_deferred("queue_collision_box_free")
	set_physics_process(false)
	set_process(false)
	for spring in springs:
		if is_instance_valid(spring.spring_collisions):
			spring.spring_collisions.call_deferred("queue_free")

func _while_dragging():
	drag_to_snapped_mouse_position()

func drag_to_snapped_mouse_position():
	var mousepos = get_viewport().get_mouse_position()
	linear_velocity = (mousepos - global_position) * 100

func get_save_data():
	node_settings.set_node_info_data(node_info)
	#node_info.node_number = int(number_label.text)
	#node_info.room_type = selected_button.text
	_save_position()
	state = SAVED
	for spring in springs:
		node_info.springs_info.append(spring.get_save_data())
	return node_info

func _save_position():
	if is_inside_tree():
		node_info.position = global_position
	else:
		node_info.position = position

func has_spring_with_same_connected_nodes(other_spring) -> bool:
	for spring in springs:
		var a_matches_a = spring.spring_info.c_node_number_a == other_spring.spring_info.c_node_number_a
		var a_matches_b = spring.spring_info.c_node_number_a == other_spring.spring_info.c_node_number_b
		var b_matches_a = spring.spring_info.c_node_number_b == other_spring.spring_info.c_node_number_a
		var b_matches_b = spring.spring_info.c_node_number_b == other_spring.spring_info.c_node_number_b
		if (a_matches_a and b_matches_b) or (a_matches_b and b_matches_a):
			return true
	return false

func is_connected_to_node_number(number : int) -> bool:
	for spring in springs:
		if spring.is_connected_to_number(number):
			return true
	return false

func disconnect_nodes(node_number : int) -> void:
	for spring in springs:
		if spring.is_connected_to_number(node_number):
			var other_node = spring.get_node_with_number(node_number)
			other_node.springs.erase(spring)
			springs.erase(spring)
			spring.call_deferred("queue_free")
			break

func get_node_rect() -> Rect2:
	var rect : Rect2
	if is_inside_tree():
		rect = Rect2(global_position - size / 2, size)
	else:
		rect = Rect2(position - size / 2, size)
	return rect

func _draw():
	var color = Color.BLACK
	color = starting_node_color if node_info.is_starting_node else color
	color = ending_node_color if node_info.is_ending_node else color
	if node_info.replaceable:
		#var color = Color.RED if state == SELECTED else Color.GREEN
		var rect_pos = -Vector2(size.x / 2, size.y / 2)
		var rect = Rect2(rect_pos, size)
		draw_rect(rect, color, false)
	else:
		#var color = Color.RED if state == SELECTED else Color.BLUE
		draw_circle_arc(Vector2.ZERO, side_length, 0, 360, color)

func draw_circle_arc(center, side_length, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * side_length)
	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _on_replaceable_checkbox_toggled():
	node_info.replaceable = node_settings.replaceable_checkbox.pressed

func _on_node_number_text_changed(new_text: String):
	set_node_number(int(new_text))
	for spring in springs:
		spring.set_connected_node_number(self)

func _on_room_type_item_selected(index : int):
	selected_button.text = node_settings.room_type.get_item_text(index)
	node_info.room_type = selected_button.text

func _on_delete_button_pressed():
	self.call_deferred("queue_free")

func _on_SelectedButton_toggled(button_pressed):
	if selected_button.pressed:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_toggle_node_settings()
			state = SELECTED
			add_to_group("SelectedNodes")
		else:
			state = DRAGGING
	else:
		deselect_node()

func _toggle_node_settings():
	node_settings.visible = !node_settings.visible

func deselect_node():
	if not node_settings == null:
		node_settings.visible = false
	if not selected_button == null:
		selected_button.button_pressed = false
	state = SITTING
	remove_from_group("SelectedNodes")

func _on_GrammarNode_input_event(viewport, event, shape_idx):
	if event == InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var rect = Rect2(global_position - size / 2, size)
			if rect.has_point(get_viewport().get_mouse_position()):
				_toggle_node_settings()

func queue_grammar_node_objects_free():
	if is_instance_valid(node_settings):
		node_settings.queue_free()
	if is_instance_valid(selected_button):
		selected_button.queue_free()
	if is_instance_valid(number_label):
		number_label.queue_free()
	if is_instance_valid(collision_box):
		collision_box.queue_free()

func _exit_tree():
	emit_signal("g_node_queue_free")

func color_selected_button(color : Color):
	if is_instance_valid(selected_button):
		modulate = color

func update_node_settings():
	if is_instance_valid(get_node_or_null("NodeSettings")):
		$NodeSettings.update_data(node_info)

func _on_is_starting_checkbox_pressed():
	node_info.is_starting_node = node_settings.is_starting_checkbox.pressed
	emit_signal("starting_node_updated", self)

func _on_is_ending_checkbox_pressed():
	node_info.is_ending_node = node_settings.is_ending_checkbox.pressed
	emit_signal("ending_node_updated", self)


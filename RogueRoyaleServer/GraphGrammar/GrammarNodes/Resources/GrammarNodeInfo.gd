extends Resource
class_name GrammarNodeInfo

@export var node_number : int
@export var room_type : String
@export var springs_info : Array
@export var replaceable : bool = true
@export var position : Vector2
@export var dist_from_closest_spawn : int = 0
@export var closest_spawn_nodes: Array = []
@export var is_starting_node: bool = false
@export var is_ending_node: bool = false

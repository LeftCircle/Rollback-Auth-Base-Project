extends Resource
class_name GrammarSaveInfo

@export var rule_saves: Array
@export var starting_save: Resource

func set_rule_saves(array : Array) -> void:
	rule_saves = array

func set_starting_save(res : Resource) -> void:
	starting_save = res

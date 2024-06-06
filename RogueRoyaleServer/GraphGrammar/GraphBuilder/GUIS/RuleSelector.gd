extends GridContainer
class_name RuleSelector

@export var rule_selection_template: Resource : set = set_rule_selection_template

@onready var add_rule_button = $AddRuleButton
#onready var rule_selection_template = $RuleSelection

signal add_rule_pressed

func set_rule_selection_template(res : Resource) -> void:
	rule_selection_template = res

func _ready():
	pass

func add_new_rule_selection(rule : Resource) -> void:
	var new_rule_selection = rule_selection_template.instantiate()
	new_rule_selection.init_rule_data(rule)
	add_sibling(add_rule_button, new_rule_selection)
	new_rule_selection.show()

func get_active_rules() -> Array:
	var rule_saves = []
	var children = get_children()
	for rule_selection in children:
		if rule_selection != add_rule_button:
			if rule_selection.rule_reader.executions > 0:
				rule_saves.append(rule_selection.rule_reader)
	return rule_saves

func get_rule_saves() -> Array:
	var rule_saves = []
	var children = get_children()
	for rule_selection in children:
		if rule_selection != add_rule_button:
			rule_saves.append(rule_selection.rule_reader.get_rule_save())
	return rule_saves

func _on_AddRuleButton_pressed():
	emit_signal("add_rule_pressed")

extends GridContainer
class_name RuleSelection

@export var rule_info_reader: Script

var rule_reader : Resource
@onready var rule_name = $RuleName
@onready var executions_line_edit = $Executions
@onready var node_container = $NodeContainer
var priority = 0

func _ready():
	if not rule_reader == null:
		rule_name.text = rule_reader.rule_name

func init_rule_data(rule : Resource) -> void:
	rule_reader = rule

func _on_DeleteRuleButton_pressed():
	self.call_deferred("queue_free")

func _on_Executions_text_changed(new_text):
	if int(new_text) > 0:
		rule_reader.executions = int(new_text)

func _exit_tree():
	rule_reader.free_resource()

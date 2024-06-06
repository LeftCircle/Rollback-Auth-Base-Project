extends Node

# This is set up to autoload on project start so that everything can access the skill_data
var skill_data

var test_data = {
	"Stats" : {
		"Strength" : 42,
		"Vitality" : 68,
		"Dexterity" : 37,
		"Intelligence" : 24,
		"Wisdom" : 17,
		"Speed" : 500,
		"Acceleration" : 300
	}
}

func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://Data/skills_data.json", File.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(skill_data_file.get_as_text())
	var skill_data_json = test_json_conv.get_data()
	skill_data_file.close()
	skill_data = skill_data_json.result

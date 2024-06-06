extends Control


@onready var strength = get_node("Background/VBoxContainer/Strength/StatValue")
@onready var vitality = get_node("Background/VBoxContainer/Vitality/StatValue")
@onready var dexterity = get_node("Background/VBoxContainer/Dexterity/StatValue")
@onready var intelligence = get_node("Background/VBoxContainer/Intelligence/StatValue")
@onready var wisdom = get_node("Background/VBoxContainer/Wisdom/StatValue")

func _ready():
	Server.get_player_stats()
	
# sets the text of the node to the string of the stat value
func load_player_stats(stats : Dictionary) -> void:
	strength.set_text(str(stats.Strength))
	vitality.set_text(str(stats.Vitality))
	dexterity.set_text(str(stats.Dexterity))
	intelligence.set_text(str(stats.Intelligence))
	wisdom.set_text(str(stats.Wisdom))						

extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(self, " registering for menu")
	get_parent().get_parent().register_player_prompt(self)

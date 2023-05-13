extends Node

var main = null

func _ready():
	main = get_parent()

func _input(event):
	if event is InputEventJoypadButton or event is InputEventMouseButton or event is InputEventKey:
		if event.pressed:
			main.end_win_screen()

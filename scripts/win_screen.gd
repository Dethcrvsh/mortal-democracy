extends Node

var main = null
var delay = 0
var winner = "unknown"
var text = null

func _ready():
	text = get_node("Text")
	text.text = "player %d won!" % winner
	main = get_parent()
	delay = 2
	
func _process(delta):
	if delay > 0:
		delay -= delta

func _input(event):
	if delay > 0:
		return
	
	if event is InputEventJoypadButton or event is InputEventMouseButton or event is InputEventKey:
		if event.pressed:
			main.end_win_screen()

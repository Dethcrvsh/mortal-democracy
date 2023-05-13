extends Node3D


var votes = {"p1": 0}
var text = null

func _ready():
	text = get_node("vote_text")

func _process(delta):
	print_debug(votes)
	
	if text == null:
		return
		
	var s = ""
	for player in votes:
		s += "%s votes: %d \n" % [player, int(votes[player])]
	text.text = s

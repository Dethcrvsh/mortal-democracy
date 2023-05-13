extends Node3D

const INIT = 1
const MAIN_MENU = 2
const GAME_PLAYING = 3
const GAME_END = 4

var votes = {}
var text = null
var state = INIT

func _ready():
	text = get_node("vote_text")

func _process(_delta):
	if text == null:
		return
		
	var s = ""
	for player in votes:
		s += "%s votes: %d \n" % [player, int(votes[player])]
	text.text = s

func reset():
	var votes = {}

extends Node3D

const INIT = 1
const MAIN_MENU = 2
const GAME_PLAYING = 3
const GAME_END = 4

var votes = {}
var player_index_by_device = {}
var text = null
var state = INIT

func _ready():
	text = get_node("vote_text")

func _process(_delta):
	if text == null:
		return
		
	var s = ""
	for device in player_index_by_device:
		var player_index = player_index_by_device[device]
		s += "player %s votes: %d \n" % [player_index+1, int(votes[device])]
	text.text = s
	
func reset():
	votes = {}
	player_index_by_device = {}
	

extends Node3D

const INIT = 1
const MAIN_MENU = 2
const GAME_PLAYING = 3
const GAME_END = 4

const COLORS = [
	Color(255, 221, 0),
	Color(204, 33, 55),
	Color(151, 219, 247),
	Color(0, 135, 61)
]

const PROGRESS_BAR_POS = [
	Vector2(100, 1000),
	Vector2(600, 1000),
	Vector2(1100, 1000),
	Vector2(1600, 1000),
]

var progress_bars = {}

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
	

extends Node

var player_handler = null
var gamestate = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#player_handler = get_node("PlayerHandler")
	gamestate = get_node("Gamestate")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

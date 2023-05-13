extends Node

var player_handler = null
var gamestate = null
var main_menu_asset = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#player_handler = get_node("PlayerHandler")
	gamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.state = gamestate.MAIN_MENU
	

func start_game(main_menu: Node2D):
	main_menu.visible = false
	gamestate.state = gamestate.GAME_PLAYING

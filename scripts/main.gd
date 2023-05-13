extends Node

const NUM_VOTES_WIN_CONDITION = 10

var player_handler = null
var gamestate = null
var win_screen = null
var main_menu = null
var map1 = null

@onready var win_screen_asset = load("res://scenes/WinScreen.tscn")
@onready var main_menu_asset = load("res://scenes/MainMenu.tscn")
@onready var map1_asset = load("res://scenes/Map2.tscn")

func _ready():
	#player_handler = get_node("PlayerHandler")
	gamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.state = gamestate.MAIN_MENU
	
	#win_screen = winscreen_asset.instance()
	main_menu = main_menu_asset.instantiate()
	add_child(main_menu)

func _process(delta):
	for key in gamestate.votes:
		if gamestate.votes[key] >= NUM_VOTES_WIN_CONDITION:
			win_game(key)
			gamestate.reset()

func win_game(player):
	print_debug("player ", player, " won!")
	gamestate.state = gamestate.GAME_END
	win_screen = win_screen_asset.instantiate()
	add_child(win_screen)

func start_game():
	gamestate.state = gamestate.GAME_PLAYING
	main_menu.queue_free()
	map1 = map1_asset.instantiate()
	add_child(map1)

func end_win_screen():
	win_screen.queue_free()
	gamestate.state = gamestate.MAIN_MENU
	main_menu = main_menu_asset.instantiate()
	add_child(main_menu)

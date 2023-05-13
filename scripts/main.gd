extends Node

const NUM_VOTES_WIN_CONDITION = 10

var player_handler = null
var gamestate = null
var win_screen = null
var main_menu = null
var map = null

@onready var win_screen_asset = load("res://scenes/WinScreen.tscn")
@onready var main_menu_asset = load("res://scenes/MainMenu.tscn")
@onready var map1_asset = load("res://scenes/Map1.tscn")
@onready var map2_asset = load("res://scenes/Map2.tscn")
@onready var menu_map_asset = load("res://scenes/MenuMap.tscn")

func _ready():
	gamestate = get_tree().get_first_node_in_group("gamestate")
	player_handler = get_node("PlayerHandler")
	
	main_menu = main_menu_asset.instantiate()
	add_child(main_menu)
	map = menu_map_asset.instantiate()
	add_child(map)
	
	gamestate.state = gamestate.MAIN_MENU
	player_handler.set_map(map)
	

func _process(delta):
	for key in gamestate.votes:
		if gamestate.votes[key] >= NUM_VOTES_WIN_CONDITION:
			win_game(key)
			return

func win_game(player):
	print_debug("player ", player, " won!")
	gamestate.state = gamestate.GAME_END
	win_screen = win_screen_asset.instantiate()
	gamestate.reset()
	player_handler.despawn_players()
	add_child(win_screen)

func start_game():
	main_menu.queue_free()
	if map != null: 
		map.queue_free()
	map = map2_asset.instantiate()
	add_child(map)
	player_handler.set_map(map)
	player_handler.despawn_players()
	
	for device in gamestate.player_index_by_device:
		gamestate.votes[device] = 0
		player_handler.spawn_new_player(device)
	
	gamestate.state = gamestate.GAME_PLAYING

func end_win_screen():
	win_screen.queue_free()
	gamestate.state = gamestate.MAIN_MENU
	main_menu = main_menu_asset.instantiate()
	add_child(main_menu)
	
func player_joined(device):
	var player_index = player_handler.spawn_new_player(device)
	gamestate.votes[device] = 0
	gamestate.player_index_by_device[device] = player_index

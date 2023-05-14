extends Node

const NUM_VOTES_WIN_CONDITION = 50

var player_handler = null
var gamestate = null
var win_screen = null
var main_menu = null
var map = null

@onready var win_screen_asset = load("res://scenes/WinScreen.tscn")
@onready var main_menu_asset = load("res://scenes/MainMenu2.tscn")
@onready var map1_asset = load("res://scenes/Map1.tscn")
@onready var map2_asset = load("res://scenes/Map2.tscn")
@onready var menu_map_asset = load("res://scenes/MenuMap2.tscn")
@onready var progress_bar_0 = load("res://scenes/ProgressBar0.tscn")
@onready var progress_bar_1 = load("res://scenes/ProgressBar1.tscn")
@onready var progress_bar_2 = load("res://scenes/ProgressBar2.tscn")
@onready var progress_bar_3 = load("res://scenes/ProgressBar3.tscn")
@onready var audio_player = AudioStreamPlayer.new()
@onready var music = load("res://Audio/music.mp3")

func _ready():
	gamestate = get_tree().get_first_node_in_group("gamestate")
	player_handler = get_node("PlayerHandler")
	
	main_menu = main_menu_asset.instantiate()
	add_child(main_menu)
	map = menu_map_asset.instantiate()
	add_child(map)
	
	gamestate.state = gamestate.MAIN_MENU
	player_handler.set_map(map)
	add_child(audio_player)
	audio_player.stream = music
	audio_player.play()

func _process(delta):
	if not audio_player.playing:
		audio_player.play()
	if gamestate.state == gamestate.GAME_PLAYING:
		handle_votes()

func handle_votes() -> void:
	for key in gamestate.votes:
		if gamestate.votes[key] >= NUM_VOTES_WIN_CONDITION:
			win_game(key)
			return
		gamestate.progress_bars[key].set_votes(gamestate.votes[key])
	

func win_game(player):
	print_debug("player ", player, " won!")
	gamestate.state = gamestate.GAME_END
	win_screen = win_screen_asset.instantiate()
	win_screen.winner = gamestate.player_index_by_device[player] + 1
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
	player_handler.move_players_to_spawn()
	
	for device in gamestate.player_index_by_device:
		gamestate.votes[device] = 0
		add_progress_bar(device)

	gamestate.state = gamestate.GAME_PLAYING

func add_progress_bar(device: String) -> void:
	var player_index = gamestate.player_index_by_device[device]
	var id = player_handler.get_characters()[player_index]
	var progress_bar = null
	
	if id == 0:
		progress_bar = progress_bar_0.instantiate()
	elif id == 1:
		progress_bar = progress_bar_1.instantiate()
	elif id == 2:
		progress_bar = progress_bar_2.instantiate()
	if id == 3:
		progress_bar = progress_bar_3.instantiate()
	add_child(progress_bar)
	progress_bar.set_offset(gamestate.PROGRESS_BAR_POS[player_index])
	gamestate.progress_bars[device] = progress_bar
	

func end_win_screen():
	win_screen.queue_free()
	gamestate.state = gamestate.MAIN_MENU
	main_menu = main_menu_asset.instantiate()
	map.queue_free()
	map = menu_map_asset.instantiate()
	add_child(map)
	add_child(main_menu)
	player_handler.set_map(map)
	
	
func player_joined(device):
	var player_index = player_handler.spawn_new_player(device)
	gamestate.votes[device] = 0
	gamestate.player_index_by_device[device] = player_index

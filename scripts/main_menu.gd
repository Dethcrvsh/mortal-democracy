extends Node

const KEYBOARD_ID = -1337

var players_entered = []
var player_prompts = []
var new_player = false
var gamestate = null

# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate = get_tree().get_first_node_in_group("gamestate")

func register_player_prompt(text: RichTextLabel):
	print_debug(text, " registered")
	player_prompts.append(text)

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if not players_entered.any(func(id): return id == event.device):
			new_player = true
			players_entered.append(event.device)
	
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		if not players_entered.any(func(id): return id == KEYBOARD_ID):
			print_debug("keyboard joined")
			new_player = true
			players_entered.append(KEYBOARD_ID)
		
	if event.is_action("start"):
		print_debug("starting game")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gamestate.state != gamestate.MAIN_MENU:
		return
	if new_player:
		for i in range(len(players_entered)):
			if players_entered[i] == KEYBOARD_ID:
				player_prompts[i].text = "Player %d\nkeyboard" % (i+1)
			else:
				player_prompts[i].text = "Player %d\njoypad %d" % [i+1, players_entered[i]+1]
		new_player = false

func _start_button_pressed():
	get_parent().start_game()

extends Node

const KEYBOARD_ID = "KB"

var players_entered = []
var player_prompts = []
var new_player = false
var gamestate = null
var main = null

# Called when the node enters the scene tree for the first time.
func _ready():
	gamestate = get_tree().get_first_node_in_group("gamestate")
	main = get_parent()

func register_player_prompt(text: RichTextLabel):
	print_debug(text, " registered")
	player_prompts.append(text)

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		var device = "%d" % (event.device+1)
		if not players_entered.any(func(id): return id == device):
			players_entered.append(device)
			main.player_joined(device)
			new_player = true
	
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		if not players_entered.any(func(id): return id == KEYBOARD_ID):
			players_entered.append(KEYBOARD_ID)
			main.player_joined(KEYBOARD_ID)
			new_player = true
		
	if event.is_action("start"):
		_start_button_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gamestate.state != gamestate.MAIN_MENU:
		return
	if new_player:
		for i in range(len(players_entered)):
			if players_entered[i] == KEYBOARD_ID:
				player_prompts[i].text = "Player %s\nkeyboard" % (i+1)
			else:
				player_prompts[i].text = "Player %s\njoypad %s" % [i+1, players_entered[i]]
		new_player = false

func _start_button_pressed():
	get_parent().start_game()

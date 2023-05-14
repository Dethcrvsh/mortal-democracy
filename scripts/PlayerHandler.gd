extends Node3D

# Keep track of the currently spawned players
var players = []

@onready var player_node = load("res://scenes/player.tscn")
@onready var map = get_tree().get_first_node_in_group("maps")

func set_map(map_node) -> void:
	print_debug("map set to %s" % map_node)
	map = map_node

func spawn_new_player(device) -> int:
	var player_index = players.size()
	
	# Get the spawn point for the new player
	var spawn_pos = map.get_spawn_point(player_index)
	
	var player = player_node.instantiate()
	player.position += spawn_pos
	player.set_player(device)
	
	add_child(player)
	players.append(player)
	
	return player_index

func move_players_to_spawn() -> void:
	for i in players.size():
		var spawn_pos = map.get_spawn_point(i)
		players[i].global_position = spawn_pos	

func despawn_players() -> void:
	for player in players:
		player.queue_free()
	players = []

func get_characters():
	var characters = []
	for player in players:
		characters.append(player.character_id)
	return characters

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Node3D

# Keep track of the currently spawned players
var players = []

@onready var player_node = load("res://scenes/player.tscn")
@onready var map = get_tree().get_first_node_in_group("maps")

func set_map(map_node) -> void:
	map = map_node

func spawn_new_player() -> void:
	var player_index = players.size()
	
	# Get the spawn point for the new player
	var spawn_pos = map.get_spawn_point(player_index)
	
	var player = player_node.instantiate()
	player.position += spawn_pos
	player.set_player(player_index)
	
	add_child(player)
	players.append(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

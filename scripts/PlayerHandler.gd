extends Node3D

# Keep track of the currently spawned players
var players = []

@onready var player_node = load("res://scenes/player.tscn")
@onready var map = get_tree().get_first_node_in_group("maps")

#func _ready():
#	spawn_new_player(0)
#	spawn_new_player(1)
#	spawn_new_player(2)
#	spawn_new_player(3)

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

func despawn_players() -> void:
	for player in players:
		player.queue_free()
	players = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

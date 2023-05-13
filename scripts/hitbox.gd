extends Area3D

var player = null

func set_player(player_in):
	player = player_in

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	if body != player and body.is_in_group("players"):
		body.take_damage(player.last_move_dir, player.input_dir)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
